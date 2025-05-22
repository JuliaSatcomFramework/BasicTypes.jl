# Initialize the global TerminalLogger
const TERMINAL_LOGGER = Ref{TerminalLogger}()

# Define the NamedTuple containing the physical constants used in the simulation
const CONSTANTS = (
    q = 1.60217662e-19, # Electron Charge [Coulomb]
    h = 6.62607004e-34, # Planck's constant [m²⋅kg/s]
    c = 299_792_458, # Speed of light [m/s]
    Re = 6371e3, # Earth Radius [m]
    G = 6.67408e-11, # Gravitational constant [m3 kg-1 s-2]
    M = 5.972e24, # Earth mass [kg]
    k = 1.38064852e-23, # Boltzman Constant
)