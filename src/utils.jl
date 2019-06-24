function width()
    Terminals.width(Base.active_repl.t)
end

function height()
    Terminals.height(Base.active_repl.t)
end

@doc """
   input(prompt::String="")::String

Read a string from STDIN. The trailing newline is stripped.

The prompt string, if given, is printed to standard output without a
trailing newline before reading input.
""" ->
function input(prompt::String="")::String
   print(prompt)
   return chomp(readline())
end

function get_cursor_row()
    io = IOBuffer();
    script = abspath(joinpath(dirname(@__FILE__), "script.sh"))
    run(pipeline(`$script`, stdout=io))
    parse(Int, strip(String(take!(io))))
end

