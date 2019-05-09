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
    for empty_cell in board.forbiddens
        board[empty_cell] = Empty
    end
    board[cell] = board.color
    board.forbiddens = find_double_threes(board)
    for empty_cell in board.forbiddens
        board[empty_cell] = Forbidden
    end
    add_captured(board, capture(board, cell))
    is_win(board) && return true
    set_time(board, Millisecond(0))
    board.color = !board.color
    false
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
            if board[cell] == Empty
                play_turn(board, cell) && break
            end
        end
        prev = mouseKeys
        add_time(board, now() - start_time)
        start_time = now()
    end
    @info "$(board.color) wins !"
end

play()