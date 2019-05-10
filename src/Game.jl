@enum Tile Empty White Black Forbidden Outside

struct Cell
    x::Integer
    y::Integer
end

mutable struct Board
    tab::Array{Tile, 2}
    pieces::Tuple{Array{Cell},Array{Cell}}
    captured::Array{Integer, 1}
    time::Array{Dates.AbstractTime, 1}
    color::Tile
    Board() = new(fill(Empty, 19, 19), ([], []), [0, 0], [Millisecond(0), Millisecond(0)], White)
    Board(board) = new(deepcopy(board.tab), deepcopy(board.pieces), copy(board.captured), copy(board.time), board.color)
end

change_color(board::Board) = board.color = !board.color

get_pieces(board::Board; enemy=false) = board.pieces[Int(enemy ? !board.color : board.color)]
add_piece(board::Board, cell; enemy=false) = add_piece(board, cell, enemy ? !board.color : board.color)
add_piece(board::Board, cell, tile) = push!(board.pieces[Int(tile)], cell)

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
    if tile in (Black, White)
        add_piece(board, cell, tile)
    end
    board.tab[cell.x, cell.y] = tile
end

function each_piece(board::Board; enemy=false)
    Channel(ctype=Cell) do chnl
        for (i, cell) in enumerate(get_pieces(board; enemy=enemy))
            if board[cell] != (enemy ? !board.color : board.color)
                deleteat!(board.pieces[Int(enemy ? !board.color : board.color)], i)
            else
                put!(chnl, cell)
            end
        end
    end
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

function is_alone(board, cell)
    for dir in EACH_DIR
        if board[cell + dir] in (Black, White)
            return false
        end
    end
    return true
end

function each_not_alone_cell(board::Board)
    Channel(ctype=Cell) do chnl
        for cell in each_empty_cell(board)
            if !is_alone(board, cell)
                put!(chnl, cell)
            end
        end
    end
end

function capture(board::Board, cell::Cell)
    result = []
    for dir in HALF_DIR
        if board[cell + dir] == !board.color && board[cell + 2dir] == !board.color && board[cell + 3dir] == board.color
            board[cell+dir] = Empty
            push!(result, cell+dir)
            board[cell+2dir] = Empty
            push!(result, cell+2dir)
        elseif board[cell - dir] == !board.color && board[cell - 2dir] == !board.color && board[cell - 3dir] == board.color
            board[cell-dir] = Empty
            push!(result, cell-dir)
            board[cell-2dir] = Empty
            push!(result, cell-2dir)
        end
    end
    result
end