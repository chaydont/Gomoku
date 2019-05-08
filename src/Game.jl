@enum Tile White Black Empty Forbidden Outside

struct Cell
    x::Integer
    y::Integer
end

function Base.getindex(board::Array{Tile,2}, cell::Cell)
    (cell.y < 1 || cell.y > 19) && return Outside
    (cell.x < 1 || cell.x > 19) && return Outside
    board[cell.x, cell.y]
end

function Base.setindex!(board::Array{Tile,2}, tile::Tile, cell::Cell)
    (cell.y < 1 || cell.y > 19) && @error "Failing to write $tile at index $cell"
    (cell.x < 1 || cell.x > 19) && @error "Failing to write $tile at index $cell"
    board[cell.x, cell.y] = tile
end

import Base.+
import Base.-
import Base.*

+(a::Cell, b::Cell)    = Cell(a.x + b.x, a.y + b.y)
-(a::Cell, b::Cell)    = Cell(a.x - b.x, a.y - b.y)
*(a::Integer, b::Cell) = Cell(a * b.x,   a * b.y)

function each_cell()
    Channel(ctype=Cell) do chnl
        for i in 1:19
            for j in 1:19
                put!(chnl, Cell(i, j))
            end
        end
    end
end

enemy(color::Tile) = color == Black ? White : Black

function find_length(board, current::Cell, dir::Cell, color)
    length = 1
    cell = current - dir
    while board[cell] == color
        length += 1
        cell -= dir
    end
    cell = current + dir
    while board[cell] == color
        length += 1
        cell += dir
    end
    length
end

each_dir(; half=false) = [Cell(i, j) for i in -1:1 for j in -1:1 if !(i == j == 0) && (!half || i + j <= 0)]

function check_capture(board, cell, color)
    for dir in each_dir()
        if board[cell+dir] == enemy(color) && board[cell+2dir] == enemy(color) && board[cell+3dir] == color
            board[cell+dir] = Empty
            board[cell+2dir] = Empty
        end
    end
end

function has_5_aligned(board, cell, color)
    for i in each_dir(half=true)
        find_length(board, cell, i, color) >= 5 && return true
    end
    false
end