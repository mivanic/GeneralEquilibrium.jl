function generate_starting_values(; hSets, hData, hParameters)

    (sets) = prepare_sets(hSets=hSets, hParameters=hParameters)

    (parameters) = prepare_parameters(hParameters=hParameters)

    data = prepare_initial_values(sets=sets, hData=hData, hParameters=hParameters)

    data = prepare_taxes(data=data, hData=hData)

    data = prepare_quantities(data=data, parameters=parameters, sets=sets, hData=hData)

    (; parameters, data) = prepare_initial_calibrated_parameters(data=data, sets=sets, parameters=parameters, hData=hData)

    # Prepare a set of fixed parameters
    fixed = Dict(
        k => NamedArray(trues(size(data[k])), names(data[k])) for (k) in ["to", "tfe", "tx", "txs", "tm", "tms", "tfd", "tfm", "tpd", "tpm", "tgd", "tgm", "tid", "tim", "tinc", "qesf", "qe", "ppa"]
    )

    fixed["ppa"][:, :] .= false
    ## The price of the first commodity in the first region is fixed
    fixed["ppa"][comm[1], reg[1]] = true

    # Calculate calibrated_parameter initial values

    calibrated_parameters = Dict(String(k) => parameters[k] for k ∈ ["α_pca", "α_qca", "α_qes2", "α_qfa", "α_qfdqfm", "α_qfe", "α_qga", "α_qgdqgm", "α_qia", "α_qidqim", "α_qintva", "α_qinv", "α_qpdqpm", "α_qst", "α_qtmfsd", "α_qxs", "β_qpa", "γ_pca", "γ_qca", "γ_qes2", "γ_qfa", "γ_qfdqfm", "γ_qfe", "γ_qga", "γ_qgdqgm", "γ_qia", "γ_qidqim", "γ_qintva", "γ_qpdqpm", "γ_qst", "γ_qxs", "σyg", "σyp", "δ"])

    return (sets=sets, parameters=parameters, data=data, calibrated_parameters=calibrated_parameters, fixed=fixed)

end