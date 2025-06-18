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
unwrap_optional(T::Type) = T === Any ? T : _unwrap_optional(T)

# We need to do this indirection to special case for T === Any, otherwise T = Any would fall in the method with signature below
_unwrap_optional(::Type{Optional{T}}) where {T} = T === Any ? throw(ArgumentError("You can't call `unwrap_optional` with `Optional` (without a type parameter) as input")) : T
_unwrap_optional(T::Type) = T

# We define these explicitly to avoid relying on the internal `instance` field of the function type to get the instance 
_f_from_type(::Type{typeof(<:)}) = <:
_f_from_type(::Type{typeof(===)}) = ===

const VALID_COMPARISONS = Union{typeof(<:), typeof(===)}


@generated function _getfield_oftype(object, comparison::VALID_COMPARISONS, target::Type{T}) where T
    nms = fieldnames(object)
    tps = fieldtypes(object)
    f = _f_from_type(comparison)
    for i in eachindex(nms, tps)
        nm = nms[i]
        tp = tps[i] |> unwrap_optional
        f(tp, T) && return :(getfield(object, $(QuoteNode(nm))))
    end
    return :(nothing)
end

"""
    PropertyOrNothing{name}

Singleton structure that can be used as a functor of the form:
```julia
PropertyOrNothing{name}(object)
```
to extract the property `name` from the provided object, falling back to returning `nothing` if the provided object does not have a property called `name`. 

This is mostly useful as a fallback (or part of a fallback) to be used with [`getproperty_oftype`](@ref).
"""
struct PropertyOrNothing{name} 
    function PropertyOrNothing{name}() where {name}
        name isa Symbol || throw(ArgumentError("You can only use `Symbol` values as type parameter `name` for instantiating a `PropertyOrNothing` object"))
        return new{name}()
    end
end

PropertyOrNothing(name::Symbol) = PropertyOrNothing{name}()

(::PropertyOrNothing{name})(object) where {name} = hasproperty(object, name) ? getproperty(object, name) : nothing

"""
    getproperty_oftype(container, target_type::Type, fallback, default)
    getproperty_oftype(container, target_type::Type, fallback, exception::Exception)
    getproperty_oftype(container, target_type::Type[, fallback]; exception::Exception)

Returns the first field of `container` which satisfies `field isa target_type`.

!!! note
    When the type of a specific field (as returned by `fieldtype`) is `Optional{T}` (with `T` being any arbitrary type), the function will actually tests for `T <: target_type` rather than `Optional{T} <: target_type`

In case no field is found this way, the function will try to extract the desired property calling `fallback(container)`.

If `fallback(container)` returns `nothing`, the function will finally return the provided `default`, or throw the provided `exception`.

!!! note
    This function can not be called with a `target_type === Optional` or `target_type <: Union{Nothing, NotSet}`.

The second method is a convenience methdo which allow customizing the default exception thrown when `fallback(container)` returns nothing, and defaults `fallback = Returns(nothing)`.

# Example

```jldoctest
julia> using BasicTypes

julia> @kwdef struct MyType
           a::Int
           b::Float64
           c::Optional{String} = NotProvided()
       end;

julia> getproperty_oftype(MyType(1, 2.0, "test"), String) # Returns field `c`
"test"

julia> getproperty_oftype(MyType(; a = 1, b = 2.0), String) # Still returns `c` even if its value is not actually a String as its field is `Optional{String}`
NotProvided()

julia> getproperty_oftype(MyType(; a = 1, b = 2.0), ComplexF64, PropertyOrNothing(:b)) # This will return field `:b` as fallback
2.0

julia> getproperty_oftype(MyType(; a = 1, b = 2.0), ComplexF64, PropertyOrNothing(:d), 15) # This will fail the type check and the fallback, and returns 15
15

julia> try
           # This throws an error as it couldn't find a field with the right type and has no fallback
           getproperty_oftype((; a = 1), String; exception = ArgumentError("OPS"))
       catch e
           e.msg
       end
"OPS"
```
"""
@inline function getproperty_oftype(object, target_type::Type, fallback = Returns(nothing); exception::Exception = ArgumentError("The desired property could not be extracted"))
    getproperty_oftype(object, <:, target_type, fallback; exception)
end

@inline function getproperty_oftype(object, target_type, fallback, default)
    getproperty_oftype(object, <:, target_type, fallback, default)
end

# This for the moment we keep undocumented
@inline function getproperty_oftype(object, comparison::VALID_COMPARISONS, target_type::Type, fallback::F = Returns(nothing); exception::Exception = ArgumentError("The desired property could not be extracted")) where {F}
    getproperty_oftype(object, comparison, target_type, fallback, exception)
end
@inline function getproperty_oftype(object, comparison::VALID_COMPARISONS, target::Type, fallback, default)
    (target <: Union{Nothing,NotSet} || target === Optional) && throw(ArgumentError("You can't call this function with a target type `T <: Union{Nothing, NotSet}` or `T === Optional`, and `target_type = $target` was provided as input"))
    if default isa Exception
        @something _getfield_oftype(object, comparison, target) fallback(object) throw(default)
    elseif default === nothing
        intermediate = @something _getfield_oftype(object, comparison, target) fallback(object) missing
        @coalesce intermediate nothing
    else
        @something _getfield_oftype(object, comparison, target) fallback(object) default
    end
end