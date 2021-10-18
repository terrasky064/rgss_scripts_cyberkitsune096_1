# Created by Cyberkitsune096
class Game_Party
 
  GUESTS = {
  5=>30,
  6=>100
  }
 
  attr_accessor :guests
 
  alias guest_initialize initialize
  def initialize
    @guests = [5, 6]
    guest_initialize
  end
 
  def guest_act
    if @guests == []
      return 0
    end
    for guest in @guests
      unless GUESTS[guest] == nil
        if rand(100) < GUESTS[guest]
          return guest
        end
      end
    end
    return 0
  end
 
end

class Scene_Battle
 
  alias guest_update_phase4_step1 update_phase4_step1
  def update_phase4_step1
    if @last_guest_act == nil
      @last_guest_act = 0
    end
    if @last_guest_act != $game_temp.battle_turn
      @last_guest_act = $game_temp.battle_turn
      tmp = $game_party.guest_act
      if tmp == 0
        guest_update_phase4_step1
      else
        @animation1_id = 0
        @animation2_id = 0
        @common_event_id = 0
        @active_battler = $game_actors[tmp]
        if @active_battler.weapon_id > 0 and rand(@active_battler.skills.size + 1) == 0
          @active_battler.current_action.kind = 0
          @active_battler.current_action.basic = 0
        else
          @active_battler.recover_all
          @active_battler.current_action.kind = 1
          @active_battler.current_action.skill_id = @active_battler.skills[rand(@active_battler.skills.size)]
        end
        @active_battler.current_action.decide_random_target_for_actor
        @target_battlers = []
        case @active_battler.current_action.kind
        when 0  # basic
          make_basic_action_result
        when 1  # skill
          make_skill_action_result
        end
        @phase4_step = 3
      end
    else
      guest_update_phase4_step1
    end
  end
 
end