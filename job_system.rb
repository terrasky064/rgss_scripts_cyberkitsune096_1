#--------------------------------------------------------------------------
# * Job System I
#   system by cyberkitsune096
# This section is about accumulating exp
#--------------------------------------------------------------------------

class Game_Enemy < Game_Battler

#--------------------------------------------------------------------------
# * Get Name
#--------------------------------------------------------------------------
def name
#get the name
name = $data_enemies[@enemy_id].name
#remove the 0s from the start of the name
while name[0] == 48
name = name[1...name.size]
end
#now i get the number and make it into a string so I can see how
#long it is
x = name.to_i
x = x.to_s
name = name[x.size...name.size]
return name
end

#--------------------------------------------------------------------------
# * Get AP
#--------------------------------------------------------------------------
def ap
#get the name where the ap is entered to help people uncomfortable
#with scripts
name = $data_enemies[@enemy_id].name
#lets just have the nice number
name = name.to_i
if name == nil
name = 0
end
return name
end

end



class Scene_Battle

#--------------------------------------------------------------------------
# * Start After Battle Phase
#--------------------------------------------------------------------------
def start_phase5
# Shift to phase 5
@phase = 5
# Play battle end ME
$game_system.me_play($game_system.battle_end_me)
# Return to BGM before battle started
$game_system.bgm_play($game_temp.map_bgm)
# Initialize EXP, amount of gold, and treasure
exp = 0
gold = 0
#oh and AP
ap = 0
treasures = []
# Loop
for enemy in $game_troop.enemies
# If enemy is not hidden
unless enemy.hidden
# Add EXP and amount of gold obtained
exp += enemy.exp
gold += enemy.gold
ap += enemy.ap
# Determine if treasure appears
if rand(100) < enemy.treasure_prob
if enemy.item_id > 0
treasures.push($data_items[enemy.item_id])
end
if enemy.weapon_id > 0
treasures.push($data_weapons[enemy.weapon_id])
end
if enemy.armor_id > 0
treasures.push($data_armors[enemy.armor_id])
end
end
end
end
# Treasure is limited to a maximum of 6 items
treasures = treasures[0..5]
# Obtaining EXP
for i in 0...$game_party.actors.size
actor = $game_party.actors[i]
if actor.cant_get_exp? == false
last_level = actor.level
actor.exp += exp
if actor.level > last_level
@status_window.level_up(i)
end
last_level = actor.job_level
actor.gain_ap(ap)
if actor.job_level > last_level
actor.job_level_up(last_level)
actor.damage = "Job Level Up"
actor.damage_pop = true
end
end
end
# Obtaining gold
$game_party.gain_gold(gold)
# Obtaining treasure
for item in treasures
case item
when RPG::Item
$game_party.gain_item(item.id, 1)
when RPG::Weapon
$game_party.gain_weapon(item.id, 1)
when RPG::Armor
$game_party.gain_armor(item.id, 1)
end
end
# Make battle result window
@result_window = Window_BattleResult.new(exp, gold, treasures, ap)
# Set wait count
@phase5_wait_count = 100
end
end

