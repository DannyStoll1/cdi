#! /usr/bin/env julia

using FromFile

@from "utils/utils.jl" using Utils
@from "graphics/graphics.jl" using Graphics
@from "frames/frames.jl" using Frames

f(z) = z^2 - 1

plane = DynamicalPlane{Float64}(f, center=0.6+0im, zoom_scale=0.1)

compute_potentials(plane)

render(plane)
