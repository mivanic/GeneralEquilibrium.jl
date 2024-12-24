function generate_starting_values(; hSets, hData, hParameters)

    (sets) = prepare_sets(hSets=hSets, hParameters=hParameters)

    (parameters) = prepare_parameters(hParameters=hParameters)

    data = prepare_initial_values(sets=sets, hData=hData, hParameters=hParameters)

    data = prepare_taxes(data=data, hData=hData)

    data = prepare_quantities(data=data, parameters=parameters, sets=sets, hData=hData)

    (; parameters, data) = prepare_initial_calibrated_parameters(data=data, sets=sets, parameters=parameters, hData=hData)

    # Prepare a set of fixed parameters
    (; comm, reg) = NamedTuple(Dict(Symbol(k) => sets[k] for k ∈ ["comm", "reg"]))
    fixed = Dict(
        k => NamedArray(trues(size(data[k])), names(data[k])) for (k) in ["to", "tfe", "tx", "txs", "tm", "tms", "tfd", "tfm", "tpd", "tpm", "tgd", "tgm", "tid", "tim", "tinc", "qesf", "qe", "ppa"]
    )

    fixed["ppa"][:, :] .= false
    ## The price of the first commodity in the first region is fixed
    fixed["ppa"][comm[1], reg[1]] = true

    # Calculate calibrated_parameter initial values
    return (sets=sets, parameters=parameters, data=data, fixed=fixed)

end