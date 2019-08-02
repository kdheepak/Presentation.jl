abstract type PandocMarkdown end

const CODEBLOCK_FOREGROUND = 0xafa88b
const CODEBLOCK_BACKGROUND = 0xfbf3d2

const Slide = Vector{Pandoc.Element}

mutable struct Slides
    current_slide::Int
    content::Vector{Slide}
    filename::String
end

function Slides(d::Pandoc.Document, filename::String)
    content = Pandoc.Element[]
    slides = Slides(1, Slide[], filename)
    for e in d.blocks
        if typeof(e) == Pandoc.Header && e.level == 1 && length(content) == 0
            push!(content, e)
            push!(slides.content, content)
            content = Pandoc.Element[]
        elseif typeof(e) == Pandoc.Header && e.level == 1 && length(content) != 0
            push!(slides.content, content)
            content = Pandoc.Element[]
            push!(content, e)
        elseif typeof(e) == Pandoc.Header && e.level == 2 && length(content) == 0
            push!(content, e)
        elseif typeof(e) == Pandoc.Header && e.level == 2 && length(content) != 0
            push!(slides.content, content)
            content = Pandoc.Element[]
            push!(content, e)
        else
            push!(content, e)
        end
    end
    push!(slides.content, content)
    return slides
end

function Base.read(::Type{PandocMarkdown}, filename::String)
    return Pandoc.run_pandoc(filename)
end

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

function Format.render(io::IO, ::MIME"text/ansi", tokens::Format.TokenIterator)
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

function render(es::Vector{Pandoc.Block}, xy=getXY(), io=stdout, c=Crayon())
    x, y = xy
    cmove(x + 4, y)
    for e in es
        render(e)
    end
    cmove(x, getY())
end

function render(e::Pandoc.SoftBreak, xy = getXY(), io = stdout, c = Crayon())
end

function render(e::Pandoc.Plain, xy=getXY(), io=stdout, c=Crayon())
    x, y = xy
    print(c("▶ "))
    for se in e.content
        render(se)
    end
    cmove(x, getY() + 2)
end

function render(e::Pandoc.OrderedList, xy=getXY(), io=stdout, c=Crayon())
    x, y = xy
    for items in e.content
        render(items)
    end
end

function render(e::Pandoc.BulletList, xy=getXY(), io=stdout, c=Crayon())
    x, y = xy
    for items in e.content
        render(items)
    end
end

function render(e::Pandoc.Image, xy=getXY(), io=stdout, c=Crayon())
    w, h = canvassize()
    x, y = xy
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


render(e::Pandoc.Element, xy=getXY(), io=stdout, c=Crayon()) = error("Not implemented renderer for $e")

hex2rgb(c) = convert.(Int, ((c >> 16) % 0x100, (c >> 8) % 0x100, c % 0x100))

function render(e::Pandoc.CodeBlock, xy=getXY(), io=stdout, c=Crayon())
    w = round(Int, getW() * 6 / 8)
    x, y = xy
    io = IOBuffer()
    if length(e.attr.classes) > 0 && e.attr.classes[1] == "julia"
        highlight(io, MIME("text/ansi"), e.content, Lexers.JuliaLexer)
        content = String(take!(io))
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

render(h::Pandoc.Header, xy=getXY(), io=stdout, c=Crayon(bold = true)) = render(h, Val{h.level}(), xy, io, c)

render(e::Pandoc.Str, xy=getXY(), io=stdout, c=Crayon()) = print(io, c(e.content))
render(e::Pandoc.Space, xy=getXY(), io=stdout, c=Crayon()) = print(io, c(" "))
render(e::Pandoc.Code, xy=getXY(), io=stdout, c=Crayon(foreground=:red)) = print(io, "`", c("$(e.content)"), "`")

function render(e::Pandoc.Header, level::Val{1}, xy=getXY(), io=stdout, c=Crayon(bold = true))
    w, h = canvassize()
    x, y = round(Int, w / 2), round(Int, h / 2)
    iob = IOBuffer()
    for se in e.content
        render(se, getXY(), iob)
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

function render(e::Pandoc.Header, level::Val{2}, xy=getXY(), io=stdout, c=Crayon(bold = true))
    w, h = canvassize()
    x, y = round(Int, w / 2), round(Int, h / 4)
    iob = IOBuffer()
    for se in e.content
        render(se, getXY(), iob)
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

function render(e::Pandoc.Para, xy=getXY(), io=stdout, c=Crayon())
    w, h = canvassize()
    cmove(round(Int, w / 8), getY() + 2)
    for se in e.content
        render(se)
    end
    cmove(round(Int, w / 8), getY() + 2)
end

wrap(s) = wrap(s, round(Int, getW() * 3 / 4))

function wrap(s, w::Int)
    length(s) < w && return String[s]
    i = findprev(" ", s, w)
    i = (i == nothing) ? w : i[1]
    first, remaining = s[1:i], s[i+1:end]
    first = first
    remaining = remaining
    return vcat(String[first], wrap(remaining, w))
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

current_slide(s::Slides) = s.content[s.current_slide]
filename(s::Slides) = s.filename

function next(s::Slides)
    if s.current_slide < length(s.content)
        s.current_slide += 1
    end
    render(s)
end

function previous(s::Slides)
    if s.current_slide > 1
        s.current_slide -= 1
    end
    render(s)
end
