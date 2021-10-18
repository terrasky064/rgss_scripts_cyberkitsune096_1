#Credit Cyberkitsune096
module Fomar
 
  Attack_Cost = 500
  Skill_Cost = 750
  Defend_Cost = 250
  Item_Cost = 500
  Flee_Attempt = 100
  Refresh_Rate = 5
 
  def self.attack
    return Attack_Cost
  end
 
  def self.skill
    return Skill_Cost
  end
 
  def self.defend
    return Defend_Cost
  end
 
  def self.item
    return Item_Cost
  end
 
  def self.critical_value(n)
    return (n == Attack_Cost or n == Skill_Cost or n == Defend_Cost or n == Item_Cost)
  end
 
end

class Game_BattleAction
 
  alias cbs_clear clear
  def clear
    unless (@kind == 0 and @basic == 1)
      cbs_clear
      return
    end
    @speed = 0
    @skill_id = 0
    @item_id = 0
    @target_index = -1
    @forcing = false
  end
 
end

class Game_Battler
 
  attr_accessor :stamina
  attr_accessor :vitality
  attr_accessor :max_stamina
 
  alias cbs_initialize initialize
  def initialize
    cbs_initialize
    @stamina = 0
    @vitality = 1
    @max_stamina = 1000
  end
 
  def stamina_action_cost
    if (@current_action.kind == 0 and @current_action.basic == 1) or
      ((@current_action.kind == 0 and @current_action.basic == 0) and
      @current_action.target_index == -1)
      return
    end
    if @current_action.kind == 0 and @current_action.basic == 0
      @stamina -= Fomar.attack
    end
    if @current_action.kind == 1
      @stamina -= Fomar.skill
    end
    if @current_action.kind == 2
      @stamina -= Fomar.item
    end
   
  end
 
end

class Game_Enemy < Game_Battler
 
  alias cbs_make_action make_action
  def make_action
    return
  end
 
  def can_do_action?
    if @current_action.kind == 0 and @current_action.basic == 0
      return self.stamina >= Fomar.attack
    end
    if @current_action.kind == 1
      return self.stamina >= Fomar.skill
    end
    if @current_action.kind == 0 and @current_action.basic == 1
      return self.stamina >= Fomar.defend
    end
    if @current_action.kind == 0 and @current_action.basic == 3
      return false
    end
  end
 
end

class Window_BattleStatus < Window_Base
  def refresh
    self.contents.clear
    self.contents.font.size = 20
    @item_max = $game_party.actors.size
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      actor_x = i * 160 + 4
      draw_actor_name(actor, actor_x, 0)
      draw_actor_hp(actor, actor_x, 25, 120)
      draw_actor_sp(actor, actor_x, 50, 120)
      draw_fomar_bar(actor_x, 80, ((actor.stamina * 100)/actor.max_stamina), 120)
      if @level_up_flags[i]
        self.contents.font.color = normal_color
        self.contents.draw_text(actor_x, 100, 120, 32, "LEVEL UP!")
      else
        draw_actor_state(actor, actor_x, 100)
      end
    end
  end
 
  def redraw_bars
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      actor_x = i * 160 + 4
      draw_fomar_bar(actor_x, 80, ((actor.stamina * 100)/actor.max_stamina), 120)
    end
  end
 
  def draw_fomar_bar(x, y, full = 100, width = 128)
    self.contents.fill_rect(x, y, width, 20, Color.new(0, 0, 0, 255))
    self.contents.fill_rect(x + 2, y + 2, width - 4, 16, Color.new(255, 255, 255, 255))
    width *= full
    width /= 100
    # full is a percentage
    self.contents.fill_rect(x +2, y + 2, width - 4, 16, Color.new(255, 0, 0, 255))
  end
end

