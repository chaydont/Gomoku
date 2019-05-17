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
    is_win(board) && return 1_000_000
    score += count_all_lines(board) * 100
    score += (get_captured(board)) ^ 2 * 150
    change_color(board)
    score -= count_all_lines(board) * 100
    score -= (get_captured(board)) ^ 2 * 150
    change_color(board)
    return Int(floor(score))
end

function heuristic_moves(board::Board, cell::Cell)
    score = 0
    for dir in HALF_DIR
        if board[cell + dir] == !board.color && board[cell + 2dir] == !board.color && board[cell + 3dir] == board.color
            score += (get_captured(board) + 2) ^ 2 * 150
        elseif board[cell - dir] == !board.color && board[cell - 2dir] == !board.color && board[cell - 3dir] == board.color
            score += (get_captured(board) + 2) ^ 2 * 150
        end
        length = 1
        count = 1
        while board[cell + dir * count] == board.color
            length += 1
            count += 1
        end
        count = 1
        while board[cell - dir * count] == board.color
            length += 1
            count += 1
        end
        if length >= 5
            score += length ^ 5 * 100
        end
    end
    if is_cell_capturable(board, cell)
        score -= (get_captured(board; enemy=true) + 2) ^ 2 * 150
    end
    score
end

function get_moves(board::Board, turn::Bool)
    moves = Cell[]
    scores = Integer[]
    for cell in each_cell()
        if board[cell] == Empty && !is_alone(board, cell) && !is_double_three(board, cell)
            child_value = heuristic_moves(board, cell) * (turn ? 1 : -1)
            if turn
                count = 1
                while count <= length(scores) && child_value <= scores[count]
                    count += 1
                end
                insert!(moves, count, cell)
                insert!(scores, count, child_value)
            else
                count = 1
                while count <= length(scores) && child_value >= scores[count]
                    count += 1
                end
                insert!(moves, count, cell)
                insert!(scores, count, child_value)
            end
        end
    end
    moves
end

function revert_turn(board::Board, cell::Cell, captured)
    board[cell] = Empty
    for capture in captured
        board[capture] = !board.color
        add_captured(board, -1)
    end
end

function ai(board::Board, depth::Integer=3, alpha::Integer=-10_000_000, beta::Integer=10_000_000, turn::Bool=true, time=now())
    if now() - time > Millisecond(490) || depth == 0
        return heuristic(board) * (turn ? 1 : -1), nothing
    end
    best_value = turn ? -10_000_000 : 10_000_000
    best_cell = Cell(10, 10)
    for cell in get_moves(board, turn)
        captured = play_turn(board, cell)
        if is_win(board)
            child_value = heuristic(board) * (turn ? 1 : -1)
        else
            change_color(board)
            child_value = ai(board, depth - 1, alpha, beta, !turn, time)[1]
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
    return best_value, best_cell
end