class Window_BattleResult < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     exp       : EXP
  #     gold      : amount of gold
  #     treasures : treasures
  #--------------------------------------------------------------------------
  def initialize(exp, gold, treasures, ap = 0)
    @exp = exp
    @gold = gold
    @treasures = treasures
    @ap = ap
    super(160, 0, 320, @treasures.size * 32 + 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.y = 160 - height / 2
    self.back_opacity = 160
    self.visible = false
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    x = 4
    self.contents.font.color = normal_color
    cx = contents.text_size(@exp.to_s).width
    self.contents.draw_text(x, 0, cx, 32, @exp.to_s)
    x += cx + 4
    self.contents.font.color = system_color
    cx = contents.text_size("EXP").width
    self.contents.draw_text(x, 0, 64, 32, "EXP")
    x += cx + 16
    self.contents.font.color = normal_color
    cx = contents.text_size(@gold.to_s).width
    self.contents.draw_text(x, 0, cx, 32, @gold.to_s)
    x += cx + 4
    self.contents.font.color = system_color
    self.contents.draw_text(x, 0, 128, 32, $data_system.words.gold)
    x += cx + 16
    self.contents.font.color = normal_color
    cx = contents.text_size(@ap.to_s).width
    self.contents.draw_text(x, 0, cx, 32, @ap.to_s)
    x += cx + 4
    self.contents.font.color = system_color
    self.contents.draw_text(x, 0, 128, 32, "AP")
    y = 32
    for item in @treasures
      draw_item_name(item, 4, y)
      y += 32
    end
  end
end

#--------------------------------------------------------------------------
# * Job System II
#   system by Fomar0153
# This section is about the jobs themselves and the
# actors but no interfaces
#--------------------------------------------------------------------------
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
Jobs = [
  {'name'=>"Knight", 'command'=>'!Defend',
  'max_lvl'=>6, 'lvl1'=>10, 'lvl2'=>20, 'lvl3'=>30, 'lvl4'=>40, 'lvl5'=>50, 'lvl6'=>100,
  'ability1'=>'!Defend', 'ability2'=>nil, 'ability3'=>nil, 'ability4'=>nil, 'ability5'=>nil, 'ability6'=>'Equip Sword',
  'HP'=>20,'SP'=>0,'STR'=>20,'DEX'=>10,'INT'=>0,'AGI'=>0,
  'style1'=>'Sword', 'style2'=>'Shield', 'style3'=>'Armour'
  },
  {'name'=>"Mage", 'command'=>'!Ice-Skill',
  'max_lvl'=>6, 'lvl1'=>10, 'lvl2'=>20, 'lvl3'=>30, 'lvl4'=>40, 'lvl5'=>50, 'lvl6'=>100,
  'ability1'=>'!Skill', 'ability2'=>nil, 'ability3'=>nil, 'ability4'=>nil, 'ability5'=>nil, 'ability6'=>'Equip Staff',
  'HP'=>0,'SP'=>20,'STR'=>0,'DEX'=>0,'INT'=>20,'AGI'=>10,
  'style1'=>'Staff', 'style2'=>'Robe', 'style3'=>'Cloak'
  },
 
  ]
 
  Unemployed = "Job-Free"             #The bare job
 
  Gain_stats = true
  Weapon_style_by_attribute = true #false will mean it is done individually by id
  Change_Graphics = false #if set to true you can specify differant character/battler images for each job
  #--------------------------------------------------------------------------
  # * Weapon/Armour Styles
  #    0 is weapons and 1 is armour
  #--------------------------------------------------------------------------
  def get_style(type, id)
    if Weapon_style_by_attribute == true
      # BY ATTRIBUTE
    if type == 0
      item = $data_weapons[id]
      if item.element_set.include?(17)
        #this element means it requires the ability to wield swords
        return 'Sword'
      end
      if item.element_set.include?(18)
        #this element means it requires the ability to wield staffs
        return 'Staff'
      end
     
    end
    if type == 1
      item = $data_armors[id]
      if item.element_set.include?(17)
        #you can re-use elements for armour for example this can mean shield when tagged on armour
        return 'Shield'
      end
      if item.element_set.include?(19)
        #or to avoid confusion you can use differant ones
        return 'Armour'
      end
    end
    return nil
  else
    # BY ID
    if type == 0
      case id
      when 1
        return 'Sword'
      when 29
         return 'Staff'
      end
    end
    if type == 1
      case id
      when 1
        return 'Shield'
      end
    end
    return nil
    end
  end
  #--------------------------------------------------------------------------
  # * Update actor_graphics
  #--------------------------------------------------------------------------
  def update_actor_graphics
    case @actor_id
    #note: most people won't know what to do with the hues so I'll leave as their default
      when 1
       
        case @job_current
          when Unemployed
            @battler_name = '001-Fighter01'
            @character_name = '001-Fighter01'
          when 'Knight'
            @battler_name = '001-Fighter01'
            @character_name = '001-Fighter01'
          when 'Mage'
            @battler_name = '001-Fighter01'
            @character_name = '001-Fighter01'
          end
         
      when 2
       
        case @job_current
          when Unemployed
            @battler_name = '010-Lancer02'
            @character_name = '010-Lancer02'
          when 'Knight'
            @battler_name = '010-Lancer02'
            @character_name = '010-Lancer02'
          when 'Mage'
            @battler_name = '010-Lancer02'
            @character_name = '010-Lancer02'
          end
    end
     
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # * Change Job
  #--------------------------------------------------------------------------
  def change_job(prospect)
    last_maxhp = self.maxhp
    last_maxsp = self.maxsp
    old_job = get_job
    @job_current = prospect
    new_job = get_job
    drop_active_abilities(old_job['name'])
    unless prospect == Unemployed
      @active_abilities.push(new_job['command'])
    else
      @active_abilities.push(' ')
    end
    @active_abilities.push(' ')
    if Change_Graphics == true
      update_actor_graphics
    end
    @hp = (@hp.to_f * (self.maxhp.to_f / last_maxhp.to_f)).to_i
    @sp = (@sp.to_f * (self.maxsp.to_f / last_maxsp.to_f)).to_i
  end
  #--------------------------------------------------------------------------
  # * Drop active abilities
  #--------------------------------------------------------------------------
  def change_active_abilities(ability, pos = 1)
    special_unequip(@active_abilities[pos])
    @active_abilities[pos] = ability
    special_equip(@active_abilities[pos])
  end
  #--------------------------------------------------------------------------
  # * Drop active abilities
  #--------------------------------------------------------------------------
  def drop_active_abilities(job_name)
    if job_name == Unemployed
      special_unequip(@active_abilities[0])
    end
    special_unequip(@active_abilities[1])
    @active_abilities = []
  end
  #--------------------------------------------------------------------------
  # * special equip
  #    This is for the non-normal abilities, there are no
  #    examples this is really for scripters rather than
  #    non-scripters
  #--------------------------------------------------------------------------
  def special_equip(ability_name)
      case ability_name
        when ' '
        #having no whens causes an error
        #you would type when and then the ability
        #this is if you have obscure but interesting
        #abilities like duel wielding
        #note:you don't need these for abilities like
        #equip or battle commands
      end
      return
    end
  #--------------------------------------------------------------------------
  # * special unequip
  #    This is for the non-normal abilities, there are no
  #    examples this is really for scripters rather than
  #    non-scripters
  #--------------------------------------------------------------------------
  def special_unequip(ability_name)
      case ability_name
        when ' '
        #having no whens causes an error
        #you would type when and then the ability
        #this is if you have obscure but interesting
        #abilities like duel wielding
        #note:you don't need these for abilities like
        #equip or battle commands
      end
      return
    end
  #--------------------------------------------------------------------------
  # * Setup
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  def setup(actor_id)
    actor = $data_actors[actor_id]
    @actor_id = actor_id
    @job_history = []
    for job in Jobs
    @job_history.push({'name'=>job['name'], 'ap'=>0})
    end
    @job_current = Unemployed
    @abilities = [' ']
    @active_abilities = []
    @name = actor.name
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    @battler_name = actor.battler_name
    @battler_hue = actor.battler_hue
    @class_id = actor.class_id
    @weapon_id = actor.weapon_id
    @armor1_id = actor.armor1_id
    @armor2_id = actor.armor2_id
    @armor3_id = actor.armor3_id
    @armor4_id = actor.armor4_id
    @level = actor.initial_level
    @exp_list = Array.new(101)
    make_exp_list
    @exp = @exp_list[@level]
    @skills = []
    @hp = maxhp
    @sp = maxsp
    @states = []
    @states_turn = {}
    @maxhp_plus = 0
    @maxsp_plus = 0
    @str_plus = 0
    @dex_plus = 0
    @agi_plus = 0
    @int_plus = 0
    # Learn skill
    for i in 1..@level
      for j in $data_classes[@class_id].learnings
        if j.level == i
          learn_skill(j.skill_id)
        end
      end
    end
    # Update auto state
    update_auto_state(nil, $data_armors[@armor1_id])
    update_auto_state(nil, $data_armors[@armor2_id])
    update_auto_state(nil, $data_armors[@armor3_id])
    update_auto_state(nil, $data_armors[@armor4_id])
  end
 
  def abilities(x = 0)
    if x == 0
      return @active_abilities
    elsif x == 1
      return @abilities
    end
  end
  #--------------------------------------------------------------------------
  # * Gain_ap
  #--------------------------------------------------------------------------
  def gain_ap(ap)
    unless @job_current == Unemployed
      for job in @job_history
        if job['name'] == @job_current
          job['ap'] += ap
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Unemployed_text
  #--------------------------------------------------------------------------
  def unemployed_text
    return Unemployed
  end
  #--------------------------------------------------------------------------
  # * Get Job
  #--------------------------------------------------------------------------
  def get_job(job_hunt = @job_current)
    unless job_hunt == Unemployed
    for job in Jobs
      if job['name'] == job_hunt
        return job
      end
    end
  end
  return   {'name'=>Unemployed, 'command'=>' ',
  'max_lvl'=>0, 'lvl1'=>0, 'lvl2'=>0, 'lvl3'=>0, 'lvl4'=>0, 'lvl5'=>0, 'lvl6'=>0,
  'ability1'=>nil, 'ability2'=>nil, 'ability3'=>nil, 'ability4'=>nil, 'ability5'=>nil, 'ability6'=>nil,
  'HP'=>0,'SP'=>0,'STR'=>0,'DEX'=>0,'INT'=>0,'AGI'=>0,
  'style1'=>nil, 'style2'=>nil, 'style3'=>nil
  }

  end
 
  #--------------------------------------------------------------------------
  # * Job Level
  #--------------------------------------------------------------------------
  def job_level(job_hunt = @job_current)
    unless job_hunt == Unemployed
      for job in @job_history
        if job['name'] == job_hunt
          ap = job['ap']
          lvl = 0
          job_advert = get_job
          for i in 1...job_advert['max_lvl'] + 1
            key = 'lvl' + i.to_s
            if ap >= job_advert[key]
              ap -= job_advert[key]
              lvl += 1
            end
          end
          return lvl
        end
    end
  end
    return 0
  end
  #--------------------------------------------------------------------------
  # * Ap to next Job Level
  #--------------------------------------------------------------------------
  def ap_to_next_job_level(job_hunt = @job_current)
    unless job_hunt == Unemployed
      for job in @job_history
        if job['name'] == job_hunt
          ap = job['ap']
          lvl = 0
          job_advert = get_job
          for i in 1...job_advert['max_lvl'] + 1
            key = 'lvl' + i.to_s
            if ap >= job_advert[key]
              ap -= job_advert[key]
              lvl += 1
            end
          end
          if job_advert['max_lvl'] == lvl
            ap = 0
          end
          return ap
        end
    end
    return 0
  end

  end
  #--------------------------------------------------------------------------
  # * This method could be replaced with an accessor if
  #    if you like them.
  #--------------------------------------------------------------------------
  def current_job
    return @job_current
  end
 
  #--------------------------------------------------------------------------
  # * Job Level Up
  #--------------------------------------------------------------------------
  def job_level_up(last_level)
    job = get_job
    while (last_level < job_level and last_level < job['max_lvl'])
      last_level += 1
       key = 'ability' + last_level.to_s
       unless job[key] == nil
       @abilities.push(job[key])
       end
       if Gain_stats == true
         @maxhp_plus += job['HP']
         @maxsp_plus += job['SP']
         @str_plus += (job['STR'] / 10)
         @dex_plus += (job['DEX'] / 10)
         @agi_plus += (job['AGI'] / 10)
         @int_plus += (job['INT'] / 10)
       end
    end
  end
 
  #--------------------------------------------------------------------------
  # * First Command
  #--------------------------------------------------------------------------
  def first_command
  if @active_abilities.size > 0
    x = @active_abilities[0]
    if x[0...1] == '!'
      return x[1...x.size]
    end
  end
  return ' '
  end

  #--------------------------------------------------------------------------
  # * Second Command
  #--------------------------------------------------------------------------
  def second_command
  if @active_abilities.size > 1
    x = @active_abilities[1]
    if x[0...1] == '!'
      return x[1...x.size]
    end
  end
  return ' '
  end
  #--------------------------------------------------------------------------
  # * Determine if Equippable
  #     item : item
  #--------------------------------------------------------------------------
  def equippable?(item)
    # If weapon
    if item.is_a?(RPG::Weapon)
      style = get_style(0, item.id)
      # If included among equippable weapons in current class
      if $data_classes[@class_id].weapon_set.include?(item.id)
        if style == nil or @job_current == Unemployed
          return true
        else
          #check if they have the style
          job = get_job
          for i in 1...3
              key = 'style' + i.to_s
              if job[key] == style
                return true
              end
            end
            if (first_command == 'Equip ' + style) or (second_command == 'Equip ' + style)
              return true
            end
        end
      end
    end
    # If armor
    if item.is_a?(RPG::Armor)
      style = get_style(1, item.id)
      # If included among equippable armor in current class
      if $data_classes[@class_id].armor_set.include?(item.id)
        if style == nil or @job_current == Unemployed
          return true
        else
          #check if they have the style
          job = get_job
          for i in 1...3
              key = 'style' + i.to_s
              if job[key] == style
                return true
              end
            end
            if (first_command == 'Equip ' + style) or (second_command == 'Equip ' + style)
              return true
            end
        end
      end
    end
    return false
  end

end















class Window_EquipItem < Window_Selectable
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
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
        if ($game_party.weapon_number(i) > 0 and weapon_set.include?(i)) and (@actor.equippable?($data_weapons[i]))
          @data.push($data_weapons[i])
        end
      end
    end
    # Add equippable armor
    if @equip_type != 0
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

#--------------------------------------------------------------------------
# * Job System III
#   system by Fomar0153
# This section is about stat bonuses use these as
# examples so you can add your own remember
# you can have ones like HP + 500 rather than just
# percentages.
#--------------------------------------------------------------------------
class Game_Actor < Game_Battler
 
  #--------------------------------------------------------------------------
  # * Get Basic Maximum HP
  #--------------------------------------------------------------------------
  def base_maxhp
    n = $data_actors[@actor_id].parameters[0, @level]
    job = get_job
    n = ((n * (100 + job['HP']))/100)
    for i in 0...@active_abilities.size - 1
      if @active_abilities[i] == 'HP + 10%'
        n = ((n * 110)/100)
      end
    end
    return n
  end
  #--------------------------------------------------------------------------
  # * Get Basic Maximum SP
  #--------------------------------------------------------------------------
  def base_maxsp
    n = $data_actors[@actor_id].parameters[1, @level]
    job = get_job
    n = ((n * (100 + job['SP']))/100)
    for i in 0...@active_abilities.size - 1
      if @active_abilities[i] == 'SP + 10%'
        n = ((n * 110)/100)
      end
    end
    return n
  end
  #--------------------------------------------------------------------------
  # * Get Basic Strength
  #--------------------------------------------------------------------------
  def base_str
    n = $data_actors[@actor_id].parameters[2, @level]
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.str_plus : 0
    n += armor1 != nil ? armor1.str_plus : 0
    n += armor2 != nil ? armor2.str_plus : 0
    n += armor3 != nil ? armor3.str_plus : 0
    n += armor4 != nil ? armor4.str_plus : 0
    job = get_job
    n = ((n * (100 + job['STR']))/100)
    for i in 0...@active_abilities.size - 1
      if @active_abilities[i] == 'STR + 10%'
        n = ((n * 110)/100)
      end
    end
    return [[n, 1].max, 999].min
  end
  #--------------------------------------------------------------------------
  # * Get Basic Dexterity
  #--------------------------------------------------------------------------
  def base_dex
    n = $data_actors[@actor_id].parameters[3, @level]
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.dex_plus : 0
    n += armor1 != nil ? armor1.dex_plus : 0
    n += armor2 != nil ? armor2.dex_plus : 0
    n += armor3 != nil ? armor3.dex_plus : 0
    n += armor4 != nil ? armor4.dex_plus : 0
    job = get_job
    n = ((n * (100 + job['DEX']))/100)
    for i in 0...@active_abilities.size - 1
      if @active_abilities[i] == 'DEX + 10%'
        n = ((n * 110)/100)
      end
    end
    return [[n, 1].max, 999].min
  end
  #--------------------------------------------------------------------------
  # * Get Basic Agility
  #--------------------------------------------------------------------------
  def base_agi
    n = $data_actors[@actor_id].parameters[4, @level]
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.agi_plus : 0
    n += armor1 != nil ? armor1.agi_plus : 0
    n += armor2 != nil ? armor2.agi_plus : 0
    n += armor3 != nil ? armor3.agi_plus : 0
    n += armor4 != nil ? armor4.agi_plus : 0
    job = get_job
    n = ((n * (100 + job['AGI']))/100)
    for i in 0...@active_abilities.size - 1
      if @active_abilities[i] == 'AGI + 10%'
        n = ((n * 110)/100)
      end
    end
    return [[n, 1].max, 999].min
  end
  #--------------------------------------------------------------------------
  # * Get Basic Intelligence
  #--------------------------------------------------------------------------
  def base_int
    n = $data_actors[@actor_id].parameters[5, @level]
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.int_plus : 0
    n += armor1 != nil ? armor1.int_plus : 0
    n += armor2 != nil ? armor2.int_plus : 0
    n += armor3 != nil ? armor3.int_plus : 0
    n += armor4 != nil ? armor4.int_plus : 0
    job = get_job
    n = ((n * (100 + job['INT']))/100)
    for i in 0...@active_abilities.size - 1
      if @active_abilities[i] == 'INT + 10%'
        n = ((n * 110)/100)
      end
    end
    return [[n, 1].max, 999].min
  end
 
end


#--------------------------------------------------------------------------
# * Job System IV
#   system by Fomar0153
# This section is about the battle commands, you
# will need to script them yourselves.
#--------------------------------------------------------------------------
class Scene_Battle
  #--------------------------------------------------------------------------
  # * This is your main concern in this section
  #--------------------------------------------------------------------------
  def command_does(command)
      case command
        when "Skill"
          # Play decision SE
          $game_system.se_play($data_system.decision_se)
          # Set action
          @active_battler.current_action.kind = 1
          # Start skill selection
          start_skill_select
        when "Ice-Skill"
          # Play decision SE
          $game_system.se_play($data_system.decision_se)
          # Set action
          @active_battler.current_action.kind = 1
          # Start skill selection
          start_skill_select(2)
        when "Defend"
          # Play decision SE
          $game_system.se_play($data_system.decision_se)
          # Set action
          @active_battler.current_action.kind = 0
          @active_battler.current_action.basic = 1
          # Go to command input for next actor
          phase3_next_actor
         
          #Place other commands here
        end
        return
      end
  #--------------------------------------------------------------------------
  # * Start Skill Selection
  #--------------------------------------------------------------------------
  def start_skill_select(element = 0)
    # Make skill window
    @skill_window = Window_Skill.new(@active_battler, element)
    # Associate help window
    @skill_window.help_window = @help_window
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : basic command)
  #--------------------------------------------------------------------------
  def update_phase3_basic_command
    # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Go to command input for previous actor
      phase3_prior_actor
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      # Branch by actor command window cursor position
      x = @actor_command_window.index
      case @actor_command_window.index
      when 0  # attack
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
        # Start enemy selection
        start_enemy_select
      when 1
          command = @active_battler.first_command
          command_does(command)
      when 2
          command = @active_battler.second_command
          command_does(command)
       
      when 3  # item
        # Play decision SE
        $game_system.se_play($data_system.decision_se)
        # Set action
        @active_battler.current_action.kind = 2
        # Start item selection
        start_item_select
      end
      return
    end
  end
     
  #--------------------------------------------------------------------------
  # * A new method that draws the right commands
  #--------------------------------------------------------------------------
  def draw_command_window(actor_pos = 0)
    actor = $game_party.actors[actor_pos]
    s1 = $data_system.words.attack
    s2 = actor.first_command
    s3 = actor.second_command
    s4 = $data_system.words.item
    @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4])
  end
 
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Initialize each kind of temporary battle data
    $game_temp.in_battle = true
    $game_temp.battle_turn = 0
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = $game_map.battleback_name
    $game_temp.forcing_battler = nil
    # Initialize battle event interpreter
    $game_system.battle_interpreter.setup(nil, 0)
    # Prepare troop
    @troop_id = $game_temp.battle_troop_id
    $game_troop.setup(@troop_id)
    # Make actor command window
    @actor_command_window = draw_command_window(0)
    @actor_command_window.y = 160
    @actor_command_window.back_opacity = 160
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Make other windows
    @party_command_window = Window_PartyCommand.new
    @help_window = Window_Help.new
    @help_window.back_opacity = 160
    @help_window.visible = false
    @status_window = Window_BattleStatus.new
    @message_window = Window_Message.new
    # Make sprite set
    @spriteset = Spriteset_Battle.new
    # Initialize wait count
    @wait_count = 0
    # Execute transition
    if $data_system.battle_transition == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" +
        $data_system.battle_transition)
    end
    # Start pre-battle phase
    start_phase1
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Refresh map
    $game_map.refresh
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @actor_command_window.dispose
    @party_command_window.dispose
    @help_window.dispose
    @status_window.dispose
    @message_window.dispose
    if @skill_window != nil
      @skill_window.dispose
    end
    if @item_window != nil
      @item_window.dispose
    end
    if @result_window != nil
      @result_window.dispose
    end
    # Dispose of sprite set
    @spriteset.dispose
    # If switching to title screen
    if $scene.is_a?(Scene_Title)
      # Fade out screen
      Graphics.transition
      Graphics.freeze
    end
    # If switching from battle test to any screen other than game over screen
    if $BTEST and not $scene.is_a?(Scene_Gameover)
      $scene = nil
    end
  end
 
  #--------------------------------------------------------------------------
  # * Actor Command Window Setup
  #--------------------------------------------------------------------------
  def phase3_setup_command_window
    # Disable party command window
    @party_command_window.active = false
    @party_command_window.visible = false
    # Enable actor command window
    @actor_command_window.dispose
    @actor_command_window = draw_command_window(@actor_index)
    @actor_command_window.y = 160
    @actor_command_window.back_opacity = 160
    @actor_command_window.active = true
    @actor_command_window.visible = true
    # Set actor command window position
    @actor_command_window.x = @actor_index * 160
    # Set index to 0
    @actor_command_window.index = 0
  end

