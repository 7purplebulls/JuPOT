module JuPOT

import JuMP
import DataFrames
# We extend length so it needs to be imported
import Base.length
export AbstractModel, optimize, AssetsCollection, SimpleMVO, RobustMVO, 
getAssetAndReturnsFromCSV, getReturns, setReturns, getCovariance, getCoVarForAssetPair,
getVarForAsset, getReturnForAsset, 
setReturns, setCovariance, setCoVarForAssetPair,
setVarForAsset, setReturnForAsset, getNames, setNames, exportModelResultsToCSV

include("core/utils.jl")
include("core/assetscollection.jl")
include("core/abstractmodel.jl")
include("models/simplemvo.jl")
include("models/robustmvo.jl")

end
