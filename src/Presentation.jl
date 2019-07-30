module Presentation

import Pandoc
import REPL
import REPL: Terminals
import Base: read

using Crayons

export render, next, previous, wrap

include("utils.jl")
include("markdown.jl")

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

