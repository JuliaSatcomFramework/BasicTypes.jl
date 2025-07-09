"""
    ScopedRefValue{T}()
    ScopedRefValue{T}(x)
    ScopedRefValue(x)

Structure that combines a `RefValue` and a `ScopedValue`. It aims to have the basic functionality of a `ScopedValue` but allow to also change it's value persistently outside of `ScopedValues.with` blocks.

The value assigned within `ScopedValues.with` (or `BasicTypes.with`) has always precedence over the one assigned with `setindex!`.

!!! note
    If one wants to mix `ScopedRefValue` and `ScopedValue` instances in the same call to `with`, the custom `BasicTypes.with` function must be used, otherwise `ScopedRefValue` also work with the `ScopedValues.with` function as a normal `ScopedValue`.

# Examples
```jldoctest
julia> using BasicTypes, Base.ScopedValues

julia> sv = ScopedRefValue{Float64}(3.0);

julia> sv[]
3.0

julia> sv[] = 5
5

julia> sv[]
5.0

julia> with(() -> sv[], sv => 1.0) # Setting with `with` has precedence over `setindex!`
1.0
"""
struct ScopedRefValue{T}
    ref::Base.RefValue{T}
    scoped::ScopedValue{T}
end

ScopedRefValue{T}() where T = ScopedRefValue{T}(Ref{T}(), ScopedValue{T}())
ScopedRefValue{T}(x) where T = ScopedRefValue{T}(Ref{T}(x), ScopedValue{T}())
ScopedRefValue(x) = ScopedRefValue{typeof(x)}(x)

Base.setindex!(sv::ScopedRefValue, x) = return setindex!(sv.ref, x)
ScopedValues.get(sv::ScopedRefValue) = ScopedValues.get(scoped(sv))

Base.getindex(sv::ScopedRefValue) = @something ScopedValues.get(sv) getindex(sv.ref)

Base.isassigned(sv::ScopedRefValue) = isassigned(sv.ref) || isassigned(scoped(sv))

"""
    with(f, pairs::Pair{<:Union{ScopedRefValue, ScopedValue}}...)

This is functionally equivalent to `ScopedValues.with` but we have a custom implementation to support mixed pairs with both `ScopedRefValue` and `ScopedValue` as first element without committing type piracy.

See also: [`ScopedValues.with`](@ref), [`ScopedRefValue`](@ref)
"""
function with(f, pairs::Pair{<:Union{ScopedRefValue, ScopedValue}}...)
    pairs = map(p -> scoped(first(p)) => last(p), pairs)
    ScopedValues.with(f, pairs...)
end
# We also add a method just for ScopedRefValue to ScopedValues.with
function ScopedValues.with(f, pair::Pair{<:ScopedRefValue}, rest::Pair{<:ScopedRefValue}...)
    pairs = map(p -> scoped(first(p)) => last(p), (pair, rest...))
    ScopedValues.with(f, pairs...)
end

scoped(sv::ScopedRefValue) = sv.scoped
scoped(sv::ScopedValue) = sv