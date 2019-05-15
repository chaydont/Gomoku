function find_length(board::Board, cell::Cell, dir::Cell; enemy::Bool=false)
    color = enemy ? !board.color : board.color
    length = 1
    while board[cell + length * dir] == color
        length += 1
    end
    if length <= 2
        return length - 1
    end
    empty_length = 0
    count = 1
    while board[cell - count * dir] == Empty && empty_length + length < 5
        empty_length += 1
        count += 1
    end
    count = 1
    while board[cell + count * dir] == Empty && empty_length + length < 5
        empty_length += 1
        count += 1
    end
    if empty_length + length < 5
        return 0
    end
    return length - 1
end

function count_all_lines(board::Board)
    score = 0
    for cell in each_piece(board)
        for dir in HALF_DIR
            if board[cell - dir] != board.color
                score += find_length(board, cell, dir) ^ 5
            end
        end
    end
    return score
end

function heuristic(board::Board)
    score = 0
    is_win(board) && return 10_000_000
    change_color(board)
    is_win(board) && return -10_000_000
    change_color(board)
    score += count_all_lines(board) * 150
    score += (get_captured(board)) ^ 2 * 150
    change_color(board)
    score -= count_all_lines(board) * 150
    score -= (get_captured(board)) ^ 2 * 150
    change_color(board)
    return Int(floor(score))
end

function revert_turn(board::Board, cell::Cell, captured)
    board[cell] = Empty
    @simd for capture in captured
        board[capture] = !board.color
        add_captured(board, -1)
    end
end

hash_table = Array{UInt64}(undef, 19, 19)

function create_hash_table()
    for y in 1:19
        for x in 1:19
            global hash_table[x, y] = rand(0:typemax(UInt64)) 
        end
    end
end

function hash(board::Board)
    hash_key = 0
    for cell in each_cell()
        score_cell = 0
        if board[cell] == White
            hash_key += hash_table[cell.x, cell.y] ^ 2
        elseif board[cell] == Black
            hash_key -= hash_table[cell.x, cell.y] ^ 2
        end
    end
    return hash_key
end

transposition_table = Array{Tuple{UInt64, Int64}}(undef, 100000)

function ai(board::Board, depth::Integer=3, alpha::Integer=-10_000_000, beta::Integer=10_000_000, hash_key::Integer, turn::Bool=true)
    if depth == 0
        hash_key = hash(board)
        if transposition_table[hash_key % 100000][1] == hash_key
            score = transposition_table[hash_key % 100000][2]
        else
            score = heuristic(board) * (turn ? 1 : -1)
            transposition_table[hash_key % 100000] = (hash_key, score)
        end
        return score, nothing
    end
    best_value = turn ? -10_000_000 : 10_000_000
    best_cell = Cell(19, 19)
    for cell in each_cell()
        if board[cell] == Empty && !is_alone(board, cell) && !is_double_three(board, cell)
            captured = play_turn(board, cell)
            if is_win(board)
                child_value = heuristic(board) * (turn ? 1 : -1)
            else
                change_color(board)
                child_value = ai(board, depth - 1, alpha, beta, !turn)[1]
                change_color(board)
            end
            revert_turn(board, cell, captured)
            if turn
                if child_value > best_value
                    best_value = child_value
                    best_cell = cell
                end
                if best_value > alpha
                    alpha = best_value
                end
            else
                if child_value < best_value
                    best_value = child_value
                    best_cell = cell
                end
                if best_value < beta
                    beta = best_value
                end
            end
            if alpha >= beta
                return best_value, best_cell
            end
        end
    end
    return best_value, best_cell
end
