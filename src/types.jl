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
Base.length(::EmptyIterator) = return 0 # Need return to hit coverage
Base.iterate(::EmptyIterator, state::Int=1) = nothing
Base.eltype(::EmptyIterator) = Union{}
Base.keys(::EmptyIterator) = Base.OneTo(0) # Required for `eachindex`

"""
    NotFound

Singletone type used as return type of some functions in this package to clearly identified that the desired output could not be found
"""
struct NotFound end

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


"""
    struct SkipChecks end

Singleton type used for dispatch to indicate that a certain check should be skipped.
"""
struct SkipChecks end