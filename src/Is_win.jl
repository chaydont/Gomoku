function is_cell_capturable(board::Board, cell::Cell)
    for dir in HALF_DIR
        if board[cell + dir] == Empty && board[cell - dir] == board.color && board[cell - 2dir] == !board.color
            return true
        elseif board[cell + dir] == !board.color && board[cell - dir] == board.color && board[cell - 2dir] == Empty
            return true
        elseif board[cell + dir] == board.color
            if board[cell - dir] == Empty && board[cell + 2dir] == !board.color
                return true
            elseif board[cell - dir] == !board.color && board[cell + 2dir] == Empty
                return true
            end
        end
    end
    return false
end

function is_line_capturable(board::Board, line::Array{Cell, 1})
    last_capturable_cell = 0
    for (index, cell) in enumerate(line)
        if index - last_capturable_cell > 5
            return false
        elseif  is_cell_capturable(board, cell)
            if length(line) - index < 5
                return true
            end
            last_capturable_cell = index
        end
    end
    return false
end

function is_win_with_line(board::Board)
    for cell in each_piece(board)
        for dir in HALF_DIR
            line = [cell]
            length = 1
            while board[cell + length * dir] == board.color
                push!(line, cell + length * dir)
                length += 1
            end
            if length >= 5
                !is_line_capturable(board, line) && return true 
            end
            end
    end
    return false
end

function is_enemy_win_by_captures(board::Board)
    for cell in each_piece(board)
        is_cell_capturable(board, cell) && return true
    end
    return false
end

function is_win(board::Board)
    if get_captured(board) >= 10
        return true
    end
    if is_win_with_line(board) && !(get_captured(board; enemy=true) == 8 && is_enemy_win_by_captures(board))
        return true
    end
    return false
end