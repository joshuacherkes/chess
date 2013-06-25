# encoding: UTF-8

chess_symbols = [white_chess_symbols, black_chess_symbols]
white_chess_symbols = {king: "♔", queen: "♕", rook: "♖", bishop: "♗",
                       knight: "♘", pawn: "♙"}
black_chess_symbols = {king: "♚", queen: "♛", rook: "♜", bishop: "♝",
                       knight: "♞", pawn: "♟"}

class Piece
  def initialize(position, color)
  @position, @color = position, color
  end

  def move
=begin 
  knight: check 8 spaces relative to current position;
          select those that are on the board
          and aren't occupied by own_color pieces

  rook, bishop, queen: along {diagonal/orthogonal} lines, 
          recursively check if each square is occupied by
          an enemy piece (then end and include that square),
          if it is occupied by own_color piece 
          (then end but don't include), or if the square 
          is off the board (then end but don't include).

  king:   check 8 spaces relative to current position, 
          see if they are off the board / occupied by same color piece.

  pawn:   check space in front; if empty, can move there. check two
          spaces forward-diagonal; iff occupied by enemy piece, can
          move there. if on starting position, and space in front 
          is empty, and two spaces in front is empty, can move there. 
=end
  end
end 

#illegal moves: if the position after making an otherwise legal move 
  #would have your king in a position where an enemy piece could move to
  #that position, that move is illegal.
#if you have no legal moves, you are checkmated