end


#--------------------------------------------------------------------------
# * Job System V
#   system by Fomar0153
# This section is the most annoying part to write
#  and probably the part you will mess with least
#  this section is about the windows and their "scenes"
#--------------------------------------------------------------------------
class Scene_Abilities_Change

  def initialize(actor_pos)
    @actor_pos = actor_pos
    @actor = $game_party.actors[actor_pos]
  end
 
    def main   
    # Make command window
    command_window_make

    @command_window.active = true
    # Make status window
    @actor_window = Window_Job_Status.new(@actor_pos)
    @actor_window.x = 0
    @actor_window.y = 0
    @actor_window.refresh(@actor.current_job)
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @command_window.dispose
    @actor_window.dispose
  end

  def update
    @command_window.update
    unless @abilities_window == nil
      @abilities_window.update
    end
   
        # If C button was pressed
      if Input.trigger?(Input::C)
       
        if @command_window.active == true
          if @command_window.index == 2 or (@command_window.index == 1 and @actor.current_job == @actor.unemployed_text)
          @abilities_window = Window_Command.new(160 * 2 - 90, @actor.abilities(1))
          @abilities_window.x = (640 - @abilities_window.width)/2
          @abilities_window.height = 32 * 6
          @abilities_window.y = (480 - @abilities_window.height)/2
          @abilities_window.z = 500
          @command_window.active = false
          @abilities_window.active = true
        else
          # Play cancel SE
          $game_system.se_play($data_system.cancel_se)
        end
        else
          x = @actor.abilities(1)
          @actor.change_active_abilities(x[@abilities_window.index], (@command_window.index - 1))
          @abilities_window.dispose
          @abilities_window = nil
          @command_window.dispose
          command_window_make
          @command_window.active = true
        end
      end
     
        # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
        if @command_window.active == true
            # Switch to menu screen
           $scene = Scene_Menu.new
           return
         else
          @abilities_window.dispose
          @abilities_window = nil
          @command_window.active = true
        end
    end
    # If R button was pressed
    if Input.trigger?(Input::R)
      # Play cursor SE
      $game_system.se_play($data_system.cursor_se)
      # To next actor
      @actor_pos += 1
      @actor_pos %= $game_party.actors.size
      # Switch to different status screen
      $scene = Scene_Abilities_Change.new(@actor_pos)
      return
    end
    # If L button was pressed
    if Input.trigger?(Input::L)
      # Play cursor SE
      $game_system.se_play($data_system.cursor_se)
      # To previous actor
      @actor_pos += $game_party.actors.size - 1
      @actor_pos %= $game_party.actors.size
      # Switch to different status screen
      $scene = Scene_Abilities_Change.new(@actor_pos)
      return
    end

  end

  def command_window_make
    y = @actor.abilities(0)
    if y[0] == nil
      y[0] = ' '
    end
    if y[1] == nil
      y[1] = ' '
    end
    @ability_list = ['Attack', y[0], y[1], 'Item']
    @command_window = Window_Command.new(210, @ability_list)
    @command_window.height = 480
    @command_window.x = 430
    @command_window.y = 0
    @command_window.index = 0
  end
 
 
