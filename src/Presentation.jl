module Presentation

import Pandoc
import REPL
import REPL: Terminals
import Base: read

using Crayons
using Highlights
using TerminalExtensions

export render, next, previous, current_slide

include("utils.jl")
include("slideshow.jl")
include("renderer.jl")

TERMINAL = nothing # Contains reference to the built in Terminal
SLIDES = nothing # Contains reference to a `Slides` object

render() = render(SLIDES)

function render(d::Pandoc.Document, filename::String="")
    global SLIDES
    s = Slides(d, filename)
    SLIDES = s
    return render(s)
end

next() = next(SLIDES)
previous() = previous(SLIDES)
current_slide() = current_slide(SLIDES)
filename() = filename(SLIDES)

function __init__()
    global TERMINAL
    TERMINAL = REPL.Terminals.TTYTerminal(get(ENV, "TERM", Sys.iswindows() ? "" : "dumb"), stdin, stdout, stderr)
end

end

