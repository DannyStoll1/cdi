module Graphics

using Images
using KittyTerminalImages

export make_image
export draw_image

function to_color(count::T) where {T<:Real}
    if count == 0
        return 0
    end

    cmap = cmap_2

    color = cmap(log(count) % 1)
    return RGB.(color)
end

function cmap_1(value::T) where {T<:Real}
    r = cos(2pi*value)
    g = sin(4pi*value)
    b = sin(8pi*value)
    return RGB(r,g,b)
end

function cmap_2(value::T) where {T<:Real}
    h = value*360
    return HSV(h,1,1)
end

function make_image(
        counts::Matrix{T}
        )::Matrix{RGB} where {T<:Real}
    img = reverse(
        map(to_color, transpose(counts)),
        dims=1
    )
    return img
end

function draw_image(counts::Matrix{T}) where {T<:Real}
    img = make_image(counts)
    display(img)
end

end
