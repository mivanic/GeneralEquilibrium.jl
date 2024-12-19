# GeneralEquilibrium.jl

[![Build Status](https://github.com/mivanic/GeneralEquilibrium.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/mivanic/GeneralEquilibrium.jl/actions/workflows/CI.yml?query=branch%3Amaster)

## Purpose of the package

The purpose of this package is to allow CGE modelers to run general equilibrium models in a single framework.

Module `GeneralEquilibrium` has several functions:

- provide some common functions used in CGE models, e.g., CDE, CES, CET functions, in submodule `FunctionLibrary`
- provide a library of CGE models in submodule `ModelLibrary` (that can be expanded)

The current version contains a single model GTAP version 7 expressed in levels as submodule `GTAPv7`

## Running GTAPv7 model

To run the GTAPv7 model, you need to follow the following steps:

- Get GTAP sets, data and parameters prepared for version 7 of the GTAP model
    - The sets, data and parameters need to be provided as a dictionary with the correct keys matching the headers of the model file for GEMPACK in lower case. For example, the data should contain key "vfob" with a three dimensional array with the value of bilateral trade measured FOB
    - If you are interested in actual GTAP data, you may obtain a free dataset from [the GTAP Center's website](https://www.gtap.agecon.purdue.edu/)
    - To turn a Fortran-style HAR file into a Julia dictionary, you may use package [HeaderArrayFile](https://github.com/mivanic/HeaderArrayFile.jl)
    - You may either aggregate your data outside module `GTAPv7`, e.g., by using GTAPAgg or FlexAgg programs also distributed by the GTAP Center, or you can use function `aggregate_data` in model `GTAPv7` as explained below

- To aggregate GTAP data in module `GTAPv7`, you can run function `aggregate_data(; hData, hParameters, hSets, comMap, regMap, endMap)` with the following arguments:
    - `hData`: a Dict object with the keys appropriate for the GTAPv7 model data (e.g., "vfob", "evos", etc.)
    - `hParameters`: a Dict object with the keys appropriate for the GTAPv7 model parameters (e.g., "esbq", etc.)
    - `comMap`: a Named Vector which maps original commodities to the new ones 
    - `regMap`: a Named Vector which maps original regions to the new ones
    - `endMap`: a Named Vector which maps original endowments to the new ones
        
## Aggregating the data

```
# Use packages HeaderArrayFile and NamedArrays to process the initial data
using HeaderArrayFile, NamedArrays

# Load the disaggregated data (e.g., from FlexAgg)
parameters = HeaderArrayFile.readHar("./gsdfpar.har")
data = HeaderArrayFile.readHar("./gsdfdat.har")
sets = HeaderArrayFile.readHar("./gsdfset.har")

# Aggregate the data

## Prepare the mapping vectors
## You can start by reading the regions, commodities and endowments from the disaggregated data and modifying them
regMap = NamedArray(sets["reg"], sets["reg"])
regMap[1:3] .= "oceania"
regMap[4:27] .= "asia"
regMap[28:55] .= "americas"
regMap[56:82] .= "eu"
regMap[83:98] .= "oeurope"
regMap[99:121] .= "mena"
regMap[122:160] .= "ssafrica"


comMap = NamedArray(copy(sets["comm"]), copy(sets["comm"]))
comMap[1:8] .= "crops"
comMap[9:12] .= "animals"
comMap[13:18] .= "extract"
comMap[19:26] .= "food"
comMap[27:45] .= "manuf"
comMap[46:65] .= "svces"

endMap = NamedArray(copy(sets["endw"]), copy(sets["endw"]))
endMap[:] .= "other"
endMap[1:1] .= "land"
endMap[[2,5]] .= "sklabor"
endMap[[3,4,6]] .= "unsklabor"
endMap["capital"] = "capital"

using GeneralEquilibrium.ModelLibrary.GTAPv7

# Do the aggregation
(; hData, hParameters, hSets) = GTAPv7.aggregate_data(hData=data, hParameters=parameters, hSets=sets, comMap=comMap, regMap=regMap, endMap=endMap)

```

# Generating starting values

```
# Starting data and parameters
(; sets, parameters, data, calibrated_parameters, fixed) = GTAPv7.generate_starting_values(hSets=hSets, hData=hData, hParameters=hParameters)
start_data = copy(data)
start_calibrated_parameters = copy(calibrated_parameters)
```

# Calibrate the data and parameters

```
(; data, calibrated_parameters) = GTAPv7.model(sets=sets, data=start_data, parameters=parameters, calibrated_parameters=start_calibrated_parameters, fixed=fixed, hData=hData, calibrate=true, max_iter=200)

calibrated_data = copy(data)
calibrated_calibrated_parameters = copy(calibrated_parameters)
```


# Running baseline scenario (the world before the shock)

```
(; data, calibrated_parameters) = GTAPv7.model(sets=sets, data=calibrated_data, parameters=parameters, calibrated_parameters=calibrated_calibrated_parameters, fixed=fixed, hData=hData, calibrate=false, max_iter = 20)

# Let's save the state of the world before the simulation
data0 = copy(data)
```

# Running the scenario (the world after the shock)

```
# Set the tariff on crops from ssafrica to eu to 1.2 (20 percent)
data["tms"]["crops", "ssafrica", "eu"] = 1.2

# Run the model
(; data, calibrated_parameters) = GTAPv7.model(sets=sets, data=data, parameters=parameters, calibrated_parameters=calibrated_calibrated_parameters, fixed=fixed, hData=hData, calibrate=false, max_iter=20)

# Save the world after the simulation
data1 = copy(data)
```

# Analyzing the results

```
# Show the change in exports (percent)
((data1["qxs"]./data0["qxs"])[:, :, "eu"] .- 1) .* 100

```




