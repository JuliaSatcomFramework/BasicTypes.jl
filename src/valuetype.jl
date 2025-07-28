

"""
    valuetype(x)

Return the type of the underlying value contained in `x`.

For primitive types like `Number`, this is the type of `x` itself.
For container types like `AbstractArray{T}`, this is `T`.

For any type that does not explicitly have a custom method for `valuetype`, the default is to return `Union{}`.
"""
function valuetype end
valuetype(::Type{<:Quantity{T}}) where T  = T
valuetype(::Type{T}) where T <: Real = T
valuetype(::T) where T = valuetype(T)
valuetype(T::DataType) = Union{}
valuetype(::Type{<:AbstractArray{T}}) where T = T
valuetype(::Type{ScopedRefValue{T}}) where T = T

"""
    change_valuetype(::Type{T}, x)
    change_valuetype(type::Type)

Change the type of the value contained in `x` to `T`.

If `x` is a primitive type like `Number`, this will convert `x` to `T` and return it.
If `x` is a container type like `SVector{T}`, this will convert the elements of `x` to `T`.

The second method with just a single argument being a `type::Type` is simply a convenience method equivalent to `Base.Fix1(change_valuetype, type)`
"""
function change_valuetype end
change_valuetype(::Type{T}, x) where {T} = convert(T, x)::T
change_valuetype(::Type{T}, x::SVector{N}) where {T, N} = convert(SVector{N, T}, x)
change_valuetype(::Type{T}, x::NotSet) where {T} = x
change_valuetype(type::Type) = Base.Fix1(change_valuetype, type)

"""
    common_valuetype(::Type{BaseType}, ::Type{DefaultType}, args...)

Determine the common value type of the arguments `args...`, ensuring it is a subtype of `BaseType`.
For args that are containers, such as `AbstractArray{T}`, the common value type is determined by the element type `T`.

If the promoted value type of `args...` is not a subtype of `BaseType`, then `DefaultType` is returned instead.

# Arguments
- `BaseType::Type`: The required base type for the common value type.
- `DefaultType::Type`: The fallback type if the common value type is not a subtype of `BaseType`.
- `args...`: Arguments from which to determine the common value type.

# Returns
The common value type of `args...`, or `DefaultType` if the common type is not a subtype of `BaseType`.

# Examples
```jldoctest
julia> using BasicTypes: common_valuetype

julia> common_valuetype(AbstractFloat, Float64, 1, 2)
Float64

julia> common_valuetype(AbstractFloat, Float64, "what", 2f0) # For the string, `valuetype` returns `Union{}` so it' bypassed by during promotion
Float32

julia> common_valuetype(AbstractFloat, Float64, "what") # Still use default in case `Union{}` is the only returned valuetype
Float64
```
"""
function common_valuetype end
function common_valuetype(::Type{BaseType}, ::Type{DefaultType}, args::Vararg{Any, N}) where {BaseType, DefaultType, N}
    T = promote_type(map(valuetype, args)...)
    return T <: BaseType ? bypass_bottom(T, DefaultType) : DefaultType
end

"""
    promote_valuetype(::Type{BaseType}, ::Type{DefaultType}, args...)

Cbange the value type of the arguments `args...` to a common type that is a subtype of `BaseType`.
For args that are containers, such as `AbstractArray{T}`, the type of the underlying elements is changed.
If the promoted value type of `args...` is not a subtype of `BaseType`, then `DefaultType` is used instead.

# Arguments
- `BaseType::Type`: The required base type for the common value type.
- `DefaultType::Type`: The fallback type if the common value type is not a subtype of `BaseType`.
- `args...`: Arguments to convert to the common value type.

# Returns
The arguments `args...` with their value types changed to a common type that is a subtype of `BaseType`.
"""
function promote_valuetype end
function promote_valuetype(::Type{BaseType}, ::Type{DefaultType}, args::Vararg{Any, N}) where {BaseType, DefaultType, N}
    T = common_valuetype(BaseType, DefaultType, args...)
    return map(Base.Fix1(change_valuetype, T), args)
end