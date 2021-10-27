require './lib/board'
require './lib/array_methods'
require 'colorize' # gem install colorize in terminal if needed

class User

  attr_reader :board, :ships

  def initialize(board, ships)
    @board = board
    @ships = ships
  end

  def hunt(board, ships, mode) #returns chosen cell coordinate
    if mode == "random"
      unfired_cells = board.cells.values.find_all {|cell| cell.fired_upon? == false}
      chosen_coordinate = unfired_cells.sample.coordinate
    elsif mode == "probability"
      self.update_possible_ships(board, ships)
      # remove cells that have already been fired at.
      unfired_cells = board.cells.values.find_all {|cell| cell.fired_upon? == false}
      # find most highest # of ships
      max = unfired_cells.map{|cell| cell.possible_ships}.max
      # gather all cells with this value
      possible_targets = unfired_cells.find_all{|cell| cell.possible_ships == max}
      # randomly select from possible target
      chosen_coordinate = possible_targets.sample(1)[0].coordinate
    end
  end

  def target_near(opponent_board, opponent_ships)
    hit_cells = opponent_board.cells.values.find_all { |cell| cell.render == "H".blue.bold }
    hit_coordinates = hit_cells.map { |cell| cell.coordinate }

    # Find all coordinates adjacent to hits, and haven't been fired upon
    adjacent_coordinates = []
    hit_coordinates.each do |coordinate|
      adjacent_coordinates << create_cell_array(coordinate, 2, 'up')[1]
      adjacent_coordinates << create_cell_array(coordinate, 2, 'down')[1]
      adjacent_coordinates << create_cell_array(coordinate, 2, 'left')[1]
      adjacent_coordinates << create_cell_array(coordinate, 2, 'right')[1]
    end
    adjacent_coordinates = adjacent_coordinates.find_all { |coordinate| opponent_board.valid_fire?(coordinate) }
    adjacent_coordinates.uniq!

    # Use probability map to identify bast adjacent cell to target
    self.update_possible_ships(opponent_board, opponent_ships)
    unfired_cells = adjacent_coordinates.map{|coordinate| opponent_board.cells[coordinate]}
    max = unfired_cells.map{|cell| cell.possible_ships}.max
    possible_targets = unfired_cells.find_all{|cell| cell.possible_ships == max}
    chosen_coordinate = possible_targets.sample(1)[0].coordinate
  end

  def target_row(opponent_board, opponent_ships)
    hit_cells = opponent_board.cells.values.find_all { |cell| cell.render == "H".blue.bold }
    hit_coordinates = hit_cells.map { |cell| cell.coordinate }
    possible_rows = []
    # find longest possible ship length
    max_length = opponent_ships.map{|ship| ship.length}.max - 1
    # create an array of possible row length to try to build into Hit cells.
    row_lengths = (2..max_length).to_a
    # iterate through all row lengths and hit cells and build possible rows of each length from each cell
    row_lengths.each do |row_length|
      hit_coordinates.each do |coordinate|
        possible_rows  << create_cell_array(coordinate, row_length, 'up')
        possible_rows  << create_cell_array(coordinate, row_length, 'down')
        possible_rows  << create_cell_array(coordinate, row_length, 'left')
        possible_rows  << create_cell_array(coordinate, row_length, 'right')
      end
    end

    # test if possible_row fits entirely in hit cells
    rows = possible_rows.find_all do |coordinates|
      # clean possible rows to remove invalid coordinates
      coordinates2 = coordinates.find_all do |coordinate|
         opponent_board.valid_coordinate?(coordinate, true)
      end
      # are all cells in row cells with hits?
      coordinates2.find_all {|coordinate|opponent_board.cells[coordinate].render == "H".blue.bold}.length == coordinates.length
    end
    # if rows are empty (single cell or multiple single cells) return nil
    if rows.length == 0
      return target_near(opponent_board, opponent_ships)
    end
    # rows now hold all possible rows of coordinates within my hit cells
    # find longest row
    max_row_length = rows.map{|row| row.length}.max
    possible_rows = rows.find_all{|row| row.length == max_row_length}
    chosen_row = possible_rows.sample(1)[0]
    # get next cells on edge of row

    # identify if up/down or left right

    #split coordiantes into letters and numbers
    letters = []
    numbers = []
    chosen_row = chosen_row.sort
    chosen_row.each do |row|
      letters << row[0]
      numbers << row[1..].to_i
    end

    # collect end coordinates
    possible_coordinates = []
    if letters.everything_same?
      possible_coordinates << letters[0] + (numbers[0] - 1).to_s
      possible_coordinates << letters[-1] + (numbers[-1] + 1).to_s
    else
      possible_coordinates << (letters[0].ord - 1).chr + (numbers[0]).to_s
      possible_coordinates << (letters[-1].ord + 1).chr + (numbers[-1]).to_s
    end
    # if up/down, sort coordinates, take first and last coordinates, then subtract 1 from first and add 1 to last to create new coordinates.
    # if left/right, sort coordinates, take first and last coordinates, then subtract 1 letter from first and add 1 letter to last to create new coordinates.

    possible_coordinates = possible_coordinates.find_all { |coordinate| opponent_board.valid_fire?(coordinate) }
    possible_coordinates.uniq!

    # Use probability map to identify bast adjacent cell to target
    self.update_possible_ships(opponent_board, opponent_ships)
    unfired_cells = possible_coordinates.map{|coordinate| opponent_board.cells[coordinate]}
    max = unfired_cells.map{|cell| cell.possible_ships}.max
    possible_targets = unfired_cells.find_all{|cell| cell.possible_ships == max}

    # if possible_targets == []
    #   return target_near(opponent_board, opponent_ships)
    # end
    chosen_coordinate = possible_targets.sample(1)[0].coordinate
  end

  def target(opponent_board, opponent_ships)
    # First, find all hit coordinates that are not sunk
    hit_cells = opponent_board.cells.values.find_all { |cell| cell.render == "H".blue.bold }
    # If there are no hits, end the target method.
    return nil if hit_cells.length == 0
    self.target_row(opponent_board, opponent_ships)
  end


  def setup_board(ai)
    if ai
      ai_setup_board
    else
      human_setup_board
    end
  end

  def ai_setup_board
    failed = false
    @ships.each do |ship|
      # randomly choose placement
      chosen_placement = random_placement(ship)
      #place ship
      if !(chosen_placement == nil)
        @board.place(ship,chosen_placement)
      else
        return @board = nil
      end
    end
  end

  def human_setup_board
    loop = true
    message = nil
    puts "\nIf you want your ships randomly placed for you, please enter 'random'.".light_black.bold
    puts "\nOtherwise, press any key to manually place your ships.".light_black.bold
    choice = gets.chomp
    if choice == 'random'
      failed = false
      @ships.each do |ship|
        # randomly choose placement
        chosen_placement = random_placement(ship)
        #place ship
        if !(chosen_placement == nil)
          @board.place(ship,chosen_placement)
        else
          return @board = nil
        end
      end
    else
      unplaced_ships = @ships.map { |ship| ship}
      until loop == false
        if unplaced_ships.length == 0
          break
        end
        puts "\n"
        puts ("_" * 30).red.bold
        puts "SETUP YOUR BOARD: \n".red.bold
        puts @board.render(true)
        puts "AVAILABLE SHIPS:".yellow.bold
        unplaced_ships.each{|ship| puts " * #{ship.name}: #{ship.length}".yellow}
        puts message
        puts "\nPlease place one of the ships from the following listed on your board.".light_black.bold
        puts "Put 'finish' when you are done.".light_black.bold
        puts "Example: ShipName A1 A2 A3".light_black.italic
        print ' > '.magenta
        choice = gets.chomp
        # upcase ship name and coordinates
        choice = choice.upcase

        if choice != 'FINISH'
          # split user input into ship name and coordinates
          choice = choice.split(' ')
          # ship choice = the first chunk. Find chosen ship within unplaced ship array
          ship_choice = unplaced_ships.find{|ship| ship.name.upcase == choice[0].to_s }
          # assign coordiantes to the other chunks input by user
          coordinates = choice[1..].to_a
          coordinates = coordinates.find_all{|coordinate| @board.valid_coordinate?(coordinate)}
          if ship_choice.class == Ship && @board.valid_placement?(ship_choice, coordinates) && coordinates.length >= 2
            @board.place(ship_choice, coordinates)
            unplaced_ships.reject!{|ship| ship_choice.name == ship.name}
            message =  "Ship placed successfully!".green
          else
            message = "Invalid Input! Make sure the coordinates form a\nstraight line and don't overlap any other ships.".red
          end
          loop = true
        else
          break
        end
      end
    end
  end

  def random_placement(ship)
    # randomly choose starting cell.
    # Generate 4 possible cell arrays based on ship length
    # Check validity. Randomly choose one that works.
    # Keep looping until valid placement found
    chosen_placement = nil
    possible_placements = []
    valid_placements = []
    # first, check that ship can fit.
    # If not, reset
    while chosen_placement == nil do
      if !@board.fits?(ship.length)
        return nil
      end
      start_cell = @board.cells.values.sample
      possible_placements << self.create_cell_array(start_cell.coordinate, ship.length, "up")
      possible_placements << self.create_cell_array(start_cell.coordinate, ship.length, "down")
      possible_placements << self.create_cell_array(start_cell.coordinate, ship.length, "left")
      possible_placements << self.create_cell_array(start_cell.coordinate, ship.length, "right")
      valid_placements = possible_placements.find_all{|placement| @board.valid_placement?(ship, placement)}
      chosen_placement = valid_placements.sample
    end
    chosen_placement
  end

  def create_cell_array(coordinate, length, direction)
    alphabet = ('A'..'Z').to_a
    start_letter = coordinate[0]
    start_num = coordinate[1..2]
    new_coordinates = []


    if direction == "up"
      # create array that decreases in letters but has same number
      start_index = start_letter.ord
      end_index = start_index - (length - 1)

      # create ord number array, convert to characters, append column #, then reverse.
      # create array doesn't work (large..small) so we do (small..large) then reverse.
      new_coordinates = (end_index..start_index).to_a.map { |x| x.chr + "#{start_num}" }.reverse
    elsif direction == "down"
      # create array that increases in letters but has same number
      start_index = start_letter.ord
      end_index = start_index + (length - 1)
      # create ord number array, convert to characters, append column #.
      new_coordinates = (start_index..end_index).to_a.map { |x| x.chr + "#{start_num}" }
    elsif direction == "left"
      # create array with same letter that decreases in number
      start_index = start_num.to_i
      end_index = start_index - (length - 1)
      # create number array, convert to string, prepend column letter, then reverse.
      # create array doesn't work (large..small) so we do (small..large) then reverse.
      new_coordinates = (end_index..start_index).to_a.map { |x| "#{start_letter}" + x.to_s}.reverse
    elsif direction == "right"
      # create array with same letter that increases in number
      start_index = start_num.to_i
      end_index = start_index + (length - 1)
      # create number array, convert to string, prepend column letter.
      new_coordinates = (start_index..end_index).to_a.map { |x| "#{start_letter}" + x.to_s}
    else
      []
    end
  end

  def update_possible_ships(board, ships)
    # reset @possible_ship counter in all cells
    board.cells.values.each{|cell| cell.possible_ships = 0}
    # loop through all cells
    board.cells.values.each do |cell|
      # loops through all unsunken ships
      unsunken_ships = ships.find_all{|ship| !(ship.sunk?)}
      unsunken_ships.each do |ship|
        # generate all possible arrangements per ship per starting cell
        possible_placements = []
        valid_placements = []
        #only down and right are needed, not up and left, because we are testing every cell.
        # Left from one cell becomes right from another cell, duplicating true placements.
        possible_placements << self.create_cell_array(cell.coordinate, ship.length, "down")
        possible_placements << self.create_cell_array(cell.coordinate, ship.length, "right")
        # check validity, return valid placements.
        # NOTE: right now this knows where existing ships are.
        # How do we check validity while only looking at hit or miss?
        valid_placements = possible_placements.find_all{|placement| board.valid_placement?(ship, placement, true)}

        # if valid placements exist update possible_ships, otherwise move on
        if valid_placements.length > 0
          # loop through each valid placement
          valid_placements.each do |valid_placement|
            # loop through each coordinate to gather each cell in the valid placement
            valid_placement.each do |coordinate|
              # get cell at coordiante and increase the possible_ships counter of that cell by one
              board.cells[coordinate].possible_ships += 1
            end
          end
        end
      end
    end
    # return nothing - board cells have been updated with new total probability
  end
end