end

class Scene_Job_Change
 
  def initialize(actor_pos)
    @actor_pos = actor_pos
    @actor = $game_party.actors[actor_pos]
  end
 
 
    def main
    y = $game_party.job_adverts.clone
    @job_list = [@actor.unemployed_text]
    for i in 0...(y.size)
      @job_list.push(y[i])
    end
   
    # Make command window
   
    @command_window = Window_Command.new(210, @job_list)
    @command_window.height = 480
    @command_window.x = 430
    @command_window.y = 0
    @command_window.index = 0
    @command_window.active = true
    # Make status window
    @actor_window = Window_Job_Status.new(@actor_pos)
    @actor_window.x = 0
    @actor_window.y = 0
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @command_window.dispose
    @actor_window.dispose
  end
 
  def update
    @command_window.update
    @actor_window.refresh(@job_list[@command_window.index])
   
   
        # If C button was pressed
      if Input.trigger?(Input::C)
        @actor.change_job(@job_list[@command_window.index])
        if @actor.hp > @actor.maxhp
          @actor.hp = @actor.maxhp
        end
        if @actor.sp > @actor.maxsp
          @actor.sp = @actor.maxsp
        end
        for x in 0...4
          @actor.equip(x, 0)
        end
      $scene = Scene_Abilities_Change.new(@actor_pos)
      end
     
        # If B button was pressed
    if Input.trigger?(Input::B)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Switch to menu screen
      $scene = Scene_Menu.new
      return
    end
    # If R button was pressed
    if Input.trigger?(Input::R)
      # Play cursor SE
      $game_system.se_play($data_system.cursor_se)
      # To next actor
      @actor_pos += 1
      @actor_pos %= $game_party.actors.size
      # Switch to different status screen
      $scene = Scene_Job_Change.new(@actor_pos)
      return
    end
    # If L button was pressed
    if Input.trigger?(Input::L)
      # Play cursor SE
      $game_system.se_play($data_system.cursor_se)
      # To previous actor
      @actor_pos += $game_party.actors.size - 1
      @actor_pos %= $game_party.actors.size
      # Switch to different status screen
      $scene = Scene_Job_Change.new(@actor_pos)
      return
    end

  end
