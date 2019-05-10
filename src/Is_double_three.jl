function is_double_three(board::Board, cell::Cell)
    count = 0
    for dir in HALF_DIR
        if board[cell - dir] == board.color
            if board[cell + dir] == Empty
                if board[cell - 2dir] == board.color && board[cell - 3dir] == Empty
                    (count += 1) == 2 ? true : continue
                    return true
                elseif board[cell - 2dir] == Empty && board[cell - 3dir] == board.color && board[cell - 4dir] == Empty
                    (count += 1) == 2 ? true : continue
                    return true
                end
            elseif board[cell + dir] == board.color && board[cell - 2dir] == Empty && board[cell + 2dir] == Empty
                (count += 1) == 2 ? true : continue
                return true
            end
        elseif board[cell - dir] == Empty
            if board[cell + dir] == board.color
                if board[cell + 2dir] == board.color && board[cell + 3dir] == Empty
                    (count += 1) == 2 ? true : continue
                    return true
                elseif board[cell + 2dir] == Empty && board[cell + 3dir] == board.color && board[cell + 4dir] == Empty
                    (count += 1) == 2 ? true : continue
                    return true
                end
            elseif board[cell + dir] == Empty
                if board[cell - 2dir] == board.color && board[cell - 3dir] == board.color && board[cell - 4dir] == Empty
                    (count += 1) == 2 ? true : continue
                    return true
                elseif board[cell + 2dir] == board.color && board[cell + 3dir] == board.color && board[cell + 4dir] == Empty
                    (count += 1) == 2 ? true : continue
                    return true
                end
            end
        end
    end
    return false
end

function list_double_three(board, cell)
    forbiddens = board.forbiddens[Int(board.color)]
    for (index, cell) in enumerate(forbiddens)
        if !is_double_three(board, cell)
            deleteat!(forbiddens, index)
            if board[cell] == Forbidden
                board[cell] = Empty
            end
        end
    end
    for y in -3:3
        for x in -3:3
            if is_double_three(board, cell + Cell(x, y))
                push!(forbiddens, cell + Cell(x, y))
                board[cell + Cell(x, y)] = Forbidden
            end
        end
    end
    board.forbiddens
end