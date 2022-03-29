#! /usr/bin/env julia

using Images
using KittyTerminalImages

function compute_mandel_iters(
        c::Complex,
        max_iter::Int64
        )::Float64
    z::Complex = 0

    for i = 1:max_iter
        z = z*z+c
        if abs2(z) > 10
            return i - log2(log2(abs(z)))
        end
    end
    return 0.
end

function compute_mandel(;
        xmin::Real = -2.1,
        xmax::Real = 0.4,
        ymin::Real = -1.5,
        ymax::Real = 1.5,
        width::Int64 = 100,
        max_iter::Int64 = 128
    )
    cs = make_grid(xmin, xmax, ymin, ymax, width)
    iter_counts = zeros(Float64, size(cs))
    residues = zeros(Complex, size(cs))

    for (i,c) in enumerate(cs)
        iter_counts[i] = compute_mandel_iters(c, max_iter)
    end
    return iter_counts
end

# Create a grid of complex numbers with given bounds and width
function make_grid(
        xmin::Real,
        xmax::Real,
        ymin::Real,
        ymax::Real,
        width::Int64,
        )::Matrix{Complex}
    x_size = xmax - xmin
    y_size = ymax - ymin

    step = x_size / (width-1)

    xs = xmin:step:xmax
    ys = im*(ymin:step:ymax)

    grid = map(sum, Base.product(xs, ys))
    return grid
end

function to_color(count::Float64)
    if count == 0
        return 0
    end

    cmap = cmap_2

    color = cmap(log(count) % 1)
    return RGB.(color)
end

function cmap_1(value::Float64)
    r = cos(2pi*value)
    g = cos(4pi*value)
    b = cos(8pi*value)
    return RGB(r,g,b)
end

function cmap_2(value::Float64)
    h = value*360
    return HSV(h,1,1)
end

function draw_image(
        counts::Matrix{Float64}
        )::Matrix{RGB}
    color = reverse(
        map(to_color, transpose(counts)),
        dims=1)
    return color
end

counts = compute_mandel(
        xmin = -0.7500,
        xmax = -0.7498,
        ymin = 0.0314,
        ymax = 0.0316,
        width = 1024,
        max_iter = 4096
        )

draw_image(
    counts
    )
