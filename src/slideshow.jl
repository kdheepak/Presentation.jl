
mutable struct SlideShow
    markdown::Markdown.MD
end

struct Slide
    blocks::Vector{Any}
end

function slides(ss::SlideShow)

    Channel() do channel

        slide = Any[]
        for element in ss.markdown.content
            if element isa Markdown.Header{1}
                if length(slide) != 0
                    put!(channel, copy(slide))
                    empty!(slide)
                end
                put!(channel, Any[element])
            elseif element isa Markdown.Header{2}
                if length(slide) != 0
                    put!(channel, copy(slide))
                    empty!(slide)
                end
                push!(slide, element)
            else
                push!(slide, element)
            end
        end
        if length(slide) != 0
            put!(channel, copy(slide))
            empty!(slide)
        end
    end


end

function render(ss::SlideShow)
    all_slides = [Slide(s) for s in slides(ss)]
    current_slide = 1
    should_quit = false
    while !should_quit
        slide = all_slides[current_slide]
        render(slide)

        cmd = input()
        if cmd == "" || cmd == "n"
            current_slide += 1
        elseif cmd == "p"
            current_slide -= 1
        elseif cmd == "r"
            JULIA = abspath(joinpath(Sys.BINDIR, "julia"))
            run(`$JULIA --color=yes`)
        elseif cmd == "q"
            should_quit = true
        else
            @warn "Unknown command: $cmd"
        end

        if current_slide > length(all_slides)
            current_slide = length(all_slides)
        end
        if current_slide < 1
            current_slide = 1
        end
    end

end

function render(s::Slide)
    Terminals.clear(Base.active_repl.t)
    for element in s.blocks
        render(element)
    end
    h1 = get_cursor_row()
    h2 = height()
    print("\n"^(h2-h1))
end

function main(filename)
    folder = dirname(filename)
    text = open(filename) do io
        read(io, String)
    end
    current_folder = pwd()
    cd(folder)
    ss = SlideShow(Markdown.parse(text))
    render(ss)
    cd(current_folder)
end

