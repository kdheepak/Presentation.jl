using Documenter, Presentation

mkpath(joinpath(@__DIR__, "src")
cp(joinpath(@__DIR__, "../README.md"), joinpath(@__DIR__, "src/index.md"))
cp(joinpath(@__DIR__, "../LICENSE"), joinpath(@__DIR__, "src/LICENSE"))

# Build documentation.
# ====================

makedocs(
    # options
    modules = [
               Presentation,
              ],
    doctest = false,
    clean = false,
    format = Documenter.HTML(),
    sitename = "Presentation.jl",
    authors = "Dheepak Krishnamurthy",
    pages = Any[
        "Home" => "index.md",
        "License" => "LICENSE"]
)

# Deploy built documentation from Travis.
# =======================================

deploydocs(
    # options
    target = "build",
    repo = "github.com/kdheepak/Presentation.jl.git"
)
