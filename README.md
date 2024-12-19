# GeneralEquilibrium

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
    - If you are interested in actual GTAP data, you may obtain a free dataset from [the GTAP Center's](website https://www.gtap.agecon.purdue.edu/)
    - To turn a Fortran-style HAR file into a Julia dictionary, you may use package [HeaderArrayFile](https://github.com/mivanic/HeaderArrayFile.jl)
    - You may either aggregate your data outside module `GTAPv7`, e.g., by using GTAPAgg or FlexAgg programs also distributed by the GTAP Center, or you can use function `aggregate_data` in model `GTAPv7` as explained below

- To aggregate GTAP data in module `GTAPv7`, you can run function `aggregate_data(; hData, hParameters, mapping)` with the following arguments:
    - `hData`: a Dict object with the keys appropriate for the GTAPv7 model data (e.g., "vfob", "evos", etc.)
    - `hParameters`: a Dict object with the keys appropriate for the GTAPv7 model parameters (e.g., "esbq", etc.)
    - `mapping`: a Dict object with four keys:
        - `comMap`: a Named Vector which maps original commodities to the new ones 
        - `regMap`: a Named Vector which maps original regions to the new ones
        - `endMap`: a Named Vector which maps original endowments to the new ones
        - `marMap`: a Named Vector which maps original margin commodities to the new ones


