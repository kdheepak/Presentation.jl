abstract type PandocMarkdown end

text(x) = repr(x)
text(h::Pandoc.Header) = join([text(e) for e in h.content])
text(s::Pandoc.Str) = s.content
text(s::Pandoc.Space) = " "

function read(::Type{PandocMarkdown}, filename::String)
    return Pandoc.run_pandoc(filename)
end

render(h::Pandoc.Header) = render(h, Val{h.level}())

function render(header::Pandoc.Header, level::Val{1})
    width, height = canvassize()
    x, y = round(Int, width / 2), round(Int, mean(0, height))
    t = text(header)
    cmove(x - round(Int, length(t)/2), y)
    c = Crayon(bold=true)
    print(c(t))

    cmove(x - round(Int, length(t)/2) - 1, y + 1)
    print(c(repeat("━", length(t) + 2)))

    cmove(x - round(Int, length(t)/2) - 1, y - 1)
    print(c(repeat("━", length(t) + 2)))

    cmove(x - round(Int, length(t)/2) - 2, y)
    print(c("┃"))
    cmove(x - round(Int, length(t)/2) + 1 + length(t), y)
    print(c("┃"))

    cmove(x - round(Int, length(t)/2) - 2, y - 1)
    print(c("┏"))
    cmove(x - round(Int, length(t)/2) + 1 + length(t), y - 1)
    print(c("┓"))
    cmove(x - round(Int, length(t)/2) - 2, y + 1)
    print(c("┗"))
    cmove(x - round(Int, length(t)/2) + 1 + length(t), y + 1)
    print(c("┛"))

    cmove_bottom()
end

function render(d::Pandoc.Document)
    clear()
    for e in d.blocks
        if typeof(e) == Pandoc.Header
            return render(e)
        end
    end

end

render(::Type{T}, filename::String) where T = render(read(T, filename))
render(filename::String) = render(PandocMarkdown, filename)
