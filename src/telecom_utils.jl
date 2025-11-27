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