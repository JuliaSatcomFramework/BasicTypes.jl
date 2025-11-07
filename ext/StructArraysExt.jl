module StructArraysExt

using StructArrays: StructArrays, StructArray
using BasicTypes: BasicTypes, sa_type

function BasicTypes.sa_type(DT::DataType, N::Union{Int,TypeVar}; unwrap=T -> false)
    # Create the NamedTuple for the StructArray type parameter
    f = T -> unwrap(T) ? sa_type(T, N; unwrap) : Array{T,N} # Eventually unwrap like in the StructArray constructor
    TT = Tuple{map(f, fieldtypes(DT))...}
    NT = if DT <: Tuple
        TT
    else
        NamedTuple{fieldnames(DT),TT}
    end
    return StructArray{DT,N,NT,Int}
end

end