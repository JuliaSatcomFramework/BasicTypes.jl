
const Time{T} = Union{DimensionQuantity{Unitful.𝐓, T}, Dates.FixedPeriod}
raw_time(x::Time) = ustrip(enforce_unit(base_unit(u"s"), x))
