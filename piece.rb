require './game.rb'
class Piece
  attr_accessor :pos, :color

  def initialize(game, pos, color)
    @game, @pos, @color = game, pos, color
  end

  def try_to_move(dest)
    raise "Not a legal move." unless move_works?(dest)
    do_move(dest)
  end

  def move_works?(dest)
    return unless legal?(dest)
    temp_board, temp_pos = @game.board.deep_dup, @pos.dup

    do_move(dest)
    works = !@game.in_check?(@color)
    set_board_to(temp_board, temp_pos)

    works
  end

    private
    def set_board_to(temp_board, temp_pos)
      @game.board, @pos = temp_board.deep_dup, temp_pos.dup
      @game.collect_pieces
    end

    def do_move(dest)
      @game.board[@pos[0]][@pos[1]] = nil
      @pos = dest
      @game.board[@pos[0]][@pos[1]] = self
      @game.collect_pieces
    end

    def diag_clear?(dest)
      delta_y, delta_x = (dest[0] - @pos[0]), (dest[1] - @pos[1])
      shift = [(delta_y / delta_y.abs) , (delta_x / delta_x.abs)]
      path = diag_path(delta_y, shift)
      path_clear?(path)
    end

    def diag_path(distance, shift)
      #debugger
      (1...distance.abs).map do |i|
        [@pos[0] + (i * shift[0]), @pos[1] + (i * shift[1])]
      end
    end

    def orthog_clear?(dest)
      path = @pos[0] == dest[0] ? horizontal_path(dest) : vertical_path(dest)
      path_clear?(path)
    end

    def horizontal_path(dest)
      left, right = [@pos, dest].sort
      ((left[1]+1)...right[1]).map{ |x| [@pos[0], x] }
    end

    def vertical_path(dest)
      up, down = [@pos, dest].sort
      ((up[0]+1)...down[0]).map{ |y| [y, @pos[1]] }
    end

    def path_clear?(path)
      path.all?{ |square| @game.occupied_by(square).nil? }
    end

    def on_same_line?(dest)
      @pos[0] == dest[0] || @pos[1] == dest[1]
    end

    def on_same_diag?(dest)
      (@pos[0] - dest[0]).abs == (@pos[1] - dest[1]).abs
    end

    def can_end_on?(square)
      on_the_board?(square) && (not friendly?(square))
    end

    def on_the_board?(square)
      square.all? { |coord| (0..7).include?(coord) }
    end

    def friendly?(square)
      piece = @game.occupied_by(square)
      piece && piece.color == @color
    end

    def delta(dest)
      [dest[0] - @pos[0], dest[1] - @pos[1]]
    end

end

class Knight < Piece
  STEPS = [
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
    can_end_on?(dest) && STEPS.include?(delta(dest))
  end

end

class Rook < Piece

  def legal?(dest)
    return unless on_same_line?(dest)
    can_end_on?(dest) && orthog_clear?(dest)
  end

end

class Bishop < Piece

  def legal?(dest)
    return unless on_same_diag?(dest)
    can_end_on?(dest) && diag_clear?(dest)
  end

end

class Queen < Piece

  def legal?(dest)
    return unless can_end_on?(dest)
    return unless (on_same_diag?(dest) || on_same_line?(dest))
    on_same_diag?(dest) ? diag_clear?(dest) : orthog_clear?(dest)
  end

end

class King < Piece

  STEPS = [
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
    can_end_on?(dest) && STEPS.include?(delta(dest))
  end

end

class Pawn < Piece

  def initialize(game, pos, color)
    super(game, pos, color)
    @home_row = @color == :white ?  6 : 1
    @facing   = @color == :white ? -1 : 1
  end

  def legal?(dest)
    return unless on_the_board?(dest)
    delta = delta(dest)
    steps.include?([delta[0], delta[1]])
  end

    private
    def steps
      steps = [one_up, two_up, flanks[0], flanks[1]]
      steps.reject{ |step| step.nil? }
    end

    def one_up
      [@facing, 0] unless @game.occupied_by([@pos[0]+@facing, @pos[1]])
    end

    def two_up
      return if @pos[0] != @home_row || one_up.nil?
      [@facing * 2, 0] unless @game.occupied_by([@pos[0]+@facing * 2, @pos[1]])
    end

    def flanks
      [[@facing, -1], [@facing, 1]].reject do |(y, x)|
        piece = @game.occupied_by([@pos[0] + y, @pos[1] + x])
        piece.nil? || piece.color == color
      end
    end

end

class Array
  def deep_dup
    inject([]) { |dup, el| dup << (el.is_a?(Array) ? el.deep_dup : el) }
  end
end
