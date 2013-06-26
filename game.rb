# encoding: UTF-8
require './piece.rb'
require './human_player.rb'
require 'colored'

class Game
  attr_accessor :board

  def initialize
    @board = (0...8).map { [nil] * 8 }
    populate_board
    collect_pieces
  end

  def run
    make_players
    player = @player_1

    loop do
      display
      break if game_end?(player)
      puts "#{player.color.capitalize} to move."

      try_turn(player)

      player = player == @player_1 ? @player_2 : @player_1
    end

    put_results(player)
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

  def in_check?(color)
    king_pos = nil
    @pieces.each do |piece|
      king_pos = piece.pos if piece.class == King && piece.color == color
    end
    @pieces.any? do |piece| next if piece.color == color
      piece.legal?(king_pos)
    end
  end


    private
    def make_players
      @player_1 = HumanPlayer.new(self, :white)
      @player_2 = HumanPlayer.new(self, :black)
    end

    def populate_board
      corner = [Rook, Knight, Bishop]
      middle = [Queen, King]
      back_rank = corner + middle + corner.reverse

      @board[1].each_index{|i| @board[1][i] = Pawn.new(self, [1, i], :black)}
      @board[6].each_index{|i| @board[6][i] = Pawn.new(self, [6, i], :white)}

      8.times do |i|
        @board[0][i] = back_rank[i].new(self, [0, i], :black)

      end

      8.times do |i|
        @board[7][i] = back_rank[i].new(self, [7, i], :white)
      end
    end

    def display
      put_in_notation(chess_chars).each { |row| puts row.join }
    end

    def put_in_notation(array)
      array.each_index { |row| array[row].unshift(8 - row) }
      array.unshift([" "] + (" a ".." h ").to_a)
    end

    def generate_all_squares
      array = []
      (0..7).each { |y| (0..7).each { |x| array << [y,x] } }
      array
    end

    def chess_chars
      array = (0...8).map { [nil] * 8 }

      @board.each_index do |row|
        @board[row].each_with_index do |piece,col|
          if (row+col) % 2 == 0
            array[row][col] = colorize(piece, "white")
          else
            array[row][col] = colorize(piece, "black")
          end
        end
      end

      array
    end

    def colorize(piece, background)
      char_hash = {
        King => " ♔ ",
        Queen => " ♕ ",
        Rook => " ♖ ",
        Bishop => " ♗ ",
        Knight => " ♘ ",
        Pawn => " ♙ ",
        NilClass => "   "
      }

      if piece.nil? || piece.color == :white
        char_hash[piece.class].send("magenta_on_#{background}".to_sym)
      else
        char_hash[piece.class].send("blue_on_#{background}".to_sym)
      end
    end

    def game_end?(player)
      no_possible_moves?(player)
    end

    def try_turn(player)
      begin
        player.takes_turn
      rescue StandardError => e
        puts "#{e.message}"
        retry
      end
    end

    def put_results(player)
      if in_check?(player.color)
        puts "Oh snap, #{player.color} got checkmated!"
      else
        puts "Ha, you got a stalemate, whaaat."
      end
    end

    def no_possible_moves?(player)
      array = generate_all_squares
       @pieces.each do |piece|
         next unless piece.color == player.color
         array.each do |square|
           return false if piece.move_works?(square)
         end
       end
       true
    end

end

if __FILE__ == $PROGRAM_NAME
  game = Game.new
  game.run
end