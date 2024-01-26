using Documenter
using Folds

makedocs(
    sitename = "Folds",
    format = Documenter.HTML(),
    modules = [Folds],
)

deploydocs(
    repo = "github.com/JuliaFolds2/Folds.jl",
    push_preview = true,
)
