#=

utils.jl
========
    A collection of useful methods that are used in the module.

    Methods:
    -------


Author: Fady Shoukry
Date: 01/30/2016
=#
function createSymsBlock{T<:Any}(modelname::Symbol, syms_dict::Dict{Symbol}{T})
    """
    Return a dynamically generated block of code that, when evaluated, will
    define variables for each key in syms_dict
    """
    blk = Expr(:block)
    for (key,val) in syms_dict
        push!(blk.args, :($key = $val))
    end
    blk
end

function createConstraintsBlock(modelname::Symbol, constraints::Array{Expr})
    """
    Return a dynamically generated block of code that, when evaluated, will add
    all the constraints to the model required
    """
    blk = Expr(:block)
    # First replace all symbols
    for expr in constraints
        str = string(expr)
        push!(blk.args, quote
                            try
                                JuMP.@addConstraint($modelname, $expr)
                            catch e
                                JuMP.@addNLConstraint($modelname, $expr)
                                warn($str, " is a non-linear constraint")
                            end
                        end)   
    end
    blk
end

function createVarsBlock(modelname::Symbol, vars::Array{Expr})
    """
    Return a dynamically generated block of code that, when evaluated, will add
    all the variables to the model required
    """
    blk = Expr(:block)
    # First replace all symbols
    for var in vars 
        push!(blk.args, :(JuMP.@defVar($modelname, $var))) 
    end
    blk
end

function createJuMPModelGenFunc{T<:Any}(vars::Array{Expr}, sense::Symbol, 
    objective::Expr, constraints::Array{Expr}, syms_dict::Dict{Symbol}{T})
    """
    Dynamically generate and return an anonymous function that creates 
    and returns the final JuMP model
    """
    model_sym = :model
    syms_blk = createSymsBlock(model_sym, syms_dict)
    objective_ex = :(JuMP.@setObjective($model_sym, $sense, $objective))
    vars_blk = createVarsBlock(model_sym, vars)
    constraints_blk = createConstraintsBlock(model_sym, constraints)
    @eval function (solver)
        $model_sym = JuMP.Model(solver = solver)
        $syms_blk
        $vars_blk
        $objective_ex
        $constraints_blk
        $model_sym
    end
end

