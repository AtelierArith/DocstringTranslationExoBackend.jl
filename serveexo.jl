using Pkg

Pkg.activate(@__DIR__)

using CondaPkg

CondaPkg.withenv() do
  exo = CondaPkg.which("exo")
  run(`$(exo)`)
end