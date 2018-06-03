module Presentation

    export Slide, next_slide, previous_slide, show_slide

    import Base.show
    import Base: LineEdit, REPL

    # repl = Base.active_repl

    mutable struct SlideShow{T}
        slides::Array{T,1}
        current_slide::Int
        current_expr::Int
    end

    SlideShow(;
              slides=[],
              current_slide=1,
              current_expr=1
             ) = SlideShow(slides, current_slide, current_expr)

    slide_show = SlideShow()

    struct Slide
        text::String
        expressions::Array
        function Slide(text, expressions)
            s = new(strip(text), expressions)
            push!(slide_show.slides, s)
            s
        end
    end

    Slide(text) = Slide(text, Array{Expr,1}())

    function justify(s, width)
        len = Int(round(length(s) / 2))
        half_width = Int(round( width / 2 ))
        return rpad(lpad(s, half_width + len), width)
    end

    function terminal_width_height()
        repl = Base.active_repl
        width = Base.Terminals.width(repl.t)
        height = Base.Terminals.height(repl.t) - 10
        width, height
    end

    function format_slide(s::Slide)
        width, height = terminal_width_height()
        text = s.text
        lines = split(text, "\n")
        text = ""
        for l in lines
            if startswith(l, "#")
                l = justify(l, width)
            end
            text = text * l * "\n"
        end
        H = length(lines)
        i = H
        while i < height - 3
            text = text * "\n"
            i = i + 1
        end
        text
    end

    function Base.show(io::IO, s::Slide)
        text = format_slide(s)
        print(text)
    end

    function Base.show(io::IO, ::MIME"text/plain", s::Slide)
        print(io, s)
    end

    function next_slide()
        slide_show.current_expr = 1
        if slide_show.current_slide == length(slide_show.slides)
            return nothing
        else
            slide_show.current_slide = slide_show.current_slide + 1
            show_slide()
            return nothing
        end
    end

    function previous_slide()
        slide_show.current_expr = 1
        if slide_show.current_slide == 1
            return nothing
        else
            slide_show.current_slide = slide_show.current_slide - 1
            show_slide()
            return nothing
        end
    end

    function current_slide()
        s = slide_show.slides[slide_show.current_slide]
    end

    function string_from_expression(expr)
        string = "$expr"
        text = ""
        for line in split(string, "\n")
            if contains(line, ", line") & endswith(line, ":")
                line = rsplit(line, "#")[1]
            end
            text = text * line
            text = text * "\n"
        end
        strip(text)
    end

    function get_next_expression()
        s = current_slide()

        if slide_show.current_expr > length(s.expressions)
            return ""
        else
            expr = s.expressions[slide_show.current_expr]

            slide_show.current_expr = slide_show.current_expr + 1

            return string_from_expression(expr)
        end
    end

    function show_slide()
        clear()
        println(slide_show.slides[slide_show.current_slide])
        return nothing
    end

    function clear()
        Base.run(`clear`)
        gc()
    end

    function create_extra_repl_keymap()
        D = Dict{Any, Any}()
        D["^Q"] = "^L"
        D["^F"] = (s, data, c) -> begin
            next_slide()
            show_slide()
            LineEdit.refresh_line(s)
        end
        D["^B"] = (s, data, c) -> begin
            previous_slide()
            show_slide()
            LineEdit.refresh_line(s)
        end
        D["^E"] = (s, data, c) -> begin
            LineEdit.edit_clear(s)
            expr = get_next_expression()
            if !(expr == nothing)
                LineEdit.edit_insert(LineEdit.buffer(s), """$expr""")
            end
            LineEdit.refresh_line(s)
        end
        return D
    end

    function __init__()
        options = Base.JLOptions()
        # command-line
        if (options.isinteractive != 1) && ((options.eval != C_NULL) || (options.print != C_NULL))
            return
        end

        if isdefined(Base, :active_repl)
            println("Use Presentation in ~/.juliarc.jl.")
        else
            atreplinit() do repl
                repl.interface = Base.REPL.setup_interface(repl; extra_repl_keymap = create_extra_repl_keymap())
            end
        end

    end

end

