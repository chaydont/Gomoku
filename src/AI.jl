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
                score += find_length(board, cell, dir) ^ 4
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
    score += count_all_lines(board) * 100
    score += (get_captured(board))^2 * 100
    change_color(board)
    score -= count_all_lines(board) * 100
    score -= (get_captured(board))^2 * 100
    change_color(board)
    return score
end

function revert_turn(board::Board, cell::Cell, captured)
    board[cell] = Empty
    for capture in captured
        board[capture] = !board.color
        add_captured(board, -1)
    end
end

function ai(board::Board, depth::Integer=3, alpha::Integer=-10_000_000, beta::Integer=10_000_000, turn::Bool=true)
    if depth == 0
        return heuristic(board) * (turn ? 1 : -1), nothing
    end
    best_value = turn ? -10_000_000 : 10_000_000
    best_cell = Cell(19, 19)
    for cell in each_cell()
        if board[cell] == Empty && !is_alone(board, cell) && !is_double_three(board, cell)
            captured = play_turn(board, cell)
            if is_win(board)
                revert_turn(board, cell, captured)
                return (turn ? 10_000_000 : -10_000_000), cell
            end
            change_color(board)
            child_value = ai(board, depth - 1, alpha, beta, !turn)[1]
            change_color(board)
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
