function find_length(board::Board, cell::Cell, dir::Cell; enemy::Bool=false)
    length = 0
    color = enemy ? !board.color : board.color
    while board[cell + length * dir] == color
        length += 1
    end
    empty_length = 1
    while board[cell - empty_length * dir] == Empty && empty_length + length - 1 < 5
        empty_length += 1
    end
    count = 1
    empty_length -= 1
    while board[cell + count * dir] == Empty && empty_length + length < 5
        empty_length += 1
    end
    if empty_length + length < 5
        return 0
    end
    return length
end

function count_all_lines(board::Board)
    score = 0
    for cell in get_pieces(board)
        for dir in HALF_DIR
            score += find_length(board, cell, dir)
        end
    end
    return score
end

function heuristic(board::Board)
    score = 0
    score += is_win(board) ? 10_000_000 : 0
    score += count_all_lines(board) * 20
    score += (get_captured(board))^2 * 100
    return score
end

function ai(board::Board, depth::Integer=3, beta::Integer=10_000_000, alpha::Integer=-10_000_000)
    best = -10_000_000
    best_cell = Cell(1, 1)
    new_board = Board(board)
    for cell in each_not_alone_cell(new_board)
        if !is_double_three(board, cell)
            play_turn(new_board, cell)
            if depth > 1
                new_board.color = !new_board.color
                actual, actual_cell = ai(new_board, depth - 1, -beta, -alpha)
            else
                actual = heuristic(new_board)
            end
            if actual > best
                best = actual
                best_cell = cell
                if best > alpha
                    alpha = best
                    if alpha >= beta
                        return -best, best_cell
                    end
                end
            end
            new_board = Board(board)
        end
    end
    return -best, best_cell
end