class Scene_Battle
 
  alias cbs_main main
  def main
    @fleeing = false
    @flee_attempt = 0
    @refresh_rate = 0
    @enemy_decision = 0
    for actor in $game_party.actors
      actor.current_action.cbs_clear
    end
    cbs_main
  end
 
  alias cbs_update update
  def update
    if @refresh_rate == Fomar::Refresh_Rate
      @status_window.redraw_bars
      @refresh_rate = 0
    else
      @refresh_rate += 1
    end
    cbs_update
  end
 
  alias cbs_start_phase2 start_phase2
  def start_phase2
    @fleeing = false
    cbs_start_phase2
  end
 
  def update_phase2_escape
    @fleeing = true
    @flee_attempt = 0
    start_phase3
  end
 
  def end_phase2
    @party_command_window.active = false
    @party_command_window.visible = false
  end
 
  def start_phase3
    end_phase2
    @phase = 3
    @actor_index = 0
    @active_battler = $game_party.actors[0]
    $game_party.clear_actions
    unless @fleeing == true
      phase3_setup_command_window
    end
  end
 
  def phase3_setup_command_window
    phase3_make_command_window
    @party_command_window.active = false
    @party_command_window.visible = false
    @actor_command_window.active = true
    @actor_command_window.visible = true
    @actor_command_window.x = @actor_index * 160
  end
 
  def phase3_make_command_window
    unless @actor_command_window == nil
      @actor_command_window.dispose
    end
    s1 = $data_system.words.attack
    s2 = $data_system.words.skill
    s3 = $data_system.words.guard
    s4 = $data_system.words.item
    @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4])
    @actor_command_window.y = 160
    @actor_command_window.back_opacity = 160
    unless @active_battler.inputable?
      @actor_command_window.disable_item(0)
      @actor_command_window.disable_item(1)
      @actor_command_window.disable_item(2)
      @actor_command_window.disable_item(3)
      return
    end
    unless @active_battler.stamina >= Fomar.attack
      @actor_command_window.disable_item(0)
    end
    unless @active_battler.stamina >= Fomar.skill
      @actor_command_window.disable_item(1)
    end
    unless @active_battler.stamina >= Fomar.defend
      @actor_command_window.disable_item(2)
    end
    unless @active_battler.stamina >= Fomar.item
      @actor_command_window.disable_item(3)
    end
  end
 
  alias cbs_update_phase3 update_phase3
  def update_phase3
    if judge
      return
    end
    cbs_update_phase3
    if @actor_command_window.active == true or @fleeing == true
      @enemy_decision += 1
      if @enemy_decision == 50
        @enemy_decision -= 50
        resolve = false
        for enemy in $game_troop.enemies
          enemy.cbs_make_action
          if enemy.can_do_action?
            resolve = true
          else
            enemy.current_action.clear
          end
        end
        if resolve == true
          @check_index = @actor_index
          start_phase4
          return
        end
      end
    end
    if @fleeing == true
      if Input.trigger?(Input::B)
        start_phase2
      end
      @flee_attempt += 1
      if @flee_attempt == Fomar::Flee_Attempt
        enemies_agi = 0
        enemies_number = 0
        for enemy in $game_troop.enemies
          if enemy.exist?
            enemies_agi += enemy.agi
            enemies_number += 1
          end
        end
        if enemies_number > 0
          enemies_agi /= enemies_number
        end
        actors_agi = 0
        actors_number = 0
        for actor in $game_party.actors
          if actor.exist?
            actors_agi += actor.agi
            actors_number += 1
          end
        end
        if actors_number > 0
          actors_agi /= actors_number
        end
        success = rand(100) < 50 * actors_agi / enemies_agi
        if success
          $game_system.se_play($data_system.escape_se)
          $game_system.bgm_play($game_temp.map_bgm)
          battle_end(1)
        else
          @flee_attempt -= Fomar::Flee_Attempt
        end
      end
    end
    if @active_battler != nil
      if Fomar.critical_value(@active_battler.stamina)
        i = @actor_command_window.index
        k = @actor_command_window.visible
        l = @actor_command_window.active
        phase3_make_command_window
        @actor_command_window.x = @actor_index * 160
        @actor_command_window.index = i
        @actor_command_window.visible = k
        @actor_command_window.active = l
      end
    end
    if @actor_command_window.active
      if Input.trigger?(Input::LEFT)
        @actor_index -= 1
        if @actor_index == -1
          @actor_index = $game_party.actors.size - 1
        end
        @active_battler = $game_party.actors[@actor_index]
        phase3_make_command_window
        @actor_command_window.x = @actor_index * 160
      end
      if Input.trigger?(Input::RIGHT)
        @actor_index += 1
        if @actor_index == $game_party.actors.size
          @actor_index = 0
        end
        @active_battler = $game_party.actors[@actor_index]
        phase3_make_command_window
        @actor_command_window.x = @actor_index * 160
      end
    end
    if @actor_command_window.active == true or @fleeing == true
      phase3_pass_time
    end
  end
 
  def phase3_pass_time
    for battler in $game_party.actors + $game_troop.enemies
      battler.stamina += battler.vitality
      if battler.stamina > battler.max_stamina
        battler.stamina = battler.max_stamina
      end
    end
  end
 
  alias cbs_update_phase4_step1 update_phase4_step1
  def update_phase4_step1
    if @action_battlers.size == 0
      @phase = 3
      for battler in $game_party.actors + $game_troop.enemies
        battler.stamina_action_cost
      end
      i = @actor_command_window.index
      phase3_make_command_window
      @actor_command_window.index = 1
      @actor_command_window.visible = true
      @actor_command_window.active = true
      @actor_index = @check_index
      @actor_command_window.x = 160 * @actor_index
      @active_battler = $game_party.actors[@actor_index]
      $game_party.clear_actions
      for enemy in $game_troop.enemies
        enemy.current_action.clear
      end
      return
    end
    cbs_update_phase4_step1
  end
 
  def phase3_next_actor
    @check_index = @actor_index
    start_phase4
    return
  end
 
  def phase3_prior_actor
    start_phase2
    return
  end
 
  def update_phase3_basic_command
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      phase3_prior_actor
      return
    end
    if Input.trigger?(Input::C)
      case @actor_command_window.index
      when 0
        if @active_battler.stamina < Fomar.attack
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
        start_enemy_select
      when 1
        if @active_battler.stamina < Fomar.skill
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        @active_battler.current_action.kind = 1
        start_skill_select
      when 2
        if @active_battler.stamina < Fomar.defend
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 1
        @active_battler.stamina -= Fomar.defend
        phase3_next_actor
      when 3
        if @active_battler.stamina < Fomar.item
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        @active_battler.current_action.kind = 2
        start_item_select
      end
      return
    end
  end
 
end