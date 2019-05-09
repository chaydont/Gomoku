function find_length(board::Board, current::Cell, dir::Cell; enemy::Bool=false)
    length = 1
    color = enemy ? !board.color : board.color
    while board[cell + length * dir] == color
        length += 1
    end
    length
end

function count_all_lines(board::Board)
    score = 0
    for cell in get_pieces(board)
        for dir in HALF_DIR
            score += find_length(board, cell, dir)
        end
    end
    for cell in get_pieces(board; enemy=true)
        for dir in HALF_DIR
            score -= find_length(board, cell, dir; enemy=true)
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
            if depth > 0
                new_board.color = !new_board.color
                actual, actual_cell = ai(new_board, depth - 1)
                actual = -actual
            else
                actual = heuristic(new_board) * (depth % 2 == 0 ? -1 : 1) 
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