#HELLO WORLD!
#PLAYER TO PLAYER CHESS GAME




class Integer
  
  def to_square
    if (0..63).to_a.include?(self)
      then
        square = String.new
        square << ((self.to_i % 8) + "A".ord).chr
        square << ((self.to_i/8).floor + 1).to_s
    end
    return square
  end

  def move(initial_cell,terminal_cell)
    return self - 2**initial_cell + 2**terminal_cell
  end

 
  def remove(cell)
    return self - 2**cell
  end

 
  def to_cells
    cells_array = Array.new
    0.upto(63) do |i|
      cells_array << i if 2**i & self > 0
    end
    return cells_array
  end
end
#################################################
class String
 
  def to_cell
    # check if in standard form
    return nil if self.length!= 2
    rank = self[0].upcase
    file = self[1]
    cell = file.to_i*8 + (rank.ord - 65) - 8
    return cell
  end
end

class Game
  
  attr_accessor :whitePawns, :whiteKnights, :whiteBishops, :whiteRooks, :whiteQueens, :whiteKing, 
                :blackPawns, :blackKnights, :blackBishops, :blackRooks, :blackQueens, :blackKing,
                :whitePieces, :blackPieces,
                :whiteCastled, :blackCastled,
                :whitesMove


  
  def initialize
   
    @whitePawns =   0b0000000000000000000000000000000000000000000000001111111100000000
    @whiteKnights = 0b0000000000000000000000000000000000000000000000000000000001000010
    @whiteBishops = 0b0000000000000000000000000000000000000000000000000000000000100100
    @whiteRooks =   0b0000000000000000000000000000000000000000000000000000000010000001
    @whiteQueens =  0b0000000000000000000000000000000000000000000000000000000000010000
    @whiteKing =    0b0000000000000000000000000000000000000000000000000000000000001000
    # assign black pieces' cells
    @blackPawns =   0b0000000011111111000000000000000000000000000000000000000000000000
    @blackKnights = 0b0100001000000000000000000000000000000000000000000000000000000000
    @blackBishops = 0b0010010000000000000000000000000000000000000000000000000000000000
    @blackRooks =   0b1000000100000000000000000000000000000000000000000000000000000000
    @blackQueens =  0b0001000000000000000000000000000000000000000000000000000000000000
    @blackKing =    0b0000100000000000000000000000000000000000000000000000000000000000
    # game control flags
    @whitesMove = true
    @whiteCastled = false
    @blackCastles = false
  end

  def board
    @board = Array.new
    0.upto(63) do |i|
      @board[i] = nil
    end
    0.upto(63) do |i|
      bit_compare = 2**i
      @board[i] = "P" if @whitePawns    & bit_compare != 0
      @board[i] = "N" if @whiteKnights  & bit_compare != 0
      @board[i] = "B" if @whiteBishops  & bit_compare != 0
      @board[i] = "R" if @whiteRooks    & bit_compare != 0
      @board[i] = "Q" if @whiteQueens   & bit_compare != 0
      @board[i] = "K" if @whiteKing     & bit_compare != 0
      @board[i] = "p" if @blackPawns    & bit_compare != 0
      @board[i] = "n" if @blackKnights  & bit_compare != 0
      @board[i] = "b" if @blackBishops  & bit_compare != 0
      @board[i] = "r" if @blackRooks    & bit_compare != 0
      @board[i] = "q" if @blackQueens   & bit_compare != 0
      @board[i] = "k" if @blackKing     & bit_compare != 0
    end
    return @board
  end

  
  def make_move(initial_cell,terminal_cell)
   
    instance_variables.select{ |var| var =~ /Pawns|Knights|Bishops|Rooks|Queens|King/ }.each do |var|
      if opponentsPieces & 2**terminal_cell > 0
      then
        instance_variables.select{ |var2| var2 =~ /Pawns|Knights|Bishops|Rooks|Queens|King/ }.each do |opp_var|
          if 2**terminal_cell & instance_variable_get(opp_var) > 0
            instance_variable_set(opp_var,instance_variable_get(opp_var).remove(terminal_cell))
          end
        end
      end
    end
    
    instance_variables.select{ |var| var =~ /Pawns|Knights|Bishops|Rooks|Queens|King/ }.each do |var|
      if 2**initial_cell & instance_variable_get(var) > 0
        instance_variable_set(var,instance_variable_get(var).move(initial_cell,terminal_cell))
      end
    end
  end

 
  def whitePieces
    return @whitePawns | @whiteKnights | @whiteBishops | @whiteRooks | @whiteQueens | @whiteKing
  end

  # out; bitstring of black piece locations
  def blackPieces
    return @blackPawns | @blackKnights | @blackBishops | @blackRooks | @blackQueens | @blackKing
  end

  # out: bitstring of pieces belonging to the moving color
  def moversPieces
    case @whitesMove
      when true then return whitePieces
      when false then return blackPieces
    end
  end

  # out: bitstring of pieces belonging to not the moving color
  def opponentsPieces
    case @whitesMove
      when true then return blackPieces
      when false then return whitePieces
    end
  end

 

  def legal_move?(terminal_cell)
    return 2**terminal_cell & movers_pieces == 0
  end

  def save_state

  end

  # output current state or game board to terminal
  def display
    system('clear')
    puts
    # show board with pieces
    print "\t\tA\tB\tC\tD\tE\tF\tG\tH\n\n"
    print "\t    +", " ----- +"*8,"\n\n"
    8.downto(1) do |rank|
      print "\t#{rank}   |\t"
      'A'.upto('H') do |file|
        if board["#{file}#{rank}".to_cell] then piece = board["#{file}#{rank}".to_cell]
          else piece = " "
        end
        print "#{piece}   |\t"
      end
      print "#{rank}\n\n\t    +", " ----- +"*8,"\n\n"
    end
    print "\t\tA\tB\tC\tD\tE\tF\tG\tH"
    puts "\n\n"
    # show occupancy
    print " White occupancy: "
    puts whitePieces.to_cells.map{ |cell| cell.to_square}.join(", ")
    print " Black occupancy: "
    puts blackPieces.to_cells.map{ |cell| cell.to_square}.join(", ")
    puts
    # show whose move it is
    case @whitesMove
      when true
        puts " WHITE to move."
      when false
        puts " BLACK to move."
    end
    puts
  end

  def play
    until false do
      # show board
      display
      # request move
      initial_cell, terminal_cell = nil
      until !initial_cell.nil? & !terminal_cell.nil? do
        print " enter move : "
        # get move in D2-D4 format; break apart into array by "-" and remove any whitespace in each piece
        user_input = gets.strip.upcase.delete(' ')
        # if string entered is something like "A4-C5" or " a4  -C5  " etc
        if user_input =~ /[A-H][1-8]-[A-H][1-8]/
          user_move = user_input.split("-").map { |cell| cell.strip }
          # if initial square contains one of your pieces   & terminal square does not
          if ((2**user_move[0].to_cell & moversPieces) > 0) & ((2**user_move[1].to_cell & ~moversPieces) > 0)
            then
              initial_cell, terminal_cell = user_move[0].to_cell, user_move[1].to_cell
          end
        end
      end
      make_move(initial_cell,terminal_cell)
      @whitesMove = !@whitesMove
    end
  end
end

game = Game.new
game.play
