require "./game.rb"
require "./piece.rb"

class HumanPlayer
  attr_accessor :color

  def initialize(game, color)
    @game, @color = game, color
  end

  def takes_turn
    puts "Please enter your turn in Standard Chess Notation ('g8, f6')"
    start, dest = parse_input(gets.chomp)
    piece_at(start).try_to_move(dest)
  end

    private
    def parse_input(user_input)
      unless valid(user_input)
        raise "Please enter your move in the correct format"
      end

      translated_data(parsed_data(user_input))
    end

    def parsed_data(user_input)
      user_input.downcase.split(",").map(&:strip).map { |coord| coord.split("") }
    end

    def translated_data(parsed_data)
      letters = ["a","b", "c", "d", "e", "f", "g", "h"]
      parsed_data.each do |coord|
        coord[1], coord[0] = letters.index(coord[0]), (8 - (coord[1].to_i))
      end
    end

    def valid(user_input)
      user_input.downcase =~ /^\s*[a-h][1-8]\s*,\s*[a-h][1-8]\s*$/
    end

    def piece_at(pos)
      validate_piece(@game.board[pos[0]][pos[1]])
    end

    def validate_piece(piece)
      if piece.nil?
        raise "There's no piece there."
      elsif piece.color != @color
        raise "That's not actually your piece."
      end

      piece
    end
end