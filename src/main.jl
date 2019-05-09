using Dates
using SimpleDirectMediaLayer

const SDL = SimpleDirectMediaLayer

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

function play_turn(board::Board, cell::Cell)
    board[cell] = board.color
    add_captured(board, capture(board, cell))
    board.color = !board.color
    set_time(board, Millisecond(0))
end

function play()
    board = Board()
    prev = 0

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
        display_board(board)

        if ((prev & SDL.BUTTON_LEFT) == 0) && (mouseKeys & SDL.BUTTON_LEFT) > 0
            if board[cell] == Empty && !is_double_three(board, cell)
                board.color = !board.color
                play_turn(board, cell)
                board.color = !board.color
                is_win(board) && break
                board.color = !board.color
                display_board(board)
                add_time(board, now() - start_time)
                start_time = now()
                best, best_cell = ai(board, 0)
                add_time(board, now() - start_time)
                play_turn(board, best_cell)
                board.color = !board.color
                is_win(board) && break
                start_time = now()
            end
        end
        prev = mouseKeys
        add_time(board, now() - start_time)
        start_time = now()
    end
    @info "$(board.color) wins !"
end

play()