function model(; sets, data, parameters, fixed, max_iter=50)

    # Structural parameters (some CES/CET options are not happening)
    δ_evfp = data["evfp"] .> 0
    δ_maks = data["maks"] .> 0
    δ_vtwr = data["vtwr"] .> 0
    δ_vtwr_sum = NamedArray(mapslices(sum, data["vtwr"], dims=1)[1, :, :, :] .> 0, names(data["vtwr"])[[2, 3, 4]])
    δ_qxs = data["vcif"] .> 0


    # Read  sets
    (; reg, comm, marg, acts, endw, endwc, endws, endwm, endwms, endwf) = NamedTuple(Dict(Symbol(k) => sets[k] for k ∈ keys(sets)))

    # Read hard parameters
    (; endowflag, esubt, esubc, esubva, esubd, etraq, esubq, subpar, incpar, etrae, esubg, esubm, esubs) = NamedTuple(Dict(Symbol(k) => parameters[k] for k ∈ keys(parameters)))

    # Set up the model
    model = JuMP.Model(Ipopt.Optimizer)

    # Set up the general constraints
    p_min = 1e-8
    p_max = 1e+8
    q_min = 1e-8
    q_max = 1e+12
    y_min = 1e-8
    y_max = 1e+12
    t_min = -1e2
    t_max = 1e2

    # All variables used in the model
    @variables(model,
        begin
            # Firms top nest
            q_min <= qint[acts, reg] <= q_max
            p_min <= pint[acts, reg] <= p_max
            q_min <= qva[acts, reg] <= q_max
            p_min <= pva[acts, reg] <= p_max
            q_min <= qo[acts, reg] <= q_max
            p_min <= po[acts, reg] <= p_max

            # Firms second nest
            q_min <= qfa[comm, acts, reg] <= q_max
            p_min <= pfa[comm, acts, reg] <= p_max
            q_min <= qfe[endw, acts, reg] <= q_max
            p_min <= pfe[endw, acts, reg] <= p_max
            p_min <= tfe[endw, acts, reg] <= p_max
            q_min <= qfd[comm, acts, reg] <= q_max
            p_min <= pfd[comm, acts, reg] <= p_max
            q_min <= qfm[comm, acts, reg] <= q_max
            p_min <= pfm[comm, acts, reg] <= p_max

            # # # Firm distribution
            q_min <= qca[comm, acts, reg] <= q_max
            p_min <= pca[comm, acts, reg] <= p_max
            p_min <= ps[comm, acts, reg] <= p_max
            q_min <= qc[comm, reg] <= q_max
            p_min <= pds[comm, reg] <= p_max
            t_min <= to[comm, acts, reg] <= t_max

            # Endowments
            p_min <= peb[endw, acts, reg] <= p_max
            q_min <= qes[endw, acts, reg] <= q_max

            # Income
            y_min <= fincome[reg] <= y_max
            y_min <= y[reg] <= y_max

            # Private consumption        
            y_min <= yp[reg] <= y_max
            q_min <= u[reg] <= q_max
            p_min <= ppa[comm, reg] <= p_max
            q_min <= qpa[comm, reg] <= q_max
            p_min <= ppd[comm, reg] <= p_max
            q_min <= qpd[comm, reg] <= q_max
            p_min <= ppm[comm, reg] <= p_max
            q_min <= qpm[comm, reg] <= q_max

            # Government consumption
            y_min <= yg[reg] <= y_max
            p_min <= pgov[reg] <= p_max
            p_min <= pga[comm, reg] <= p_max
            q_min <= qga[comm, reg] <= q_max
            p_min <= pgd[comm, reg] <= p_max
            q_min <= qgd[comm, reg] <= q_max
            p_min <= pgm[comm, reg] <= p_max
            q_min <= qgm[comm, reg] <= q_max

            # Saving
            -q_max <= qsave[reg] <= q_max
            p_min <= psave[reg] <= p_max

            # Investment consumption
            p_min <= pia[comm, reg] <= p_max
            q_min <= qia[comm, reg] <= q_max
            p_min <= pid[comm, reg] <= p_max
            q_min <= qid[comm, reg] <= q_max
            p_min <= pim[comm, reg] <= p_max
            q_min <= qim[comm, reg] <= q_max
            q_min <= qinv[reg] <= q_max
            p_min <= pinv[reg] <= p_max

            # Trade - exports
            q_min <= qms[comm, reg] <= q_max
            q_min <= qxs[comm, reg, reg] <= q_max
            p_min <= pmds[comm, reg, reg] <= p_max
            p_min <= pms[comm, reg] <= p_max

            # Trade - margins
            p_min <= ptrans[comm, reg, reg] <= p_max
            q_min <= qtmfsd[marg, comm, reg, reg] <= q_max
            p_min <= pt[marg] <= p_max
            q_min <= qtm[marg] <= q_max
            q_min <= qst[marg, reg] <= q_max

            # Trade - imports/exports
            t_min <= txs[comm, reg, reg] <= t_max
            t_min <= tx[comm, reg] <= t_max
            p_min <= pfob[comm, reg, reg] <= p_max
            p_min <= pcif[comm, reg, reg] <= p_max
            t_min <= tms[comm, reg, reg] <= t_max
            t_min <= tm[comm, reg] <= t_max

            # Domestic market clearing
            q_min <= qds[comm, reg] <= q_max

            # Taxes
            t_min <= tfd[comm, acts, reg] <= t_max
            t_min <= tfm[comm, acts, reg] <= t_max
            t_min <= tpd[comm, reg] <= t_max
            t_min <= tpm[comm, reg] <= t_max
            t_min <= tgd[comm, reg] <= t_max
            t_min <= tgm[comm, reg] <= t_max
            t_min <= tid[comm, reg] <= t_max
            t_min <= tim[comm, reg] <= t_max

            #Factor Market
            p_min <= pes[endw, acts, reg] <= p_max
            p_min <= pe[endwms, reg] <= p_max
            q_min <= qe[endwms, reg] <= q_max
            q_min <= qesf[endwf, acts, reg] <= q_max
            p_min <= tinc[endw, acts, reg] <= p_max

            # Global Investment
            1 <= globalcgds <= q_max

            p_min <= pcgdswld <= p_max

            q_min <= walras_sup <= q_max
            q_min <= walras_dem <= q_max

            # Capital stocks
            q_min <= kb[reg] <= q_max
            q_min <= ke[reg] <= q_max


            # Soft parameters
            1e-8 <= α_qintva[["int", "va"], acts, reg] <= 1
            1e-8 <= γ_qintva[acts, reg]
            1e-8 <= α_qfa[comm, acts, reg] <= 1
            1e-8 <= γ_qfa[acts, reg]
            1e-8 <= α_qfe[endw, acts, reg] <= 1
            1e-8 <= γ_qfe[acts, reg]
            0 <= ϵ_qfe[acts, reg]
            1e-8 <= α_qfdqfm[["dom", "imp"], comm, acts, reg] <= 1
            1e-8 <= γ_qfdqfm[comm, acts, reg]
            0 <= ϵ_qfdqfm[comm, acts, reg]
            1e-8 <= α_qca[comm, acts, reg] <= 1
            1e-8 <= γ_qca[acts, reg]
            1e-8 <= α_pca[comm, acts, reg] <= 1
            1e-8 <= γ_pca[acts, reg]
            1e-8 <= σyp[reg] <= 1
            1e-8 <= σyg[reg] <= 1
            -1 <= σsave[reg] <= 1
            1e-8 <= α_qga[comm, reg] <= 1
            1e-8 <= γ_qga[reg]
            1e-8 <= α_qia[comm, reg] <= 1
            1e-8 <= γ_qia[reg]
            1e-8 <= α_qpdqpm[["dom", "imp"], acts, reg] <= 1
            1e-8 <= γ_qpdqpm[acts, reg]
            0 <= ϵ_qpdqpm[acts, reg]
            1e-8 <= α_qgdqgm[["dom", "imp"], acts, reg] <= 1
            1e-8 <= γ_qgdqgm[acts, reg]
            0 <= ϵ_qgdqgm[acts, reg]
            1e-8 <= β_qpa[comm, reg]
            1e-8 <= α_qidqim[["dom", "imp"], acts, reg] <= 1
            1e-8 <= γ_qidqim[acts, reg]
            0 <= ϵ_qidqim[acts, reg]
            1e-8 <= α_qxs[comm, reg, reg] <= 1
            1e-8 <= γ_qxs[comm, reg]
            0 <= ϵ_qxs[comm, reg]
            1e-8 <= α_qtmfsd[marg, comm, reg, reg] <= 1
            1e-8 <= α_qst[marg, reg] <= 1
            1e-8 <= γ_qst[marg]
            1e-8 <= α_qes2[endws, acts, reg] <= 1
            1e-8 <= γ_qes2[endws, reg]
            1e-8 <= ϵ_qes2[endws, reg]
            1e-8 <= α_qinv[reg] <= 1

            0 <= δ[reg] <= 1
            0 <= ρ[reg] <= 1

            # Values
            0 <= vdfp[comm, acts, reg]
            0 <= vmfp[comm, acts, reg]
            0 <= vdpp[comm, reg]
            0 <= vmpp[comm, reg]
            0 <= vdgp[comm, reg]
            0 <= vmgp[comm, reg]
            0 <= vdip[comm, reg]
            0 <= vmip[comm, reg]
            0 <= evfp[endw, acts, reg]
            0 <= evos[endw, acts, reg]
            0 <= vfob[comm, reg, reg]
            0 <= vcif[comm, reg, reg]
            0 <= vst[marg, reg]
            0 <= vtwr[marg, comm, reg, reg]
            0 <= maks[comm, acts, reg]
        end
    )


    #(;pcif,qo,pcgdswld,tpd,pfd,globalcgds,pint,pfm,qxs,pt,qfd,pga,qtm,tid,ppa,y,pgov,pgd,qid,pmds,qpa,qes,qva,tinc,peb,qpm,qst,psave,txs,qsave,tfd,pfob,qesf,pms,tgm,pca,qfe,tm,qe,ps,pfa,pid,pva,pe,qc,qinv,tms,to,tx,pgm,pfe,qga,walras_dem,u,qpd,pia,walras_sup,qim,po,ppd,qtmfsd,pim,tgd,pes,qfa,tfe,ppm,qint,qds,yp,qca,tim,pinv,tpm,qgm,fincome,pds,qia,qgd,qfm,ptrans,tfm,yg,qms) = NamedTuple(data)

    # All model equations
    @constraints(model,
        begin
            # Firms (top nest)
            e_qintva[a=acts, r=reg], log.([qint[a, r], qva[a, r]]) .== log.(demand_ces(qo[a, r], [pint[a, r], pva[a, r]], α_qintva[:, a, r], esubt[a, r], γ_qintva[a, r]))
            e_qo, log.(qo .* po) .== log.(qva .* pva .+ qint .* pint)

            # Firms (second nest)
            e_qfa[a=acts, r=reg], log.(qfa[:, a, r]) .== log.(demand_ces(qint[a, r], pfa[:, a, r], Vector(α_qfa[:, a, r]), esubc[a, r], γ_qfa[a, r]))
            e_pint[a=acts, r=reg], log.(qint[a, r] * pint[a, r]) == log.(sum(pfa[:, a, r] .* qfa[:, a, r]))
            e_qfe[a=acts, r=reg], log.(Vector(qfe[:, a, r])[δ_evfp[:, a, r]]) .== log.(Vector(demand_ces(qva[a, r], Vector(pfe[:, a, r])[δ_evfp[:, a, r]], Vector(α_qfe[:, a, r])[δ_evfp[:, a, r]], esubva[a, r], γ_qfe[a, r])))
            e_pva[a=acts, r=reg], log.(qva[a, r] * pva[a, r]) == log.(sum(Vector(pfe[:, a, r] .* qfe[:, a, r])[δ_evfp[:, a, r]]))
            e_qfdqfm[c=comm, a=acts, r=reg], log.([qfd[c, a, r], qfm[c, a, r]]) .== log.(demand_ces(qfa[c, a, r], [pfd[c, a, r], pfm[c, a, r]], α_qfdqfm[:, c, a, r], esubd[c, r], γ_qfdqfm[c, a, r]))
            e_pfa, log.(pfa .* qfa) .== log.(qfd .* pfd .+ qfm .* pfm)

            # Firms (distribution)
            e_qca[a=acts, r=reg], log.(Vector(qca[:, a, r])[δ_maks[:, a, r]]) .== log.(Vector(demand_ces(qo[a, r], Vector(ps[:, a, r])[δ_maks[:, a, r]], Vector(α_qca[:, a, r])[δ_maks[:, a, r]], etraq[a, r], γ_qca[a, r])))
            e_po[a=acts, r=reg], log.(po[a, r] * qo[a, r]) == log.(sum(qca[:, a, r] .* ps[:, a, r]))
            e_pca[c=comm, r=reg], log.((esubq[c, r] == 0 ? Vector(pca[c, :, r])[δ_maks[c, :, r]] : Vector(qca[c, :, r])[δ_maks[c, :, r]])) .== log.((esubq[c, r] == 0 ? pds[c, r] : Vector(demand_ces(qc[c, r], Vector(pca[c, :, r])[δ_maks[c, :, r]], Vector(α_pca[c, :, r])[δ_maks[c, :, r]], 1 / esubq[c, r], γ_pca[c, r]))))
            e_qc[c=comm, r=reg], log.(pds[c, r] * qc[c, r]) == log.(sum(pca[c, :, r] .* qca[c, :, r]))
            e_ps, log.(pca) .== log.(ps .* to)

            # Endowments
            e_peb[e=endw, a=acts, r=reg], log.(qfe[e, a, r]) == log.(qes[e, a, r])
            e_pfe[e=endw, a=acts, r=reg], log.(pfe[e, a, r]) == log.(peb[e, a, r] .* tfe[e, a, r])

            # Income
            e_fincome[r=reg], log.(fincome[r]) == log.(sum(peb[:, :, r] .* qes[:, :, r]) .- δ[r] .* pinv[r] .* kb[r])
            e_y[r=reg], log(y[r]) ==
                        log(
                fincome[r] +
                sum(qpd[:, r] .* pds[:, r] .* (tpd[:, r] .- 1)) +
                sum(qpm[:, r] .* pms[:, r] .* (tpm[:, r] .- 1)) +
                sum(qgd[:, r] .* pds[:, r] .* (tgd[:, r] .- 1)) +
                sum(qgm[:, r] .* pms[:, r] .* (tgm[:, r] .- 1)) +
                sum(qid[:, r] .* pds[:, r] .* (tid[:, r] .- 1)) +
                sum(qim[:, r] .* pms[:, r] .* (tim[:, r] .- 1)) +
                sum(qfd[:, :, r] .* pfd[:, :, r] ./ tfd[:, :, r] .* (tfd[:, :, r] .- 1)) +
                sum(qfm[:, :, r] .* pfm[:, :, r] ./ tfm[:, :, r] .* (tfm[:, :, r] .- 1)) +
                sum(qca[:, :, r] .* ps[:, :, r] .* (to[:, :, r] .- 1)) +
                sum(qfe[:, :, r] .* peb[:, :, r] .* (tfe[:, :, r] .- 1)) +
                sum(qxs[:, r, :] .* pfob[:, r, :] ./ txs[:, r, :] .* (txs[:, r, :] .- 1)) +
                sum(qxs[:, :, r] .* pcif[:, :, r] .* (tms[:, :, r] .- 1))
            )

            # Household Income
            e_yp, log.(yp) .== log.(y .* Vector(σyp))

            # Household consumption
            e_qpa[r=reg], log.([Vector(qpa[:, r]); 1]) .== log.(cde(Vector(1 .- subpar[:, r]), Vector(β_qpa[:, r]), Vector(incpar[:, r]), u[r], Vector(ppa[:, r]), yp[r]))
            e_qpdqpm[c=comm, r=reg], log.([qpd[c, r], qpm[c, r]]) .== log.(demand_ces(qpa[c, r], [ppd[c, r], ppm[c, r]], α_qpdqpm[:, c, r], esubd[c, r], γ_qpdqpm[c, r]))
            e_ppa, log.(qpa .* ppa) .== log.(ppd .* qpd .+ ppm .* qpm)

            # Government Income
            e_yg, log.(yg) .== log.(y .* Vector(σyg))

            # Government expenditure
            e_qga[r=reg], log.(pga[:, r] .* qga[:, r]) .== log.(yg[r] .* Vector(α_qga[:, r])) ##This one
            e_pgov[r=reg], log.(pgov[r] * sum(qga[:, r])) == log.(sum(qga[:, r] .* pga[:, r]))
            e_qgdqgm[c=comm, r=reg], log.([qgd[c, r], qgm[c, r]]) .== log.(demand_ces(qga[c, r], [pgd[c, r], pgm[c, r]], α_qgdqgm[:, c, r], esubd[c, r], γ_qgdqgm[c, r]))
            e_pga, log.(qga .* pga) .== log.(pgd .* qgd .+ pgm .* qgm)

            # Saving
            e_qsave, log.(y) .== log.(yp .+ yg .+ psave .* qsave)

            # Investment consumption
            e_qia[r=reg], log.(qia[:, r]) .== log.(demand_ces(qinv[r], pia[:, r], Vector(α_qia[:, r]), 0, γ_qia[r]))
            e_pinv[r=reg], log.(pinv[r] * sum(qia[:, r])) == log.(sum(pia[:, r] .* qia[:, r]))
            e_qidqim[c=comm, r=reg], log.([qid[c, r], qim[c, r]]) .== log.(demand_ces(qia[c, r], [pid[c, r], pim[c, r]], Vector(α_qidqim[:, c, r]), esubd[c, r], γ_qidqim[c, r]))
            e_pia, log.(pia .* qia) .== log.(pid .* qid .+ pim .* qim)
            e_psave, log.(psave) .== log.(pinv)

            # Trade - exports
            e_qms[c=comm, r=reg], log.(qms[c, r]) == log.(sum(qfm[c, :, r]) + qpm[c, r] + qgm[c, r] + qim[c, r])
            e_qxs[c=comm, r=reg], log.(Array(qxs[c, :, r])[δ_qxs[c, :, r]]) .== log.(demand_ces(qms[c, r], Vector(pmds[c, :, r])[δ_qxs[c, :, r]], Vector(α_qxs[c, :, r])[δ_qxs[c, :, r]], esubm[c, r], γ_qxs[c, r]))
            e_pms[c=comm, r=reg], log.(pms[c, r] * qms[c, r]) == log.(sum(pmds[c, :, r] .* qxs[c, :, r]))

            # Trade - margins
            e_qtmfsd[m=marg, c=comm, s=reg, d=reg], log.(qtmfsd[m, c, s, d]) .== log.(α_qtmfsd[m, c, s, d] .* qxs[c, s, d])
            e_ptrans[c=comm, s=reg, d=reg], log.(ptrans[c, s, d] * sum(qtmfsd[:, c, s, d])) == log.(sum(qtmfsd[:, c, s, d] .* pt[:]))
            e_qtm[m=marg], log.(qtm[m]) == log.(sum(qtmfsd[m, :, :, :]))
            e_qst[m=marg], log.(qst[m, :]) .== log.(demand_ces(qtm[m], pds[m, :], Vector(α_qst[m, :]), esubs[m], γ_qst[m]))
            e_pt[m=marg], log.(pt[m] * qtm[m]) == log.(sum(pds[m, :] .* qst[m, :]))

            # Trade - imports / exports
            e_pfob[c=comm, s=reg, d=reg], log(pfob[c, s, d]) == log(pds[c, s] * tx[c, s] * txs[c, s, d])
            e_pcif[c=comm, s=reg, d=reg], log(pcif[c, s, d] * qxs[c, s, d]) == log(pfob[c, s, d] * (qxs[c, s, d]) + ptrans[c, s, d] * sum(qtmfsd[:, c, s, d]))
            e_pmds[c=comm, s=reg, d=reg], log(pmds[c, s, d]) == log(pcif[c, s, d] * tm[c, d] * tms[c, s, d])

            # Domestic market clearing 
            e_qds[c=comm, r=reg], log(qds[c, r]) == log(sum(qfd[c, :, r]) + qpd[c, r] + qgd[c, r] + qid[c, r])
            e_pds[c=comm, r=reg], log(qc[c, r]) == log(qds[c, r] + sum(qxs[c, r, :]) + (c ∈ marg ? qst[c, r] : 0))

            # Taxes
            e_pfd[c=comm, a=acts, r=reg], log(pfd[c, a, r]) == log(pds[c, r] * tfd[c, a, r])
            e_pfm[c=comm, a=acts, r=reg], log(pfm[c, a, r]) == log(pms[c, r] * tfm[c, a, r])
            e_ppd, log.(ppd) .== log.(pds .* tpd)
            e_ppm, log.(ppm) .== log.(pms .* tpm)
            e_pgd, log.(pgd) .== log.(pds .* tgd)
            e_pgm, log.(pgm) .== log.(pms .* tgm)
            e_pid, log.(pid) .== log.(pds .* tid)
            e_pim, log.(pim) .== log.(pms .* tim)

            # Factor Market
            e_pe1[e=endwm, r=reg], log.(qe[e, r]) == log.(sum(qfe[e, :, r]))
            e_qes1[e=endwm, a=acts, r=reg], log(pes[e, a, r]) == log(pe[e, r])
            e_qes2[e=endws, r=reg], log.(Vector(qes[e, :, r])[δ_evfp[e, :, r]]) .== log.(Vector(demand_ces(qe[e, r], Vector(pes[e, :, r])[δ_evfp[e, :, r]], Vector(α_qes2[e, :, r])[δ_evfp[e, :, r]], etrae[e, r], γ_qes2[e, r])))
            e_pe2[e=endws, r=reg], log(pe[e, r] * qe[e, r]) == log(sum(pes[e, :, r] .* qes[e, :, r]))
            e_qes3[e=endwf, a=acts, r=reg], log(qes[e, a, r]) == log(qesf[e, a, r])
            e_pes[e=endw, a=acts, r=reg], log(peb[e, a, r]) == log(pes[e, a, r] * tinc[e, a, r])

            # Investment is a fixed share of global investment
            #e_qinv, log.(qinv) .== log.(Vector(α_qinv) .* globalcgds)
            e_qinv, log.(qinv .- δ .* kb) .== log.(Vector(α_qinv) .* globalcgds)

            e_pcgdswld, log(pcgdswld) == log(sum(pinv .* qinv) / sum(qinv))

            e_walras_sup, log(walras_sup) == log(pcgdswld * globalcgds)
            e_walras_dem, log(walras_dem) == log(sum(psave .* qsave))

            # Capital accumulation
            e_kb[r=reg], log(ρ[r] * pinv[r] * kb[r]) == log(sum(qe[endwc, r] .* pe[endwc, r]))
            e_ke, log.(ke) .== log.(qinv .+ (1 .- δ .* kb))

            # Values
            cvdfp, log.(vdfp) .== log.(pfd .* qfd)
            cvmfp, log.(vmfp) .== log.(pfm .* qfm)
            cvdpp, log.(vdpp) .== log.(ppd .* qpd)
            cvmpp, log.(vmpp) .== log.(ppm .* qpm)
            cvdgp, log.(vdgp) .== log.(pgd .* qgd)
            cvmgp, log.(vmgp) .== log.(pgm .* qgm)
            cvdip, log.(vdip) .== log.(pid .* qid)
            cvmip, log.(vmip) .== log.(pim .* qim)
            cevfp, log.(Array(evfp)[δ_evfp]) .== log.(Array(pfe .* qfe)[δ_evfp])
            cevos, log.(Array(evos)[δ_evfp]) .== log.(Array(pes .* qes)[δ_evfp])
            cvfob, log.(vfob) .== log.(pfob .* qxs)
            cvcif, log.(vcif) .== log.(pcif .* qxs)
            cvst[m=marg], log.(vst[m, :]) .== log.(pds[m, :] .* qst[m, :])
            cvtwr[c=comm, s=reg, d=reg], log.(Vector(vtwr[:, c, s, d])[δ_vtwr[:, c, s, d]]) .== log.(Vector(pt .* qtmfsd[:, c, s, d])[δ_vtwr[:, c, s, d]])
            cmaks, log.(Array(maks)[δ_maks]) .== log.(Array(ps .* qca)[δ_maks])

            # Soft parameter constraints
            sf_α_qxs[c=comm, d=reg], log(sum(α_qxs[c, :, d])) == log(ϵ_qxs[c, d])
            sf_α_qfe[a=acts, r=reg], log(sum(α_qfe[:, a, r])) == log(ϵ_qfe[a, r])
            sf_α_qes2[e=endws, r=reg], log(sum(α_qes2[e, :, r])) == log(ϵ_qes2[e, r])
            sf_α_qfdqfm[c=comm, a=acts, r=reg], log(sum(α_qfdqfm[:, c, a, r])) == log(ϵ_qfdqfm[c, a, r])
            sf_α_qpdqpm[c=comm, r=reg], log(sum(α_qpdqpm[:, c, r])) == log(ϵ_qpdqpm[c, r])
            sf_α_qgdqgm[c=comm, r=reg], log(sum(α_qgdqgm[:, c, r])) == log(ϵ_qgdqgm[c, r])
            sf_α_qidqim[c=comm, r=reg], log(sum(α_qidqim[:, c, r])) == log(ϵ_qidqim[c, r])
            sf_save, log.(σsave .+ σyp .+ σyg) .== log(1)
        end
    )

    # Structurally zero variables
    fix.(Array(qca)[δ_maks.==false], 0; force=true)
    fix.(Array(pca)[δ_maks.==false], 1; force=true)
    fix.(Array(maks)[δ_maks.==false], 0; force=true)
    fix.(Array(evfp)[δ_evfp.==false], 0; force=true)
    fix.(Array(evos)[δ_evfp.==false], 0; force=true)
    #fix.(Array(vtwr)[δ_vtwr.==false], 0; force=true)
    fix.(Array(qxs)[δ_qxs.==false], 1e-6; force=true)

    # Drop structurally missing vtwr
    delete.(model, Array(vtwr)[δ_vtwr.==false])
    for c ∈ comm
        for s ∈ reg
            for d ∈ reg
                if length(cvtwr[c,s,d]) == 0
                    delete.(model, cvtwr[c,s,d])
                else
                    delete.(model, Array(cvtwr[c,s,d])[δ_vtwr[:,c,s,d].==false])
                end
            end
        end
    end

    for c = comm
        for s = reg
            for d = reg
                if (δ_vtwr_sum[c, s, d] == false) | (δ_qxs[c, s, d] == false)
                    delete(model, e_ptrans[c, s, d])
                    fix(ptrans[c, s, d], 0; force=true)
                end
               
                if δ_qxs[c, s, d] == false
                    delete(model, e_pcif[c, s, d])
                    fix(pcif[c, s, d], 1; force=true)
                    delete(model, cvfob[c, s, d])
                    delete(model, cvcif[c, s, d])
                    fix(vfob[c, s, d], 0; force=true)
                    fix(vcif[c, s, d], 0; force=true)
                end

                for m = marg
                    if (δ_vtwr[m, c, s, d] == false) | (δ_qxs[c, s, d] == false)
                        delete(model, e_qtmfsd[m, c, s, d])
                        fix(qtmfsd[m, c, s, d], 0; force=true)
                    end
                end
            end
        end
    end

    for a = acts
        for r = reg
            for e = endw
                if δ_evfp[e, a, r] == false
                    fix(qfe[e, a, r], 0; force=true)
                    fix(peb[e, a, r], 0; force=true)
                    fix(pes[e, a, r], 0; force=true)
                    fix(pfe[e, a, r], 0; force=true)
                    delete(model, e_peb[e, a, r])
                    delete(model, e_pes[e, a, r])
                    delete(model, e_pfe[e, a, r])
                end
            end
            for e = endws
                if δ_evfp[e, a, r] == false
                    fix(qes[e, a, r], 0; force=true)
                end
            end
            for e = endwf
                if δ_evfp[e, a, r] == false
                    fix(qes[e, a, r], 0; force=true)
                    delete(model, e_qes3[e, a, r])
                end
            end

        end
    end


    free_variables = filter((x) -> is_fixed.(x) == false, all_variables(model))
    for v ∈ free_variables
        set_start_value.(v, 1.01)
    end


    # Set starting values
    for k in keys(data)
        if Symbol(k) ∈ keys(object_dictionary(model))
            if data[k] isa NamedArray
                set_start_value.(model[Symbol(k)], Array(data[k]))
            else
                set_start_value.(model[Symbol(k)], data[k])
            end
        end
    end

    # Fix fixed values and delete missing ones
    for fv ∈ keys(fixed)
        for fvi ∈ CartesianIndices(fixed[fv])
            if fixed[fv][fvi]
                if isnan(data[fv][fvi])
                    if is_valid(model, model[Symbol(fv)][fvi])
                        delete(model, model[Symbol(fv)][fvi])
                    end
                else
                    fix(model[Symbol(fv)][fvi], data[fv][fvi]; force=true)
                end
            end
        end
    end

    set_attribute(model, "max_iter", max_iter)

    # # Summary of constraints and free variables
    constraints = all_constraints(model; include_variable_in_set_constraints=false)
    free_variables = filter((x) -> is_fixed.(x) == false, all_variables(model))

    # Solve
    optimize!(model)

    # Save results
    results = merge(Dict(
            String(k) => begin
                arrayOut = NamedArray(zeros(map(length, v.axes)), v.axes)
                arrayOut[is_valid.(model, v).data] .= value.(Array(v)[is_valid.(model, v).data])
                arrayOut[.!is_valid.(model, v).data] .= NaN
                arrayOut
            end for (k, v) in object_dictionary(model)
            if v isa AbstractArray{VariableRef}
        ), Dict(
            String(k) => begin
                (is_valid(model, v) ? value.(v) : NaN)
            end for (k, v) in object_dictionary(model)
            if v isa VariableRef
        ))


    return (
        sets=sets,
        data=merge(data, Dict(k => results[k] for k ∈ setdiff(keys(results), keys(parameters)))),
        parameters=merge(parameters, Dict(k => results[k] for k ∈ keys(results) ∩ keys(parameters))),
        constraints=constraints,
        free_variables=free_variables)

end
