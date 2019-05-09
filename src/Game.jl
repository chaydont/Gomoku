@enum Tile Empty White Black Forbidden Outside

struct Cell
    x::Integer
    y::Integer
end

mutable struct Board
    tab::Array{Tile, 2}
    forbiddens::Array{Cell, 1}
    captured::Array{Integer, 1}
    time::Array{Dates.AbstractTime, 1}
    color::Tile
    Board() = new(fill(Empty, 19, 19), [], [0, 0], [Millisecond(0), Millisecond(0)], White)
    Board(board) = new(deepcopy(board.tab), copy(board.forbiddens), copy(board.captured), copy(board.time), board.color)
end

get_time(board::Board; enemy=false) = board.time[Int(enemy ? !board.color : board.color)]
set_time(board::Board, value; enemy=false) = board.time[Int(enemy ? !board.color : board.color)] = value
add_time(board::Board, value; enemy=false) = board.time[Int(enemy ? !board.color : board.color)] += value

get_captured(board::Board; enemy=false) = board.captured[Int(enemy ? !board.color : board.color)]
set_captured(board::Board, value; enemy=false) = board.captured[Int(enemy ? !board.color : board.color)] = value
add_captured(board::Board, value; enemy=false) = board.captured[Int(enemy ? !board.color : board.color)] += value

function Base.getindex(board::Board, cell::Cell)
    (cell.y < 1 || cell.y > 19) && return Outside
    (cell.x < 1 || cell.x > 19) && return Outside
    board.tab[cell.x, cell.y]
end

function Base.setindex!(board::Board, tile::Tile, cell::Cell)
    (cell.y < 1 || cell.y > 19) && @error "Failing to write $tile at index $cell"
    (cell.x < 1 || cell.x > 19) && @error "Failing to write $tile at index $cell"
    board.tab[cell.x, cell.y] = tile
end

import Base.+
import Base.-
import Base.*
import Base.!

+(a::Cell, b::Cell)    = Cell(a.x + b.x, a.y + b.y)
-(a::Cell, b::Cell)    = Cell(a.x - b.x, a.y - b.y)
*(a::Integer, b::Cell) = Cell(a * b.x,   a * b.y)
*(a::Cell, b::Integer) = Cell(a.x * b,   a.y * b)
!(color::Tile) = color == Black ? White : Black


const EACH_DIR = Cell[Cell(j, i) for i in -1:1 for j in -1:1 if !(i == j == 0)]
const HALF_DIR = EACH_DIR[5:end]

function each_cell()
    Channel(ctype=Cell) do chnl
        for i in 1:19
            for j in 1:19
                put!(chnl, Cell(i, j))
            end
        end
    end
end

function each_empty_cell(board::Board)
    Channel(ctype=Cell) do chnl
        for cell in each_cell()
            if board[cell] == Empty
                put!(chnl, cell)
            end
        end
    end
end

function find_length(board::Board, current::Cell, dir::Cell)
    length = 1
    cell = current - dir
    while board[cell] == board.color
        length += 1
        cell -= dir
    end
    cell = current + dir
    while board[cell] == board.color
        length += 1
        cell += dir
    end
    length
end

function capture(board::Board, cell::Cell)
    result = 0
    for dir in EACH_DIR
        if board[cell+dir] == !board.color && board[cell+2dir] == !board.color && board[cell+3dir] == board.color
            board[cell+dir] = Empty
            board[cell+2dir] = Empty
            result += 2
        end
    end
    return result
end