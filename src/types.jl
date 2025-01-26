"""
    abstract type EmptyIterator end

Abstract type which defines methods so that concrete subtypes behave as empty iterators, so that the code:
```
for item in T()
    # Do something
end
```
where `T <: EmptyIterator` will simply do nothing.
"""
abstract type EmptyIterator end
Base.length(::EmptyIterator) = 0
Base.iterate(::EmptyIterator, state::Int=1) = nothing
Base.eltype(::EmptyIterator) = Union{}
Base.keys(::EmptyIterator) = Base.OneTo(0) # Required for `eachindex`

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
    ExtraOutput

Singleton type used for dispatch, and specifically to create function methods
that return more than one output.
"""
struct ExtraOutput end

"""
    struct NoTrait end

Singleton type used to indicate that a trait is not implemented, resorting the
eventual default behavior.
"""
struct NoTrait end