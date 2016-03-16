#=

AssetsCollection
================
    A container to hold all information regarding the collection of assests to
    be optimized

    Methods:
    -------


Author: Fady Shoukry, Azamat Berdyshev, Shen Wang
Date: 01/23/2016
=#

type AssetsCollection{T1<:Real, T2<:AbstractString}
    # NOTE: All arrays in the collection are expected to have matching indices

    # A list of indicator strings for the assets in the collection
    names::Vector{T2}
    # A list of the expected returns of the assets in the collection
    returns::Vector{T1}
    # A covariance matrix for the assets in the collection
    covariance::Matrix{T1}

    function AssetsCollection(names, returns, covariance)
        # Do some validation work on the covariance matrix
        if !issym(covariance)
        # Make sure it's symmetric
            error("Covariance Matrix must be symmetric")
        elseif !isposdef(covariance)
        # Make sure it's positive semi-definite
            error("Covariance Matrix must be positive semi-definite")
        end
        n_cov = size(covariance, 1)
        n_ret = size(returns, 1)
        n_names = size(names, 1)
        # Make sure the size of the inputs match
        if n_cov != n_ret
            error("Covariance matrix size ($n_cov x $n_cov) and the length of
            returns ($n_ret) must be equal")
        elseif n_ret != n_names
            error("length of names ($n_names) and the length of
            returns ($n_ret) must be equal")
        end

        new(names, returns, covariance)
    end
end

AssetsCollection{T1<:Real, T2<:AbstractString}(names::Vector{T2},
    returns::Vector{T1}, covariance::Matrix{T1}) =
    AssetsCollection{T1, T2}(names, returns, covariance)

function length{T1<:Real,
    T2<:AbstractString}(assets::AssetsCollection{T1, T2})
    """
    Return the number of assets in the collection
    """
    size(assets.returns, 1)
end

function getReturnForAsset{T1<:Real, T2<:AbstractString}(
    assets::AssetsCollection{T1, T2}, name::AbstractString)
    """
    Access the expected return of a given asset by its name
    """
    idx = findfirst(assets.names, name)
    if idx == 0
        error("The asset collection has no asset named $name")
    end
    assets.returns[idx]
end

function setReturnForAsset{T1<:Real, T2<:AbstractString}(
    assets::AssetsCollection{T1, T2}, name::AbstractString, value)
    """
    Set the expected return of a given asset by its name
    """
    # First convert the value to the correct type
    value = convert(T1, value)
    idx = findfirst(assets.names, name)
    if idx == 0
        error("The asset collection has no asset named $name")
    end
    assets.returns[idx] = value
end

function getVarForAsset{T1<:Real, T2<:AbstractString}(
    assets::AssetsCollection{T1, T2}, name::AbstractString)
    """
    Access the variance of a given asset by its name
    """
    idx = findfirst(assets.names, name)
    if idx == 0
        error("The asset collection has no asset named $name")
    end
    assets.covariance[idx, idx]
end

function setVarForAsset{T1<:Real, T2<:AbstractString}(
    assets::AssetsCollection{T1, T2}, name::AbstractString, value)
    """
    Set the variance of a given asset by its name
    """
    # First convert the value to the correct type
    value = convert(T1, value)
    idx = findfirst(assets.names, name)
    if idx == 0
        error("The asset collection has no asset named $name")
    end
    saved_value = assets.covariance[idx, idx]
    assets.covariance[idx, idx] = value
    # Check to see if the positive semi-definitiveness has been violated
    if !isposdef(assets.covariance)
        assets.covariance[idx, idx] = saved_value
        error("The updated covariance matrix is no longer positive
        semi-definite")
    end
end

function getCoVarForAssetPair{T1<:Real, T2<:AbstractString}(
    assets::AssetsCollection{T1, T2}, asset1::AbstractString,
    asset2::AbstractString)
    """
    Access the covariance of 2 given assets by their names
    """
    idx_1 = findfirst(assets.names, asset1)
    idx_2 = findfirst(assets.names, asset2)
    if idx_1 == 0
        error("The asset collection has no asset named $asset1")
    elseif idx_2 == 0
        error("The asset collection has no asset named $asset2")
    end
    assets.covariance[idx_1, idx_2]
end

function setCoVarForAssetPair{T1<:Real, T2<:AbstractString}(
    assets::AssetsCollection{T1, T2}, asset1::AbstractString,
    asset2::AbstractString, value)
    """
    Set the covariance of 2 given assets by their names
    """
    # First convert the value to the correct type
    value = convert(T1, value)
    idx_1 = findfirst(assets.names, asset1)
    idx_2 = findfirst(assets.names, asset2)
    if idx_1 == 0
        error("The asset collection has no asset named $asset1")
    elseif idx_2 == 0
        error("The asset collection has no asset named $asset2")
    end
    saved_value = assets.covariance[idx_1, idx_2]
    assets.covariance[idx_1, idx_2] = value
    assets.covariance[idx_2, idx_1] = value
    # Check to see if the positive semi-definitiveness has been violated
    if !isposdef(assets.covariance)
        assets.covariance[idx_1, idx_2] = saved_value
        assets.covariance[idx_2, idx_1] = saved_value
        error("The updated covariance matrix is no longer positive
        semi-definite")
    end
end

function getCovariance{T1<:Real, T2<:AbstractString}(assets::AssetsCollection{T1, T2})
    return assets.covariance::Matrix{T1}
end

function setCovariance{T1<:Real, T2<:AbstractString}(assets::AssetsCollection{T1, T2}, covariance::Matrix{T1})
    # Perform validation of the covariance matrix
    n = length(assets)
    if n != size(covariance, 1)
        # Make sure it's the correct size
        error("Covariance Matrix must have size $n x $n")
    elseif !issym(covariance)
    # Make sure it's symmetric
        error("Covariance Matrix must be symmetric")
    elseif !isposdef(covariance)
    # Make sure it's positive semi-definite
        error("Covariance Matrix must be positive semi-definite")
    end

    assets.covariance = covariance
end

function getReturns{T1<:Real, T2<:AbstractString}(assets::AssetsCollection{T1, T2})
    return assets.returns::Vector{T1}
end

function setReturns{T1<:Real, T2<:AbstractString}(assets::AssetsCollection{T1, T2}, returns::Vector{T1})
    assets.returns = returns
end

function getNames{T1<:Real, T2<:AbstractString}(assets::AssetsCollection{T1, T2})
    return assets.names::Vector{T2}
end

function setNames{T1<:Real, T2<:AbstractString}(assets::AssetsCollection{T1, T2}, names::Vector{T2})
    assets.names = names
end

function Base.show(io::IO, a::AssetsCollection)

    a_length = length(a.names)
    a_df = DataFrames.DataFrame(Names = AbstractString[], Expected_Returns = Real[])

    for i = 1:a_length
        push!(a_df, [a.names[i], a.returns[i]])
    end

    print(io, a_df)
end

function getAssetAndReturnsFromCSV(filepath::AbstractString)
    asset_table = DataFrames.readtable(filepath, header=false)
    return vec(convert(Vector{ASCIIString}, asset_table[1])), vec(convert(Vector{Float64}, asset_table[2]))
end