end


class Window_Job_Status < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor_pos)
    super(0, 0, 430, 480)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = $game_party.actors[actor_pos]
    @unemployed = @actor.unemployed_text
    refresh(@unemployed)
    end
   
    def refresh(job_name)
     
      self.contents.clear
      x = 64
      y = 0
      draw_actor_graphic(@actor, x - 40, y + 80)
      draw_actor_name(@actor, x, y)
      draw_actor_class(@actor, x + 90, y)
      draw_actor_level(@actor, x, y + 32)
      draw_actor_state(@actor, x + 90, y + 32)
      draw_actor_exp(@actor, x, y + 64)
      unless @actor.get_job == @unemployed
      draw_job_level(@actor, x + 190 , y + 32, job_name)
      draw_ap(@actor, x + 190, y + 64, job_name)
      end
      unless job_name == @unemployed
      job = @actor.get_job(job_name)
      self.contents.font.color = normal_color
      self.contents.draw_text( x - 40, y + 180, 230, 32, job_name)
      self.contents.font.color = system_color
      draw_job_level(@actor, x + 190 , y + 32, job_name)
      self.contents.draw_text( x - 40, y + 244, 230, 32, 'HP Bonus')
      self.contents.font.color = normal_color
      self.contents.draw_text( x + 50, y + 244, 230, 32, job['HP'].to_s)
      self.contents.font.color = system_color
      self.contents.draw_text( x + 75, y + 244, 230, 32, 'SP Bonus')
      self.contents.font.color = normal_color
      self.contents.draw_text( x + 165, y + 244, 230, 32, job['SP'].to_s)
      self.contents.font.color = system_color
      self.contents.draw_text( x - 40, y + 276, 230, 32, 'STR Bonus')
      self.contents.font.color = normal_color
      self.contents.draw_text( x + 50, y + 276, 230, 32, job['STR'].to_s)
      self.contents.font.color = system_color
      self.contents.draw_text( x + 75, y + 276, 230, 32, 'DEX Bonus')
      self.contents.font.color = normal_color
      self.contents.draw_text( x + 165, y + 276, 230, 32, job['DEX'].to_s)
      self.contents.font.color = system_color
      self.contents.draw_text( x - 40, y + 308, 230, 32, 'INT Bonus')
      self.contents.font.color = normal_color
      self.contents.draw_text( x + 50, y + 308, 230, 32, job['INT'].to_s)
      self.contents.font.color = system_color
      self.contents.draw_text( x + 75, y + 308, 230, 32, 'AGL Bonus')
      self.contents.font.color = normal_color
      self.contents.draw_text( x + 165, y + 308, 230, 32, job['AGI'].to_s)
      end
    end
   
