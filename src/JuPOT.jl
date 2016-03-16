module JuPOT

import JuMP
import DataFrames
# We extend length so it needs to be imported

import Base: length, show

export AbstractModel,
       optimize,
       AssetsCollection,
       SimpleMVO,
       RobustMVO,
       CVaRO,
       MinVarO,
       getAssetAndReturnsFromCSV,
       getReturns,
       setReturns,
       getCovariance,
       getCoVarForAssetPair,
       getVarForAsset,
       getReturnForAsset,
       setReturns,
       setCovariance,
       setCoVarForAssetPair,
       setVarForAsset,
       setReturnForAsset,
       getNames,
       setNames,
       exportModelResultsToCSV

include("core/utils.jl")
include("core/assetscollection.jl")
include("core/abstractmodel.jl")

include("models/simplemvo.jl")
include("models/robustmvo.jl")
include("models/minvaro.jl")
include("models/cvaro.jl")
end
