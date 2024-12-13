function aggregate_data(; data, parameters, mapping)

    # Read the data, parameters and mapping
    (; comMap, regMap, marMap, endMap, fixedMap) = NamedTuple(Dict(Symbol(k) => mapping[k] for k in keys(mapping)))

    # Generate the aggregated data
    dataAg =
        Dict(
            "vdpb" => agg(data["vdpb"], [comMap, regMap]),
            "vmpb" => agg(data["vmpb"], [comMap, regMap]),
            "vdpp" => agg(data["vdpp"], [comMap, regMap]),
            "vmpp" => agg(data["vmpp"], [comMap, regMap]),
            "vdgb" => agg(data["vdgb"], [comMap, regMap]),
            "vmgb" => agg(data["vmgb"], [comMap, regMap]),
            "vdgp" => agg(data["vdgp"], [comMap, regMap]),
            "vmgp" => agg(data["vmgp"], [comMap, regMap]),
            "vdib" => agg(data["vdib"], [comMap, regMap]),
            "vmib" => agg(data["vmib"], [comMap, regMap]),
            "vdip" => agg(data["vdip"], [comMap, regMap]),
            "vmip" => agg(data["vmip"], [comMap, regMap]),
            "vdfb" => agg(data["vdfb"], [comMap, comMap, regMap]),
            "vmfb" => agg(data["vmfb"], [comMap, comMap, regMap]),
            "vdfp" => agg(data["vdfp"], [comMap, comMap, regMap]),
            "vmfp" => agg(data["vmfp"], [comMap, comMap, regMap]),
            "evfb" => agg(data["evfb"], [endMap, comMap, regMap]),
            "evfp" => agg(data["evfp"], [endMap, comMap, regMap]),
            "evos" => agg(data["evos"], [endMap, comMap, regMap]),
            "vmsb" => agg(data["vmsb"], [comMap, regMap, regMap]),
            "vxsb" => agg(data["vxsb"], [comMap, regMap, regMap]),
            "vfob" => agg(data["vfob"], [comMap, regMap, regMap]),
            "vcif" => agg(data["vcif"], [comMap, regMap, regMap]),
            "vtwr" => agg(data["vtwr"], [marMap, comMap, regMap, regMap]),
            "vst" => agg(data["vst"], [marMap, regMap]),
            "save" => agg(data["save"], [regMap]),
            "vdep" => agg(data["vdep"], [regMap]),
            "vkb" => agg(data["vkb"], [regMap]),
            "maks" => agg(data["maks"], [comMap, comMap, regMap]),
            "makb" => agg(data["makb"], [comMap, comMap, regMap]))

    # Generate the aggregated parameters
    paramAg = Dict(
        ### "esbv" => aggComb(params["esbv"], NamedArray(mapslices(sum, data["evfp"], dims=1)[1, :, :], names(params["esbv"])), [comMap, regMap]),
        "esbv" => aggComb(params["esbv"], NamedArray(repeat(reshape(mapslices(sum, data["evfp"], dims=[1, 3])[1, :, 1], (length(comMap), 1)), inner=[1, length(regMap)]), names(params["esbv"])), [comMap, regMap]),
        "esbt" => aggComb(params["esbt"], NamedArray(
                mapslices(sum, data["vdfp"], dims=1)[1, :, :]
                + mapslices(sum, data["vmfp"], dims=1)[1, :, :]
                + mapslices(sum, data["evfp"], dims=1)[1, :, :], names(params["esbt"])), [comMap, regMap]),
        "esbc" => aggComb(params["esbt"], NamedArray(
                mapslices(sum, data["vdfp"], dims=1)[1, :, :] + mapslices(sum, data["vmfp"], dims=1)[1, :, :], names(params["esbv"])), [comMap, regMap]),
        "etrq" => aggComb(params["etrq"], NamedArray(
                mapslices(sum, data["maks"], dims=1)[1, :, :], names(params["etrq"])), [comMap, regMap]),
        "esbq" => aggComb(params["esbq"], NamedArray(
                mapslices(sum, data["maks"], dims=2)[:, 1, :], names(params["esbq"])), [comMap, regMap]),
        "esbg" => aggComb(params["esbg"], NamedArray(mapslices(sum, data["vdgp"] .+ data["vmgp"], dims=1)[1, :], names(params["esbg"])[1]), [regMap]),
        #"esbd" => aggComb(params["esbd"], NamedArray(mapslices(sum, data["vdfp"] .+ data["vmfp"], dims=2)[:, 1, :], names(params["esbd"])) .+ data["vdpp"].+ data["vmpp"] .+ data["vdgp"].+ data["vmgp"] .+ data["vdip"].+ data["vmip"], [comMap, regMap]),
        #"esbm" => aggComb(params["esbm"], NamedArray(mapslices(sum, data["vmfp"], dims=2)[:, 1, :], names(params["esbm"])) .+ data["vmpp"] .+ data["vmgp"] .+ data["vmip"], [comMap, regMap]),
        "esbd" => aggComb(params["esbd"], NamedArray(repeat(reshape(mapslices(sum, NamedArray(mapslices(sum, data["vdfp"] .+ data["vmfp"], dims=2)[:, 1, :], names(params["esbd"])) .+ data["vdpp"] .+ data["vmpp"] .+ data["vdgp"] .+ data["vmgp"] .+ data["vdip"] .+ data["vmip"], dims=2), (length(comMap), 1)), inner=[1, length(regMap)]), names(params["esbd"])), [comMap, regMap]),
        "esbm" => aggComb(params["esbm"], NamedArray(repeat(reshape(mapslices(sum, NamedArray(mapslices(sum, data["vmfp"], dims=2)[:, 1, :], names(params["esbm"])) .+ data["vmpp"] .+ data["vmgp"] .+ data["vmip"], dims=2), (length(comMap), 1)), inner=[1, length(regMap)]), names(params["esbm"])), [comMap, regMap]),
        "esbs" => aggComb(params["esbs"], NamedArray(mapslices(sum, data["vst"], dims=2)[:, 1], names(params["esbs"])[1]), [marMap]),
        "subp" => aggComb(params["subp"], data["vdpp"] .+ data["vmpp"], [comMap, regMap]),
        "incp" => aggComb(params["incp"], data["vdpp"] .+ data["vmpp"], [comMap, regMap]),
        "rflx" => params["rflx"],
        "etre" => aggComb(params["etre"], NamedArray(mapslices(sum, data["evos"], dims=2)[:, 1, :], names(params["etre"])), [endMap, regMap]), #params["etre"],
        "eflg" => agg(params["eflg"], [endMap, fixedMap])
    )

    paramAg["eflg"] = paramAg["eflg"] ./ maximum.([paramAg["eflg"][i, :] for i ∈ 1:size(paramAg["eflg"], 1)])
    paramAg["eflg"][paramAg["eflg"].<0] .= 0

    # Return the aggregated data
    return Dict(data => dataAg, parameters => parametersAg)
end
