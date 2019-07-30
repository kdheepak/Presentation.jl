abstract type PandocMarkdown end

const ESC = "\u001B"

text(x) = repr(x)
text(h::Pandoc.Header) = join([text(e) for e in h.content])
text(s::Pandoc.Str) = s.content
text(s::Pandoc.Space) = " "

function read(::Type{PandocMarkdown}, filename::String)
    return Pandoc.run_pandoc(filename)
end

function render(header::Pandoc.Header)
    width, height = terminal_dimension()
    x, y = round(Int, width / 2), round(Int, mean(0, height / 3))
    t = text(header)
    cursor_position(x, y)
    print(t)
    cursor_position(1, height)
end

function render(d::Pandoc.Document)

    for e in d.blocks
        if typeof(e) == Pandoc.Header
            return render(e)
        end
    end

end

render(::Type{T}, filename::String) where T = render(read(T, filename))
render(filename::String) = render(PandocMarkdown, filename)
