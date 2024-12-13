function aggregate_data(; data, parameters, mapping)

    # Read the data, parameters and mapping
    (; comMap, regMap, marMap, endMap, fixedMap) = NamedTuple(Dict(Symbol(k) => mapping[k] for k in keys(mapping)))

    # Generate the aggregated data
    dataAg =
        Dict(
            "vdpb" => GeneralEquilibrium.agg(data["vdpb"], [comMap, regMap]),
            "vmpb" => GeneralEquilibrium.agg(data["vmpb"], [comMap, regMap]),
            "vdpp" => GeneralEquilibrium.agg(data["vdpp"], [comMap, regMap]),
            "vmpp" => GeneralEquilibrium.agg(data["vmpp"], [comMap, regMap]),
            "vdgb" => GeneralEquilibrium.agg(data["vdgb"], [comMap, regMap]),
            "vmgb" => GeneralEquilibrium.agg(data["vmgb"], [comMap, regMap]),
            "vdgp" => GeneralEquilibrium.agg(data["vdgp"], [comMap, regMap]),
            "vmgp" => GeneralEquilibrium.agg(data["vmgp"], [comMap, regMap]),
            "vdib" => GeneralEquilibrium.agg(data["vdib"], [comMap, regMap]),
            "vmib" => GeneralEquilibrium.agg(data["vmib"], [comMap, regMap]),
            "vdip" => GeneralEquilibrium.agg(data["vdip"], [comMap, regMap]),
            "vmip" => GeneralEquilibrium.agg(data["vmip"], [comMap, regMap]),
            "vdfb" => GeneralEquilibrium.agg(data["vdfb"], [comMap, comMap, regMap]),
            "vmfb" => GeneralEquilibrium.agg(data["vmfb"], [comMap, comMap, regMap]),
            "vdfp" => GeneralEquilibrium.agg(data["vdfp"], [comMap, comMap, regMap]),
            "vmfp" => GeneralEquilibrium.agg(data["vmfp"], [comMap, comMap, regMap]),
            "evfb" => GeneralEquilibrium.agg(data["evfb"], [endMap, comMap, regMap]),
            "evfp" => GeneralEquilibrium.agg(data["evfp"], [endMap, comMap, regMap]),
            "evos" => GeneralEquilibrium.agg(data["evos"], [endMap, comMap, regMap]),
            "vmsb" => GeneralEquilibrium.agg(data["vmsb"], [comMap, regMap, regMap]),
            "vxsb" => GeneralEquilibrium.agg(data["vxsb"], [comMap, regMap, regMap]),
            "vfob" => GeneralEquilibrium.agg(data["vfob"], [comMap, regMap, regMap]),
            "vcif" => GeneralEquilibrium.agg(data["vcif"], [comMap, regMap, regMap]),
            "vtwr" => GeneralEquilibrium.agg(data["vtwr"], [marMap, comMap, regMap, regMap]),
            "vst" => GeneralEquilibrium.agg(data["vst"], [marMap, regMap]),
            "save" => GeneralEquilibrium.agg(data["save"], [regMap]),
            "vdep" => GeneralEquilibrium.agg(data["vdep"], [regMap]),
            "vkb" => GeneralEquilibrium.agg(data["vkb"], [regMap]),
            "maks" => GeneralEquilibrium.agg(data["maks"], [comMap, comMap, regMap]),
            "makb" => GeneralEquilibrium.agg(data["makb"], [comMap, comMap, regMap]))

    # Generate the aggregated parameters
    paramAg = Dict(
        ### "esbv" => GeneralEquilibrium.aggComb(params["esbv"], NamedArray(mapslices(sum, data["evfp"], dims=1)[1, :, :], names(params["esbv"])), [comMap, regMap]),
        "esbv" => GeneralEquilibrium.aggComb(params["esbv"], NamedArray(repeat(reshape(mapslices(sum, data["evfp"], dims=[1, 3])[1, :, 1], (length(comMap), 1)), inner=[1, length(regMap)]), names(params["esbv"])), [comMap, regMap]),
        "esbt" => GeneralEquilibrium.aggComb(params["esbt"], NamedArray(
                mapslices(sum, data["vdfp"], dims=1)[1, :, :]
                + mapslices(sum, data["vmfp"], dims=1)[1, :, :]
                + mapslices(sum, data["evfp"], dims=1)[1, :, :], names(params["esbt"])), [comMap, regMap]),
        "esbc" => GeneralEquilibrium.aggComb(params["esbt"], NamedArray(
                mapslices(sum, data["vdfp"], dims=1)[1, :, :] + mapslices(sum, data["vmfp"], dims=1)[1, :, :], names(params["esbv"])), [comMap, regMap]),
        "etrq" => GeneralEquilibrium.aggComb(params["etrq"], NamedArray(
                mapslices(sum, data["maks"], dims=1)[1, :, :], names(params["etrq"])), [comMap, regMap]),
        "esbq" => GeneralEquilibrium.aggComb(params["esbq"], NamedArray(
                mapslices(sum, data["maks"], dims=2)[:, 1, :], names(params["esbq"])), [comMap, regMap]),
        "esbg" => GeneralEquilibrium.aggComb(params["esbg"], NamedArray(mapslices(sum, data["vdgp"] .+ data["vmgp"], dims=1)[1, :], names(params["esbg"])[1]), [regMap]),
        #"esbd" => GeneralEquilibrium.aggComb(params["esbd"], NamedArray(mapslices(sum, data["vdfp"] .+ data["vmfp"], dims=2)[:, 1, :], names(params["esbd"])) .+ data["vdpp"].+ data["vmpp"] .+ data["vdgp"].+ data["vmgp"] .+ data["vdip"].+ data["vmip"], [comMap, regMap]),
        #"esbm" => GeneralEquilibrium.aggComb(params["esbm"], NamedArray(mapslices(sum, data["vmfp"], dims=2)[:, 1, :], names(params["esbm"])) .+ data["vmpp"] .+ data["vmgp"] .+ data["vmip"], [comMap, regMap]),
        "esbd" => GeneralEquilibrium.aggComb(params["esbd"], NamedArray(repeat(reshape(mapslices(sum, NamedArray(mapslices(sum, data["vdfp"] .+ data["vmfp"], dims=2)[:, 1, :], names(params["esbd"])) .+ data["vdpp"] .+ data["vmpp"] .+ data["vdgp"] .+ data["vmgp"] .+ data["vdip"] .+ data["vmip"], dims=2), (length(comMap), 1)), inner=[1, length(regMap)]), names(params["esbd"])), [comMap, regMap]),
        "esbm" => GeneralEquilibrium.aggComb(params["esbm"], NamedArray(repeat(reshape(mapslices(sum, NamedArray(mapslices(sum, data["vmfp"], dims=2)[:, 1, :], names(params["esbm"])) .+ data["vmpp"] .+ data["vmgp"] .+ data["vmip"], dims=2), (length(comMap), 1)), inner=[1, length(regMap)]), names(params["esbm"])), [comMap, regMap]),
        "esbs" => GeneralEquilibrium.aggComb(params["esbs"], NamedArray(mapslices(sum, data["vst"], dims=2)[:, 1], names(params["esbs"])[1]), [marMap]),
        "subp" => GeneralEquilibrium.aggComb(params["subp"], data["vdpp"] .+ data["vmpp"], [comMap, regMap]),
        "incp" => GeneralEquilibrium.aggComb(params["incp"], data["vdpp"] .+ data["vmpp"], [comMap, regMap]),
        "rflx" => params["rflx"],
        "etre" => GeneralEquilibrium.aggComb(params["etre"], NamedArray(mapslices(sum, data["evos"], dims=2)[:, 1, :], names(params["etre"])), [endMap, regMap]), #params["etre"],
        "eflg" => GeneralEquilibrium.agg(params["eflg"], [endMap, fixedMap])
    )

    paramAg["eflg"] = paramAg["eflg"] ./ maximum.([paramAg["eflg"][i, :] for i ∈ 1:size(paramAg["eflg"], 1)])
    paramAg["eflg"][paramAg["eflg"].<0] .= 0

    # Return the aggregated data
    return Dict(data => dataAg, parameters => parametersAg)
end
