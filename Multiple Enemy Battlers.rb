#Credit Cyberkitsune096
class Game_Enemy < Game_Battler
  alias old_initialize initialize
  def initialize(troop_id, member_index)
    old_initialize(troop_id, member_index)
    if (rand(100) + 1) > 50 #50%
      case @enemy_id
      when 1 #enemy 1 in the database
        @battler_name = '052-Undead02' #example of a differant battler entirely
      when 2
        @battler_hue = 124 #example of a differant coloured enemy (range is 0 - 360)
      end
    end
  end
end