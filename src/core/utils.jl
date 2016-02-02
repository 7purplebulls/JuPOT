#=

utils.jl
========
    A collection of useful methods that are used in the module.

    Methods:
    -------


Author: Fady Shoukry
Date: 01/30/2016
=#

symReplace!(ex, s, v) = ex
symReplace!(ex::Symbol, s, v) = s == ex ? v : ex
function symReplace!(ex::Expr, s, v)
    """
    These methods allow us to substitute a single symbol (s) in an expression with
    some value (v)
    """
    for i=1:length(ex.args)
        ex.args[i] = symReplace!(ex.args[i], s, v)
    end
    ex
end

function symReplaceAll!{T<:Any}(exprs::Array{Expr}, d::Dict{Symbol}{T})
    """
    Replace all symbols given in an a dictionary with their corresponding values
    in an array of expressions
    """
    for ex in exprs
        for (k, v) in d
            symReplace!(ex, k, v)
        end
    end
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

function createJuMPModelGenFunc(vars::Array{Expr}, sense::Symbol, 
    objective::Expr, constraints::Array{Expr})
    """
    Dynamically generate and return an anonymous function that creates 
    and returns the final JuMP model
    """
    model_sym = :model
    objective_ex = :(JuMP.@setObjective($model_sym, $sense, $objective))
    vars_blk = createVarsBlock(model_sym, vars)
    constraints_blk = createConstraintsBlock(model_sym, constraints)
    @eval function (solver)
        $model_sym = JuMP.Model(solver = solver)
        $vars_blk
        $objective_ex
        $constraints_blk
        $model_sym
    end
end

