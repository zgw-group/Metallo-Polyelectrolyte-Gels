module MPEC
using LinearAlgebra, GenericLinearAlgebra, ForwardDiff, Clapeyron
import Clapeyron: Solvers

include("model.jl")
include("methods/single_component.jl")

end # module