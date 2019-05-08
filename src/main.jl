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

get_cell_from_pixel(x, y) = Cell(div(x * 19, BOARD_SIZE) + 1, div(y * 19, BOARD_SIZE) + 1)

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

    captured = [0, 0]
    time = [Millisecond(0), Millisecond(0)]
    start_time = now()
    while true
        x, y = Int[0], Int[0]
    
        events = SDL.Event(ntuple(i->UInt8(0),56))
        SDL.PollEvent(pointer_from_objref(events))
        evtype = UInt32(0)
        for x in events._Event[4:-1:1]
            evtype = evtype << (sizeof(x)*8)
            evtype |= x
        end
        SDL.Event(evtype) == SDL.QuitEvent && break
        mouseKeys = SDL.GetMouseState(pointer(x), pointer(y))
        cell = get_cell_from_pixel(x[1], y[1])
        display_board(board, captured..., time...)
        if ((prev & SDL.BUTTON_LEFT) == 0) && (mouseKeys & SDL.BUTTON_LEFT) > 0
            #check_all_free_threes(board, color)
            if board[cell] == Empty
                board[cell] = color
                captured[Int(color)] += check_capture(board, cell, color)
                is_win(board, cell, color) && break
                time[Int(color)] = Millisecond(0)
                color = enemy(color)
            end
            remove_forbidden(board)
        end
        prev = mouseKeys
        time[Int(enemy(color))] += now() - start_time
        start_time = now()
    end
    @info "$color wins !"
end

play()