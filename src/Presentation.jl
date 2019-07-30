module Presentation

import Pandoc
import REPL
import Terminals

export render, text

include("utils.jl")
include("markdown.jl")

function __init__()
    global terminal
    terminal = REPL.Terminals.TTYTerminal(get(ENV, "TERM", Sys.iswindows() ? "" : "dumb"), stdin, stdout, stderr)
end

end

