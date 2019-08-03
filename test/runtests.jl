using Test

using Presentation


BASE_DIR = abspath(joinpath(dirname(Base.find_package("Presentation")), ".."))

# Copied @includetests from https://github.com/ssfrr/TestSetExtensions.jl.
# Ideally, we could import and use TestSetExtensions.  Its functionality was broken by changes
# in Julia v0.7.  Refer to https://github.com/ssfrr/TestSetExtensions.jl/pull/7.

"""
Includes the given test files, given as a list without their ".jl" extensions.
If none are given it will scan the directory of the calling file and include all
the julia files.
"""
macro includetests(testarg...)
    if length(testarg) == 0
        tests = []
    elseif length(testarg) == 1
        tests = testarg[1]
    else
        error("@includetests takes zero or one argument")
    end

    quote
        tests = $tests
        rootfile = @__FILE__
        if length(tests) == 0
            tests = readdir(dirname(rootfile))
            tests = filter(f->endswith(f, ".jl") && f != basename(rootfile), tests)
        else
            tests = map(f->string(f, ".jl"), tests)
        end
        println()
        for test in tests
            print(splitext(test)[1], ": ")
            include(test)
            println()
        end
    end
end

function run_tests()
    @time @testset "Begin tests" begin
        @includetests ARGS
    end
end

run_tests()
