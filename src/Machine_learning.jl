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