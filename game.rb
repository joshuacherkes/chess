# encoding: UTF-8
require './piece.rb'
require './human_player.rb'
require 'colored'

# chess_symbols = [white_chess_symbols, black_chess_symbols]
class Game
  attr_accessor :grid

  def initialize
    @grid = [
      [nil,nil,nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil,nil,nil]
    ]
    @pieces = []
    populate_grid
    collect_pieces
  end

  def run
    @player_1, @player_2 = HumanPlayer.new(self), HumanPlayer.new(self)

    loop do
      [@player_1, @player_2].each do |player|
        display
        begin
          player.takes_turn
        rescue StandardError => e
          puts "#{e.message}"
          retry
        end
        #if game over, break
      end
    end

  end

  def occupied_by(square)
    @grid[square[0]][square[1]]
  end

  def collect_pieces
    @pieces = []
    @grid.each_index do |row|
      @grid[row].each_index do |col|
        piece = occupied_by([row, col])
        @pieces << piece if piece
      end
    end
  end

  def in_check?(color)
    king_pos = nil
    @pieces.each do |piece|
      king_pos = piece.pos if piece.class == King && piece.color == color
    end
    @pieces.any? do |piece| next if piece.color == color
      piece.legal?(king_pos)
    end
  end

  def display
    main_array = write_chess_chars
    main_array = color_in(main_array)
    main_array = put_in_notation(main_array)

    main_array.map! do |row|
      puts row.join("")
    end
  end

  def put_in_notation(array)
    array.each_index do |row|
      array[row].unshift(8 - row)
    end

    array.unshift([" ", " a ", " b ", " c ", " d ", " e ", " f ", " g ", " h "])
  end

  def write_chess_chars
    main_array = []
    chess_chars = {
      King => " ♔ ",
      Queen => " ♕ ",
      Rook => " ♖ ",
      Bishop => " ♗ ",
      Knight => " ♘ ",
      Pawn => " ♙ "
    }

    @grid.each_with_index do |row, i|
     sub_array = []
     row.each_with_index do |piece, j|
       unless piece
         sub_array << "   "
         next
       end

      sub_array << chess_chars[piece.class]
     end

       main_array << sub_array
    end

    main_array
  end

  def color_in(array) #also refactor
    array.each_index do |row|
      array[row].each_with_index do |char,col|
        if (row+col) % 2 == 0

          if @grid[row][col] == nil
            array[row][col] = char.white_on_red
          elsif @grid[row][col].color == :white
            array[row][col] = char.white_on_red
          else
            array[row][col] = char.yellow_on_red
          end

        else

          if @grid[row][col] == nil
            array[row][col] = char.white_on_blue
          elsif @grid[row][col].color == :white
            array[row][col] = char.white_on_blue
          else
            array[row][col] = char.yellow_on_blue
          end

        end
      end
    end
  end
    private

    def populate_grid
      @grid[1].each_index{|i| @grid[1][i] = Pawn.new(self, [1, i], :black)}
      @grid[6].each_index{|i| @grid[6][i] = Pawn.new(self, [6, i], :white)}

      @grid[0][0] = Rook.new(self, [0, 0], :black)
      @grid[0][7] = Rook.new(self, [0, 7], :black)
      @grid[7][0] = Rook.new(self, [7, 0], :white)
      @grid[7][7] = Rook.new(self, [7, 7], :white)

      @grid[0][1] = Knight.new(self, [0, 1], :black)
      @grid[0][6] = Knight.new(self, [0, 6], :black)
      @grid[7][1] = Knight.new(self, [7, 1], :white)
      @grid[7][6] = Knight.new(self, [7, 6], :white)

      @grid[0][2] = Bishop.new(self, [0, 2], :black)
      @grid[0][5] = Bishop.new(self, [0, 5], :black)
      @grid[7][2] = Bishop.new(self, [7, 2], :white)
      @grid[7][5] = Bishop.new(self, [7, 5], :white)

      @grid[0][3] = Queen.new(self, [0, 3], :black)
      @grid[7][3] = Queen.new(self, [7, 3], :white)

      @grid[0][4] = King.new(self, [0, 4], :black)
      @grid[7][4] = King.new(self, [7, 4], :white)
    end

end
