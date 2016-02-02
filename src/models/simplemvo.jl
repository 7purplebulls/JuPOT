type SimpleMVO <: AbstractModel
    sense::Symbol
    vars::Vector{Expr}
    _objective::Expr
    _default_constraints::Vector{Expr}
    constraints::Dict{Symbol,Expr}
    assets::AssetsCollection

    # Constructor
    function SimpleMVO{T1<:Real, T2<:AbstractString}(
                        assets::AssetsCollection{T1, T2},
                        r_min::Float64,
                        constraints=Dict{Symbol,Expr}()::Dict{Symbol,Expr},
                        short_sale=false::Bool)

        n = length(assets)
        Σ = assets.covariance
        μ = assets.returns

        # if no short sale => add corresponding constraint
        if short_sale
            vars = [:(w[1:$n])]
        else
            vars = [:(w[1:$n] >= 0)]
        end

        _objective = :(dot(w,$Σ*w))
        
        _default_constraints = [:(dot($μ,w) ≥ $r_min), :(dot(ones($n),w) == 1)]

        new(:Min,
            vars,
            _objective,
            _default_constraints,
            constraints,
            assets)
    end
end

