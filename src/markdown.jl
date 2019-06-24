const ESC = "\u001B"
const MARGIN = 10

render(md) = Markdown.term(stdout, md, width())

function render(h1::Markdown.Header{1})
    # TODO: handle wrapped text
    h = height()
    pre_width = div(width() - length(join(h1.text)), 2)
    pre_height = div(h - length(h1.text), 2)

    printstyled(stdout, "\n"^pre_height)
    printstyled(stdout, " "^pre_width * join(h1.text) * "\n", bold=true)
    printstyled(stdout, "\n"^pre_height)
    return h
end

function render(h2::Markdown.Header{2})
    # TODO: handle wrapped text
    pre_width = div(width() - length(join(h2.text)), 2)
    if pre_width < 0
        pre_width = 0
    end
    pre_height = 5

    printstyled(stdout, "\n"^pre_height)
    printstyled(stdout, " "^pre_width * join(h2.text) * "\n", bold=true)
end

function render(p::Markdown.Paragraph)
    pre_height = 2
    printstyled(stdout, "\n"^pre_height)
    columns = width()
    # Markdown.term(stdout, p, width() - MARGIN)
    print(stdout, ' '^MARGIN)
    Markdown.print_wrapped(stdout, width = columns-2MARGIN, pre = ' '^MARGIN) do io
        Markdown.terminline(stdout, p.content)
    end

end

function render(l::Markdown.List)
    pre_height = 5
    printstyled(stdout, "\n"^pre_height)
    columns = width()
    for (i, point) in enumerate(l.items)
        print(stdout, ' '^MARGIN, Markdown.isordered(l) ? "$(i + l.ordered - 1). " : "•  ")
        Markdown.print_wrapped(stdout, width = columns-(2MARGIN+2), pre = ' '^(MARGIN+2),
                          i = MARGIN+2) do io
            Markdown.term(stdout, point, columns - 10)
        end
        i < lastindex(l.items) && print(stdout, '\n', '\n')
    end
end

function Markdown.terminline(io::IO, image::Markdown.Image)
    print(stdout, "\n")
    f = open(image.url)
    d = read(f)
    display(TerminalExtensions.iTerm2.InlineDisplay(), MIME("image/png"),d)
end

Base.show(b::Base64.Base64EncodePipe, ::MIME"image/png", x) = write(b, x)
