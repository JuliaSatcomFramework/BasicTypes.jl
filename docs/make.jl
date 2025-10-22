using Documenter, DocumenterVitepress
using BasicTypes

### Configuration ###
devbranch = "main"
repo = get(ENV, "REPOSITORY", "JuliaSatcomFramework/BasicTypes.jl")
remote = Documenter.Remotes.GitHub(repo)
authors = "Matteo Conti <matteo.conti@esa.int>, Alberto Mengali <alberto.mengali@esa.int>, Fabian Nawratil <fabian.nawratil@esa.int>"
deploy_url = "https://juliasatcomframework.github.io/BasicTypes.jl"
sitename = "BasicTypes.jl"
pages = [
    "Home" => "index.md",
    "Units" => "units.md",
    "API" => "api.md",
]
modules = [BasicTypes]


### Build & Deployment ###

# This controls whether or not deployment is attempted. It is based on the value
# of the `SHOULD_DEPLOY` ENV variable, which defaults to the `CI` ENV variables or
# false if not present.
should_deploy = get(ENV,"SHOULD_DEPLOY", get(ENV, "CI", "")) === "true"

makedocs(
    sitename = sitename,
    authors = authors,
    repo = remote,
    warnonly = true,
    pagesonly = true,
    doctest = false, # We anyhow run doctest manually in the tests.
    format = MarkdownVitepress(;
        repo = replace(Documenter.Remotes.repourl(remote), r"^https?://" => ""),
        devbranch,
        install_npm = should_deploy, # Use the built-in npm when running on CI. (Does not work locally on windows!)
        build_vitepress = should_deploy, # Automatically build when running on CI. (Only works with built-in npm!)
        deploy_url = should_deploy ? deploy_url : nothing,
    ),
    modules = modules,
    pages = pages,
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