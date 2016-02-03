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

function optimize{T<:Any}(m::AbstractModel, syms_dict::Dict{Symbol}{T}, solver=JuMP.UnsetSolver())
    """
    Return the optimized weights of the model generated as an array of floats
    """
    # First we replace all symbols in the constraints with their values
    constraints = getConstraints(m)
    symReplaceAll!(constraints, syms_dict)
    # Get all the variables of the model
    vars = getVariables(m)
    # Extract the objective function and the sense
    sense = getSense(m)
    objective = getObjective(m)

    # Next, generate the function that will create the JuMP model
    modelGen = createJuMPModelGenFunc(vars, sense, objective, constraints)
    JuMPModel = modelGen(solver)
    # Once the constraints are added, and the objective is set, solve the model
    m.status = JuMP.solve(JuMPModel)

    # Report the status and the solution
    m.objVal = JuMP.getObjVal(m)
    m.weights = JuMP.getVal(m, :w)

    # return the weights
    m.weights
end
