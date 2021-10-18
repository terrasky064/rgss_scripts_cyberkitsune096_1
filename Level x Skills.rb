#Credit Cyberkitsune096
class Game_Enemy < Game_Battler
 
  Default_Level = 3
  Levels = {}
  Levels[1] = 5
  Levels[8] = 7
 
  def level
    if Levels[self.id] == nil
      return Default_Level
    else
      return Levels[self.id]
    end
  end
 
end


class Game_Battler
  alias before_fomar_level_skills_skill_effect skill_effect
  def skill_effect(user, skill)
    case skill.id
    when 1 # Hmm heal can be level 3 flare!!!
      if (self.level / 3) == (self.level.to_f / 3.0)
        return before_fomar_level_skills_skill_effect(user, $data_skills[2]) # That other healing spell is flare!!!
      else
        self.critical = false
        self.damage = "Miss"
        return false
      end
    when 3 # Hmm the last healing spell can be level 4 quarter!!!
      if (self.level / 4) == (self.level.to_f / 4.0)
        self.damage = (self.hp * 3)/4
        return true
      else
        self.critical = false
        self.damage = "Miss"
        return false
      end
    when 4 # I can't even be bother to check what this is but now it is level 5 death
      if (self.level / 5) == (self.level.to_f / 5.0)
        self.hp = 0
        self.damage = 'Lvl 5 Death'
        return true
      else
        self.critical = false
        self.damage = "Miss"
        return false
      end
     
    else
      return before_fomar_level_skills_skill_effect(user, skill)
    end
  end
end