require './lib/board'
require './lib/string_methods'
require 'colorize' # gem install colorize in terminal if needed

class User

  attr_reader :board, :ships
  attr_accessor :all_fire_coordinates, :target_mode

  def initialize(board, ships)
    @board = board
    @ships = ships
    @all_fire_coordinates = []
  end


  def take_turn(ai, opposing_user)


    def ai_hunt(opposing_user) # Returns a coordinate to fire upon, with highest probability
      probabilities = Hash.new
      opposing_user.board.cells.values.each do |cell|
        probabilities[cell.coordinate] = 0 # All coordinates start with a probability of 0
        if cell.fired_upon? == false
          possible_ships = @ships.find_all {|ship| ship.length == ship.health}
          possible_ships.each do |ship|
            placements = []
            placements << create_cell_array(cell.coordinate, ship.length, 'up')
            placements << create_cell_array(cell.coordinate, ship.length, 'down')
            placements << create_cell_array(cell.coordinate, ship.length, 'left')
            placements << create_cell_array(cell.coordinate, ship.length, 'right')
            placements.each {|placement| opposing_user.board.valid_placement?(ship, placement, true) ? probabilities[cell.coordinate] += 1 : nil}
          end
        end
      end
      highest_probabilities = {}
      highest_probability = probabilities.values.max
      probabilities.each { |coordinate, probability| probability == highest_probability ? highest_probabilities[coordinate] = probability : nil }
      return highest_probabilities.keys.sample
    end

    def ai_hunt_2(opposing_user)

      last4_fire_coordinates = []
      last4_fire_coordinates << @all_fire_coordinates[-4]
      last4_fire_coordinates << @all_fire_coordinates[-3]
      last4_fire_coordinates << @all_fire_coordinates[-2]
      last4_fire_coordinates << @all_fire_coordinates[-1]
      hitten_coordinates = last4_fire_coordinates.find_all {|coordinate| opposing_user.board.cells.keys.include?(coordinate) && opposing_user.board.cells[coordinate].empty? == false}
      adjacent_hits = []

      if hitten_coordinates.length >= 2
        hitten_coordinates[-1][0] == hitten_coordinates[-2][0] && [hitten_coordinates[-1][1..], hitten_coordinates[-2][1..]].is_sequential? ? adjacent_hits += [[hitten_coordinates[-1], hitten_coordinates[-2], 'horizontal']] : nil
        hitten_coordinates[-1][1..] == hitten_coordinates[-2][1..] && [hitten_coordinates[-1][0], hitten_coordinates[-2][0]].is_sequential? ? adjacent_hits += [[hitten_coordinates[-1], hitten_coordinates[-2], 'vertical']] : nil
      end
      if hitten_coordinates.length >= 3
        hitten_coordinates[-1][0] == hitten_coordinates[-3][0] && [hitten_coordinates[-1][1..], hitten_coordinates[-3][1..]].is_sequential? ? adjacent_hits += [[hitten_coordinates[-1], hitten_coordinates[-3], 'horizontal']] : nil
        hitten_coordinates[-1][1..] == hitten_coordinates[-3][1..] && [hitten_coordinates[-1][0], hitten_coordinates[-3][0]].is_sequential? ? adjacent_hits += [[hitten_coordinates[-1], hitten_coordinates[-3], 'vertical']] : nil
      end
      if hitten_coordinates.length >= 4
        hitten_coordinates[-1][0] == hitten_coordinates[-4][0] && [hitten_coordinates[-1][1..], hitten_coordinates[-4][1..]].is_sequential? ? adjacent_hits += [[hitten_coordinates[-1], hitten_coordinates[-4], 'horizontal']] : nil
        hitten_coordinates[-1][1..] == hitten_coordinates[-4][1..] && [hitten_coordinates[-1][0], hitten_coordinates[-4][0]].is_sequential? ? adjacent_hits += [[hitten_coordinates[-1], hitten_coordinates[-4], 'vertical']] : nil
      end
      if hitten_coordinates.length >= 3
        hitten_coordinates[-2][0] == hitten_coordinates[-3][0] && [hitten_coordinates[-2][1..], hitten_coordinates[-3][1..]].is_sequential? ? adjacent_hits += [[hitten_coordinates[-2], hitten_coordinates[-3], 'horizontal']] : nil
        hitten_coordinates[-2][1..] == hitten_coordinates[-3][1..] && [hitten_coordinates[-2][0], hitten_coordinates[-3][0]].is_sequential? ? adjacent_hits += [[hitten_coordinates[-2], hitten_coordinates[-3], 'vertical']] : nil
      end
      if hitten_coordinates.length >= 4
        hitten_coordinates[-2][0] == hitten_coordinates[-4][0] && [hitten_coordinates[-2][1..], hitten_coordinates[-4][1..]].is_sequential? ? adjacent_hits += [[hitten_coordinates[-2], hitten_coordinates[-4], 'horizontal']] : nil
        hitten_coordinates[-2][1..] == hitten_coordinates[-4][1..] && [hitten_coordinates[-2][0], hitten_coordinates[-4][0]].is_sequential? ? adjacent_hits += [[hitten_coordinates[-2], hitten_coordinates[-4], 'vertical']] : nil

        hitten_coordinates[-3][0] == hitten_coordinates[-4][0] && [hitten_coordinates[-3][1..], hitten_coordinates[-4][1..]].is_sequential? ? adjacent_hits += [[hitten_coordinates[-3], hitten_coordinates[-4], 'horizontal']] : nil
        hitten_coordinates[-3][1..] == hitten_coordinates[-4][1..] && [hitten_coordinates[-3][0], hitten_coordinates[-4][0]].is_sequential? ? adjacent_hits += [[hitten_coordinates[-3], hitten_coordinates[-4], 'vertical']] : nil
      end

      require 'pry'; binding.pry
      attack_coordinate = nil
      until opposing_user.board.valid_fire?(attack_coordinate)
        if adjacent_hits.find_all{|hit| hit[2] == 'horizontal'}.length > 0
          opposing_user.board.valid_fire?(attack_coordinate) == false ? 
          opposing_user.board.valid_fire?(attack_coordinate) == false ?
        elsif adjacent_hits.find_all{|hit| hit[2] == 'vertical'}.length > 0
          opposing_user.board.valid_fire?(attack_coordinate) == false ?
          opposing_user.board.valid_fire?(attack_coordinate) == false ?
        else
          opposing_user.board.valid_fire?(attack_coordinate) == false ?
          opposing_user.board.valid_fire?(attack_coordinate) == false ?
          opposing_user.board.valid_fire?(attack_coordinate) == false ?
          opposing_user.board.valid_fire?(attack_coordinate) == false ?
        end
      end
      attack_coordinate
    end


    if ai
      target_mode == true ? attack_coordinate = ai_hunt_2(opposing_user) : attack_coordinate = ai_hunt(opposing_user)
      opposing_user.board.cells[attack_coordinate].fire_upon
      @all_fire_coordinates.push(attack_coordinate)


      if opposing_user.board.cells[@all_fire_coordinates[-1]].ship.class == Ship && opposing_user.board.cells[@all_fire_coordinates[-1]].ship.sunk?
        @target_mode = false
      elsif opposing_user.board.cells[@all_fire_coordinates[-1]].ship.class == Ship || (@all_fire_coordinates[-2].class == String && opposing_user.board.cells[@all_fire_coordinates[-2]].ship.class == Ship) || (@all_fire_coordinates[-3].class == String && opposing_user.board.cells[@all_fire_coordinates[-3]].ship.class == Ship) || (@all_fire_coordinates[-4].class == String && opposing_user.board.cells[@all_fire_coordinates[-4]].ship.class == Ship)
        @target_mode = true
      else
        @target_mode = false
      end

    end

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

        if choice != 'finish'
          choice = choice.split(' ')
          ship_choice = unplaced_ships.find{|ship| ship.name == choice[0].to_s }
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

end
