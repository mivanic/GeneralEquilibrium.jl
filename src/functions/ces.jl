function demand_ces(output, prices, α, σ, γ)
    if σ == 1
       output / (γ * prod((α ./ prices) .^ α)) * (α ./ prices)
    elseif σ == 0
       output .* α ./ γ
    elseif σ > 0 
       α=Vector(α)
       c = 1 / γ * sum((α .^ σ) .* (prices .^ (1 - σ)))^(1 / (1 - σ))
       toRet = Vector( (output / γ) .* ((α .* γ .* c) ./ (prices)) .^ σ)
       toRet[α.==0].=0
       return(toRet)
    else
       σ_adj = fill(σ, length(prices))
       σ_adj[Vector(α) .==0] .= 1
       c = 1 / γ * sum((α .^ σ_adj) .* (prices .^ (1 - σ)))^(1 / (1 - σ))
       toret = (output / γ) .* ((α .* γ .* c) ./ (prices)) .^ σ_adj
       return(toret)
    end
 end
 
 
 