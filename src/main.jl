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
            forbiddens = find_double_threes(board, color)
            @info forbiddens
            for empty_cell in forbiddens
                board[empty_cell] = Forbidden
            end
            if board[cell] == Empty
                for empty_cell in forbiddens
                    board[empty_cell] = Empty
                end
                board[cell] = color
                captured[Int(color)] += check_capture(board, cell, color)
                is_win(board, color, captured) && break
                time[Int(color)] = Millisecond(0)
                color = enemy(color)
            else
                for empty_cell in forbiddens
                    board[empty_cell] = Empty
                end
            end
        end
        prev = mouseKeys
        time[Int(enemy(color))] += now() - start_time
        start_time = now()
    end
    @info "$color wins !"
end

play()