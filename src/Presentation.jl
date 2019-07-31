module Presentation

import Pandoc
import REPL
import REPL: Terminals
import Base: read

using Crayons

export render, next, previous, wrap, current_slide, termios, TERM, RESTORE, ICANON, ECHO, TCSETS, TCSANOW,O_RDWR, O_NOCTTY


include("utils.jl")
include("renderer.jl")

TERMINAL = nothing

SLIDES = nothing

render() = render(SLIDES)

function render(d::Pandoc.Document)
    global SLIDES
    s = Slides(d)
    SLIDES = s
    return render(s)
end

next() = next(SLIDES)
previous() = previous(SLIDES)
current_slide() = current_slide(SLIDES)

function __init__()
    global TERMINAL
    TERMINAL = REPL.Terminals.TTYTerminal(get(ENV, "TERM", Sys.iswindows() ? "" : "dumb"), stdin, stdout, stderr)
end

end

