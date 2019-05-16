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

last_pressed = false

function play_turn(board::Board, cell::Cell)
    board[cell] = board.color
    captured = capture(board, cell)
    add_captured(board, length(captured))
    captured
end

function play_full_turn(board::Board, cell::Cell)
    play_turn(board, cell)
    is_win(board) && return true
    change_color(board)
    set_time(board, Millisecond(0))
    global start_time = now()
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
    global transposition_table = Array{Tuple{UInt64, Int64}}(undef, 100000)
    score, best_cell = ai(board, 2)
    play_full_turn(board, best_cell)
end


AI = true

function play()
    board = Board()
    display_board(board)
    start_time = now()
    while true
        if AI && board.color == Black
            @time AI_turn(board) && break
        else
            human_turn(board) && break
        end
        set_time(board, now() - start_time; enemy=true)
        display_board(board)
    end
    @info "$(board.color) wins !"
    if board.color == White
        return true
    else
        return false
    end
end

play()