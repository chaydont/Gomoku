@enum Tile White Black Empty Forbidden

board = fill(Empty, 19, 19)

include("Rendering.jl")
include("Game.jl")
include("AI.jl")
include("Check_free_threes.jl")

function Base.show(io::IO, tile::Tile)
    tile == Empty && print(io, ".")
    tile == Black && print(io, "@")
    tile == White && print(io, "O")
    tile == Forbidden && print(io, "X")
end

x = Int[0]
y = Int[0]

#SDL.PollEvent(Int[0])

function get_tile(x, y)
    Int(floor(x[1] * 19 / WINDOW_SIZE)) + 1, Int(floor(y[1] * 19 / WINDOW_SIZE)) + 1
end

prev = nothing
color = Black

function remove_forbidden(board)
    for x in 1:19
        for y in 1:19
            if board[x, y] == Forbidden
                board[x, y] == Empty
            end
        end
    end
end

while !has_5_aligned(board, enemy(color))
    x = Int[0]
    y = Int[0]

    SDL.PollEvent(Array{UInt8}(zeros(56)))
    mouseKeys = SDL.GetMouseState(pointer(x), pointer(y))
    x, y = get_tile(x, y)
    display_board(board)
    if (isnothing(prev) || (prev & SDL.BUTTON_LEFT) == 0) && (mouseKeys & SDL.BUTTON_LEFT) > 0
        if board[x, y] == Empty
            check_all_free_threes(board, color)
            board[x, y] = color
            check_capture(board, x, y, color)
            !has_5_aligned(board, enemy(color))
            global color = enemy(color)
            remove_forbidden(board)
            display_board(board)


            score, x, y = ai(board, true, 2)
            println(score, x, y)

            check_all_free_threes(board, color)
            board[x, y] = color
            check_capture(board, x, y, color)
            global color = enemy(color)
            remove_forbidden(board)
        end
    end
    global prev = mouseKeys
end