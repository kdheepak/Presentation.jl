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
