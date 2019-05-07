enemy(color::Tile) = color == Black ? White : Black

function find_length(board, x, y, i, j, color)
    length = 1
    u = x - i
    v = y - j
    while u >= 1 && v >= 1  && u <= 19 && v <= 19 && board[u, v] == color
        length += 1
        u -= i
        v -= j
    end
    u = x + i
    v = y + j
    while u >= 1 && v >= 1  && u <= 19 && v <= 19 && board[u, v] == color
        length += 1
        u += i
        v += j
    end
    return length
end

function _check_capture(board, x, y, i, j, color)
    if board[x+i,y+j] == enemy(color) && board[x+2i,y+2j] == enemy(color) && board[x+3i, y+3j] == color
        board[x+i,y+j] = Empty
        board[x+2i,y+2j] = Empty
    end
end

function check_capture(board, x, y, color)
    for i in [  CartesianIndex(-1, 1), CartesianIndex(-1,  0),
                CartesianIndex(-1, -1), CartesianIndex(0,  1),
                CartesianIndex( 0, -1), CartesianIndex(1,  1),
                CartesianIndex( 1,  0), CartesianIndex(1, -1)]
        _check_capture(board, x, y, Tuple(i.I)..., color)
    end
end

function has_5_aligned(board, color)
    for a in CartesianIndices(board)
        x, y = Tuple(a.I)
        if board[x, y] == color
            for i in [CartesianIndex(-1, -1), CartesianIndex(-1,  0),
                      CartesianIndex( 0, -1), CartesianIndex( 1, -1)]
                find_length(board, x, y, Tuple(i.I)..., color) >= 5 && return true
            end
        end
    end
    false
end