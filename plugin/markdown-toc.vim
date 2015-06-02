if !exists("g:mdtoc_starting_header_level")
  let g:mdtoc_starting_header_level = 2
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

command! GenerateMarkdownTOC :call <SID>GenerateMarkdownTOC()
