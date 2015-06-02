# markdown-toc.vim

Have you ever wanted to have a sweet table of contents for your markdown file but didn't want to deal with the pain of generating it yourself? Well now you dont have to.

1. [Usage](#usage)
2. [Configuration](#configuration)
3. [Example](#example)

## Usage

* Run `:GenerateMarkdownTOC` to generate the table of contents for an open markdown file. This will place the generated table of contents at the location of your cursor at the time that you run the command.
  * Supports both `#` and `==`/`--` styles of header declarations

## Configuration

By default this plugin will not generate an entry for top level headers (`#` or `==`). You can modifying this behavior by setting `g:mdtoc_starting_header_level = 1`
```vimscript
let g:mdtoc_starting_header_level = 2
```

## Example

```markdown
# Top level header

1. [Sub-heading](#sub-heading)
2. [Another sub heading](#another-sub-heading)
	1. [You can even mix heading styles if that floats your boat](#you-can-even-mix-heading-styles-if-that-floats-your-boat)
		1. [This is totally like inception](#this-is-totally-like-inception)

## Sub-heading
Some content will go here

Another sub heading
------------------
Some other content can go here if you want

### You can even mix heading styles if that floats your boat
Because we know you do what you want

#### This is totally like inception
```
