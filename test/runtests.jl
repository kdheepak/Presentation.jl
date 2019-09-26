using Test

using Presentation

if get(ENV, "CI", "") == ""

    include("test_presentation.jl")

end
