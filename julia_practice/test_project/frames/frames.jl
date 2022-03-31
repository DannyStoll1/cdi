#! /usr/bin/env julia

module Frames

using OrderedCollections
using FromFile
@from "../utils/utils.jl" using Utils
@from "../graphics/graphics.jl" using Graphics

export DynamicalPlane
export compute_potentials
export center
export set_iters
export get_orbit
export render

mutable struct DynamicalPlane{T<:Real}
    xmin::T
    xmax::T
    ymin::T
    ymax::T
    width::Int64
    max_iter::Int64
    escape_radius::T
    mapping::Function
    points::Matrix{Complex{T}}
    potentials::Matrix{T}
    degree::Int64
    is_computed::Bool
    function DynamicalPlane{T}(
            mapping::Function;
            degree::Int64 = 2,
            center::Complex{T} = 0im,
            zoom_scale::T = 1.,
            pixel_width::Int64 = 128,
            max_iter::Int64 = 128,
            escape_radius::T = 64.,
            ) where {T<:Real}
        xmin = center.re - zoom_scale
        xmax = center.re + zoom_scale
        ymin = center.im - zoom_scale
        ymax = center.im + zoom_scale
        points = make_grid(xmin, xmax, ymin, ymax, pixel_width)
        potentials = zeros(size(points))
        new(
            xmin,
            xmax,
            ymin,
            ymax,
            pixel_width,
            max_iter,
            escape_radius,
            mapping,
            points,
            potentials,
            degree,
            false)
    end
end

function center(p::DynamicalPlane{T}) where {T<:Real}
    return (p.xmin + p.xmax + (p.ymin + p.ymax)*im)/2
end

function _do_orbit(p::DynamicalPlane{T}, z::Complex{T}) where {T<:Real}
    f = p.mapping

    orbit = OrderedDict{Complex{T}, Complex{T}}()

    for i = 1:p.max_iter
        w = z
        z = f(z)
        if abs2(z) > p.escape_radius
            value = i - log(p.degree, (log2(abs(z))))
            return orbit, value
        elseif z in keys(orbit)
            return orbit, 0.
        else
            orbit[w] = z
        end
    end
    return orbit, 0.
end

function get_orbit(p::DynamicalPlane{T}, z::Complex{T}) where {T<:Real}
    orbit, _ = _do_orbit(p, z)
    return orbit
end

function get_potential(p::DynamicalPlane{T}, z::Complex{T}) where {T<:Real}
    _, i = _do_orbit(p, z)
    return i
end

function set_iters(p::DynamicalPlane{T}, max_iter::Int64) where {T<:Real}
    if max_iter >= p.max_iter
        println("Increasing iterations from $(p.max_iter) to $max_iter...")
        increase_iters(p, max_iter);
    else
        println("Decreasing iterations from $(p.max_iter) to $max_iter...")
        p.max_iter = max_iter
        compute_potentials(p);
    end
end

function increase_iters(p::DynamicalPlane, max_iter::Int64)
    @assert max_iter >= p.max_iter
    p.max_iter = max_iter
    for (i,z) in enumerate(p.points)
        if p.potentials[i] == 0
            p.potentials[i] = get_potential(p, z)
        end
    end
end

function compute_potentials(p::DynamicalPlane)
    if p.is_computed
        return
    end
    zs = p.points
    for (i,z) in enumerate(zs)
        p.potentials[i] = get_potential(p, z)
    end
    p.is_computed = true;
end

function render(p::DynamicalPlane)
    @assert p.is_computed
    draw_image(p.potentials)
end

end
