function is_three(board::Board, cell::Cell, dir::Cell, free_three::Array{Tile})
    for (index, type) in enumerate(free_three)
        if type == Empty && board[cell + dir * (index - 1)] != Empty
            return false
        elseif type == White && board[cell + dir * (index - 1)] != !board.color
            return false
        end
    end
    true
end

function is_any_three(board::Board, cell::Cell, dir::Cell)
    count = 0
    free_threes = [[Empty White White Empty White Empty], [Empty White Empty White White Empty], [Empty White White White Empty]]
    for free_three in free_threes
        if board[cell] != Outside && board[cell + dir * (length(free_three) - 1)] != Outside
            if is_three(board, cell, dir, free_three)
                count += 1
            end
        end
    end
    return count
end

function is_double_three(board::Board, cell::Cell)
    count = 0
    board[cell] = !board.color
    last_dir = Cell(0, 0)
    for i in -4:4
        if i != 0
            for dir in HALF_DIR
                if last_dir != dir && (new_count = is_any_three(board, cell + i * dir, dir)) > 0 
                    count += new_count
                    last_dir = dir
                end
            end
        end
        if count >= 2
            board[cell] = Empty
            return true
        end
    end
    board[cell] = Empty
    false
end

function find_double_threes(board::Board)
    [cell for cell in each_empty_cell(board) if is_double_three(board, cell)]
end