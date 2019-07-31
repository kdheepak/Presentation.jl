abstract type PandocMarkdown end

text(x) = repr(x)
function text(l::Pandoc.Link)
    return strip(text(l.content[1].target.url), ['"'])
end
text(h::Pandoc.Header) = join([text(e) for e in h.content])
text(s::Pandoc.Str) = s.content
text(s::Pandoc.Space) = " "
text(p::Pandoc.Para) = join([text(e) for e in p.content])
text(c::Pandoc.Code) = "`$(Crayon(foreground=:red)(c.content))`"

const Slide = Vector{Pandoc.Element}

mutable struct Slides
    current_slide::Int
    content::Vector{Slide}
end

function Slides(d::Pandoc.Document)
    content = Pandoc.Element[]
    slides = Slides(1, Slide[])
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

render(e::Pandoc.Element) = error("Not implemented renderer for $e")

function render(e::Pandoc.CodeBlock, x, y)
    w = round(Int, getW() * 6 / 8)
    io = IOBuffer()
    highlight(io, MIME("text/ansi"), e.content, Lexers.JuliaLexer)
    content = String(take!(io))
    c = Crayon(background = (255, 255, 255))
    save_y = y
    for code_line in split(content, '\n')
        cmove(x, y)
        println(c(repeat(" ", w)))
        y += 1
    end
    y = save_y
    for code_line in split(content, '\n')
        cmove(x, y)
        println(c(code_line))
        y += 1
    end
end

render(h::Pandoc.Header, x, y) = render(h, x, y, Val{h.level}())

function render(e::Pandoc.Header, x, y, level::Val{1})
    t = text(e)
    w = maximum(length(t))
    c = Crayon(bold=true)
    lines = wrap(t)
    for line in lines
        cmove(x - round(Int, w / 2), y)
        print(c(line))
        y += 1
    end
    draw_border(x - round(Int, w / 2) - 2, y - length(lines) - 1, w + 3, length(lines) + 1)
end

function render(e::Pandoc.Header, x, y, level::Val{2})
    t = text(e)
    w = maximum(length(t))
    c = Crayon(bold=true)
    lines = wrap(t)
    for line in lines
        cmove(x - round(Int, w / 2), y)
        print(c(line))
        y += 1
    end
    draw_border(x - round(Int, w / 2) - 2, y - length(lines) - 1, w + 3, length(lines) + 1)
end

function render(e::Pandoc.Para, x, y)
    t = text(e)
    c = Crayon()
    for line in wrap(t)
        cmove(x, y)
        print(c(line))
        y += 1
    end
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
    for e in current_slide(s)
        if typeof(e) == Pandoc.Header && e.level == 1
            x, y = round(Int, width / 2), round(Int, height / 2)
            render(e, x, y)
        elseif typeof(e) == Pandoc.Header && e.level == 2
            x, y = round(Int, width / 2), round(Int, height / 4)
            render(e, x, y)
        elseif typeof(e) == Pandoc.Para
            x = round(Int, width / 8)
            y = getY() + 2
            render(e, x, y)
        elseif typeof(e) == Pandoc.CodeBlock
            x = round(Int, width / 8)
            y = getY() + 2
            render(e, x, y)

        end
    end
    cmove_bottom()
end

render(filename::String) = render(PandocMarkdown, filename)
render(::Type{T}, filename::String) where T = render(read(T, filename))

current_slide(s::Slides) = s.content[s.current_slide]

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
