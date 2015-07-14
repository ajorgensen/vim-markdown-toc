if !exists("g:mdtoc_starting_header_level")
  let g:mdtoc_starting_header_level = 2
endif

if !exists("g:mdtoc_run_on_save")
  let g:mdtoc_run_on_save = 0
endif

if (g:mdtoc_run_on_save == 1)
  autocmd BufWritePre *.md :GenerateMarkdownTOC
endif

function! s:HeaderSearchRegex()
  if(g:mdtoc_starting_header_level == 1)
    return "^[#]\\{" . g:mdtoc_starting_header_level . ",}\\|.*\\n^[-=]\\{2,}"
  else
    return "^[#]\\{" . g:mdtoc_starting_header_level . ",}\\|.*\\n^[-]\\{2,}"
  endif
endfunction

function! s:FindHeaders()
  let l:winview = winsaveview()
  let l:flags = "Wc"
  let l:matches = []
  let l:searchRegex = <SID>HeaderSearchRegex()
  normal! gg

  while search(l:searchRegex, l:flags) != 0
    let l:line = getline('.')
    let l:nextLine = getline(line('.') + 1)
    if(l:line[0] == "#")
      let l:matches += [l:line]
    else
      let l:matches += [l:nextLine . " " . l:line]
    endif
    let l:flags = "W"
  endwhile

  call winrestview(l:winview)

  return l:matches
endfunction

function! s:HeadingLevel(header)
  let l:delim = split(a:header, " ")[0] 
  if(l:delim[0] == "=")
    return 1
  elseif(l:delim[0] == "-")
    return 2
  else
    return len(l:delim)
  endif
endfunction

function! s:GenerateMarkdownTOC()
  let l:headerMatches = <SID>FindHeaders()

  let l:levelsStack = []
  let l:previousLevel = 0
  for header in l:headerMatches
    let l:headingLevel = <SID>HeadingLevel(header)
    let l:sectionName = join(split(header, " ")[1:-1], " ")

    if(l:headingLevel > l:previousLevel)
      call add(l:levelsStack, 1)
    elseif(l:headingLevel < l:previousLevel)
      call remove(l:levelsStack, -1)
    endif
    let l:num = l:levelsStack[-1]
    let l:levelsStack[-1] = l:num + 1
    let l:previousLevel = l:headingLevel

    let l:formattedLine = repeat("\t", l:headingLevel - g:mdtoc_starting_header_level) . l:num . ". [" . sectionName .  "](#" .  substitute(tolower(sectionName), " ", "-", "g") . ")"
    put =l:formattedLine
  endfor
endfunction

function! s:FormatTOCEntry(sectionName)
  return "[" . a:sectionName .  "](#" .  substitute(tolower(a:sectionName), " ", "-", "g") . ")"
endfunction

function! s:ExtractHeaderText(header)
  return join(split(a:header, " ")[1:-1], " ")
endfunction

function! s:DeleteExistingTOC()
  let l:winview = winsaveview()
  normal! gg

  let l:headerMatches = <SID>FindHeaders()
  let l:firstEntry = <SID>FormatTOCEntry(<SID>ExtractHeaderText(l:headerMatches[0]))
  let l:firstEntryLineNumber = search("^\\t*\\d\\.\\s\\[.*\\]\\(.*\\)")

  let l:lastEntry = <SID>FormatTOCEntry(<SID>ExtractHeaderText(l:headerMatches[-1]))
  let l:lastEntryLineNumber = search("^\\t*\\d\\.\\s\\[.*\\]\\(.*\\)", 'b', line("}"))

  if(l:firstEntryLineNumber <= l:lastEntryLineNumber && l:firstEntryLineNumber != 0 && l:lastEntryLineNumber != 0)
    execute l:firstEntryLineNumber . "," . l:lastEntryLineNumber . "delete_"
  endif

  call winrestview(l:winview)

  return l:firstEntryLineNumber
endfunction

function! s:TOCTest()
  let l:winview = winsaveview()
  let l:oldLineNumber = <SID>DeleteExistingTOC()

  echo l:oldLineNumber

  if (l:oldLineNumber != 0)
    call cursor(l:oldLineNumber - 1, 1)
  endif

  exec <SID>GenerateMarkdownTOC()
  call winrestview(l:winview)
endfunction

command! GenerateMarkdownTOC :call <SID>TOCTest()
