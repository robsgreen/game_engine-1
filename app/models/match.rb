class Match < ActiveRecord::Base
  belongs_to :player1, :class_name => 'Player'
  belongs_to :player2, :class_name => 'Player'
  belongs_to :board

  def finished?
    finished_at.present?
  end

end