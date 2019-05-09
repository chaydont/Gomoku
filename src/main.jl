using Dates
using SimpleDirectMediaLayer

const SDL = SimpleDirectMediaLayer

include("Game.jl")
include("Rendering.jl")
include("AI.jl")
include("Is_double_three.jl")
include("Is_win.jl")


function Base.show(io::IO, tile::Tile)
    tile == Empty && print(io, ".")
    tile == Black && print(io, "@")
    tile == White && print(io, "O")
    tile == Forbidden && print(io, "X")
end

get_cell_from_pixel(x, y) = Cell(div(x * 19, BOARD_SIZE) + 1, div(y * 19, BOARD_SIZE) + 1)

function get_events()
    events = SDL.Event(ntuple(i->UInt8(0),56))
    SDL.PollEvent(pointer_from_objref(events))
    evtype = UInt32(0)
    for x in events._Event[4:-1:1]
        evtype = evtype << (sizeof(x)*8)
        evtype |= x
    end
    SDL.Event(evtype)
end

function get_mouse_state()
    x, y = Int[0], Int[0]
    mouseKeys = SDL.GetMouseState(pointer(x), pointer(y))
    get_cell_from_pixel(x[1], y[1]), (mouseKeys & SDL.BUTTON_LEFT) > 0
end

AI = true
last_pressed = false

function play_turn(board::Board, cell::Cell)
    board[cell] = board.color
    add_piece(board, cell)
    add_captured(board, capture(board, cell))
end

function play_full_turn(board::Board, cell::Cell)
    play_turn(board, cell)
    is_win(board) && return true
    change_color(board)
    set_time(board, Millisecond(0))
    false
end

function human_turn(board)
    get_events() == SDL.QuitEvent && return true
    cell, click = get_mouse_state()
    if click && !last_pressed && board[cell] == Empty && !is_double_three(board, cell)
        play_full_turn(board, cell) && return true
    end
    global last_pressed = click
    false
end

function AI_turn(board)
    score, best_cell = ai(board, 0)
    @show score, best_cell
    play_full_turn(board, best_cell)
end

function play()
    @info HALF_DIR
    board = Board()
    display_board(board)
    start_time = now()
    while true
        if AI && board.color == Black
            @time AI_turn(board) && break
        else
            human_turn(board) && break
        end
        add_time(board, now() - start_time)
        start_time = now()
        display_board(board)
    end
    @info "$(board.color) wins !"
end

play()