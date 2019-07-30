mean(x::Number, y::Number) = (x + y) / 2

const ESC = "\u001B"

canvassize() = Base.displaysize(stdout) |> reverse

pos() = pos(terminal)
getX() = getX(terminal)
getY() = getY(terminal)
getW() = canvassize()[1]
getH() = canvassize()[2]
cmove(x, y) = cmove(terminal, x, y)
clear() = clear(terminal)
cmove_bottom() = cmove(1, getH())

pos(t::Terminals.TTYTerminal) = (getX(t), getY(t))

function getXY(t::Terminals.TTYTerminal)
    io = IOBuffer();
    script = abspath(joinpath(dirname(@__FILE__), "script.sh"))
    run(pipeline(`$script`, stdout=io))
    r, c = split(strip(String(take!(io))), ",")
    return parse(Int, c), parse(Int, r)
end

function getX(t::Terminals.TTYTerminal)
    x, y = getXY(t)
    return x
end

function getY(t::Terminals.TTYTerminal)
    x, y = getXY(t)
    return y
end

@eval cmove(t::Terminals.TTYTerminal, x::Int, y::Int) = print("$(Terminals.CSI)$(y);$(x)H")
@eval function clear(t::Terminals.TTYTerminal)
    r = getH()
    print("$(Terminals.CSI)$(r);1H")
    print("$(Terminals.CSI)2J")
end

