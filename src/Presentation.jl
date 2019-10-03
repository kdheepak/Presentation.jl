module Presentation

import Pandoc
import REPL
import REPL: Terminals
import Base: read

using Crayons
using Highlights
using Highlights.Tokens
using Highlights.Lexers
using TerminalExtensions
using Markdown

export render, next, previous, current_slide

abstract type PandocMarkdown end
abstract type JuliaMarkdown end

include("lexers.jl")

include("utils.jl")
include("slideshow.jl")
include("renderer.jl")

TERMINAL = nothing # Contains reference to the built in Terminal
SLIDES = nothing # Contains reference to a `Slides` object

render() = render(SLIDES)
next() = next(SLIDES)
previous() = previous(SLIDES)
current_slide() = current_slide(SLIDES)
filename() = filename(SLIDES)

function __init__()
    global TERMINAL
    TERMINAL = REPL.Terminals.TTYTerminal(get(ENV, "TERM", Sys.iswindows() ? "" : "dumb"), stdin, stdout, stderr)
end

end