end

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Draw Class
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_class(actor, x, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, 236, 32, actor.current_job)
  end
  #--------------------------------------------------------------------------
  # * Draw Job Level
  #--------------------------------------------------------------------------
  def draw_job_level(actor, x, y, job = nil)
    if job == nil
      job == actor.current_job
    end
    unless job == actor.unemployed_text
    lvl = actor.job_level(job)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, 32, 'Job Level')
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 80, y, 36, 32, lvl.to_s, 2)
  else
    return #nothing to draw
  end
  end
  #--------------------------------------------------------------------------
  # * Draw Ap to next Job Level
  #--------------------------------------------------------------------------
  def draw_ap(actor, x, y, job_name = nil)
    if job_name == nil
      job_name == actor.current_job
    end
    unless job_name == actor.unemployed_text
    ap = actor.ap_to_next_job_level(job_name)
    lvl = actor.job_level(job_name)
    lvl += 1
    job = actor.get_job(job_name)
    key = 'lvl' + lvl.to_s
    lvl = job[key]
    if lvl == nil
      return
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, 32, 'AP')
    self.contents.font.color = normal_color
    msg = ap.to_s + '/' + lvl.to_s
    self.contents.draw_text(x + 80, y, 56, 32, msg, 2)
  else
    return #nothing to draw
  end
end

end


class Window_Skill < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor : actor
  #--------------------------------------------------------------------------
  def initialize(actor, element = 0)
    super(0, 128, 640, 352)
    @actor = actor
    @column_max = 2
    @element = element
    refresh
    self.index = 0
    # If in battle, move window to center of screen
    # and make it semi-transparent
    if $game_temp.in_battle
      self.y = 64
      self.height = 256
      self.back_opacity = 160
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    for i in 0...@actor.skills.size
      skill = $data_skills[@actor.skills[i]]
      if skill != nil and (@element == 0 or skill.element_set.include?(@element))
        @data.push(skill)
      end
    end
    # If item count is not 0, make a bit map and draw all items
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
 
end
