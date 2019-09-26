


@testset "test renderer" begin

    iob = IOBuffer()
    Presentation.render(iob, joinpath(@__DIR__, "sample.md"))

    @test String(take!(iob)) == "\e[1mPresentation.jl\e[22m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┃┃┃┃┏┓┗┛"

end

