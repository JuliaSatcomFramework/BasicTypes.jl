module CoordRefSystemsExt

using BasicTypes: BasicTypes, valuetype, change_valuetype
using CoordRefSystems: CRS, mactype, reconstruct, raw

BasicTypes.valuetype(c::Type{<:CRS}) = mactype(c)
BasicTypes.change_valuetype(T::Type{<:AbstractFloat}, c::CRS) = reconstruct(typeof(c), map(T, raw(c)))

end