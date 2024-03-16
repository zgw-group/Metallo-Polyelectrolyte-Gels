function obj_phaseq_pure(model::LSModel,F,lB,ρsup,ρco)
    ncomps = length(model)
    N = model.params.N.values
    Z = model.params.Z.values
    l = model.params.l.values
    fun(x) = f_total(model,lB,[x,x/l[1]/Z[2]])
    df(x) = ForwardDiff.derivative(fun,x)
    
    μsup = df(ρsup)
    μco  = df(ρco)
    
    F[1] = (μsup-μco)
    F[2] = -fun(ρsup)+fun(ρco)-sum(μco.*ρco)+sum(μsup.*ρsup)
    return F
end

function x0_phaseq_pure(model::LSModel, lB)
    lBc, ρc = crit_pure(model)
    
        
    return [-10., (log10(ρc)+log10(0.76*6/pi))/2]
end


"""
    phaseq_pure(model::LSModel, lB; x0 = nothing)

Method to calculate the phase equilibrium of a pure component system. 

# Arguments
- model::LSModel: Model to be used
- lB::Float64: Dimensionless Bjerrum length
- x0: Initial guess for the log-densities of the two phases (optional)
"""
function phaseq_pure(model::LSModel, lB; x0 = nothing)
    if x0 == nothing
        x0 = x0_phaseq_pure(model, lB)
    end
    f!(F,x) = obj_phaseq_pure(model,F,lB,exp10(x[1]),exp10(x[2]))
    results = Solvers.nlsolve(f!,big.(x0), Solvers.TrustRegion())
    # println(results)
    sol = Solvers.x_sol(results)

    return @. Float64(exp10(sol))
end

export phaseq_pure

function obj_crit_pure(model::LSModel,F,lB,ρ)
    ncomps = length(model)
    N = model.params.N.values
    Z = model.params.Z.values
    l = model.params.l.values
    fun(x) = f_total(model,lB,[x,x/l[1]/Z[2]])
    df(x) = ForwardDiff.derivative(fun,x)
    d2f(x) = ForwardDiff.derivative(df,x)
    d3f(x) = ForwardDiff.derivative(d2f,x)

    F[1] = d2f(ρ)
    F[2] = d3f(ρ)
    return F
end

function x0_crit_pure(model::LSModel)
    return [2.0,-3.]
end

"""
    crit_pure(model::LSModel)

Method to calculate the critical point of a pure component system. 

# Arguments
- model::LSModel: Model to be used
"""
function crit_pure(model::LSModel)
    x0 = x0_crit_pure(model)
    f!(F,x) = obj_crit_pure(model,F,x[1],exp10(x[2]))
    results = Solvers.nlsolve(f!,big.(x0))
    sol = Solvers.x_sol(results)

    return (Float64(sol[1]), Float64(exp10(sol[2])))
end

export crit_pure