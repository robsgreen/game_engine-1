class Board < ActiveRecord::Base
  serialize :x_position
  serialize :y_position
  serialize :stars

  GRID_SIZE = 20

  def save_stars
    @original_stars = self.stars
  end

  def reset!
    update! stars: @original_stars,
            x_position: [0,0],
            y_position: [GRID_SIZE - 1, GRID_SIZE - 1],
            x_score: 0,
            y_score: 0,
            player_to_move: "X"
  end

  def self.generate_random
    Board.create! stars: generate_random_stars,
                  x_position: [0,0],
                  y_position: [GRID_SIZE - 1, GRID_SIZE - 1],
                  x_score: 0,
                  y_score: 0,
                  player_to_move: "X"
  end

  def to_json
    properties.to_json
  end

  def properties
    { stars: stars, x_position: x_position, y_position: y_position,
      x_score: x_score, y_score: y_score, player_to_move: player_to_move }
  end

  def winner
    return "X" if x_score > 10
    return "Y" if y_score > 10
    return nil
  end

  def move!(direction)
    board_x, board_y = player_coordinates(player_to_move)
    if direction == "right"
      new_x, new_y = board_x, board_y + 1
    elsif direction == "left"
      new_x, new_y = board_x, board_y - 1
    elsif direction == "down"
      new_x, new_y = board_x + 1, board_y
    else
      new_x, new_y = board_x - 1, board_y
    end
    if legal_move?(new_x, new_y)
      if stars.include?([new_x, new_y])
        player_to_move == "X" ? self.x_score += 1 : self.y_score += 1
        stars.delete([new_x, new_y])
      end
      update_player_position(new_x, new_y)
    end
    self.player_to_move = other_player
    save!
  end

  def display_string
    board_output = ""
    0.upto(GRID_SIZE - 1) do |i|
      0.upto(GRID_SIZE - 1) do |j|
        if [i,j] == x_position
          board_output << "X"
        elsif [i,j] == y_position
          board_output << "Y"
        elsif stars.include?([i,j])
          board_output << "*"
        else
          board_output << "-"
        end
        board_output << " "
      end
      board_output << "\n"
    end
    board_output
  end

  def self.generate_random_stars
    star_list = []
    loop do
      rand_x = rand(GRID_SIZE)
      rand_y = rand(GRID_SIZE)
      next if [rand_x, rand_y].in?([[0,0], [GRID_SIZE - 1, GRID_SIZE - 1]] + star_list)
      star_list << [rand_x, rand_y]
      break if star_list.count == 21
    end
    star_list.uniq
  end

  def player_coordinates(player)
    if player == "X"
      x_position
    else
      y_position
    end
  end

  private

    def update_player_position(new_x, new_y)
      if player_to_move == "X"
        self.x_position = [new_x, new_y]
      else
        self.y_position = [new_x, new_y]
      end
    end

    def legal_move?(new_x, new_y)
      return false if new_x < 0 || new_y < 0 || new_x >= GRID_SIZE || new_y >= GRID_SIZE
      return false if [new_x, new_y] == player_coordinates(other_player)
      return true
    end

    def other_player
      player_to_move == "X" ? "Y" : "X"
    end

end