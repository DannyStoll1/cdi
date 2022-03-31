module Utils
export make_grid

# Create a grid of complex numbers with given bounds and width
function make_grid(
        xmin::T,
        xmax::T,
        ymin::T,
        ymax::T,
        width::Int64,
        )::Matrix{Complex{T}} where {T<:Real}
    x_size = xmax - xmin
    y_size = ymax - ymin

    step = x_size / (width-1)

    xs = xmin:step:xmax
    ys = im*(ymin:step:ymax)

    grid = map(sum, Base.product(xs, ys))
    return grid
end

end
