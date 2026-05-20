module StructArraysExt

using StructArrays: StructArrays, StructArray, staticschema
using BasicTypes: BasicTypes, sa_type

function BasicTypes.sa_type(DT::DataType, N::Union{Int,TypeVar}; unwrap=T -> false)
    # Create the NamedTuple for the StructArray type parameter
    f = T -> unwrap(T) ? sa_type(T, N; unwrap) : Array{T,N} # Eventually unwrap like in the StructArray constructor
    schema = StructArrays.staticschema(DT)
    TT = Tuple{map(f, fieldtypes(schema))...}
    NT = if schema <: Tuple
        TT
    else
        NamedTuple{fieldnames(schema),TT}
    end
    return StructArray{DT,N,NT,Int}
end

end