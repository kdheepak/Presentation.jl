mean(x::Number, y::Number) = (x + y) / 2

function displaysize()
    return Base.displaysize(terminal)
end

pos() = Terminals.pos(terminal)

function cursor_position()
    io = IOBuffer();
    script = abspath(joinpath(dirname(@__FILE__), "script.sh"))
    run(pipeline(`$script`, stdout=io))
    r, c = split(strip(String(take!(io))), ",")
    return (parse(Int, r), parse(Int, c))
end

cursor_position(x, y) = print("$ESC[$(y);$(x)H")

