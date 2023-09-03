# This file was generated, do not modify it. # hide
using DiffEqGPU, StaticArrays, OrdinaryDiffEq

function rossler(u, p, t)
    a = p[1]
    b = p[2]
    c = p[3]
    du1 = -u[2] - u[3]
    du2 = u[1] + a * u[2]
    du3 = b + u[3] * (u[1] - c)
    return SVector{3}(du1, du2, du3)
end

u0 = @SVector [1.0; 0.0; 0.0]
tspan = (0.0, 20.0)
p = @SVector [0.1, 0.1, 14.0]
prob = ODEProblem{false}(rossler, u0, tspan, p)

integ = DiffEqGPU.init(GPUTsit5(), prob.f, false, u0, 0.0, 0.005, p, nothing, CallbackSet(nothing), true, false)