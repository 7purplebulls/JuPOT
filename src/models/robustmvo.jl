#=
RobustMVO
=========
Robust Mean-Variance Optimization Model


Author: Azamat Berdyshev
Date: 02/03/2016
=#

type RobustMVO{R<:Real, S<:AbstractString} <: AbstractModel
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
    function RobustMVO(assets::AssetsCollection{R, S},
                        r_min::R,
                        constraints::Dict{Symbol,Expr},
                        uncertaintySet::Matrix{R},
                        uncertaintySetSize::R,
                        short_sale::Bool)

        n = length(assets)
        Σ = getCovariance(assets)
        μ = getReturns(assets)
        Θ = uncertaintySet
        ϵ = uncertaintySetSize

        # if no short sale => add corresponding constraint
        if short_sale
            vars = [:(w[1:$n])]
        else
            vars = [:(w[1:$n] >= 0)]
        end

        _objective = :(dot(w,$Σ*w))

        _default_constraints = [:(dot($μ,w) ≥ $r_min),
                                :(dot(ones($n),w) == 1),
                                :(dot(w,$Θ*w) ≤ $ϵ)]

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
RobustMVO{R<:Real, S<:AbstractString}(
            assets::AssetsCollection{R, S},
            r_min::R,
            constraints=Dict{Symbol,Expr}()::Dict{Symbol,Expr};
            uncertaintySet=diagm(diag(getCovariance(assets)))::Matrix{R},
            uncertaintySetSize=(dot(ones(length(assets)), uncertaintySet*ones(length(assets)))/length(assets)^2)::R,
            short_sale=false::Bool) = RobustMVO{R, S}(
                                                assets,
                                                r_min,
                                                constraints,
                                                uncertaintySet,
                                                uncertaintySetSize,
                                                short_sale)
