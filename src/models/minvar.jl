#=
SimpleMVO
=========
    Mean-Variance Optimization Model


Author: Azamat Berdyshev, Shen Wang
Date: 01/30/2016
=#

type SimpleMVO{R<:Real, S<:AbstractString} <: AbstractModel
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
    function SimpleMVO(assets::AssetsCollection{R, S},
                        r_min::R,
                        constraints::Dict{Symbol,Expr}=Dict{Symbol,Expr}(),
                        short_sale::Bool=false)

        n = length(assets)
        Σ = getCovariance(assets)
        μ = getReturns(assets)

        # if no short sale => add corresponding constraint
        if short_sale
            vars = [:(w[1:$n])]
        else
            vars = [:(w[1:$n] >= 0)]
        end

        _objective = :(dot(w,$Σ*w))

        _default_constraints = [:(dot($μ,w) ≥ $r_min),
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

function Base.show(io::IO, m::SimpleMVO)
    # print(io, "\n Sense: $(m.sense) \n")
    print(io, "\n Variables: \n")
    for vars in m.vars
        print(io, vars, "\n")
    end

    # print(io, "\n Objective Function: \n  $(m._objective) \n")

    print(io, "\n Constraints: \n")

    constraint_key_array = collect(keys(m.constraints))
    constraint_value_array = collect(values(m.constraints))
    constraint_length = length(constraint_key_array)
    constraint_df = DataFrames.DataFrame(Keys = Symbol[], Constraint = Expr[])


    def_constraint_df = DataFrames.DataFrame(Default = AbstractString[], Constraint = Expr[])

    default_constraints_value = m._default_constraints
    default_constraints_length = length(default_constraints_value)

    for i = 1:default_constraints_length
        push!(def_constraint_df, ["default", default_constraints_value[i]])
    end

    for i = 1:constraint_length
        push!(constraint_df, [constraint_key_array[i], constraint_value_array[i]])
    end

    print(io, constraint_df)

    print(io, "\n\n")

    # print(io, def_constraint_df)

    # print(io, "\n\n")

    print(io, "\n Assets: \n $(m.assets) \n")

end

# Outer constructor
SimpleMVO{R<:Real, S<:AbstractString}(
            assets::AssetsCollection{R, S},
            r_min::R,
            constraints=Dict{Symbol,Expr}()::Dict{Symbol,Expr};
            short_sale=false::Bool) = SimpleMVO{R, S}(
                                                assets,
                                                r_min,
                                                constraints,
                                                short_sale)
