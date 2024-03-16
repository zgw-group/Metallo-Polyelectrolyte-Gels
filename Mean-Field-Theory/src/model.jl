using Clapeyron
import Clapeyron: N_A, k_B

struct LSParam <: EoSParam
    N::SingleParam
    Z::SingleParam
    l::SingleParam
    κbond::Float64
end

abstract type LSModel <: EoSModel end

struct LS{T} <: LSModel
    components::Vector{String}
    params::T
end

"""
    LS(components,κbond; userlocations=String[])

Liquid-state equation to model metallo-polyelectrolyte systems using mean-field theory.

# Arguments
- components::Vector{String}: Names of the components
- κbond::Float64: Dimensionless bonding volume parameter
- userlocations::Vector{String}: Locations of the parameters in the parameter file (optional)

# Example
```julia
model = LS(["PAA","Ca2+"],1e3;userlocations=(;
           Z = [-1,3],
           N = [1000,1],
           l = [10,1]))
```
"""
function LS(components,κbond;
    userlocations=String[])
    params = getparams(components, [""]; userlocations=userlocations)
    N = params["N"]
    Z = params["Z"]
    l = params["l"]
    packagedparams = LSParam(N,Z,l,κbond)
    model = LS(components, packagedparams)
    return model
end

LS
export LS

function f_total(model::LSModel,lB,ρ)
    N           = model.params.N.values
    Z           = model.params.Z.values
    l           = model.params.l.values
    κbond       = model.params.κbond
        
    f0          = sum(@. ρ./N*(log(ρ./N)-1))
    η           = (π/6)*sum(ρ)
    fhs         = 6η^2*(4-3η)/(π*(1-η)^2)
    
    κ           = sqrt(4π*lB*sum(ρ./l.*Z.^2))
    χ           = 3/κ^3*(3/2+log1p(κ)-2*(1+κ)+1/2*(1+κ)^2)
    fel         = -1/3*lB*κ*χ*sum(ρ./l.*Z.^2)
    
    ghs         = (2+η)/(2*(1-η)^2)
    fch         = sum((1 ./N .-1).*ρ.*log.(ghs))

    if κbond==0.0
        return (f0+fhs+fel+fch)
    end
    Γ           = (-1+sqrt(1+2κ))/(2)
    g_EXP       = ghs*exp(-Z[2]*lB/(1+Γ)^2)
    F           = exp(Z[2]*lB/(1+Γ)^2)-1
    λ           = g_EXP*F*κbond

    a           = ρ[1]/l[1]*λ
    b           = 1+(ρ[2]*Z[2]-ρ[1]/l[1])*λ
    c           = -1

    Xp          = (-b+sqrt(b^2-4*a*c))/(2*a)
    Xi          = 1/(1+ρ[1]/l[1]*λ*Xp)
    fassoc      = ρ[1]/l[1]*(log(Xp)+(1-Xp)/2)+ρ[2]*Z[2]*(log(Xi)+(1-Xi)/2)
    
    # println("f0: ",f0)
    # println("fhs: ",fhs)
    # println("fel: ",fel)
    # println("fch: ",fch)
    # println("Xp: ",Xp)
    # println("Xi: ",Xi)
    # println("fassoc: ",fassoc)
    return (f0+fhs+fel+fch+fassoc)
end

function p_inter(model,lB,ρp,ρi)
    N = model.params.N.values
    l = model.params.l.values
    Z = model.params.Z.values
    κbond = model.params.κbond
    f = N./l
    ρ = [ρp,ρi,ρp/l[1],ρi*Z[2]]
    η           = (π/6)*sum(ρ)

    κ           = sqrt(4π*lB*sum(ρ./l.*Z.^2))

    ghs         = (2+η)/(2*(1-η)^2)

    Γ           = (-1+sqrt(1+2κ))/(2)
    g_EXP       = ghs*exp(-Z[2]*lB/(1+Γ)^2)
    Fm           = exp(Z[2]*lB)-1
    λ           = g_EXP*Fm*κbond

    a           = ρ[1]/l[1]*λ
    b           = 1+(ρ[2]*Z[2]-ρ[1]/l[1])*λ
    c           = -1

    Xp          = (-b+sqrt(b^2-4*a*c))/(2*a)
    Xi          = 1/(1+ρ[1]/l[1]*λ*Xp)

    κ = l[1]^(1/2)

    p = (1-(-1+sqrt(1+4*κ))/(2*κ))

    if Z[2]==2
        return (1-Xi)^2*p, (1-Xi)^2*(1-p), 2*Xi*(1-Xi)+Xi^2
    else
        return (1-Xi)*Xp*p+(1-Xi)*(1-Xp)*(p^2+2*p*(1-p))
    end
end

function osmotic_pressure(model,lB,ρ)
    f(x) = f_total(model,lB,x)
    df(x) = ForwardDiff.gradient(f,x)

    return -f(ρ)+sum(ρ.*df(ρ))
end

export osmotic_pressure