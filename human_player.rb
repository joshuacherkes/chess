require "./game.rb"
require "./piece.rb"

class HumanPlayer
  attr_accessor :color

  def initialize(game, color)
    @game = game
    @color = color
  end

  def takes_turn
    move_data = prompt_user
    command_array = parse_input(move_data)
    start, dest = command_array[0], command_array[1]
    piece = find_piece_to_move(start)

    piece.move(dest)
  end

  def prompt_user
    puts "Please enter your turn in Standard Chess Notation ('g8, f6')"
    gets.chomp #what if it's not chess command? 7, 0 or j3, i0, or whatever
    #also what if p1 tries to move a black piece? pandemonium!
  end

  def parse_input(move_data)
    unless move_data.downcase =~ /^\s*[a-h][1-8]\s*,\s*[a-h][1-8]\s*$/
      raise "Please enter your move in the correct format"
    end

    letters = ["a","b", "c", "d", "e", "f", "g", "h"]

    array = move_data.downcase.split(",").map(&:strip)  # => ["g8", "f6"]
    array.map!{ |coord| coord.split("") } #[ ["g","8"],["f","8"] ]

    array.each do |coord|
      coord[1], coord[0] = letters.index(coord[0]), (8 - (coord[1].to_i))
    end

    array
  end

  def find_piece_to_move(pos)
    piece = @game.board[pos[0]][pos[1]]

    if piece.nil?
      raise "There's no piece there."
    elsif piece.color != @color
      raise "That's not actually your piece."
    end

    piece
  end

end