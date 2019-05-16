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

function play_turn(board::Board, cell::Cell)
    board[cell] = board.color
    captured = capture(board, cell)
    add_captured(board, length(captured))
    captured
end

function human_turn(board)
    start_time = now()
    set_time(board, Millisecond(0))
    last_pressed = false
    while true
        get_events() == SDL.QuitEvent && return true
        cell, click = get_mouse_state()
        if click && !last_pressed && board[cell] == Empty && !is_double_three(board, cell)
            play_turn(board, cell)
            is_win(board) && return true
            change_color(board)
            display_board(board)
            return false
        end
        last_pressed = click
        add_time(board, Millisecond(now() - start_time))
        start_time = now()
        display_board(board)
    end
    false
end

function AI_turn(board, depth=2)
    start_time = now()
    score, best_cell = ai(board, depth)
    play_turn(board, best_cell)
    is_win(board) && return true
    set_time(board, Millisecond(now() - start_time))
    display_board(board)
    change_color(board)
    false
end


AI = true
AI_strength = 4

function play()
    board = Board()
    display_board(board)
    start_time = now()
    while true
        if AI && board.color == Black
            @time AI_turn(board, AI_strength) && break
        else
            human_turn(board) && break
        end
        set_time(board, now() - start_time; enemy=true)
        display_board(board)
    end
    @info "$(board.color) wins !"
    while !(get_events() == SDL.QuitEvent || get_mouse_state()[2]) end
    return board.color == White
end

play()