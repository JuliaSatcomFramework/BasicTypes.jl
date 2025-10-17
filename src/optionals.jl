"""
    NotProvided <: EmptyIterator

Type used to specify that a field is not provided. This is useful when a field
is optional and the user wants to specify that it is not provided, instead of
using `nothing` which could be a valid value for the field.
"""
struct NotProvided <: EmptyIterator end

"""
    NotSimulated <: EmptyIterator

Custom type to indicate that a certain operation or function is not
simulated. Used mostly for dispatch and for explicitly indicating that something
should be skipped during the simulation (without relying on `nothing` or
`missing`).
"""
struct NotSimulated <: EmptyIterator end

"""
    NotSet = Union{NotProvided, NotSimulated}
"""
const NotSet = Union{NotProvided, NotSimulated}

"""
    Optional{T} = Union{T, NotProvided, NotSimulated}

This type alias is used to represent an optional value, mostly for use as type of struct fields for which a default value (either `NotProvided` or `NotSimulated`) is expected and used as default in the type's constructor.
"""
const Optional{T} = Union{T, NotSet}

"""
    isnotset(x)

Return `true` if `x` is not set to a value. 
(That is, `x` is either `NotProvided` or `NotSimulated`)
"""
isnotset(x) = x isa NotSet

"""
    isprovided(x) -> Bool

Check if the value `x` is not of type `NotProvided`.
Returns `true` if `x` is provided, otherwise `false`.
"""
isprovided(x) = typeof(x) != NotProvided

"""
    issimulated(x) -> Bool

Check if `x` is simulated by verifying its type is not `NotSimulated`.
Returns `true` if `x` is simulated, `false` otherwise.
"""
issimulated(x) = typeof(x) != NotSimulated

"""
    fallback(x...)

Return the first value in the arguments which is set, i.e. is not equal to `NotProvided` or `NotSimulated`.
If no value is found, an `ArgumentError` is thrown.

# Examples
```
julia> x = NotProvided()
julia> y = NotSimulated()
julia> z = 1.0
julia> fallback(x, y, z)
1.0
```
"""
function fallback end

fallback() = throw(ArgumentError("No value arguments present"))
fallback(x::NotSet, y...) = fallback(y...)
fallback(x::Any, y...) = x

"""
    @fallback(x...)

Short-circuiting version of [`fallback`](@ref).

# Examples
```
julia> x = NotProvided()
julia> y = NotSimulated()
julia> z = 1.0
julia> @fallback x, y, z
1.0
```
"""
macro fallback(args...)

    # Default Expr: Error (used if none of the args is set to a value)
    expr = :(throw(ArgumentError("No arguments with value in @fallback")))

    #=
    We go through the arguments in reverse
    because we're building a nested if/else
    expression from the inside out.
    The innermost thing to check is the last argument,
    which is why we need the last argument first
    when building the final expression.
    <taken from julia/base/some.jl>
    =#
    for arg in reverse(args)
        val = gensym()
        expr = quote
            $val = $(esc(arg))
            if !isnotset($val)
                $val
            else
                $expr
            end
        end
    end
    return expr
end

"""
    unwrap_optional(::Type)

Function used to unwrap the type `T` from `Optional{T}`.
If the provided type is not of the form `Optional{T}`, it simply returns it unchanged.

!!! note
    When calling this function with simply `Optional` as input, the function throws an error.

```jldoctest
julia> using BasicTypes: BasicTypes, unwrap_optional, Optional

julia> unwrap_optional(Optional{Float32})
Float32

julia> unwrap_optional(Float64)
Float64
```
"""
unwrap_optional(T::Type) = return T
function unwrap_optional(U::Union)
    (; a, b) = U
    b <: NotSet && return a
    a <: NotSet && return unwrap_optional(b)
    return U
end



"""
    bypass_bottom(candidate::Type, fallback::Type)

This function takes as input two types, a `candidate` and a `fallback`, and returns `candidate` unless `candidate === Union{}` in which case it returns `fallback`.
"""
bypass_bottom(candidate::Type, fallback::Type) = return candidate
bypass_bottom(::typeof(Union{}), fallback::Type) = return fallback
bypass_bottom(::typeof(Union{}), ::typeof(Union{})) = throw(ArgumentError("Cannot call the `bypass_bottom` function with `Union{}` as both first and second argument."))