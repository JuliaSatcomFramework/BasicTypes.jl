module BasicTypes

using Logging: Logging, current_logger
using LoggingExtras: LoggingExtras, TeeLogger
using StaticArrays: StaticArrays, SVector
using TerminalLoggers: TerminalLoggers, TerminalLogger
using Unitful: Unitful, °, rad, Quantity, Length, NoDims, m, km, @u_str, ustrip, uconvert

# Exports from deps
export °, km, @u_str, ustrip

include("types.jl")
export ExtraOutput, NotSimulated, NotProvided

include("type_aliases.jl")
export UnitfulAngleQuantity, ValidAngle, ValidDistance, PS, Point, Point2D, Point3D, Deg, Rad, Met, Len, Optional

include("constants.jl")

include("functions.jl")
export to_meters, to_radians, to_degrees, terminal_logger, progress_logger

end
