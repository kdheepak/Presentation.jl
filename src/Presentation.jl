module Presentation

import Pandoc
import REPL
import REPL: Terminals
import Base: read

using Crayons

export render, text, displaysize, read

include("utils.jl")
include("markdown.jl")

terminal = nothing

function __init__()
    global terminal
    terminal = REPL.Terminals.TTYTerminal(get(ENV, "TERM", Sys.iswindows() ? "" : "dumb"), stdin, stdout, stderr)
end

end

