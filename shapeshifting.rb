#==============================================================================
# Individual Character Development - Shapeshifter by cyberkitsune096
#==============================================================================
class Game_Actor < Game_Battler
 
  def skill_effect(user, skill)
    super(user, skill)
    if skill.id == 1
      @icd_shape = 7
    end
    hp_check
  end
 
  alias fomar_icd_shapeshifters_setup setup
  def setup(actor_id)
    @icd_shape = 0
    fomar_icd_shapeshifters_setup(actor_id)
  end
 
  def unshift
    @icd_shape = 0
    hp_check
  end
 
  def hp_check
    if @hp > maxhp
      @hp = maxhp
    end
    # I lied it does sp to
    if @sp > maxsp
      @sp = maxsp
    end
  end
 
  def battler_name(first_call = false)
    if first_call == true
      return @battler_name
    end
    if @icd_shape == 0
      return @battler_name
    else
      return $game_actors[@icd_shape].battler_name(true)
    end
  end
 
  def battler_hue(first_call = false)
    if first_call == true
      return @battler_hue
    end
    if @icd_shape == 0
      return @battler_hue
    else
      return $game_actors[@icd_shape].battler_hue(true)
    end
  end
 
  def skills(first_call = false)
    if first_call == true
      return @skills
    end
    if @icd_shape == 0
      return @skills
    else
      return $game_actors[@icd_shape].skills(true)
    end
  end
 
  alias fomar_icd_shapeshifters_skill_can_use? skill_can_use?
  def skill_can_use?(skill_id, first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_skill_can_use?(skill_id)
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_skill_can_use?(skill_id)
    else
      return $game_actors[@icd_shape].skill_can_use?(skill_id, true)
    end
  end
 
  alias fomar_icd_shapeshifters_base_maxhp base_maxhp
  def base_maxhp(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_base_maxhp
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_base_maxhp
    else
      return $game_actors[@icd_shape].base_maxhp(true)
    end
  end
 
  alias fomar_icd_shapeshifters_base_maxsp base_maxsp
  def base_maxsp(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_base_maxsp
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_base_maxsp
    else
      return $game_actors[@icd_shape].base_maxsp(true)
    end
  end
 
  alias fomar_icd_shapeshifters_base_str base_str
  def base_str(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_base_str
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_base_str
    else
      return $game_actors[@icd_shape].base_str(true)
    end
  end
 
  alias fomar_icd_shapeshifters_base_dex base_dex
  def base_dex(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_base_dex
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_base_dex
    else
      return $game_actors[@icd_shape].base_dex(true)
    end
  end
 
  alias fomar_icd_shapeshifters_base_agi base_agi
  def base_agi(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_base_agi
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_base_agi
    else
      return $game_actors[@icd_shape].base_agi(true)
    end
  end
 
  alias fomar_icd_shapeshifters_base_int base_int
  def base_int(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_base_int
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_base_int
    else
      return $game_actors[@icd_shape].base_int(true)
    end
  end
 
  alias fomar_icd_shapeshifters_base_atk base_atk
  def base_atk(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_base_atk
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_base_atk
    else
      return $game_actors[@icd_shape].base_atk(true)
    end
  end
 
  alias fomar_icd_shapeshifters_base_pdef base_pdef
  def base_pdef(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_base_pdef
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_base_pdef
    else
      return $game_actors[@icd_shape].base_pdef(true)
    end
  end
 
  alias fomar_icd_shapeshifters_base_mdef base_mdef
  def base_mdef(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_base_mdef
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_base_mdef
    else
      return $game_actors[@icd_shape].base_mdef(true)
    end
  end
 
  alias fomar_icd_shapeshifters_base_eva base_eva
  def base_eva(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_base_eva
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_base_eva
    else
      return $game_actors[@icd_shape].base_eva(true)
    end
  end
 
  alias fomar_icd_shapeshifters_animation1_id animation1_id
  def animation1_id(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_animation1_id
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_animation1_id
    else
      return $game_actors[@icd_shape].animation1_id(true)
    end
  end
 
  alias fomar_icd_shapeshifters_animation2_id animation2_id
  def animation2_id(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_animation2_id
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_animation2_id
    else
      return $game_actors[@icd_shape].animation2_id(true)
    end
  end
 
  alias fomar_icd_shapeshifters_element_rate element_rate
  def element_rate(element_id ,first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_element_rate(element_id)
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_element_rate(element_id)
    else
      return $game_actors[@icd_shape].element_rate(element_id, true)
    end
  end
 
  alias fomar_icd_shapeshifters_state_ranks state_ranks
  def state_ranks(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_state_ranks
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_state_ranks
    else
      return $game_actors[@icd_shape].state_ranks(true)
    end
  end
 
  alias fomar_icd_shapeshifters_state_guard? state_guard?
  def state_guard?(state_id, first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_state_guard?(state_id)
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_state_guard?(state_id)
    else
      return $game_actors[@icd_shape].state_guard?(state_id, true)
    end
  end
 
  alias fomar_icd_shapeshifters_element_set element_set
  def element_set(first_call = false)
    if first_call == true
      return fomar_icd_shapeshifters_element_set
    end
    if @icd_shape == 0
      return fomar_icd_shapeshifters_element_set
    else
      return $game_actors[@icd_shape].element_set(true)
    end
  end
 
end

class Scene_Battle
 
  alias fomar_icd_shapeshifters_start_phase5 start_phase5
  def start_phase5
    for actor in $game_party.actors
      actor.unshift
    end
    fomar_icd_shapeshifters_start_phase5
  end
end