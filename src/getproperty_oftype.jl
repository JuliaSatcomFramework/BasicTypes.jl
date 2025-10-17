

"""
    fieldidx_oftype(OBJ::Type, comparison::Function)
    fieldidx_oftype(OBJ::Type, supertype::Type)

Extracts the field index of the first field of the type `OBJ` for which `comparison(fieldtype) === true`.
If no field satisfying the comparison function is found, this simply return -1 to keep the function type stable (always returning an `Int`).

If the second argument is a type, this simply translates to the following comparison function:
```julia
    comparison = T -> T <: supertype
```

!!! note
    Since v1.18.0, this function is used within the implementation of `fieldname_oftype`.
"""
function fieldidx_oftype(OBJ::Type, comparison::F) where F
    Base.@assume_effects :foldable
    idx = findfirst(comparison ∘ unwrap_optional, fieldtypes(OBJ))
    return idx === nothing ? -1 : idx
end
# Version taking just the type
function fieldidx_oftype(::Type{O}, ::Type{T}) where {O, T}
    return fieldidx_oftype(O, Base.Fix2(<:, T))
end

# We define these explicitly to avoid relying on the internal `instance` field of the function type to get the instance 
const FIELDNAME_NOT_FOUND_SYMBOL = :_field_of_type_not_found_

"""
    fieldname_oftype(OBJ::Type, comparison::Function)
    fieldname_oftype(OBJ::Type, supertype::Type)

Extracts the field name of the first field of the type `OBJ` for which `comparison(fieldtype) === true`.
If no field satisfying the comparison function is found, this simply return a dummy Symbol (whose value is stored inside the package-internal constant global `FIELDNAME_NOT_FOUND_SYMBOL`).

If the second argument is a type, this simply translates to the following comparison function:
```julia
    comparison = T -> T <: supertype
```

!!! note
    Since v1.18.0, this function relies on `fieldidx_oftype` to find the field index.
"""
function fieldname_oftype(OBJ::Type, comparison::F) where F
    Base.@assume_effects :foldable
    idx = fieldidx_oftype(OBJ, comparison)
    idx === -1 && return FIELDNAME_NOT_FOUND_SYMBOL
    return fieldname(OBJ, idx)
end


"""
    field_oftype(obj, comparison)
    field_oftype(OBJ::Type, comparison)

Function that leverages `fieldname_oftype` to extract the field (or field type in case type is passed as first argument) returned by `fieldname_oftype(typeof(obj), comparison)`

In case no field satisfying the comparison is found, this function returns an instance of the singleton type `NotFound` defined within this package.

This is the base of the `getproperty_oftype` function and should basically completely resolve at compile time allowing flexible property access without runtime penalty.
"""
function field_oftype(obj, second::F) where {F}
    fname = fieldname_oftype(typeof(obj), second)::Symbol
    fname === FIELDNAME_NOT_FOUND_SYMBOL && return NotFound()
    return getfield(obj, fname)
end
function field_oftype(obj::Type, second::F) where {F}
    fname = fieldname_oftype(obj, second)::Symbol
    fname === FIELDNAME_NOT_FOUND_SYMBOL && return NotFound()
    return fieldtype(obj, fname)
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
function getproperty_oftype(object, comparison::C, fallback::F = Returns(nothing); exception::Exception = ArgumentError("The desired property could not be extracted")) where {C, F}
    getproperty_oftype(object, comparison, fallback, exception)
end
function getproperty_oftype(object, comparison, fallback, default)
    if comparison isa Type
        (comparison <: Union{Nothing,NotSet} || comparison === Optional) && throw(ArgumentError("You can't call this function with a target type `T <: Union{Nothing, NotSet}` or `T === Optional`, and `target_type = $comparison` was provided as input"))
    end
    out = field_oftype(object, comparison)
    out isa NotFound || return out
    fallback_value = fallback(object)
    if default isa Function
        default = default()
    end
    if default isa Exception
        return @something fallback_value throw(default)
    elseif default === nothing
        intermediate = @something fallback_value missing
        return @coalesce intermediate nothing
    else
        return @something fallback_value default
    end
end