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
                ### "esbv" => GeneralEquilibrium.aggComb(parameters["esbv"], NamedArray(mapslices(sum, data["evfp"], dims=1)[1, :, :], names(parameters["esbv"])), [comMap, regMap]),
                "esbv" => GeneralEquilibrium.aggComb(parameters["esbv"], NamedArray(repeat(reshape(mapslices(sum, data["evfp"], dims=[1, 3])[1, :, 1], (length(comMap), 1)), inner=[1, length(regMap)]), names(parameters["esbv"])), [comMap, regMap]),
                "esbt" => GeneralEquilibrium.aggComb(parameters["esbt"], NamedArray(
                                mapslices(sum, data["vdfp"], dims=1)[1, :, :]
                                + mapslices(sum, data["vmfp"], dims=1)[1, :, :]
                                + mapslices(sum, data["evfp"], dims=1)[1, :, :], names(parameters["esbt"])), [comMap, regMap]),
                "esbc" => GeneralEquilibrium.aggComb(parameters["esbt"], NamedArray(
                                mapslices(sum, data["vdfp"], dims=1)[1, :, :] + mapslices(sum, data["vmfp"], dims=1)[1, :, :], names(parameters["esbv"])), [comMap, regMap]),
                "etrq" => GeneralEquilibrium.aggComb(parameters["etrq"], NamedArray(
                                mapslices(sum, data["maks"], dims=1)[1, :, :], names(parameters["etrq"])), [comMap, regMap]),
                "esbq" => GeneralEquilibrium.aggComb(parameters["esbq"], NamedArray(
                                mapslices(sum, data["maks"], dims=2)[:, 1, :], names(parameters["esbq"])), [comMap, regMap]),
                "esbg" => GeneralEquilibrium.aggComb(parameters["esbg"], NamedArray(mapslices(sum, data["vdgp"] .+ data["vmgp"], dims=1)[1, :], names(parameters["esbg"])[1]), [regMap]),
                #"esbd" => GeneralEquilibrium.aggComb(parameters["esbd"], NamedArray(mapslices(sum, data["vdfp"] .+ data["vmfp"], dims=2)[:, 1, :], names(parameters["esbd"])) .+ data["vdpp"].+ data["vmpp"] .+ data["vdgp"].+ data["vmgp"] .+ data["vdip"].+ data["vmip"], [comMap, regMap]),
                #"esbm" => GeneralEquilibrium.aggComb(parameters["esbm"], NamedArray(mapslices(sum, data["vmfp"], dims=2)[:, 1, :], names(parameters["esbm"])) .+ data["vmpp"] .+ data["vmgp"] .+ data["vmip"], [comMap, regMap]),
                "esbd" => GeneralEquilibrium.aggComb(parameters["esbd"], NamedArray(repeat(reshape(mapslices(sum, NamedArray(mapslices(sum, data["vdfp"] .+ data["vmfp"], dims=2)[:, 1, :], names(parameters["esbd"])) .+ data["vdpp"] .+ data["vmpp"] .+ data["vdgp"] .+ data["vmgp"] .+ data["vdip"] .+ data["vmip"], dims=2), (length(comMap), 1)), inner=[1, length(regMap)]), names(parameters["esbd"])), [comMap, regMap]),
                "esbm" => GeneralEquilibrium.aggComb(parameters["esbm"], NamedArray(repeat(reshape(mapslices(sum, NamedArray(mapslices(sum, data["vmfp"], dims=2)[:, 1, :], names(parameters["esbm"])) .+ data["vmpp"] .+ data["vmgp"] .+ data["vmip"], dims=2), (length(comMap), 1)), inner=[1, length(regMap)]), names(parameters["esbm"])), [comMap, regMap]),
                "esbs" => GeneralEquilibrium.aggComb(parameters["esbs"], NamedArray(mapslices(sum, data["vst"], dims=2)[:, 1], names(parameters["esbs"])[1]), [marMap]),
                "subp" => GeneralEquilibrium.aggComb(parameters["subp"], data["vdpp"] .+ data["vmpp"], [comMap, regMap]),
                "incp" => GeneralEquilibrium.aggComb(parameters["incp"], data["vdpp"] .+ data["vmpp"], [comMap, regMap]),
                "rflx" => parameters["rflx"],
                "etre" => GeneralEquilibrium.aggComb(parameters["etre"], NamedArray(mapslices(sum, data["evos"], dims=2)[:, 1, :], names(parameters["etre"])), [endMap, regMap]), #parameters["etre"],
                "eflg" => GeneralEquilibrium.agg(parameters["eflg"], [endMap, fixedMap])
        )

        paramAg["eflg"] = paramAg["eflg"] ./ maximum.([paramAg["eflg"][i, :] for i ∈ 1:size(paramAg["eflg"], 1)])
        paramAg["eflg"][paramAg["eflg"].<0] .= 0

        # Return the aggregated data
        return (data=dataAg, parameters=paramAg)
end
