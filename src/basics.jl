## Angle Types
const UnitfulAngleType = Union{typeof(°),typeof(rad)}
const UnitfulAngleQuantity = Quantity{<:Real,<:Any,<:UnitfulAngleType}
const ValidAngle = Union{UnitfulAngleQuantity,Real}
const ValidDistance = Union{Length,Real}

# Easily identify a degree quantity type with parametric number type
const Deg{T} = Quantity{T,NoDims,typeof(°)}

# Define the NamedTuple containing the physical constants used in the simulation
const Constants = (
    q=1.60217662e-19, # Electron Charge [Coulomb]
    h=6.62607004e-34, # Planck's constant [m²⋅kg/s]
    c=299_792_458, # Speed of light [m/s]
    Re=6371e3, # Mean Earth Radius [m]
    a=6378137, # [m] WGS84 semi-major axis
    b=6356752.315, # [m] WGS84 semi-minor axis    G = 6.67408e-11, # Gravitational constant [m3 kg-1 s-2]
    M=5.972e24, # Earth mass [kg]
    k=1.38064852e-23, # Boltzman Constant
)

"""
    NotProvided

Type used to specify that a field is not provided. This is useful when a field
is optional and the user wants to specify that it is not provided, instead of
using `nothing` which could be a valid value for the field.
"""
struct NotProvided end

Base.length(::NotProvided) = 0
Base.iterate(::NotProvided, state::Int=1) = nothing
Base.eltype(::NotProvided) = Union{}
Base.keys(::NotProvided) = Base.OneTo(0) # Required for `eachindex`

"""
    NotSimulated <: Exception

Custom exception type to indicate that a certain operation or function is not
simulated. This exception can be used to signal that a particular feature or
functionality is not implemented or available in the current simulation context.
"""
struct NotSimulated end

Base.length(::NotSimulated) = 0
Base.iterate(::NotSimulated, state::Int=1) = nothing
Base.eltype(::NotSimulated) = Union{}
Base.keys(::NotSimulated) = Base.OneTo(0) # Required for `eachindex`

# Initialize the global TerminalLogger and Scratch Space
const TERMINAL_LOGGER = Ref{TerminalLogger}()
const PKG_VERSION = VersionNumber(TOML.parsefile(Base.current_project(@__DIR__))["version"]) # Get the current package version at compile-time to be used as name for the scratch space.
const SCRATCH_DIR = Ref{String}()


