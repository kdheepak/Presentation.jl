abstract type PandocMarkdown end

text(x) = repr(x)
text(h::Pandoc.Header) = join([text(e) for e in h.content])
text(s::Pandoc.Str) = s.content
text(s::Pandoc.Space) = " "
text(p::Pandoc.Para) = join([text(e) for e in p.content])

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

render(e::Pandoc.Element) = error("Not implemented renderer for $e")

function render(cb::Pandoc.CodeBlock)
    width, height = canvassize()
    x, y = round(Int, width / 2), round(Int, mean(0, height))
end

render(h::Pandoc.Header) = render(h, Val{h.level}())

function render(header::Pandoc.Header, level::Val{1})
    width, height = canvassize()
    x, y = round(Int, width / 2), round(Int, mean(0, height))
    t = text(header)
    cmove(x - round(Int, length(t)/2), y)
    c = Crayon(bold=true)
    print(c(t))
    draw_border(x - round(Int, length(t) / 2) - 2, y-1, length(t) + 3, 2)
    cmove_bottom()
end

function render(header::Pandoc.Header, level::Val{2})
    width, height = canvassize()
    x, y = round(Int, width / 2), round(Int, mean(0, height / 4))
    t = text(header)
    cmove(x - round(Int, length(t)/2), y)
    c = Crayon(bold=true)
    print(c(t))
    draw_border(x - round(Int, length(t) / 2) - 2, y-1, length(t) + 3, 2)
    cmove_bottom()
end

function render(para::Pandoc.Para)
    width, height = canvassize()
    x, y = round(Int, width / 8), round(Int, height / 2)
    t = text(para)
    cmove(x, y)
    c = Crayon()
    print(c(t))
    cmove_bottom()
end

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

function render(s::Slides)
    clear()
    for e in s.content[s.current_slide]
        render(e)
    end
end

render(d::Pandoc.Document) = render(Slides(d))

render(::Type{T}, filename::String) where T = render(read(T, filename))
render(filename::String) = render(PandocMarkdown, filename)
