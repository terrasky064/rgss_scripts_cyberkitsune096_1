#==============================================================================
# Individual Character Development - Weapon Master by cyberkitsune096
#==============================================================================
class Game_Party

  attr_accessor :icd_weapon_masters
  attr_accessor :icd_weapon_type
  attr_accessor :icd_weapon_type_skills
  attr_accessor :icd_weapon_max_level
  attr_accessor :icd_weapon_damage_bonus
 
  alias fomar_icd_weapon_master_initialize initialize
  def initialize
    fomar_icd_weapon_master_initialize
    @icd_weapon_masters = [1]
    @icd_weapon_type = [
    {'name'=>'Sword', 'weapons'=>[1, 2, 3, 4]},
    {'name'=>'Spear', 'weapons'=>[5, 6, 7, 8]}
    ]
    @icd_weapon_type_skills = {'Sword1'=>57, 'Sword2'=>58, 'Sword3'=>59, 'Sword4'=>60,
    'Spear1'=>61, 'Spear2'=>62, 'Spear3'=>63, 'Spear4'=>64}
    @icd_weapon_max_level = 4
    @icd_weapon_damage_bonus = 5
   
  end
end

class Game_Actor < Game_Battler
 
  alias fomar_icd_weapon_master_setup setup
  def setup(actor_id)
    fomar_icd_weapon_master_setup(actor_id)
    @icd_weapon_type_levels = {}
   
    for icd_type in $game_party.icd_weapon_type
      @icd_weapon_type_levels[icd_type['name']] = 0
    end
   
  end
 
  def damage_multiplier
    for icd_type in $game_party.icd_weapon_type
      if icd_type['weapons'].include?(@weapon_id)
        return ((@icd_weapon_type_levels[icd_type['name']])/100)  * $game_party.icd_weapon_damage_bonus
      end
    end
    return 0
  end
 
  def improve_weapon_use
    for icd_type in $game_party.icd_weapon_type
      if icd_type['weapons'].include?(@weapon_id)
        unless @icd_weapon_type_levels[icd_type['name']] == 100 * $game_party.icd_weapon_max_level
          @icd_weapon_type_levels[icd_type['name']] += 1
          if (@icd_weapon_type_levels[icd_type['name']] / 100) == (@icd_weapon_type_levels[icd_type['name']].to_f / 100.00)
            self.learn_skill($game_party.icd_weapon_type_skills[icd_type['name'] + (@icd_weapon_type_levels[icd_type['name']] / 100).to_s])
          end
        end
      end
    end
  end
 
end

class Game_Enemy < Game_Battler
 
  def attack_effect(attacker)
    if $game_party.icd_weapon_masters.include?(attacker.id)
      attacker.improve_weapon_use
      k = super
      x = self.damage
      self.damage *= (100 + attacker.damage_multiplier)
      self.damage /= 100
      self.hp -= (self.damage - x)
      return k
    else
      return super
    end
  end
 
end