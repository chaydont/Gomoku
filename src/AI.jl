function count_all_lines(board::Board)
    score = 0
    for cell in each_cell()
        if board[cell] == board.color
            for dir in HALF_DIR
                score += find_length(board, cell, dir)
            end
        elseif board[cell] == !board.color
            for dir in HALF_DIR
                board.color = !board.color
                score -= find_length(board, cell, dir)
                board.color = !board.color
            end
        end
    end
    return score
end

function heuristic(board::Board)
    score = 0
    if is_win(board)
        return 1_000_000
    end
    score += count_all_lines(board)
    score += (get_captured(board) / 2)^2
    score -= (get_captured(board, enemy=true) / 2)^2
    return score
end


function ai(board::Board, depth::Integer=3)
    best = 10_000_000
    best_cell = Cell(0, 0)
    new_board = Board(board)
    for cell in each_empty_cell(new_board)
        if !is_double_three(board, cell)
            play_turn(new_board, cell)
            # display_board(new_board)
            new_board.color = !new_board.color
            if depth > 0
                new_board.color = !new_board.color
                actual, actual_cell = ai(new_board, depth - 1)
                actual = -actual
                new_board.color = !new_board.color
            else
                actual = -heuristic(new_board)
            end
            if actual < best
                best = actual
                best_cell = cell
            end
            new_board = Board(board)
        end
    end
    return best, best_cell
end