# function check_pair(board::Array{Tile, 2}, x::Integer, y::Integer, color::Tile, enemy::Tile)
#     score = 0
#     minx = x == 1 ? 1 : x - 1
#     maxx = x == 19 ? 19 : x + 1
#     miny = y == 1 ? 1 : y - 1
#     maxy = y == 19 ? 19 : y + 1
#     for j in miny:maxy
#         for i in minx:maxx
#             if j != y && i != x
#                 u = i
#                 v = j
#                 length = 0
#                 while u >= 1 && v >= 1  && u <= 19 && v <= 19 && board[u, v] == enemy
#                     length += 1
#                     u += i - x
#                     v += j - y
#                 end
#                 if length == 2 && u + (i - x) >= 1 &&
#                     u + (i - x) >= 19 && v + (j - y) >= 1 &&
#                     v + (j - y) >= 19 && board[u + (i - x), v + (j - y)] == color
#                     score += 16
#                 end
#             end
#         end
#     end
#     return score
# end

# function find_length(board, x, y, i, j)
#     length = 1
#     u = x - i
#     v = y - j
#     while u >= 1 && v >= 1  && u <= 19 && v <= 19 && board[u, v] == color
#         length += 1
#         u -= i
#         v -= j
#     end
#     u = x + i
#     v = y + j
#     while u >= 1 && v >= 1  && u <= 19 && v <= 19 && board[u, v] == color
#         length += 1
#         u += i
#         v += j
#     end
#     return length
# end

# function check_line(board::Array{Tile, 2}, x::Integer, y::Integer, color::Tile)
#     pos = [CartesianIndex(-1, -1), CartesianIndex(-1, 0), CartesianIndex(0, -1), CartesianIndex(1, -1)]
#     score = 0
#     for a in pos
#         i = a[1]
#         j = a[2]
#         length = find_length(board, x, y, i, j)
#         if length >= 5
#             score = 500
#         elseif length != 1
#             score += length * length
#         end
#     end
#     return score
# end

function heuristic(board::Array{Tile, 2}, color::Tile)

    return score
end


function ai(board::Array{Tile, 2},color::Tile, depth::Integer=3)
    best = 10000000
    best_cell = Cell(0, 0)
    for cell in each_emtpy_cell(board)
        board[cell] = color
        if depth > 0
            actual, acutal_cell = -ai(board, enemy(color), depth - 1)
        else
            actual = heuristic(board, color)
        end
        board[cell] = Empty
        if actual < best
            best = actual
            best_cell = cell
        end
    end
    return best, best_cell
end