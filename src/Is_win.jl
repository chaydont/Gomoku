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
    for win_cell in line
        is_cell_capturable(board, win_cell) && return true
    end
    return false
end

function get_winning_lines(board::Board)
    lines = []
    for cell in each_cell()
        if board[cell] == board.color
            for dir in HALF_DIR
                line = [cell]
                while board[cell + length * dir] == board.color && length < 5
                    length += 1
                    push!(line, cell + length * dir)
                end
                if length == 5
                    push!(lines, line)
                end
            end
        end
    end
    return lines
end

function is_enemy_win_by_captures(board::Board)
    for cell in each_cell()
        if board[cell] == board.color
            check_can_be_capture(board, cell) && return true
        end
    end
    return false
end

function is_win_with_line(board, lines)
    for line in lines
        if !is_line_capturable(board, line)
            return true
        end
    end
    return false
end

function is_win(board::Board)
    if get_captured(board) >= 10
        return true
    end
    if is_win_with_line(board, get_winning_lines(board)) && is_capturable(board, enemy = true) == 8 && !is_enemy_win_by_captures(board)
        return true
    end
    return false
end