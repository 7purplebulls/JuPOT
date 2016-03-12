#=
AbstractModel
=============
    An abstract financial optimization model, all concrete models in this package
    (including the customizable models) are children of this type.
    
    Methods:
    -------
    get_obj_fun(m) - retrieves the objective function of the model
    

Author: Fady Shoukry
Date: 01/23/2016
=#

abstract AbstractModel

function getObjective(m::AbstractModel)
    """
    Return the objective function of the given Model as an Expr type
    """
    m._objective
end

function getDefaultConstraints(m::AbstractModel)
    """
    Return the default constraints of a given Model as a ConstraintsContainer
    type
    """
    m._default_constraints
end

function getConstraints(m::AbstractModel)
    """
    Return an array of constraints as expressions
    """
    user_constraints = collect(values(m.constraints))
    all_constraints = vcat(m._default_constraints, user_constraints)
    all_constraints
end

function getSense(m::AbstractModel)
    """
    Return the Sense of the Model, Min or Max
    """
    m.sense
end

function getVariables(m::AbstractModel)
    """
    Return the list of variables in the model
    """
    m.vars
end

function optimize(m::AbstractModel, syms_dict=Dict{Symbol,Any}()::Dict, solver=JuMP.UnsetSolver())
    #TODO: Make this Parametrized?
    """
    Return the optimized weights of the model generated as an array of floats
    """
    constraints = getConstraints(m)

    vars = getVariables(m)
    sense = getSense(m)
    objective = getObjective(m)

    # Next, generate the function that will create the JuMP model
    modelGen = createJuMPModelGenFunc(vars, sense, objective, constraints, syms_dict)
    JuMPModel = modelGen(solver)
    # Once the constraints are added, and the objective is set, solve the model
    TT = STDOUT
    redirect_stdout()
    m.status = JuMP.solve(JuMPModel)
    redirect_stdout(TT)

    # Report the status and the solution
    m.objVal = JuMP.getObjectiveValue(JuMPModel)
    m.weights = JuMP.getValue(JuMP.getVar(JuMPModel, :w))


    # return the weights

    return m.objVal, m.weights
end

#TODO: Select one of the two

function exportModelObjValAndWeightsToCSV(m::AbstractModel, path::AbstractString)

    if  any(isnan,m.weights) || any(isnan, m.objVal)
        #Weights and Obj Val is still NaN, user has not run optimize properly
        warn("Model has not been Optimized")
        return false
    end

    df = DataFrames.DataFrame()
    df[:ObjValue_And_Weights] = vcat(m.objVal, m.weights)

    DataFrames.writetable(path, df)
    return true

end

function exportModelResultsToCSV{R<:Real}(result::Tuple{R,Array{R,1}}, path::AbstractString)

    df = DataFrames.DataFrame()
    df[:ObjValue_And_Weights] = vcat(result[1], result[2])

    DataFrames.writetable(path, df)
    return true
end
