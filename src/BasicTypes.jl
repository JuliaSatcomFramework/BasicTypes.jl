module BasicTypes

using Unitful: °, rad, Quantity, Length
using TOML: TOML
using TerminalLoggers: TerminalLogger, TerminalLoggers

include("basics.jl")
export ValidAngle, ValidDistance, Constants, NotProvided, NotSimulated, TERMINAL_LOGGER, PKG_VERSION, SCRATCH_DIR, Deg

end
