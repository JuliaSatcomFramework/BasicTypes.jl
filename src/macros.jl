# Main function that will cycle through the keyword arguments defined in a function signature and add defaults for the ones without default values (when a specific default value for that kwarg has been defined)
function add_defaults_to_kwargs!(funcdef::Expr, defaults)
    signature = first(funcdef.args)
    if Meta.isexpr(signature, :where)
        signature = signature.args[1]
    end
    length(signature.args) > 1 || return false # There is no argument nor keyword argument
    params = signature.args[2]
    Meta.isexpr(params, :parameters) || return false
    modified = false
    args = params.args
    for (i, arg) in enumerate(args)
        if arg isa Symbol
            kwname = arg
            hasproperty(defaults, kwname) || continue
            args[i] = Expr(:kw, arg, getproperty(defaults, kwname))
            modified = true
        elseif Meta.isexpr(arg, :(::))
            kwname = first(arg.args)
            hasproperty(defaults, kwname) || continue
            args[i] = Expr(:kw, arg, getproperty(defaults, kwname))
            modified = true
        end
    end
    return modified
end

function define_kwargs_defaults(varname::Symbol, block)
    @assert Meta.isexpr(block, :block) "You can only call the `@define_kwargs_defaults` macro with a single argument being a `begin...end` block"
    block.args
    isvalid(ex) = Meta.isexpr(ex, :(=)) && first(ex.args) isa Symbol
    make_pair(ex) = ex.args[1] => ex.args[end]
    :(const $varname = NamedTuple(($make_pair(ex) for ex in $(block.args) if $isvalid(ex))))
end
define_kwargs_defaults(block) = define_kwargs_defaults(:DEFAULT_KWARGS, block)

"""
    @define_kwargs_defaults [defaults_variable_name] begin
        kw1 = default_value1
        kw2 = default_value2
        ...
    end

This macro is a helper macro to define keyword arguments defaults to be used in conjuction with the [`@add_kwargs_defaults`](@ref) macro.

Its main argument is a `begin...end` block that will define the keyword arguments defaults in the form defined in the signature and will assign these defaults to a const `NamedTuple` variable in the caller module's scope.

If only the `begin...end` block is provided, the macro will assign the resulting `NamedTuple` to a const variable named `DEFAULT_KWARGS`.
Alternatively, a custom variable name can be provided as the first argument of the macro.

!!! note
    The default values to the RHS of each expression in the `begin...end` block are simply stored as parsed by the macro, so for any non-literal value, the resulting expression will be stored in the `NamedTuple`.

# Example
```julia
module TestKwargs
using BasicTypes

@define_kwargs_defaults begin
    boresight = true
    check_blocking = false
end

@add_kwargs_defaults f(; boresight, check_blocking) = return boresight, check_blocking
@add_kwargs_defaults g(; boresight, check_blocking = 3) = return boresight, check_blocking
end

TestKwargs.f() === (true, false)
TestKwargs.g() === (true, 3)
```
"""
macro define_kwargs_defaults(args...)
    return define_kwargs_defaults(args...) |> esc
end

function add_kwargs_defaults(defaults_name, funcdef; caller_module)
    isfuncdef(ex) = Meta.isexpr(ex, [:(=), :function]) && Meta.isexpr(ex.args[1], [:call, :where])

    @assert isfuncdef(funcdef) "You can only call this macro with a function definition as only argument"
    if isdefined(caller_module, defaults_name)
        defaults = Core.eval(caller_module, defaults_name)
        add_defaults_to_kwargs!(funcdef, defaults) || @warn "The provided function definition was not modified by the `@add_kwargs_defaults` macro"
    else
        err = ArgumentError("The `$(defaults_name)` variable supposed to contain the keyword arguments defaults was not found in the caller module's scope")
        return :(throw($err))
    end
    return funcdef
end
add_kwargs_defaults(funcdef; kwargs...) = add_kwargs_defaults(:DEFAULT_KWARGS, funcdef; kwargs...)

"""
    @add_kwargs_defaults [defaults_variable_name] function_definition

This macro is a helper macro to add keyword arguments defaults to a function definition, useful when multiple functions need to share the same keyword arguments defaults and one wants to define them only once within the codebase.

By explicitly defining each keyword argument (rather than relying on the catchall `kwargs...`) the user of the function can have autocomplete functionality also for keyword arguments in the REPL.

This macro will simply cycle through the keyword arguments parsed from the function definition and add defaults to any of the kwargs that do not have a specified default value within the signature. It will only add defaults for kwargs that have a default specified in the `NamedTuple` object reachable within the caller module's scope with the variable name provided as the optional first argument of the macro. 
    
If a custom name is not provided, the macro will look for default assignments in a variable named `DEFAULT_KWARGS`.

The macro will return the modified function definition.

See the [`@define_kwargs_defaults`](@ref) macro for a convenience way of defining the kwargs defaults within a module.
"""
macro add_kwargs_defaults(args...)
    return esc(add_kwargs_defaults(args...; caller_module=__module__))
end
