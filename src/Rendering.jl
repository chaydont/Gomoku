const BOARD_SIZE = 750
const MENU_SIZE = 250
const TILE_SIZE = Int(floor(BOARD_SIZE / 19))
const STONE_SIZE = Int(floor(TILE_SIZE * 0.9))
const OFFSET = Int(floor(BOARD_SIZE / 125))

const MENU_COLOR = (220, 179, 92, 255)
const TIMER_COLOR = (64, 64, 64, 255)
const OUTSIDE_COLOR = (128, 128, 128, 255)
const NUMBERS_COLOR = (193, 53, 59, 255)

SDL.Init(SDL.INIT_VIDEO)

window = SDL.CreateWindow("Gomoku", Int32(0), Int32(0), Int32(BOARD_SIZE + MENU_SIZE), Int32(BOARD_SIZE), SDL.WINDOW_SHOWN)
renderer = SDL.CreateRenderer(window, Int32(-1), SDL.RENDERER_ACCELERATED | SDL.RENDERER_PRESENTVSYNC)

board_texture =   SDL.CreateTextureFromSurface(renderer, SDL.LoadBMP(joinpath(@__DIR__, "..", "resources", "board.bmp")))
black_texture =   SDL.CreateTextureFromSurface(renderer, SDL.LoadBMP(joinpath(@__DIR__, "..", "resources", "black.bmp")))
white_texture =   SDL.CreateTextureFromSurface(renderer, SDL.LoadBMP(joinpath(@__DIR__, "..", "resources", "white.bmp")))
numbers_texture = SDL.CreateTextureFromSurface(renderer, SDL.LoadBMP(joinpath(@__DIR__, "..", "resources", "numbers.bmp")))

function create_background()
    SDL.SetRenderDrawColor(renderer, MENU_COLOR...)
    SDL.RenderFillRect(renderer, Ref(SDL.Rect(BOARD_SIZE, 0, MENU_SIZE, BOARD_SIZE)))

    dir = SDL.Rect(0, 0, BOARD_SIZE, BOARD_SIZE)
    src = SDL.Rect(0, 0, 2000, 2000)
    SDL.RenderCopy(renderer, board_texture, Ref(src), Ref(dir))
end

function place(x, y, piece::Tile)
    dir = SDL.Rect(x, y, STONE_SIZE, STONE_SIZE)
    src = SDL.Rect(0, 0, 384, 384)
    SDL.RenderCopy(renderer, piece == Black ? black_texture : white_texture, Ref(src), Ref(dir))
end

function place_pieces(board::Board)
    for cell in each_cell()
        piece = board[cell]
        if piece in (Black, White)
            place((cell.x - 1) * TILE_SIZE + OFFSET, (cell.y - 1) * TILE_SIZE + OFFSET, piece)
        end
    end
end

function write_number(number::Integer, place::Integer, player::Tile)
    offset = place * 35 + (place > 1 ? 11 : 0)
    dir = SDL.Rect(BOARD_SIZE + 37 + offset, 57 + (player==Black ? BOARD_SIZE / 2 : 0), 43, 61)
    src = SDL.Rect(Int(floor(62.3 * number)), 0, 62, 88)
    SDL.RenderCopy(renderer, numbers_texture, Ref(src), Ref(dir))
end

function display_time(time::Period, player::Tile)
    write_number(div(time.value, 10000) % 10, 0, player)
    write_number(div(time.value, 1000) % 10, 1, player)
    SDL.SetRenderDrawColor(renderer, NUMBERS_COLOR...)

    SDL.RenderFillRect(renderer, Ref(SDL.Rect(BOARD_SIZE + 114, 79 + (player==Black ? BOARD_SIZE / 2 : 0), 7, 7)))
    SDL.RenderFillRect(renderer, Ref(SDL.Rect(BOARD_SIZE + 114, 95 + (player==Black ? BOARD_SIZE / 2 : 0), 7, 7)))

    centi = div(time.value, 10)
    write_number(div(time.value, 100) % 10, 2, player)
    write_number(div(time.value, 10) % 10, 3, player)
end

function display_timer(time::Millisecond, player::Tile)
    SDL.SetRenderDrawColor(renderer, OUTSIDE_COLOR...)
    SDL.RenderFillRect(renderer, Ref(SDL.Rect(BOARD_SIZE + 30, 50 + (player==Black ? BOARD_SIZE / 2 : 0), 175, 75)))

    SDL.SetRenderDrawColor(renderer, TIMER_COLOR...)
    SDL.RenderFillRect(renderer, Ref(SDL.Rect(BOARD_SIZE + 37, 57 + (player==Black ? BOARD_SIZE / 2 : 0), 161, 61)))

    display_time(time, player)
end

function display_captured(number::Integer, player::Tile)
    for i in 15:15:(15 * number)
        place(BOARD_SIZE + 20 + i, 150 + (player==White ? BOARD_SIZE / 2 : 0), player)
    end
end

function display_board(board::Board)
    create_background()
    display_timer(board.time[Int(White)], Black)
    display_timer(board.time[Int(Black)], White)
    display_captured(board.captured[Int(Black)], White)
    display_captured(board.captured[Int(White)], Black)
    place_pieces(board)
    SDL.RenderPresent(renderer)
end