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

integ = DiffEqGPU.init(GPUTsit5(), rossler, false, u0, 0.0, 0.005, p, nothing, CallbackSet(nothing), true, false)

function solv(integ, tres, u1, u2, u3)
    for i in Int32(1):Int32(10000)
        @inline DiffEqGPU.step!(integ, integ.t + integ.dt, integ.u)
        tres[i] = integ.t
        u1[i] = integ.u[1]
        u2[i] = integ.u[2]
        u3[i] = integ.u[3]
    end
    nothing
end

using StaticCompiler, StaticTools

compile_wasm(solv,
    Tuple{typeof(integ),
          MallocVector{Float64}, MallocVector{Float64},
          MallocVector{Float64},MallocVector{Float64}},
    path="_libs",
    flags=`--initial-memory=1048576 walloc.o`, filename="julia_solv")

using WebAssemblyInterfaces

integ_types = js_types(typeof(integ))
integ_def = js_def(integ)

println(integ_types)