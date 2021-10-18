#--------------------------------------------------------------------------
  # Element Affinity
  # Script by Cyberkitsune096
  #--------------------------------------------------------------------------
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # Constants
  #--------------------------------------------------------------------------
  Elements = [
  {'name'=>'Fire', 'id'=>1, 'opp'=>'Ice'},
  {'name'=>'Ice', 'id'=>2, 'opp'=>'Fire'},
  {'name'=>'Thunder', 'id'=>3, 'opp'=>'Water'},
  {'name'=>'Water', 'id'=>4, 'opp'=>'Thunder'},
  {'name'=>'Earth', 'id'=>5, 'opp'=>'Wind'},
  {'name'=>'Wind', 'id'=>6, 'opp'=>'Earth'},
  {'name'=>'Light', 'id'=>7, 'opp'=>'Darkness'},
  {'name'=>'Darkness', 'id'=>8, 'opp'=>'Light'}
  ]
  # The maximum you can be aligned with an element
  Max_Affinity = 1000
  # The minimum you can be aligned with an element
  Min_Affinity = -1000
  # How much alignment you gain with the element used
  Element_Usage = 1
  # How much the opposing alignment loses
  Opposite_Cost = 1
  # How much all other alignments not linked to the used alignment lose
  All_Cost = 0
  # How much you must be aligned with an element for half spell cost
  # Note: 0 means the feature won't happen
  Half_Spell_Cost = 250
  # How much you must be aligned with an element for quarter spell cost
  # Note: 0 means the feature won't happen
  Quarter_Spell_Cost = 750
  # How much you must be aligned with an element to do double damage
  # Note: 0 means the feature won't happen
  Double_Spell_Damage = 500
  # How much you must be aligned with an element to do quadruple damage
  # Note: 0 means the feature won't happen
  Quad_Spell_Damage = 1000
  # How little you must be aligned with an element for double spell cost
  # Note: 0 means the feature won't happen
  Double_Spell_Cost = -250
  # How little you must be aligned with an element for quardruple spell cost
  # Note: 0 means the feature won't happen
  Quad_Spell_Cost = -750
  # How little you must be aligned with an element to do half damage
  # Note: 0 means the feature won't happen
  Half_Spell_Damage = -500
  # How little you must be aligned with an element to do quarter damage
  # Note: 0 means the feature won't happen
  Quarter_Spell_Damage = -1000
  # If set to true your allignments will positively affect your elemental resistences (> 0)
  Affect_Resistences_Pos = true
  # If set to true your allignments will negatively affect your elemental resistences (< 0)
  Affect_Resistences_Neg = true
  #--------------------------------------------------------------------------
  # End Of Constants
  #--------------------------------------------------------------------------
  alias old_setup setup
  def setup(actor_id)
    old_setup(actor_id)
    @element_affinity = []
    for i in 0...Elements.size
      @element_affinity.push(0)
    end
  end
 
  def is_element?(element)
    for i in 0...Elements.size
      hash = Elements[i]
      if hash['id'] == element
        return true
      end
    end
    return false
  end
 
  def element_affinity_adjust(element)
    if is_element?(element)
      for i in 0...Elements.size
        hash = Elements[i]
        if hash['id'] == element
          k = i
          opp_name = hash['opp']
        end
      end
     
      for i in 0...Elements.size
        hash = Elements[i]
        if hash['name'] = opp_name
          j = i
        end
      end
      if @element_affinity[k] < Max_Affinity
        @element_affinity[k] += Element_Usage
      end
     
      if @element_affinity[k] > Max_Affinity
        @element_affinity[k] = Element_Usage
      end
     
     
      if @element_affinity[j] > Min_Affinity
        @element_affinity[j] -= Opposite_Cost
      end
     
      if @element_affinity[j] < Min_Affinity
        @element_affinity[j] = Opposite_Cost
      end
     
      unless All_Cost == 0
        for i in 0...Elements.size
          Elements[i] -= All_Cost
        end
        Elements[k] += All_Cost
        Elements[j] += All_Cost
      end
     
    end
  end
   
  def affinity(element)
    if is_element?(element)
      for i in 0...Elements.size
        hash = Elements[i]
        if hash['id'] == element
          return @element_affinity[i]
        end
      end
    end
    return 0
  end
 
  def element_rate(element_id)
    # Get values corresponding to element effectiveness
    table = [0,200,150,100,50,0,-100]
    result = table[$data_classes[@class_id].element_ranks[element_id]]
    # For each 1% of max affinity you get +2 resistence
    # meaning at 50% you take no damage and at 100%
    # you absorb the damage (assuming you start at C (100))
    if is_element?(element_id)
      x = affinity(element_id)
      x /= Max_Affinity
      x *= 200
      if x > 0 and Affect_Resistences_Pos == true
        result -= x
      end
      if x < 0 and Affect_Resistences_Neg == true
        result -= x/2
      end
    end
    # If this element is protected by armor, then it's reduced by half
    for i in [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
      armor = $data_armors[i]
      if armor != nil and armor.guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # If this element is protected by states, then it's reduced by half
    for i in @states
      if $data_states[i].guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # End Method
    return result
  end
   
  def half_spell_cost_is
    return Half_Spell_Cost
  end
 
  def quarter_spell_cost_is
    return Quarter_Spell_Cost
  end
 
  def double_spell_damage_is
    return Double_Spell_Damage
  end
 
  def quad_spell_damage_is
    return Quad_Spell_Damage
  end
   
  def double_spell_cost_is
    return Double_Spell_Cost
  end
 
  def quad_spell_cost_is
    return Quad_Spell_Cost
  end
 
  def half_spell_damage_is
    return Half_Spell_Damage
  end
 
  def quarter_spell_damage_is
    return Quarter_Spell_Damage
  end
 
  def is_actor?
    return true
  end
 
end





class Game_Enemy < Game_Battler
  def is_actor?
    return false
  end
end





class Game_Battler
  def skill_effect(user, skill)
    # Clear critical flag
    self.critical = false
    # If skill scope is for ally with 1 or more HP, and your own HP = 0,
    # or skill scope is for ally with 0, and your own HP = 1 or more
    if ((skill.scope == 3 or skill.scope == 4) and self.hp == 0) or
       ((skill.scope == 5 or skill.scope == 6) and self.hp >= 1)
      # End Method
      return false
    end
    # Clear effective flag
    effective = false
    # Set effective flag if common ID is effective
    effective |= skill.common_event_id > 0
    # First hit detection
    hit = skill.hit
    if skill.atk_f > 0
      hit *= user.hit / 100
    end
    hit_result = (rand(100) < hit)
    # Set effective flag if skill is uncertain
    effective |= hit < 100
    # If hit occurs
    if hit_result == true
      # Calculate power
      power = skill.power + user.atk * skill.atk_f / 100
      if power > 0
        power -= self.pdef * skill.pdef_f / 200
        power -= self.mdef * skill.mdef_f / 200
        power = [power, 0].max
      end
      # Calculate rate
      rate = 20
      rate += (user.str * skill.str_f / 100)
      rate += (user.dex * skill.dex_f / 100)
      rate += (user.agi * skill.agi_f / 100)
      rate += (user.int * skill.int_f / 100)
     
      # For you merging this only the code in this method that is new
      if user.is_actor? and skill.element_set != []
       
        for i in skill.element_set
          affinity = user.affinity(i)
         
          if affinity >= user.double_spell_damage_is and user.double_spell_damage_is != 0
            rate *= 2
          end
         
          if affinity >= user.quad_spell_damage_is and user.quad_spell_damage_is != 0
            rate *= 2
          end
         
          if affinity <= user.half_spell_damage_is and user.half_spell_damage_is != 0
            rate /= 2
          end
         
          if affinity <= user.quarter_spell_damage_is and user.quarter_spell_damage_is != 0
            rate /= 2
          end
         
        end
      end
     
      # Calculate basic damage
      self.damage = power * rate / 20
      # Element correction
      self.damage *= elements_correct(skill.element_set)
      self.damage /= 100
      # If damage value is strictly positive
      if self.damage > 0
        # Guard correction
        if self.guarding?
          self.damage /= 2
        end
      end
      # Dispersion
      if skill.variance > 0 and self.damage.abs > 0
        amp = [self.damage.abs * skill.variance / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      # Second hit detection
      eva = 8 * self.agi / user.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva * skill.eva_f / 100
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
      # Set effective flag if skill is uncertain
      effective |= hit < 100
    end
    # If hit occurs
    if hit_result == true
      # If physical attack has power other than 0
      if skill.power != 0 and skill.atk_f > 0
        # State Removed by Shock
        remove_states_shock
        # Set to effective flag
        effective = true
      end
      # Substract damage from HP
      last_hp = self.hp
      self.hp -= self.damage
      effective |= self.hp != last_hp
      # State change
      @state_changed = false
      effective |= states_plus(skill.plus_state_set)
      effective |= states_minus(skill.minus_state_set)
      # If power is 0
      if skill.power == 0
        # Set damage to an empty string
        self.damage = ""
        # If state is unchanged
        unless @state_changed
          # Set damage to "Miss"
          self.damage = "Miss"
        end
      end
    # If miss occurs
    else
      # Set damage to "Miss"
      self.damage = "Miss"
    end
    # If not in battle
    unless $game_temp.in_battle
      # Set damage to nil
      self.damage = nil
    end
    # End Method
    return effective
  end
end



class Window_Skill < Window_Selectable
 
  def draw_item(index)
    skill = @data[index]
    if @actor.skill_can_use?(skill.id)
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end
    x = 4 + index % 2 * (288 + 32)
    y = index / 2 * 32
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(skill.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 204, 32, skill.name, 0)
    sp_cost = skill.sp_cost
   
    unless skill.element_set == []
      for i in skill.element_set
        affinity = @actor.affinity(i)
        if affinity >= @actor.half_spell_cost_is and @actor.half_spell_cost_is != 0
          sp_cost /= 2
        end
       
        if affinity >= @actor.quarter_spell_cost_is and @actor.quarter_spell_cost_is != 0
          sp_cost /= 2
        end

        if affinity <= @actor.double_spell_cost_is and @actor.double_spell_cost_is != 0
          sp_cost *= 2
        end
       
        if affinity <= @actor.quad_spell_cost_is and @actor.quad_spell_cost_is != 0
          sp_cost *= 2
        end
       
      end
    end
   
   
    self.contents.draw_text(x + 232, y, 48, 32, sp_cost.to_s, 2)
  end
 
end





class Scene_Battle
  def make_skill_action_result
    # Get skill
    @skill = $data_skills[@active_battler.current_action.skill_id]
    # If not a forcing action
    unless @active_battler.current_action.forcing
      # If unable to use due to SP running out
      unless @active_battler.skill_can_use?(@skill.id)
        # Clear battler being forced into action
        $game_temp.forcing_battler = nil
        # Shift to step 1
        @phase4_step = 1
        return
      end
    end
    # Use up SP
    sp_cost = @skill.sp_cost
    if @active_battler.is_actor? and @skill.element_set != []
     
      for i in @skill.element_set
        affinity = @active_battler.affinity(i)
       
        if affinity >= @active_battler.half_spell_cost_is and @active_battler.half_spell_cost_is != 0
          sp_cost /= 2
        end
       
        if affinity >= @active_battler.quarter_spell_cost_is and @active_battler.quarter_spell_cost_is != 0
          sp_cost /= 2
        end

        if affinity <= @active_battler.double_spell_cost_is and @active_battler.double_spell_cost_is != 0
          sp_cost *= 2
        end
       
        if affinity <= @active_battler.quad_spell_cost_is and @active_battler.quad_spell_cost_is != 0
          sp_cost *= 2
        end
      end
    end
    @active_battler.sp -= sp_cost
    # Refresh status window
    @status_window.refresh
    # Show skill name on help window
    @help_window.set_text(@skill.name, 1)
    # Set animation ID
    @animation1_id = @skill.animation1_id
    @animation2_id = @skill.animation2_id
    # Set command event ID
    @common_event_id = @skill.common_event_id
    # Set target battlers
    set_target_battlers(@skill.scope)
    # Apply skill effect
    for target in @target_battlers
      target.skill_effect(@active_battler, @skill)
    end
   
    if @active_battler.is_actor? and @skill.element_set != []
      for i in @skill.element_set
        @active_battler.element_affinity_adjust(i)
      end
    end
   
   
  end
 
end