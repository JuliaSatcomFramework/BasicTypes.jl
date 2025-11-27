"""
    constructor_without_checks(T, args...)
Custom types `T` with inner constructors that do checks on inputs may want to
implement a method for this function where `T` is the specific type and
`args...` are just the fields of `T`.

This method must be defined inside the struct definition and should simply
return `new(args...)`, as a way to create an instance of the type without
running the potentially expensive checks.

This is especially useful for internal methods that might already know that the
inputs are valid and within bounds, so they can skip the checks.

# Example
```julia
struct MyType{T}
    x::T
    y::T
    #= 
    This is an unsafe constructor that skips all the input checks, we have this as our only inner constructor. 
    The `CoordinateSystemsBase` is important (even if explicitly imported in the
    parent module), or a local function with the same name will be created in
    the local scope of the struct definition body.
    =#
    BasicTypes.constructor_without_checks(::Type{MyType{T}}, x::T, y::T) where T = new{T}(x, y)
end
# We define the constructor with checks as an outer one, but we could have also done this inside the struct definition
function MyType{T}(x::T, y::T)
    # do some input checks...
    validated_x = check_x(x)
    validated_y = check_y(y)
    # Return the potentially modified inputs, if we had this as inner constructor this last line would be `new{T}(validated_x, validated_y)`
    BasicTypes.constructor_without_checks(MyType{T}, validated_x, validated_y)
end
```
"""
function constructor_without_checks end


# Logger
"""
    terminal_logger()

Returns the global `TerminalLogger` to be used for logging progress bars via `ProgressLogging.jl` in the REPL.
"""
function terminal_logger()
    isassigned(TERMINAL_LOGGER) || (TERMINAL_LOGGER[] = TerminalLogger())
    return TERMINAL_LOGGER[]
end

tee_logger(base_logger = current_logger()) = base_logger isa NullLogger ? base_logger : TeeLogger(terminal_logger(), base_logger)

"""
    progress_logger(base_logger = current_logger())

Returns the logger to use for progress monitoring via ProgressLogging.jl. 

When called from the REPL (checked via the `isinteractive` function) **and** with a `base_logger` which **is not** a `NullLogger` , it will return a TeeLogger (from LoggingExtras.jl) containing the `base_logger` and a `TerminalLogger` (from TerminalLoggers.jl). 
This is because the `@progress` macro from ProgressLogging.jl does not print the
progress bar in the REPL without `TerminalLogger`.

Outside of interactive sessions, it will simply return the provided `base_logger`.
"""
progress_logger(base_logger = current_logger()) = isinteractive() ? tee_logger(base_logger) : base_logger

# This function shall create the non-parametrzed subtype, used for simplifying adding methods to `StructArrays.similar_type`. The solution is taken from https://discourse.julialang.org/t/deparametrising-types/41939/4
"""
    basetype(t)

Returns the type of `t`, removing type parameters if for parametric types (thus
returning the more generic UnionAll type for `typeof(t)`)

```julia
basetype(rand(Complex{Float64})) === Complex
```
"""
basetype(T::Type) = return Base.typename(T).wrapper
basetype(::Union) = return Union
basetype(::T) where T = return basetype(T)

"""
    sa_type(DT::DataType, N::Union{Int, TypeVar}; unwrap = T -> false)

This is a helper function that simplifies creating concrete `StructArray` types for types within struct definitions.

## Arguments
- `DT::DataType`: The type of the struct to create the `StructArray` for.
- `N::Union{Int, TypeVar}`: Specifies the dimensions of the array stored within the resulting `StructArray` type

# Examples
```julia
struct ASD{G}
    a::sa_type(Complex{G}, 3)
end
```
is equivalent to
```julia
struct ASD{G}
    a::StructArray{Complex{G}, 3, @NamedTuple{re::Array{G, 3}, im::Array{G, 3}}, Int64}
end
```

!!! note
    This function is defined inside an extension and is thus available only conditionally to the `StructArrays` package being explicitly imported

# Extended Help

The function supports unwrapping like in the `StructArray` constructor by providing the appropriate function as the `unwrap` keyword argument.

It also supports a `TypeVar` as second argument instead of simply an `Int`. This is useful for creating complex composite types like in the example below.

```julia
@kwdef struct InnerField
    a::Float64 = rand()
    b::Complex{Float64} = rand(ComplexF64)
end

@kwdef struct CompositeStruct
    inner::InnerField = InnerField()
    int::Int = rand(1:10)
end

struct SAField{N}
    sa::sa_type(CompositeStruct, N; unwrap=T -> (T <: InnerField))
end

saf = SAField(StructArray([CompositeStruct() for i in 1:3, j in 1:2]; unwrap = T -> (T <: InnerField)))
```

where the `SAField` type has a fully concrete type for it's field `sa` which would be quite complex to specify manually
"""
sa_type(U::UnionAll, args...; kwargs...) = throw(ArgumentError("The provided eltype `$U` is not fully parametrized and would result in an abstract `StructArray` type"))


"""
    lin2db(x::Real)
Convert a number from linear to dB, assuming the input value represents a _power ratio_ (i.e. 10 == 10dB, see https://en.wikipedia.org/wiki/Decibel)
"""
lin2db(x::Real) = return 10log10(x)

"""
    db2lin(x::Real)
Convert a number from linear to dB, assuming the input value represents a _power ratio_ (i.e. `10 == 10dB`, see https://en.wikipedia.org/wiki/Decibel)
"""
db2lin(x::Real) = return exp10(x/10)

"""
    f2λ(f::Real)
Get the wavelength (in m) starting from the frequency (in Hz)
"""
f2λ(f::Real) = return CONSTANTS.c/f

"""
    λ2f(λ::Real)
Get the frequency (in Hz) starting from the wavelength (in m) 
"""
λ2f(λ::Real) = return CONSTANTS.c/λ
