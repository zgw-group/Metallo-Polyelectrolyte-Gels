function obj_crit_mix(model::LSModel,F,lB,ρ)
    ncomps = length(model)
    N = model.params.N.values
    Z = model.params.Z.values
    l = model.params.l.values
    fun(x) = f_total(model,lB,[x[1], x[2], x[1]/l[1]/Z[3], x[2]*Z[2]])
    H(x) = ForwardDiff.hessian(fun,x)
    L(x) = det(Symmetric(H(x)))
    dL(x) = ForwardDiff.gradient(L,x)
    HH = H(ρ)
    LL = det(HH)
    Mᵢ = @view(HH[end,:])
    Mᵢ .=  dL(ρ)
    MM = HH
    M(x) = [HH[1:end-1,:];transpose(dL(x))]
    F[1] = LL
    F[2] = det(M(ρ))
    return F
end

function x0_crit_mix(model::LSModel)
    return [-2.,-3.]
end

function crit_mix(model::LSModel, lB; x0 = nothing)
    if x0 == nothing
        x0 = x0_crit_mix(model)
    end
    f!(F,x) = obj_crit_mix(model,F,lB,exp10.(x))
    results = Solvers.nlsolve(f!, big.(x0), Solvers.TrustRegion())
    sol = Solvers.x_sol(results)
    println(results)

    return @. Float64(exp10(sol))
end

export crit_mix

function obj_phaseq(model::LSModel,F,lB::Float64,ρ0,ρsup,ρco,ϕ,ψ)
    ncomps = length(model)
    N = model.params.N.values
    Z = model.params.Z.values
    l = model.params.l.values

    fun(x) = f_total(model,lB,x)
    df(x) = ForwardDiff.gradient(fun,x)
    
    μsup = df(ρsup)
    μco  = df(ρco)
    
    F[1:ncomps] = @. (μsup-μco)-ψ*Z/l
    F[ncomps+1:2*ncomps] = (1-ϕ).*ρco + ϕ.*ρsup .- ρ0   
    
    F[2*ncomps+1] = -fun(ρsup)+fun(ρco)-sum(μco.*ρco)+sum(μsup.*ρsup)-ψ*sum(Z.*ρsup./l)
    F[2*ncomps+2] = sum(ρsup.*Z./l)
    # Add mass balance
     
    return F
end

function x0_phaseq(model::LSModel, lB, ρ0)
    Z = model.params.Z.values
    ρT = sum(ρ0)
    f = ρT/0.76*6/π*0.98
    println(f)
    ϕ = f*(1-1e-10)
    ρco0 = ρ0/f
    ρsup0 = (ρ0-ϕ*ρco0)/ϕ

    μco = chemical_potential(model, lB, ρco0)
    μsup = chemical_potential(model, lB, ρsup0)
    ψ = @. (μsup-μco)./Z
    ψ = sum(ψ)/length(ψ)


    return vcat(log10.(ρco0), log10.(ρsup0), ϕ, ψ)
end

"""
    phaseq(model::LSModel, lB; x0 = nothing)

Method to calculate the phase equilibrium of a mixture system. 

# Arguments
- model::LSModel: Model to be used
- lB::Float64: Dimensionless Bjerrum length
- ρ0: Input density of the system
- x0: Initial guess for the log-densities of the two phases, phase fraction and electrochemical potential (optional)
"""
function phaseq(model::LSModel, lB, ρ0; x0 = nothing)
    Z = model.params.Z.values
    l = model.params.l.values

    if sum(ρ0.*Z./l) != 0.
        @error "The initial conditions do not satisfy the electroneutrality condition"
    end

    if x0 == nothing
        x0 = x0_phaseq(model, lB, ρ0)
    end
    f!(F,x) = obj_phaseq(model,F,lB,ρ0,exp10.(x[1:4]),exp10.(x[5:8]),x[9],x[10])
    results = Solvers.nlsolve(f!,big.(x0), Solvers.TrustRegion())
    sol = Solvers.x_sol(results)

    ρ = @. Float64(exp10(sol[1:8]))

    return ρ[1:4], ρ[5:8]
end

export phaseq