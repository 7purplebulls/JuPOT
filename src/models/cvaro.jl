#=
CVaRO
=========
    CVaR Optimization Model


Author: Azamat Berdyshev
Date: 15/03/2016
=#

type CVaRO{R<:Real, S<:AbstractString} <: AbstractModel
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
    function CVaRO(assets::AssetsCollection{R, S},
                   losses::Matrix{R},
                   constraints::Dict{Symbol,Expr},
                   α::R,
                   short_sale::Bool)

    # n - number of assets
    # k - number of Monte-Carlo Scenarios
    # α - CVaR level
    # losses - Monte-Carlo sample of losses for every asset in every scenario

        (k, n) = length(assets)

        # if no short sale => add corresponding constraint
        if short_sale
            vars = [:(w[1:$n])]
        else
            vars = [:(w[1:$n] >= 0)]
        end
        push!(vars, :(y[1:$k] >= 0))
        push!(vars, :q)

        _objective = :(q + sum(y)/($k*(1-$α)))

        _default_constraints = [:($losses*w - q*ones($k) - y .≤ 0),
                                :(dot(ones($n),w) == 1)]

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
CVaRO{R<:Real, S<:AbstractString}(
            assets::AssetsCollection{R, S},
            losses::Matrix{R},
            constraints=Dict{Symbol,Expr}()::Dict{Symbol,Expr};
            alpha=.95::R,
            short_sale=false::Bool) = CVaRO{R, S}(assets,
                                                  losses,
                                                  constraints,
                                                  alpha,
                                                  short_sale)
