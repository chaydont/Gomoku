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
    score, best_cell = ai(board, 4)
    play_full_turn(board, best_cell)
end


AI = true

function play()
    board = Board()
    display_board(board)
    start_time = now()
    create_hash_table()
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

function set_variable(a, b, c, d)
    global variable_1 = a
    global variable_2 = b
    global variable_3 = c
    global variable_4 = d
end

function AI_play(a, b, c, d, e, f, g, h)
    board = Board()
    while true
        set_variable(a, b, c, d)
        AI_turn(board) && break
        set_variable(e, f, g, h)
        AI_turn(board) && break
        display_board(board)
    end
    @info "$(board.color) wins ! $a, $b, $c, $d / $e, $f, $g, $h"
    if board.color == White
        return true
    else
        return false
    end
end

function create_players(prev_players)
    players = []
    for player in prev_players
        player[5] = 0
        random = rand(1:4)
        if random == 1
            negative = player[1] - rand(1:5)
            positive = player[1] + rand(1:5)
            player_1 = copy(player)
            player_2 = copy(player)
            player_1[1] = negative
            player_2[1] = positive
            push!(players, player_1)
            push!(players, player_2)
        elseif random == 2
            negative = player[2] - rand(10:100)
            positive = player[2] + rand(10:100)
            player_1 = copy(player)
            player_2 = copy(player)
            player_1[2] = negative
            player_2[2] = positive
            push!(players, player_1)
            push!(players, player_2)
        elseif random == 3
            negative = player[3] - rand(1:5)
            positive = player[3] + rand(1:5)
            player_1 = copy(player)
            player_2 = copy(player)
            player_1[3] = negative
            player_2[3] = positive
            push!(players, player_1)
            push!(players, player_2)
        elseif random == 4
            negative = player[4] - rand(10:100)
            positive = player[4] + rand(10:100)
            player_1 = copy(player)
            player_2 = copy(player)
            player_1[4] = negative
            player_2[4] = positive
            push!(players, player_1)
            push!(players, player_2)
        end
    end
    players
end

function machine_learning()
    player = create_players(create_players(create_players([[40, 100, 20, 100, 0]])))
    while true
        for i=1:8
            for j=i + 1:8
                if AI_play(player[i][1], player[i][2], player[i][3], player[i][4], player[j][1], player[j][2], player[j][3], player[j][4])
                    player[i][5] += 1
                else
                    player[j][5] += 1
                end
            end
        end
        sort!(player; by = x -> x[5])
        print(player[5:end])
        player = create_players(player[5:end])
    end
end

play()