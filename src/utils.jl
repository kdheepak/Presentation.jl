mean(x::Number, y::Number) = (x + y) / 2

function terminal_dimension()
    return displaysize(stdout) |> reverse
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

function cursor_position()
    io = IOBuffer();
    script = abspath(joinpath(dirname(@__FILE__), "script.sh"))
    run(pipeline(`$script`, stdout=io))
    r, c = split(strip(String(take!(io))), ",")
    return (parse(Int, r), parse(Int, c))
end

cursor_position(x, y) = print("$ESC[$(y);$(x)H")

