include("Game.jl")
include("Rendering.jl")
include("AI.jl")
include("Check_free_threes.jl")

function Base.show(io::IO, tile::Tile)
    tile == Empty && print(io, ".")
    tile == Black && print(io, "@")
    tile == White && print(io, "O")
    tile == Forbidden && print(io, "X")
end


get_cell_from_pixel(x, y) = Cell(div(x * 19, WINDOW_SIZE) + 1, div(y * 19, WINDOW_SIZE) + 1)

function remove_forbidden(board)
    for x in 1:19
        for y in 1:19
            if board[x, y] == Forbidden
                board[x, y] == Empty
            end
        end
    end
end



function play()
    board = fill(Empty, 19, 19)
    prev = 0
    color = White
    while true
        x, y = Int[0], Int[0]
    
        SDL.PollEvent(Array{UInt8}(zeros(56)))
        mouseKeys = SDL.GetMouseState(pointer(x), pointer(y))
        cell = get_cell_from_pixel(x[1], y[1])
        display_board(board)
        if ((prev & SDL.BUTTON_LEFT) == 0) && (mouseKeys & SDL.BUTTON_LEFT) > 0
            check_all_free_threes(board, color)
            if board[cell] == Empty
                board[cell] = color
                is_win(board, cell, color) && break
                check_capture(board, cell, color)
                color = enemy(color)
            end
            remove_forbidden(board)
        end
        prev = mouseKeys
    end
    @info "$color wins !"
end

play()