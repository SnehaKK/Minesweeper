require 'byebug'

class Board
  NUM_MINES = 10

  attr_reader :num_rows, :num_cols
  attr_accessor :mine_arr

  def initialize(num_rows = 9, num_cols = 9)
    @grid = Array.new(num_rows) { Array.new(num_cols) }
    @num_rows = num_rows
    @num_cols = num_cols
    @mine_arr = []
    initialize_board
    randomize_board
  end

  def initialize_board
    num_rows.times do |row|
      num_cols.times do |col|
        self[row,col]= Tile.new(self,[row,col],0)
      end
    end
  end

  def [](row, col)
    @grid[row][col]
  end

  def []=(row, col, value)
    @grid[row][col] = value
  end

  def display
    num_rows.times do |row|
      str = ''
      num_cols.times do |col|
        tile = self[row,col]
        # Check the tile state and update the symbols approrpiately
        if tile.face == :down
          str << ((tile.state == :flagged) ? 'F' : '*') + " "
        else
          str << char_for_tile_state(tile) + " "
        end
      end
      puts str
    end
  end

  def char_for_tile_state(tile)
    case(tile.state)
    when :interior ; "_"
    else tile.value.to_s
    end
  end

  def secret_display
    num_rows.times do |row|
      str = ''
      num_cols.times do |col|
        tile = self[row,col]
        str << tile.value.to_s + " "
      end
      puts str
    end
  end


  private
  def randomize_board
    place_mines
    place_numbers
  end

  def place_mines
    until (mine_arr.count == NUM_MINES) do
      row = rand(num_rows)
      col = rand(num_cols)
      # put mines on rand num_min positions
      unless mine_arr.include?([row,col])
        self[row,col].value = :m
        mine_arr << [row,col]
      end
    end
  end

  def place_numbers
    # Find neighbors of the Mine tile and increment the value
    mine_arr.each do |mine_pos|
      self[*mine_pos].neighbors.each do |tile_pos|
        tile = self[*tile_pos]
        # tile.value = 0 if tile.value.nil?
        tile.value += 1 unless tile.value == :m
      end
    end
  end

end

class Tile

  attr_reader :pos, :board
  attr_accessor :value, :state, :face
  OFFSETS = [[-1,-1],[-1,0],[1,-1],[0,1],[1,1],[1,0],[-1,1],[0,-1]]

  def initialize(board, pos, value = 0)
    @face = :down
    @value = value
    @board = board
    @pos = pos
    @state = :unexplored
  end

  def reveal
    if face == :down
      #debugger
      self.face = :up unless (value == :m || state == :flagged)
      if value == 0 # Means it Tile is an interior square
        state = :interior
        # keep revealing the neighbors until all the neighbors are only digits
        arr = neighbors
        arr.each do |neighbor_pos|
          board[*neighbor_pos].reveal
        end
      end
    end
  end

  def reveal1
    if state == :down
      state = :up
      if value == :m
        board.display
        Kernel.abort("Clicked on a mine! Byebye")
      else
        if value == 0 # Means it Tile is an interior square
          state = :interior
          # keep revealing the neighbors until all the neighbors are only digits
          arr = neighbors
          arr.each do |neighbor_pos|
            board[*neighbor_pos].reveal
          end
        end
      end
    end
  end

  def neighbor_bomb_count

  end

  def neighbors
    neighbors = []
    OFFSETS.each do |tile|
      row = tile[0] + pos[0]
      col = tile[1] + pos[1]
      neighbors << [row, col] if is_valid_position?([row,col])
    end
    neighbors
  end

  def is_valid_position?(pos)
    return false if pos.any?{ |el| el < 0 || el > (board.num_rows - 1)}
    true
  end
end

class Minesweeper
  attr_reader :board

  def initialize
    @board = Board.new
  end

  def play
    # @board.display
    until won?
      board.secret_display
      puts "Actual board"
      board.display

      puts "Flag or reveal? Enter f or r"
      flag_or_reveal = gets.chomp
      puts "Get coordinate in the for x,y"
      pos_str = gets.chomp
      pos = pos_str.split(',').map(&:to_i)

      tile = board[*pos]
      if flag_or_reveal == 'r'
        if tile.value == :m
          tile.face = :up
          bomb_revealed
        end
        tile.reveal unless tile.state == :flagged
      elsif flag_or_reveal == 'f'
        flag(tile)
      end
    end
  end

  def bomb_revealed
    board.display
    Kernel.abort("Clicked on a mine! Bye bye")
  end

  def flag(tile)
    if tile.face != :up
      if tile.state != :flagged
        tile.state = :flagged
      else
        tile.state = :unexplored
      end
    end
  end

  def won?
    board.num_rows.times do |row|
      board.num_cols.times do |col|
        tile = board[row,col]
        return false if (tile.face == :down && tile.value.is_a?(Fixnum))
      end
    end
  end

end

game = Minesweeper.new
game.play
