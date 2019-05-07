isempty(board::Array{Tile, 2}, x::Integer, y::Integer) = board[x, y] == Empty

iscolor(board::Array{Tile, 2}, x::Integer, y::Integer, color::Tile) = board[x, y] == color

function check_free_three(board::Array{Tile, 2}, color::Tile, x::Integer, y::Integer, i::Integer, j::Integer, free_three::Array{Tile})
    for (index, type) in enumerate(free_three)
        if type == Empty && !isempty(board, x + i * (index - 1), y + j * (index - 1))
            return false
        elseif type == White && !iscolor(board, x + i * (index - 1), y + j * (index - 1), color)
            return false
        end
    end
    true
end

function check_pos_free_three(board::Array{Tile, 2}, color::Tile, x::Integer, y::Integer, i::Integer, j::Integer)
    count = 0
    free_threes = [[Empty White White Empty White Empty], [Empty White White White Empty]]
    for free_three in free_threes
        if (x >= 1 && y >= 1 &&
            x <= 19 && y <= 19 && 
            x + i * (length(free_three) - 1) <= 19 && 
            x + i * (length(free_three) - 1) >= 1 &&
            y + j * (length(free_three) - 1) <= 19 &&
            y + j * (length(free_three) - 1) >= 1)
            if check_free_three(board, color, x, y, i, j, free_three)
                count += 1
            end
        end
    end
    return count
end

function check_all_free_three(board::Array{Tile, 2}, color::Tile, x::Integer, y::Integer)
    count = 0
    board[x, y] = color
    for i in -4:4
        if i != 0
            count += check_pos_free_three(board, color, x + i, y + i, 1, 1)
            count += check_pos_free_three(board, color, x + i, y - i, 1, -1)
            count += check_pos_free_three(board, color, x + i, y, 1, 0)
            count += check_pos_free_three(board, color, x, y + i, 0, 1)
        end
        if count >= 2
            board[x, y] = Forbidden
            return true
        end
    end
    board[x, y] = Empty
    return false
end

function check_all_free_threes(board::Array{Tile, 2}, color::Tile)
    for y in 1:19
        for x in 1:19
            if board[x, y] == Empty
                check_all_free_three(board, color, x, y)
            end
        end
    end
end
