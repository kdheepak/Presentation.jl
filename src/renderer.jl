const CODEBLOCK_FOREGROUND = 0xafa88b
const CODEBLOCK_BACKGROUND = 0xfbf3d2

draw_border(x, y, w, h) = draw_border(x, y, w, h, Crayon())

function draw_border(x, y, w, h, c)

    cmove(x, y)             ; print(c(repeat("━", w)))
    cmove(x, y + h)         ; print(c(repeat("━", w)))
    for i in 1:h
        cmove(x, y + i)     ; print(c("┃"))
        cmove(x + w, y + i) ; print(c("┃"))
    end
    cmove(x, y)             ; print(c("┏"))
    cmove(x + w, y)         ; print(c("┓"))
    cmove(x, y + h)         ; print(c("┗"))
    cmove(x + w, y + h)     ; print(c("┛"))

end

"""
Syntax Highlighter
"""
function Highlights.Format.render(io::IO, ::MIME"text/ansi", tokens::Highlights.Format.TokenIterator)
    for (str, id, style) in tokens
        fg = style.fg.active ? map(Int, (style.fg.r, style.fg.g, style.fg.b)) : :nothing
        bg = style.bg.active ? map(Int, (style.bg.r, style.bg.g, style.bg.b)) : :nothing
        crayon = Crayon(
            foreground = fg,
            background = bg,
            bold       = style.bold,
            italics    = style.italic,
            underline  = style.underline,
        )
        print(io, crayon, str, inv(crayon))
    end
end

## Render functions

render(e) = render(stdout, e)

function render(io, e::Pandoc.Link)
    iob = IOBuffer()
    for se in e.content
        render(iob, se)
    end
    title = String(take!(iob))
    url = e.target.url
    # This seems to be an iTerm2 only feature
    print("$ESC]8;;$url$ESC\\$title$ESC]8;;$ESC\\")
end

function render(io, es::Vector{Pandoc.Block})
    x, y = getXY()
    cmove(x + 4, y)
    for e in es
        render(e)
    end
    cmove(x, getY())
end

function render(io, e::Pandoc.SoftBreak)
end

function render(io, e::Pandoc.Plain)
    x, y = getXY()
    print("▶ ")
    for se in e.content
        render(se)
    end
    cmove(x, getY() + 2)
end

function render(io, e::Pandoc.OrderedList)
    x, y = getXY()
    for items in e.content
        render(items)
    end
end

function render(io, e::Pandoc.BulletList)
    x, y = getXY()
    for items in e.content
        render(items)
    end
end

function render(io, e::Pandoc.Image)
    w, h = canvassize()
    x, y = getXY()
    cmove(round(Int, w / 3), y + 2)
    data = read(abspath(joinpath(dirname(filename()), e.target.url)))
    TerminalExtensions.iTerm2.display_file(
                                           data;
                                           io=io,
                                           width="$(round(Int, w/3))",
                                           filename="image",
                                           inline=true,
                                           preserveAspectRatio=true
                                          )
    title = e.target.title
    cmove(round(Int, w / 2) - round(Int, length(title) / 2), getY() + 2)
    print("$title")
end


render(io, e::Pandoc.Element) = error("Not implemented renderer for $e")

hex2rgb(c) = convert.(Int, ((c >> 16) % 0x100, (c >> 8) % 0x100, c % 0x100))

function render(io, e::Pandoc.CodeBlock)
    w = round(Int, getW() * 6 / 8)
    x, y = getXY()
    if length(e.attr.classes) > 0 && e.attr.classes[1] == "julia"
        iob = IOBuffer()
        highlight(iob, MIME("text/ansi"), e.content, Lexers.JuliaLexer)
        content = String(take!(iob))
    else
        content = e.content
    end
    c = Crayon(background = hex2rgb(CODEBLOCK_BACKGROUND))
    cmove(x, y)
    print(c(repeat(" ", w)))
    y += 1
    # draw background
    save_y = y
    split_content = split(content, '\n')
    for (i, code_line) in enumerate(split_content)
        cmove(x, y)
        print(c(repeat(" ", w)))
        print(Crayon(background = hex2rgb(CODEBLOCK_FOREGROUND))(" "))
        y += 1
    end
    cmove(x, y)
    print(c(repeat(" ", w)))
    print(Crayon(background = hex2rgb(CODEBLOCK_FOREGROUND))(" "))
    y += 1
    cmove(x+1, y)
    println(Crayon(foreground = hex2rgb(CODEBLOCK_FOREGROUND))(repeat("▀", w)))
    # write code blocks
    y = save_y
    for code_line in split_content
        cmove(x+2, y)
        println(c(code_line))
        y += 1
    end
end

render(io, e::Pandoc.Str) = print(io, e.content)
render(io, e::Pandoc.Space) = print(io, " ")
render(io, e::Pandoc.Code) = print(io, "`", Crayon(foreground=:red)("$(e.content)"), "`")

render(io, h::Pandoc.Header) = render(io, h, Val{h.level}())

function render(io, e::Pandoc.Header, level::Val{1})
    c = Crayon(bold = true)
    w, h = canvassize()
    x, y = round(Int, w / 2), round(Int, h / 2)
    iob = IOBuffer()
    for se in e.content
        render(iob, se)
    end
    t = String(take!(iob))
    lines = wrap(t)
    for line in lines
        cmove(x - round(Int, length(line) / 2), y)
        print(c(line))
        y += 1
    end
    m = maximum(length.(lines))
    draw_border(x - round(Int, m / 2) - 2, y - length(lines) - 1, m + 3, length(lines) + 1)
    cmove(round(Int, w / 8), getY() + 4)
end

function render(io, e::Pandoc.Header, level::Val{2})
    c = Crayon(bold = true)
    w, h = canvassize()
    x, y = round(Int, w / 2), round(Int, h / 4)
    iob = IOBuffer()
    for se in e.content
        render(iob, se)
    end
    t = String(take!(iob))
    lines = wrap(t)
    for line in lines
        cmove(x - round(Int, length(line) / 2), y)
        print(c(line))
        y += 1
    end
    m = maximum(length.(lines))
    draw_border(x - round(Int, m / 2) - 2, y - length(lines) - 1, m + 3, length(lines) + 1)
    cmove(round(Int, w / 8), getY() + 4)
end

function render(io, e::Pandoc.Para)
    w, h = canvassize()
    cmove(round(Int, w / 8), getY() + 2)
    for se in e.content
        render(se)
    end
    cmove(round(Int, w / 8), getY() + 2)
end

function render(s::Slides)
    clear()
    width, height = canvassize()
    x, y = round(Int, width / 2), round(Int, height / 4)
    cmove(x, y)
    for e in current_slide(s)
        render(e)
    end
    cmove_bottom()
end

render(filename::String) = render(PandocMarkdown, filename)
render(::Type{T}, filename::String) where T = render(read(T, filename), filename)

