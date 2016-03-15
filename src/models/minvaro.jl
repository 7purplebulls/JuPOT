#=
MinVarO
=========
    Minimum-Variance Optimization Model


Author: Azamat Berdyshev
Date: 15/03/2016
=#

type MinVarO{R<:Real, S<:AbstractString} <: AbstractModel
    sense::Symbol
    vars::Vector{Expr}
    _objective::Expr
    _default_constraints::Vector{Expr}
    constraints::Dict{Symbol,Expr}
    assets::AssetsCollection{R,S}
    objVal::R
    weights::Vector{R}
    status::Symbol

    # Inner constructor
    function MinVarO(assets::AssetsCollection{R, S},
                    constraints::Dict{Symbol,Expr}=Dict{Symbol,Expr}(),
                    short_sale::Bool=false)

        n = length(assets)
        Σ = getCovariance(assets)

        # if no short sale => add corresponding constraint
        if short_sale
            vars = [:(w[1:$n])]
        else
            vars = [:(w[1:$n] >= 0)]
        end

        _objective = :(dot(w,$Σ*w))

        _default_constraints = [:(dot(ones($n),w) == 1)]

        new(:Min,
            vars,
            _objective,
            _default_constraints,
            constraints,
            assets,
            NaN,
            fill(NaN,n),
            :Unsolved)
    end
end


# Outer constructor
MinVarO{R<:Real, S<:AbstractString}(
            assets::AssetsCollection{R, S},
            constraints=Dict{Symbol,Expr}()::Dict{Symbol,Expr};
            short_sale=false::Bool) = MinVarO{R, S}(
                                                assets,
                                                constraints,
                                                short_sale)
