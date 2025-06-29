module MeshesExt

using BasicTypes: BasicTypes, valuetype, change_valuetype
using Meshes: Meshes, Point, coords, Domain, Geometry, crs

BasicTypes.valuetype(P::Type{<:Point}) = valuetype(crs(P))
BasicTypes.change_valuetype(T::Type{<:AbstractFloat}, p::Point) = coords(p) |> change_valuetype(T) |> Point

BasicTypes.valuetype(x::Union{Type{<:Geometry}, Type{<:Domain}}) = crs(x) |> valuetype

# We don't explicitly define change_valuetype for Geometry/Domain as that would need to allocate new vectors (nested) for all the rings in the geometry. We leave this to more explicit functions

end