require 'debugger'
require './game.rb'

class Piece
  attr_accessor :pos, :color

  def initialize(game, pos, color)
    @game, @pos, @color = game, pos, color
  end

  def d_dup(array)
    array.inject([]) { |dup, el| dup << (el.is_a?(Array) ? d_dup(el) : el) }
  end

  def move_works?(dest)

    return false unless legal?(dest)
    temp_board, temp_pos  = d_dup(@game.board), @pos.dup
    do_move(dest)
    works = !(@game.in_check?(@color))
    undo_move(temp_board, temp_pos)
    works
  end

  def undo_move(temp_board, temp_pos)
    @game.board, @pos  = d_dup(temp_board), temp_pos.dup
    @game.collect_pieces
  end

  def do_move(dest)
    @game.board[@pos[0]][@pos[1]] = nil
    @pos = dest
    @game.board[@pos[0]][@pos[1]] = self
    @game.collect_pieces
  end


  def move(dest)
    raise "Not a legal move." unless move_works?(dest)

    do_move(dest)
  end


    # test a move    #
    # if legal?(dest)
    #   temp_board, temp_pos  = d_dup(@game.board), @pos.dup
    #   @game.board[@pos[0]][@pos[1]] = nil
    #   @pos = dest
    #   @game.board[@pos[0]][@pos[1]] = self
    #   @game.collect_pieces
    #   #do the move
    #  # debugger
    #   if @game.in_check?(@color)

  #
  #     end
  #
  #     @game.collect_pieces
  #
  #   else
  #
  #   end
  #
  # end



  def orthog_clear?(dest)
    #debugger
    path = @pos[0] == dest[0] ? horizontal_path(dest) : vertical_path(dest)

    path.all?{ |square| @game.occupied_by(square).nil? }
  end

  def horizontal_path(dest)
    left, right = [@pos, dest].sort

    ((left[1]+1)...right[1]).map{ |x| [@pos[0], x] }
  end

  def vertical_path(dest)
    up, down = [@pos, dest].sort

    ((up[0]+1)...down[0]).map{ |y| [y, @pos[1]] }
  end

  def diag_clear?(dest) #NEED TO REFACTOR
    first, second = (dest[0] - @pos[0]), (dest[1] - @pos[1])
    shift = [(first / first.abs), (second / second.abs)]

    path = []
    (first.abs).times do |i|
      next if i == 0
        path << [@pos[0] + (i * shift[0]), @pos[1] + (i * shift[1])]
    end

    path.all?{ |square| @game.occupied_by(square).nil? }
  end #method

  def can_end?(square)
    on_the_board?(square) && (not friendly?(square))
  end

  def on_the_board?(square)
    square.all? {|coord| (0..7).include?(coord) }
  end

  def friendly?(square)
    piece = @game.occupied_by(square)
    piece && piece.color == @color
  end

  def enemy?(square)
    piece = @game.occupied_by(square)
    piece && piece.color != @color
  end
end

class Knight < Piece
  @@shifts = [
    [-2, -1],
    [-2,  1],
    [-1, -2],
    [-1,  2],
    [ 1, -2],
    [ 1,  2],
    [ 2, -1],
    [ 2,  1]
  ]

  def legal?(dest)
    diff = [
      @pos[0] - dest[0],
      @pos[1] - dest[1]
    ]

    can_end?(dest) && @@shifts.include?(diff)
  end

end

class Rook < Piece

  def legal?(dest)
    return unless @pos[0] == dest[0] || @pos[1] == dest[1]

    can_end?(dest) && orthog_clear?(dest)
  end

end

class Bishop < Piece

  def legal?(dest)
    return unless (@pos[0] - dest[0]).abs == (@pos[1] - dest[1]).abs

    can_end?(dest) && diag_clear?(dest)
  end

end

class Queen < Piece

  def legal?(dest)
    diag = (@pos[0] - dest[0]).abs == (@pos[1] - dest[1]).abs
    orthog = (@pos[0] == dest[0] || @pos[1] == dest[1])

    return unless diag || orthog

    can_end?(dest) && (diag ? diag_clear?(dest) : orthog_clear?(dest))
  end

end

class King < Piece

  @@shifts = [
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, -1],
    [0, 1],
    [1, -1],
    [1, 0],
    [1, 1]
  ]

  def legal?(dest)
    diff = [
      @pos[0] - dest[0],
      @pos[1] - dest[1]
    ]

    can_end?(dest) && @@shifts.include?(diff)
  end

end

class Pawn < Piece

  def initialize(game, pos, color)
    super(game, pos, color)

    @home_row = @color == :white ? 6 : 1
    @facing = @color == :white ? -1 : 1
  end


  def legal?(dest)
    return unless on_the_board?(dest)

    delta = [dest[0] - @pos[0], dest[1] - @pos[1]]
    can_move_to.include?(delta)
  end

  def can_move_to
    shifts = []
    unless @game.occupied_by([@pos[0]+@facing, @pos[1]])
      shifts << [@facing, 0]
      if @pos[0] == @home_row && !@game.occupied_by([@pos[0]+@facing * 2, @pos[1]])
        shifts << [@facing * 2, 0]
      end
    end

    [-1,1].each do |x|
      piece = @game.occupied_by([@pos[0]+@facing, @pos[1] + x])
      next if piece.nil?

      shifts << [@facing, x] if piece.color != color
    end

    shifts
  end

end
