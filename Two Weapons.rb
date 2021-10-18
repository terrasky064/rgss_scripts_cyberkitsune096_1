#Credit Cyberkitsune096
class Game_Actor < Game_Battler
 
  attr_accessor :two_weapons
  attr_accessor :sec_attack
 
  alias before_fomar_two_weapons_setup setup
  def setup(actor_id)
    before_fomar_two_weapons_setup(actor_id)
    @two_weapons = false
    @sec_attack = false
  end
 
  def hand_check
    if @weapon_id == 0 and @two_weapons == true
      @weapon_id = @armor1_id
      @armor1_id = 0
      @two_weapons = false
    end
  end
       
 
  def equip(equip_type, item)
   
    if item == 0
      id = 0
    else
      id = item.id
    end
   
   
    case equip_type
    when 0  # Weapon
      if id == 0 or $game_party.weapon_number(id) > 0
        $game_party.gain_weapon(@weapon_id, 1)
        @weapon_id = id
        $game_party.lose_weapon(id, 1)
      end
    when 1  # Shield
      if item.is_a?(RPG::Weapon)
        if @weapon_id == 0
          @weapon_id = id
          $game_party.lose_weapon(id, 1)
        else
          if @two_weapons == true
            $game_party.gain_weapon(@armor1_id, 1)
          else
            $game_party.gain_armor(@armor1_id, 1)
          end
          @armor1_id = id
          $game_party.lose_weapon(id, 1)
          @two_weapons = true
        end
      else # RPG::Armor
        if id == 0 or $game_party.armor_number(id) > 0
          update_auto_state($data_armors[@armor1_id], $data_armors[id])
          if @two_weapons == true
            $game_party.gain_weapon(@armor1_id, 1)
            @two_weapons = false
          else
            $game_party.gain_armor(@armor1_id, 1)
          end
          @armor1_id = id
          $game_party.lose_armor(id, 1)
        end
      end
    when 2  # Head
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor2_id], $data_armors[id])
        $game_party.gain_armor(@armor2_id, 1)
        @armor2_id = id
        $game_party.lose_armor(id, 1)
      end
    when 3  # Body
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor3_id], $data_armors[id])
        $game_party.gain_armor(@armor3_id, 1)
        @armor3_id = id
        $game_party.lose_armor(id, 1)
      end
    when 4  # Accessory
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor4_id], $data_armors[id])
        $game_party.gain_armor(@armor4_id, 1)
        @armor4_id = id
        $game_party.lose_armor(id, 1)
      end
    end
  end
 
  def element_rate(element_id)
    # Get values corresponding to element effectiveness
    table = [0,200,150,100,50,0,-100]
    result = table[$data_classes[@class_id].element_ranks[element_id]]
    # If this element is protected by armor, then it's reduced by half
   
   
    # MODIFIED
    #for i in [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
    #  armor = $data_armors[i]
    #  if armor != nil and armor.guard_element_set.include?(element_id)
    #    result /= 2
    #  end
    #end
   
    unless @two_weapons == true
      armor_ids = [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
    else
      armor_ids = [@armor2_id, @armor3_id, @armor4_id]
    end
   
    for i in armor_ids
      armor = $data_armors[i]
      if armor != nil and armor.guard_element_set.include?(element_id)
        result /= 2
      end
    end
   
    # END OF MODIFIED SECTION
   
   
    # If this element is protected by states, then it's reduced by half
    for i in @states
      if $data_states[i].guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # End Method
    return result
  end
 
  def state_guard?(state_id)
    # MODIFIED
    #for i in [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
   
    unless @two_weapons == true
      armor_ids = [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
    else
      armor_ids = [@armor2_id, @armor3_id, @armor4_id]
    end
   
    for i in armor_ids
     
    # END OF MODIFIED SECTION
   
      armor = $data_armors[i]
      if armor != nil
        if armor.guard_state_set.include?(state_id)
          return true
        end
      end
    end
    return false
  end
 
  def element_set
    # MODIFIED
    #weapon = $data_weapons[@weapon_id]
    unless sec_attack == true
      weapon = $data_weapons[@weapon_id]
    else
      weapon = $data_weapons[@armor1_id]
    end
   
   
    # END OF MODIFIED SECTION
   
    return weapon != nil ? weapon.element_set : []
  end
 
  def plus_state_set
    # MODIFIED
    #weapon = $data_weapons[@weapon_id]
    unless sec_attack == true
      weapon = $data_weapons[@weapon_id]
    else
      weapon = $data_weapons[@armor1_id]
    end
   
   
    # END OF MODIFIED SECTION
    return weapon != nil ? weapon.plus_state_set : []
  end
 
  def minus_state_set
    # MODIFIED
    #weapon = $data_weapons[@weapon_id]
    unless sec_attack == true
      weapon = $data_weapons[@weapon_id]
    else
      weapon = $data_weapons[@armor1_id]
    end
   
   
    # END OF MODIFIED SECTION
    return weapon != nil ? weapon.minus_state_set : []
  end
 
  def base_str
    n = $data_actors[@actor_id].parameters[2, @level]
    weapon = $data_weapons[@weapon_id]
    # MODIFIED
    #armor1 = $data_armors[@armor1_id]
    unless @two_weapons == true
      armor1 = $data_armors[@armor1_id]
    else
      armor1 = $data_weapons[@armor1_id]
    end
    # END OF MODIFIED SECTION
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.str_plus : 0
    n += armor1 != nil ? armor1.str_plus : 0
    n += armor2 != nil ? armor2.str_plus : 0
    n += armor3 != nil ? armor3.str_plus : 0
    n += armor4 != nil ? armor4.str_plus : 0
    return [[n, 1].max, 999].min
  end
 
  def base_dex
    n = $data_actors[@actor_id].parameters[3, @level]
    weapon = $data_weapons[@weapon_id]
    # MODIFIED
    #armor1 = $data_armors[@armor1_id]
    unless @two_weapons == true
      armor1 = $data_armors[@armor1_id]
    else
      armor1 = $data_weapons[@armor1_id]
    end
    # END OF MODIFIED SECTION
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.dex_plus : 0
    n += armor1 != nil ? armor1.dex_plus : 0
    n += armor2 != nil ? armor2.dex_plus : 0
    n += armor3 != nil ? armor3.dex_plus : 0
    n += armor4 != nil ? armor4.dex_plus : 0
    return [[n, 1].max, 999].min
  end
 
  def base_agi
    n = $data_actors[@actor_id].parameters[4, @level]
    weapon = $data_weapons[@weapon_id]
    # MODIFIED
    #armor1 = $data_armors[@armor1_id]
    unless @two_weapons == true
      armor1 = $data_armors[@armor1_id]
    else
      armor1 = $data_weapons[@armor1_id]
    end
    # END OF MODIFIED SECTION
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.agi_plus : 0
    n += armor1 != nil ? armor1.agi_plus : 0
    n += armor2 != nil ? armor2.agi_plus : 0
    n += armor3 != nil ? armor3.agi_plus : 0
    n += armor4 != nil ? armor4.agi_plus : 0
    return [[n, 1].max, 999].min
  end
 
  def base_int
    n = $data_actors[@actor_id].parameters[5, @level]
    weapon = $data_weapons[@weapon_id]
    # MODIFIED
    #armor1 = $data_armors[@armor1_id]
    unless @two_weapons == true
      armor1 = $data_armors[@armor1_id]
    else
      armor1 = $data_weapons[@armor1_id]
    end
    # END OF MODIFIED SECTION
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.int_plus : 0
    n += armor1 != nil ? armor1.int_plus : 0
    n += armor2 != nil ? armor2.int_plus : 0
    n += armor3 != nil ? armor3.int_plus : 0
    n += armor4 != nil ? armor4.int_plus : 0
    return [[n, 1].max, 999].min
  end
 
  def base_atk
    # MODIFIED
    #weapon = $data_weapons[@weapon_id]
    unless sec_attack == true
      weapon = $data_weapons[@weapon_id]
    else
      weapon = $data_weapons[@armor1_id]
    end
    # END OF MODIFIED SECTION
    return weapon != nil ? weapon.atk : 0
  end
 
  def base_pdef
    weapon = $data_weapons[@weapon_id]
    # MODIFIED
    #armor1 = $data_armors[@armor1_id]
    unless @two_weapons == true
      armor1 = $data_armors[@armor1_id]
    else
      armor1 = $data_weapons[@armor1_id]
    end
    # END OF MODIFIED SECTION
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    pdef1 = weapon != nil ? weapon.pdef : 0
    pdef2 = armor1 != nil ? armor1.pdef : 0
    pdef3 = armor2 != nil ? armor2.pdef : 0
    pdef4 = armor3 != nil ? armor3.pdef : 0
    pdef5 = armor4 != nil ? armor4.pdef : 0
    return pdef1 + pdef2 + pdef3 + pdef4 + pdef5
  end
 
  def base_mdef
    weapon = $data_weapons[@weapon_id]
    # MODIFIED
    #armor1 = $data_armors[@armor1_id]
    unless @two_weapons == true
      armor1 = $data_armors[@armor1_id]
    else
      armor1 = $data_weapons[@armor1_id]
    end
    # END OF MODIFIED SECTION
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    mdef1 = weapon != nil ? weapon.mdef : 0
    mdef2 = armor1 != nil ? armor1.mdef : 0
    mdef3 = armor2 != nil ? armor2.mdef : 0
    mdef4 = armor3 != nil ? armor3.mdef : 0
    mdef5 = armor4 != nil ? armor4.mdef : 0
    return mdef1 + mdef2 + mdef3 + mdef4 + mdef5
  end
 
  def base_eva
    # MODIFIED
    #armor1 = $data_armors[@armor1_id]
    unless @two_weapons == true
      armor1 = $data_armors[@armor1_id]
    else
      armor1 = nil
    end
    # END OF MODIFIED SECTION
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    eva1 = armor1 != nil ? armor1.eva : 0
    eva2 = armor2 != nil ? armor2.eva : 0
    eva3 = armor3 != nil ? armor3.eva : 0
    eva4 = armor4 != nil ? armor4.eva : 0
    return eva1 + eva2 + eva3 + eva4
  end
 
  def animation1_id
    # MODIFIED
    #weapon = $data_weapons[@weapon_id]
    unless sec_attack == true
      weapon = $data_weapons[@weapon_id]
    else
      weapon = $data_weapons[@armor1_id]
    end
    # END OF MODIFIED SECTION
    return weapon != nil ? weapon.animation1_id : 0
  end
 
  def animation2_id
    # MODIFIED
    #weapon = $data_weapons[@weapon_id]
    unless sec_attack == true
      weapon = $data_weapons[@weapon_id]
    else
      weapon = $data_weapons[@armor1_id]
    end
    # END OF MODIFIED SECTION
    return weapon != nil ? weapon.animation2_id : 0
  end
 
end


class Window_EquipItem < Window_Selectable
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    # Add equippable weapons
    if @equip_type == 0
      weapon_set = $data_classes[@actor.class_id].weapon_set
      for i in 1...$data_weapons.size
        if $game_party.weapon_number(i) > 0 and weapon_set.include?(i)
          @data.push($data_weapons[i])
        end
      end
    end
    # Add equippable armor
    if @equip_type != 0
      # MODIFIED
      if @equip_type == 1
        weapon_set = $data_classes[@actor.class_id].weapon_set
        for i in 1...$data_weapons.size
          if $game_party.weapon_number(i) > 0 and weapon_set.include?(i)
            @data.push($data_weapons[i])
          end
        end
      end
      # END OF MODIFIED SECTION
      armor_set = $data_classes[@actor.class_id].armor_set
      for i in 1...$data_armors.size
        if $game_party.armor_number(i) > 0 and armor_set.include?(i)
          if $data_armors[i].kind == @equip_type-1
            @data.push($data_armors[i])
          end
        end
      end
    end
    # Add blank page
    @data.push(nil)
    # Make a bit map and draw all items
    @item_max = @data.size
    self.contents = Bitmap.new(width - 32, row_max * 32)
    for i in 0...@item_max-1
      draw_item(i)
    end
  end
end


class Window_EquipRight < Window_Selectable
  def refresh
    self.contents.clear
    @data = []
    @data.push($data_weapons[@actor.weapon_id])
    # MODIFIED
    #@data.push($data_armors[@actor.armor1_id])
    unless @actor.two_weapons == true
      @data.push($data_armors[@actor.armor1_id])
    else
      @data.push($data_weapons[@actor.armor1_id])
    end
    # END OF MODIFIED SECTION
    @data.push($data_armors[@actor.armor2_id])
    @data.push($data_armors[@actor.armor3_id])
    @data.push($data_armors[@actor.armor4_id])
    @item_max = @data.size
    self.contents.font.color = system_color
    self.contents.draw_text(4, 32 * 0, 92, 32, $data_system.words.weapon)
    self.contents.draw_text(4, 32 * 1, 92, 32, $data_system.words.armor1)
    self.contents.draw_text(4, 32 * 2, 92, 32, $data_system.words.armor2)
    self.contents.draw_text(4, 32 * 3, 92, 32, $data_system.words.armor3)
    self.contents.draw_text(5, 32 * 4, 92, 32, $data_system.words.armor4)
    draw_item_name(@data[0], 92, 32 * 0)
    draw_item_name(@data[1], 92, 32 * 1)
    draw_item_name(@data[2], 92, 32 * 2)
    draw_item_name(@data[3], 92, 32 * 3)
    draw_item_name(@data[4], 92, 32 * 4)
  end
end


class Scene_Equip
  def update
   
   
    # Update windows
    @left_window.update
    @right_window.update
    @item_window.update
    refresh
    # If right window is active: call update_right
    if @right_window.active
      update_right
      return
    end
    # If item window is active: call update_item
    if @item_window.active
      update_item
      return
    end
  end
 
 
  def update_item
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Activate right window
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Play equip SE
      $game_system.se_play($data_system.equip_se)
      # Get currently selected data on the item window
      item = @item_window.item
      # Change equipment
      @actor.equip(@right_window.index, item == nil ? 0 : item)
     
      @actor.hand_check
     
      # Activate right window
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      # Remake right window and item window contents
      @right_window.refresh
      @item_window.refresh
      @item_window1.refresh
      @item_window2.refresh
      return
    end
  end
end


class Window_Status < Window_Base
  def refresh
    self.contents.clear
    draw_actor_graphic(@actor, 40, 112)
    draw_actor_name(@actor, 4, 0)
    draw_actor_class(@actor, 4 + 144, 0)
    draw_actor_level(@actor, 96, 32)
    draw_actor_state(@actor, 96, 64)
    draw_actor_hp(@actor, 96, 112, 172)
    draw_actor_sp(@actor, 96, 144, 172)
    draw_actor_parameter(@actor, 96, 192, 0)
    draw_actor_parameter(@actor, 96, 256, 1)
    draw_actor_parameter(@actor, 96, 288, 2)
    draw_actor_parameter(@actor, 96, 320, 3)
    draw_actor_parameter(@actor, 96, 352, 4)
    draw_actor_parameter(@actor, 96, 384, 5)
    draw_actor_parameter(@actor, 96, 416, 6)
    draw_actor_parameter(@actor, 96, 224, 7)
    self.contents.font.color = system_color
    self.contents.draw_text(320, 48, 80, 32, "EXP")
    self.contents.draw_text(320, 80, 80, 32, "NEXT")
    self.contents.font.color = normal_color
    self.contents.draw_text(320 + 80, 48, 84, 32, @actor.exp_s, 2)
    self.contents.draw_text(320 + 80, 80, 84, 32, @actor.next_rest_exp_s, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(320, 160, 96, 32, "equipment")
    draw_item_name($data_weapons[@actor.weapon_id], 320 + 16, 208)
    # MODIFIED
    #draw_item_name($data_armors[@actor.armor1_id], 320 + 16, 256)
    unless @actor.two_weapons == true
      draw_item_name($data_armors[@actor.armor1_id], 320 + 16, 256)
    else
      draw_item_name($data_weapons[@actor.armor1_id], 320 + 16, 256)
    end
    # END OF MODIFIED SECTION
    draw_item_name($data_armors[@actor.armor2_id], 320 + 16, 304)
    draw_item_name($data_armors[@actor.armor3_id], 320 + 16, 352)
    draw_item_name($data_armors[@actor.armor4_id], 320 + 16, 400)
  end
end

class Window_Base < Window
  def draw_actor_parameter(actor, x, y, type)
    case type
    when 0
      parameter_name = $data_system.words.atk
      parameter_value = actor.atk
    when 1
      parameter_name = $data_system.words.pdef
      parameter_value = actor.pdef
    when 2
      parameter_name = $data_system.words.mdef
      parameter_value = actor.mdef
    when 3
      parameter_name = $data_system.words.str
      parameter_value = actor.str
    when 4
      parameter_name = $data_system.words.dex
      parameter_value = actor.dex
    when 5
      parameter_name = $data_system.words.agi
      parameter_value = actor.agi
    when 6
      parameter_name = $data_system.words.int
      parameter_value = actor.int
    when 7
      parameter_name = $data_system.words.atk
      if actor.two_weapons == true
        actor.sec_attack = true
        parameter_value = actor.atk
        actor.sec_attack = false
      else
        parameter_value = 0
      end
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, 32, parameter_name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 120, y, 36, 32, parameter_value.to_s, 2)
  end
end


class Scene_Battle
 
  alias before_fomar_start_phase4 start_phase4
  def start_phase4
    for actor in $game_party.actors
      actor.sec_attack = false
    end
    before_fomar_start_phase4
  end
 
  def update_phase4_step6
    # Clear battler being forced into action
    $game_temp.forcing_battler = nil
    # If common event ID is valid
    if @common_event_id > 0
      # Set up event
      common_event = $data_common_events[@common_event_id]
      $game_system.battle_interpreter.setup(common_event.list, 0)
    end
   
    if @active_battler.is_a?(Game_Actor) and @active_battler.current_action.kind == 0
      if @active_battler.two_weapons == true and @active_battler.sec_attack == false
        unless judge
          @active_battler.sec_attack = true
          @phase4_step = 2
          return
        end
      end
    end
   
   
    # Shift to step 1
    @phase4_step = 1
  end
end
class Scene_Equip
  def refresh
    # Set item window to visible
    @item_window1.visible = (@right_window.index == 0)
    @item_window2.visible = (@right_window.index == 1)
    @item_window3.visible = (@right_window.index == 2)
    @item_window4.visible = (@right_window.index == 3)
    @item_window5.visible = (@right_window.index == 4)
    # Get currently equipped item
    item1 = @right_window.item
    # Set current item window to @item_window
    case @right_window.index
    when 0
      @item_window = @item_window1
    when 1
      @item_window = @item_window2
    when 2
      @item_window = @item_window3
    when 3
      @item_window = @item_window4
    when 4
      @item_window = @item_window5
    end
    item2 = @item_window.item
    # If right window is active
    if @right_window.active
      # Erase parameters for after equipment change
      @left_window.set_new_parameters(nil, nil, nil, nil)
    end
    # If item window is active
    if @item_window.active
      if item2 == nil
        id = 0
      else
        id = item2.id
      end
     
      new_atk = @actor.new_atk(@right_window.index, id)
      new_atk2 = @actor.new_atk2(@right_window.index, id, item2.is_a?(RPG::Weapon))
      new_pdef = @actor.new_pdef(@right_window.index, id, item2.is_a?(RPG::Weapon))
      new_mdef = @actor.new_mdef(@right_window.index, id, item2.is_a?(RPG::Weapon))
     
      @left_window.set_new_parameters(new_atk, new_atk2, new_pdef, new_mdef)
    end
  end
end

class Game_Actor < Game_Battler
 
  def new_atk(index, id)
    if index == 0
      weapon = $data_weapons[id]
    else
      weapon = $data_weapons[@weapon_id]
    end
    return weapon != nil ? weapon.atk : 0
  end
 
  def new_atk2(index, id, weapony = false)
    if index == 1
      if weapony == false
        return 0
      end
      weapon = $data_weapons[id]
    else
      if @two_weapons == true
        weapon = $data_weapons[@armor1_id]
      end
    end
    return weapon != nil ? weapon.atk : 0
  end
 
  def new_pdef(index, id, weapony = false)
    weapon = $data_weapons[@weapon_id]
    unless @two_weapons == true
      armor1 = $data_armors[@armor1_id]
    else
      armor1 = $data_weapons[@armor1_id]
    end
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    case index
    when 0
      weapon = $data_weapons[id]
    when 1
    unless weapony == true
      armor1 = $data_armors[id]
    else
      armor1 = $data_weapons[id]
    end
    when 2
      armor2 = $data_armors[id]
    when 3
      armor3 = $data_armors[id]
    when 4
      armor4 = $data_armors[id]
    end
    pdef1 = weapon != nil ? weapon.pdef : 0
    pdef2 = armor1 != nil ? armor1.pdef : 0
    pdef3 = armor2 != nil ? armor2.pdef : 0
    pdef4 = armor3 != nil ? armor3.pdef : 0
    pdef5 = armor4 != nil ? armor4.pdef : 0
    return pdef1 + pdef2 + pdef3 + pdef4 + pdef5
  end
 
  def new_mdef(index, id, weapony = false)
    weapon = $data_weapons[@weapon_id]
    unless @two_weapons == true
      armor1 = $data_armors[@armor1_id]
    else
      armor1 = $data_weapons[@armor1_id]
    end
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    case index
    when 0
      weapon = $data_weapons[id]
    when 1
    unless weapony == true
      armor1 = $data_armors[id]
    else
      armor1 = $data_weapons[id]
    end
    when 2
      armor2 = $data_armors[id]
    when 3
      armor3 = $data_armors[id]
    when 4
      armor4 = $data_armors[id]
    end
    mdef1 = weapon != nil ? weapon.mdef : 0
    mdef2 = armor1 != nil ? armor1.mdef : 0
    mdef3 = armor2 != nil ? armor2.mdef : 0
    mdef4 = armor3 != nil ? armor3.mdef : 0
    mdef5 = armor4 != nil ? armor4.mdef : 0
    return mdef1 + mdef2 + mdef3 + mdef4 + mdef5
  end
 
end


class Window_EquipLeft < Window_Base
 
  def refresh
    self.contents.clear
    self.contents.font.size = 22
    draw_actor_name(@actor, 4, 0)
    draw_actor_level(@actor, 4, 32)
    draw_actor_parameter(@actor, 4, 64, 0)
    @actor.sec_attack = true
    draw_actor_parameter(@actor, 4, 86, 7)
    @actor.sec_attack = false
   
    draw_actor_parameter(@actor, 4, 108, 1)
    draw_actor_parameter(@actor, 4, 130, 2)
    if @new_atk != nil
      self.contents.font.color = system_color
      self.contents.draw_text(160, 64, 40, 32, "->", 1)
      self.contents.font.color = normal_color
      self.contents.draw_text(200, 64, 36, 32, @new_atk.to_s, 2)
    end
    if @new_pdef != nil
      self.contents.font.color = system_color
      self.contents.draw_text(160, 108, 40, 32, "->", 1)
      self.contents.font.color = normal_color
      self.contents.draw_text(200, 108, 36, 32, @new_pdef.to_s, 2)
    end
    if @new_mdef != nil
      self.contents.font.color = system_color
      self.contents.draw_text(160, 130, 40, 32, "->", 1)
      self.contents.font.color = normal_color
      self.contents.draw_text(200, 130, 36, 32, @new_mdef.to_s, 2)
    end
   
    if @new_atk2 != nil
      self.contents.font.color = system_color
      self.contents.draw_text(160, 86, 40, 32, "->", 1)
      self.contents.font.color = normal_color
      self.contents.draw_text(200, 86, 36, 32, @new_atk2.to_s, 2)
    end
  end
 
 
  def set_new_parameters(new_atk, new_atk2, new_pdef, new_mdef)
    if @new_atk != new_atk or @new_atk2 != new_atk2 or @new_pdef != new_pdef or @new_mdef != new_mdef
      @new_atk = new_atk
      @new_atk2 = new_atk2
      @new_pdef = new_pdef
      @new_mdef = new_mdef
      refresh
    end
  end
end