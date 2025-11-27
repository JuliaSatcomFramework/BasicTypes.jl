module BasicTypes

using Logging: Logging, current_logger, NullLogger
using LoggingExtras: LoggingExtras, TeeLogger
using Base.ScopedValues: ScopedValues, ScopedValue
using StaticArrays: StaticArrays, SVector
using TerminalLoggers: TerminalLoggers, TerminalLogger
using Unitful: Unitful, °, rad, Quantity, Length, NoDims, m, km, @u_str, 
    ustrip, uconvert, unit, Units
import Dates

# Exports from deps
export °, km, @u_str, ustrip

include("types.jl")
export ExtraOutput, SkipChecks

include("type_aliases.jl")
public PS, Point, Point2D, Point3D

include("optionals.jl")
export NotProvided, NotSimulated, NotSet, Optional, isnotset, isprovided, issimulated, fallback, @fallback, unwrap_optional
public bypass_bottom

include("units.jl")
export Angle, Distance, Speed, Mass, Duration, Temperature, Frequency, Power, AngularRate
export base_unit, enforce_unit, enforce_unitless, raw_angle, raw_distance, raw_mass, raw_duration, assert_angle_limit
public Meter, Degree, Radian

include("constants.jl")
export CONSTANTS

include("functions.jl")
export terminal_logger, progress_logger, basetype, sa_type, db2lin, lin2db, f2λ, λ2f

include("macros.jl")
export @define_kwargs_defaults, @add_kwargs_defaults

include("valuetype.jl")
export valuetype, change_valuetype, common_valuetype, promote_valuetype

include("getproperty_oftype.jl")
export PropertyOrNothing, getproperty_oftype

include("deprecated.jl")
export Time, raw_time

end