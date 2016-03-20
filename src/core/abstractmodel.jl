#=
AbstractModel
=============
    An abstract financial optimization model, all concrete models in this package
    (including the customizable models) are children of this type.

    Methods:
    -------
    get_obj_fun(m) - retrieves the objective function of the model


Author: Fady Shoukry, Shen Wang
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
    Return the default constraints of a given Model
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

function optimize(m::AbstractModel, syms_dict=Dict{Symbol,Any}()::Dict; solver=JuMP.UnsetSolver())
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
    #redirect_stdout()
    m.status = JuMP.solve(JuMPModel)
    redirect_stdout(TT)

    # Report the status and the solution
    m.objVal = JuMP.getObjectiveValue(JuMPModel)
    m.weights = JuMP.getValue(JuMP.getVar(JuMPModel, :w))


    # return the weights

    return m.objVal, m.weights
end

function exportModelResultsToCSV{R<:Real}(result::Tuple{R,Array{R,1}}, path::AbstractString)

    df = DataFrames.DataFrame()
    df[:ObjValue_And_Weights] = vcat(result[1], result[2])

    DataFrames.writetable(path, df)
    return true
end

function Base.show(io::IO, m::AbstractModel)
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
