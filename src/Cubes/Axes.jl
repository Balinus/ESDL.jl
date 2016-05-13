module Axes
export CubeAxis, TimeAxis, VariableAxis, LonAxis, LatAxis, CountryAxis, SpatialPointAxis,Axes
import NetCDF.NcDim
importall ..Cubes

abstract CubeAxis{T} <: AbstractCubeMem{T,1}
immutable TimeAxis <: CubeAxis{DateTime}
  values::Vector{DateTime}
end

immutable VariableAxis <: CubeAxis{UTF8String}
  values::Vector{UTF8String}
end

immutable LonAxis <: CubeAxis{Float64}
  values::FloatRange{Float64}
end
immutable LatAxis <: CubeAxis{Float64}
  values::FloatRange{Float64}
end
immutable SpatialPointAxis <: CubeAxis{Tuple{Float64,Float64}}
  values::Vector{Tuple{Float64,Float64}}
end
immutable CountryAxis<: CubeAxis{UTF8String}
  values::Vector{UTF8String}
end
Base.length(a::CubeAxis)=length(a.values)

axes(x::CubeAxis)=CubeAxis[x]
Base.ndims(::CubeAxis)=1

axname(a::CubeAxis)=split(string(typeof(a)),'.')[end]
axunits(::CubeAxis)="unknown"
axname(::LonAxis)="longitude"
axunits(::LonAxis)="degrees_east"
axname(::LatAxis)="latitude"
axunits(::LatAxis)="degrees_north"
axname(::TimeAxis)="time"

getSubRange(x::CubeAxis,i)=x[i],nothing
getSubRange(x::TimeAxis,i)=sub(x,i),nothing

function NcDim(a::TimeAxis,start::Integer,count::Integer)
  if start + count - 1 > length(a.values)
    count = oftype(count,length(a.values) - start + 1)
  end
  tv=a.values[start:(start+count-1)]
  starttime=a.values[1]
  startyear=Dates.year(starttime)
  atts=Dict{Any,Any}("units"=>"days since $startyear")
  d=map(x->(x-starttime).value/86400000,tv)
  NcDim(axname(a),length(d),values=d,atts=atts)
end
#Default constructor
NcDim(a::CubeAxis,start::Integer,count::Integer)=NcDim(axname(a),count,values=collect(a.values[start:(start+count-1)]),atts=Dict{Any,Any}("units"=>axunits(a)))
NcDim(a::VariableAxis,start::Integer,count::Integer)=NcDim(axname(a),count,values=Float64[start:(start+count-1);],atts=Dict{Any,Any}("units"=>axunits(a)))


end