module BasicTypes

using Unitful: °, rad, Quantity, Length, NoDims
using TerminalLoggers: TerminalLogger, TerminalLoggers

include("basics.jl")
export ValidAngle, ValidDistance, Constants, NotProvided, NotSimulated, TERMINAL_LOGGER, Deg

end
