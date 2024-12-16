module GeneralEquilibrium

using JuMP, NamedArrays

export agg, aggComb

include("agg.jl")
include("aggComb.jl")

function solve(; model, sets, data, parameters, calibrated_parameters)
    return model(; sets=sets, data=data, parameters=parameters, calibrated_parameters, calibrate=false)
end

function calibrate(; model, sets, data, parameters, calibrated_parameters)
    return model(; sets=sets, data=data, parameters=parameters, calibrated_parameters, calibrate=true)
end

module FunctionLibrary

include("./functions/cde.jl")
include("./functions/ces.jl")

end


module ModelLibrary
import ..GeneralEquilibrium, ..FunctionLibrary

module GTAPv7

using NamedArrays, Ipopt, JuMP
import ..ModelLibrary, ..GeneralEquilibrium
import ..FunctionLibrary: cde

include("./models/GTAPv7/helpers/prepare_sets.jl")
include("./models/GTAPv7/helpers/prepare_parameters.jl")
include("./models/GTAPv7/helpers/prepare_initial_values.jl")
include("./models/GTAPv7/helpers/prepare_taxes.jl")
include("./models/GTAPv7/helpers/prepare_quantities.jl")
include("./models/GTAPv7/helpers/prepare_initial_calibrated_parameters.jl")

# The main model function
include("./models/GTAPv7/model.jl")

# Function that aggregates data on the assumption that the standard GTAP data are provided (based on headers)
include("./models/GTAPv7/aggregate_data.jl")

# Function that calculates starting values for data and parameters
include("./models/GTAPv7/generate_starting_values.jl")

end

end


end
