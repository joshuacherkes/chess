require './game.rb'

class Piece
  attr_accessor :pos, :color

  def initialize(board, pos, color)
    @board, @pos, @color = board, pos, color
  end

  def d_dup(array)
    array.inject([]) { |dup, el| dup << (el.is_a?(Array) ? d_dup(el) : el) }
  end

  def move(dest)
    if legal?(dest)
      temp_grid, temp_pos  = d_dup(@board.grid), @pos.dup
      @board.grid[@pos[0]][@pos[1]] = nil
      @pos = dest
      @board.grid[@pos[0]][@pos[1]] = self
      @board.collect_pieces

     # debugger
      if @board.in_check?(self.color)
        @board.grid = d_dup(temp_grid)
        @pos = temp_pos.dup
        @board.collect_pieces
        raise "Your King would DIE!"
      end

      @board.collect_pieces

    else
      raise "Not a Legal move, bro"
    end

  end



  def orthog_clear?(dest) #NEED TO REFACTOR
    #position = [4,4] dest = [7, 4] || [4, 1]
    #debugger
    axis = @pos[0] == dest[0] ? :x : :y
    path = []

    case axis
    when :x
      if dest[1] - @pos[1] >= 0
        (@pos[1]...dest[1]).each do |x|
          next if x == @pos[1]
          path << [@pos[0], x]
        end

      else
        #dest 7 6 pos 7 7
        ((dest[1]+1)..@pos[1]).each do |x|
          next if x == @pos[1] #(dest[1]+1)
          path << [@pos[0], x]
        end
      end

    when :y
      if dest[0] - @pos[0] >= 0
        (@pos[0]...dest[0]).each do |y|
          next if y == @pos[0]
          path << [y, @pos[1]]
        end

      else
        ((dest[0]+1)..@pos[0]).each do |y|
          next if y == (dest[0]+1)
          path << [y, @pos[1]]
        end
      end
    end

    #make path select the right squares
    path.all?{ |square| @board.occupied_by(square).nil? }
  end #method

  def diag_clear?(dest) #NEED TO REFACTOR
    first, second = (dest[0] - @pos[0]), (dest[1] - @pos[1])
    shift = [(first / first.abs), (second / second.abs)]

    path = []
    (first.abs).times do |i|
      next if i == 0
        path << [@pos[0] + (i * shift[0]), @pos[1] + (i * shift[1])]
    end

    path.all?{ |square| @board.occupied_by(square).nil? }
  end #method

  def can_end?(square)
    on_the_board?(square) && (not friendly?(square))
  end

  def on_the_board?(square)
    square.all? {|coord| (0..7).include?(coord) }
  end

  def friendly?(square)
    piece = @board.occupied_by(square)
    piece && piece.color == @color
  end

  def enemy?(square)
    piece = @board.occupied_by(square)
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

    @@shifts.include?(diff) && can_end?(dest)
  end

end

class Rook < Piece

  def legal?(dest)
    return unless @pos[0] == dest[0] || @pos[1] == dest[1]

    orthog_clear?(dest) && can_end?(dest)
  end

end

class Bishop < Piece

  def legal?(dest)
    return unless (@pos[0] - dest[0]).abs == (@pos[1] - dest[1]).abs

    diag_clear?(dest) && can_end?(dest)
  end

end

class Queen < Piece

  def legal?(dest)
    diag = (@pos[0] - dest[0]).abs == (@pos[1] - dest[1]).abs
    orthog = (@pos[0] == dest[0] || @pos[1] == dest[1])

    return unless diag || orthog

    diag ? diag_clear?(dest) : orthog_clear?(dest) && can_end?(dest)
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

    @@shifts.include?(diff) && can_end?(dest)
  end

end

class Pawn < Piece

  def initialize(board, pos, color)
    super(board, pos, color)

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
    unless @board.occupied_by([@pos[0]+@facing, @pos[1]])
      shifts << [@facing, 0]
      if @pos[0] == @home_row && !@board.occupied_by([@pos[0]+@facing * 2, @pos[1]])
        shifts << [@facing * 2, 0]
      end
    end

    [-1,1].each do |x|
      piece = @board.occupied_by([@pos[0]+@facing, @pos[1] + x])
      next if piece.nil?

      shifts << [@facing, x] if piece.color != color
    end

    shifts
  end

end

=begin
  knight: check 8 spaces relative to current pos;
          select those that are on the board
          and aren't occupied by own_color pieces

  rook, bishop, queen: along {diagonal/orthogonal} lines,
          recursively check if each square is occupied by
          an enemy piece (then end and include that square),
          if it is occupied by own_color piece
          (then end but don't include), or if the square
          is off the board (then end but don't include).

  king:   check 8 spaces relative to current pos,
          see if they are off the board / occupied by same color piece.

  pawn:   check space in front; if empty, can move there. check two
          spaces forward-diagonal; iff occupied by enemy piece, can
          move there. if on starting pos, and space in front
          is empty, and two spaces in front is empty, can move there.
=end


#illegal moves: if the pos after making an otherwise legal move
  #would have your king in a pos where an enemy piece could move to
  #that pos, that move is illegal.
#if you have no legal moves, you are checkmated