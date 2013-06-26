# encoding: UTF-8
require './piece.rb'
require './human_player.rb'
require 'colored'

class Game
  attr_accessor :board

  def initialize
    @board = [
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
    populate_board
    collect_pieces
  end

  def run
    @player_1 = HumanPlayer.new(self, :white)
    @player_2 = HumanPlayer.new(self, :black)

    loop do
      [@player_1, @player_2].each do |player|
        display

        if no_possible_moves?(player.color)
          if in_check?(player.color)
            puts "Oh snap, #{player.color} got checkmated!"
          else
            puts "Ha, you got a stalemate, whaaat."
          return
          end
        end

        puts "#{player.color.capitalize} to move."
        begin
          player.takes_turn
        rescue StandardError => e
          puts "#{e.message}"
          retry
        end
      end
    end
  end



  def occupied_by(square)
    @board[square[0]][square[1]]
  end

  def collect_pieces
    @pieces = []
    @board.each_index do |row|
      @board[row].each_index do |col|
        piece = occupied_by([row, col])
        @pieces << piece if piece
      end
    end
  end

  def no_possible_moves?(color)
    array = generate_all_squares
     @pieces.each do |piece|
       next unless piece.color == color
       array.each do |square|
         return false if piece.move_works?(square)
       end
     end
     true
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
    array = write_chess_chars
    array = color_in(array)
    array = put_in_notation(array)

    array.each {|row| puts row.join("")}
  end



    private

    def populate_board
      @board[1].each_index{|i| @board[1][i] = Pawn.new(self, [1, i], :black)}
      @board[6].each_index{|i| @board[6][i] = Pawn.new(self, [6, i], :white)}

      @board[0][0] = Rook.new(self, [0, 0], :black)
      @board[0][7] = Rook.new(self, [0, 7], :black)
      @board[7][0] = Rook.new(self, [7, 0], :white)
      @board[7][7] = Rook.new(self, [7, 7], :white)

      @board[0][1] = Knight.new(self, [0, 1], :black)
      @board[0][6] = Knight.new(self, [0, 6], :black)
      @board[7][1] = Knight.new(self, [7, 1], :white)
      @board[7][6] = Knight.new(self, [7, 6], :white)

      @board[0][2] = Bishop.new(self, [0, 2], :black)
      @board[0][5] = Bishop.new(self, [0, 5], :black)
      @board[7][2] = Bishop.new(self, [7, 2], :white)
      @board[7][5] = Bishop.new(self, [7, 5], :white)

      @board[0][3] = Queen.new(self, [0, 3], :black)
      @board[7][3] = Queen.new(self, [7, 3], :white)

      @board[0][4] = King.new(self, [0, 4], :black)
      @board[7][4] = King.new(self, [7, 4], :white)
    end

    def put_in_notation(array)
      array.each_index do |row|
        array[row].unshift(8 - row)
      end

      array.unshift([" "] + (" a ".." h ").to_a)
    end

    def write_chess_chars
      array = []
      chess_chars = {
        King => " ♔ ",
        Queen => " ♕ ",
        Rook => " ♖ ",
        Bishop => " ♗ ",
        Knight => " ♘ ",
        Pawn => " ♙ "
      }

      @board.each_with_index do |row, i|
        array[i] = []
        row.each do |piece|
          array[i] << "   " && next unless piece
          array[i] << chess_chars[piece.class]
          end
      end
      array
    end

    def generate_all_squares
      array = []
      (0..7).each do |y|
        (0..7).each do |x|
          array << [y,x]
        end
      end
      array
    end

    def color_in(array) #also refactor
      array.each_index do |row|
        array[row].each_with_index do |char,col|
          if (row+col) % 2 == 0

            if @board[row][col] == nil
              array[row][col] = char.yellow_on_white
            elsif @board[row][col].color == :white
              array[row][col] = char.magenta_on_white
            else
              array[row][col] = char.blue_on_white
            end

          else

            if @board[row][col] == nil
              array[row][col] = char.yellow_on_black
            elsif @board[row][col].color == :white
              array[row][col] = char.magenta_on_black
            else
              array[row][col] = char.blue_on_black
            end

          end
        end
      end
    end

end
