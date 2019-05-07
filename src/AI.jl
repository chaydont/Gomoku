function check_pair(board::Array{Tile, 2}, x::Integer, y::Integer, color::Tile, enemy::Tile)
    score = 0
    minx = x == 1 ? 1 : x - 1
    maxx = x == 19 ? 19 : x + 1
    miny = y == 1 ? 1 : y - 1
    maxy = y == 19 ? 19 : y + 1
    for j in miny:maxy
        for i in minx:maxx
            if j != y && i != x
                u = i
                v = j
                length = 0
                while u >= 1 && v >= 1  && u <= 19 && v <= 19 && board[u, v] == enemy
                    length += 1
                    u += i - x
                    v += j - y
                end
                if length == 2 && u + (i - x) >= 1 &&
                    u + (i - x) >= 19 && v + (j - y) >= 1 &&
                    v + (j - y) >= 19 && board[u + (i - x), v + (j - y)] == color
                    score += 16
                end
            end
        end
    end
    return score
end

function find_length(board, x, y, i, j)
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

function check_line(board::Array{Tile, 2}, x::Integer, y::Integer, color::Tile)
    pos = [CartesianIndex(-1, -1), CartesianIndex(-1, 0), CartesianIndex(0, -1), CartesianIndex(1, -1)]
    score = 0
    for a in pos
        i = a[1]
        j = a[2]
        length = find_length(board, x, y, i, j)
        if length >= 5
            score = 500
        elseif length != 1
            score += length * length
        end
    end
    return score
end

function heuristic(board::Array{Tile, 2}, x::Integer, y::Integer, turn::Bool)
    color = turn ? White : Black
    enemy = turn ? Black : White
    score = check_pair(board, x, y, color, enemy)
    score += check_line(board, x, y, color)
    score += check_line(board, x, y, enemy)
    score += floor(10 / (abs(10 - x) + abs(10 - y) + 1))
    return score
end


function ai(board::Array{Tile, 2}, turn::Bool=true, depth::Integer=3)
    best = turn ? -1000 : 1000
    u, v = 0, 0
    for a in CartesianIndices(board)
        x, y = Tuple(a.I)
        if board[x, y] == Empty
            if depth > 0
                board[x, y] = turn ? White : Black
                actual, i, j = ai(board, !turn, depth - 1)
                board[x, y] = Empty
            else
                actual = heuristic(board, x, y, turn)
            end
            if turn && actual > best
                best = actual
                u = x
                v = y
            elseif !turn && actual < best
                best = actual
                u = x
                v = y
            end
        end
    end
    return best, u, v
end