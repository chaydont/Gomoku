using SimpleDirectMediaLayer
const SDL = SimpleDirectMediaLayer

const WINDOW_SIZE = 1000
const TILE_SIZE = Int(floor(WINDOW_SIZE / 19))
const STONE_SIZE = Int(floor(TILE_SIZE * 0.9))
const OFFSET = Int(floor(WINDOW_SIZE / 125))

SDL.Init(SDL.INIT_VIDEO)

window = SDL.CreateWindow("Gomoku", Int32(100), Int32(100), Int32(WINDOW_SIZE), Int32(WINDOW_SIZE), SDL.WINDOW_SHOWN)
renderer = SDL.CreateRenderer(window, Int32(-1), SDL.RENDERER_ACCELERATED | SDL.RENDERER_PRESENTVSYNC)

board_texture = SDL.CreateTextureFromSurface(renderer, SDL.LoadBMP("resources/board.bmp"))
black_texture = SDL.CreateTextureFromSurface(renderer, SDL.LoadBMP("resources/black.bmp"))
white_texture = SDL.CreateTextureFromSurface(renderer, SDL.LoadBMP("resources/white.bmp"))

function create_background()
    dir = SDL.Rect(0, 0, WINDOW_SIZE, WINDOW_SIZE)
    src = SDL.Rect(0, 0, 2000, 2000)
    SDL.RenderCopy(renderer, board_texture, Ref(src), Ref(dir))
end

function place_pieces(board::AbstractArray{Tile, 2})
    for a in CartesianIndices(board)
        x, y = Tuple(a.I)
        piece = board[x, y]
        if piece in (Black, White)
            dir = SDL.Rect((x - 1) * TILE_SIZE + OFFSET, (y - 1) * TILE_SIZE + OFFSET, STONE_SIZE, STONE_SIZE)
            src = SDL.Rect(0, 0, 384, 384)
            SDL.RenderCopy(renderer, piece == Black ? black_texture : white_texture, Ref(src), Ref(dir))
        end
    end
end

function display_board(board::AbstractArray{Tile, 2})
    create_background()
    place_pieces(board)
    SDL.RenderPresent(renderer)
end