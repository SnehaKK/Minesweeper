class Board
  # MAX_MINES = 10
  # MIN_MINES = 20
  NUM_MINES = 10

  attr_reader :num_rows, :num_cols
  attr_accessor :mine_arr

  def initialize(num_rows = 9, num_cols = 9)
    @grid = Array.new(num_rows) { Array.new(num_cols) }
    @num_rows = num_rows
    @num_cols = num_cols
    @mine_arr = []
    randomize_board
  end

  def initialize_board
    num_rows.times do |row|
      num_cols.times do |col|
        self[row,col]= Tile.new(nil,self,[row,col])
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
    @grid.num_rows.times do |row|
      str = ''
      @grid.num_cols.times do |col|
        tile = self[row,col]
        str << tile.value
        # if tile.value == :mine
        #   puts *
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
      self[*mine_pos].neighbors.each do |tile|
        tile.value += 1 unless tile.value == :m
      end
    end
  end


end



class Tile

  attr_reader :pos, :board
  OFFSETS = [[-1,-1],[-1,0],[1,-1],[0,1],[1,1],[1,0],[-1,1],[0,-1]]

  def initialize(value = nil, board, pos)
    @state = :down
    @value = value ? value : 0
    @board = board
    @pos = pos
  end

  def reveal

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

  def initialize
    @board = Board.new
  end

  def play
    until game_over?
      @board.display
      puts "Flag or reveal? Enter f or r"
      flag_or_reveal = gets.chomp
      puts "Get coordinate in the for x,y"
      pos_str = gets.chomp
      pos = pos_str.split(',').map(&:to_i)

    end
  end

  def game_over?
    bomb_revealed? || won?
  end

end
