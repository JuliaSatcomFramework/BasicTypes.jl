using Documenter, DocumenterVitepress
using BasicTypes

DocMeta.setdocmeta!(BasicTypes, :DocTestSetup, :(using BasicTypes); recursive=true)

should_deploy = get(ENV,"SHOULD_DEPLOY", get(ENV, "CI", "") === "true")

repo = get(ENV, "REPOSITORY", "JuliaSatcomFramework/BasicTypes.jl")
remote = Documenter.Remotes.GitHub(repo)
authors = "Alberto Mengali <alberto.mengali@esa.int>, Matteo Conti <matteo.conti@esa.int>"
sitename = "BasicTypes.jl"
devbranch = "main"
pages = [
    "Home" => "index.md",
]

makedocs(;
    sitename = sitename,
    modules = [BasicTypes],
    warnonly = true,
    authors=authors,
    repo = remote,
    pagesonly = true, # This only builds the source files listed in pages
    pages = pages,
    format = MarkdownVitepress(;
        repo = replace(Documenter.Remotes.repourl(remote), r"^https?://" => ""),
        devbranch,
        install_npm = should_deploy, # Use the built-in npm when running on CI. (Does not work locally on windows!)
        build_vitepress = should_deploy, # Automatically build when running on CI. (Only works with built-in npm!)
        # md_output_path = should_deploy ? ".documenter" : ".", # When automatically building, the output should be in build./.documenter, otherwise just output to build/
        # deploy_decision,
    ),
    clean = should_deploy,
)

if should_deploy
    repo_url = "https://github.com/" * repo
    DocumenterVitepress.deploydocs(;
        repo = repo_url,
        target = joinpath(@__DIR__, "build"),
        branch = "gh-pages",
        devbranch,
        push_preview = true,
    )
end
