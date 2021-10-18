#Credit Cyberkitsune096
class Game_Party
 
  Max_Party_Size = 8
 
  def max_party_size
    return Max_Party_Size
  end
 
  def add_actor(actor_id)
    actor = $game_actors[actor_id]
    if not @actors.include?(actor) and $game_party.actors.size < Max_Party_Size
      @actors.push(actor)
      $game_player.refresh
    end
  end
 
  def all_dead?
    if $game_party.actors.size == 0
      return false
    end
    for actor in @actors
      if actor.hp > 0
        return false
      end
      if actor.index >= 4
        return true
      end
    end
    return true
  end
end
 
class Scene_Menu
 
  alias party_swap_update_command update_command
  def update_command
    party_swap_update_command
    if Input.trigger?(Input::LEFT) or Input.trigger?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      @previous_index = @command_window.index
      @command_window.index = -1
      @command_window.active = false
      @status_window.active = true
      @status_window.index = @status_window.top_row
      return
    end
  end
 
  alias party_swap_update_status update_status
  def update_status
    if Input.trigger?(Input::B)
      unless @swapee != nil
        $game_system.se_play($data_system.cancel_se)
        if @command_window.index == -1
          @command_window.index = @previous_index
        end
        @command_window.active = true
        @status_window.active = false
        @status_window.index = -1
        return
      end
      @swapee = nil
      return
    end
    if Input.trigger?(Input::C) and @command_window.index == -1
      unless @swapee != nil
        @swapee = @status_window.index
        $game_system.se_play($data_system.decision_se)
        return
      end
      if @swapee == @status_window.index
        $game_system.se_play($data_system.decision_se)
        @swapee = nil
        return
      end
      $game_system.se_play($data_system.decision_se)
      party_ids = []
      for actor in $game_party.actors
        party_ids.push(actor.id)
      end
      swapee2 = @status_window.index
      if @swapee < swapee2
        for i in @swapee...party_ids.size
          $game_party.remove_actor(party_ids[i])
        end
        $game_party.add_actor(party_ids[swapee2])
        for i in (@swapee + 1)...party_ids.size
          unless i == swapee2
            $game_party.add_actor(party_ids[i])
          else
            $game_party.add_actor(party_ids[@swapee])
          end
        end
      else
        for i in swapee2...party_ids.size
          $game_party.remove_actor(party_ids[i])
        end
        $game_party.add_actor(party_ids[@swapee])
        for i in (swapee2 + 1)...party_ids.size
          unless i == @swapee
            $game_party.add_actor(party_ids[i])
          else
            $game_party.add_actor(party_ids[swapee2])
          end
        end
      end
      @swapee = nil
      @status_window.refresh
      return
    end
    if Input.trigger?(Input::LEFT) or Input.trigger?(Input::RIGHT)
      if @swapee == nil and @command_window.index == -1
        $game_system.se_play($data_system.cursor_se)
        @command_window.index = @previous_index
        @command_window.active = true
        @status_window.active = false
        @status_window.index = -1
      end
    end
    party_swap_update_status
  end
 
 
end
 
class Window_MenuStatus < Window_Selectable
 
  def initialize
    unless $game_party.actors.size > 4
      super(0, 0, 480, 480)
    else
      super(0, 0, 480, 160 * $game_party.actors.size)
    end
    self.contents = Bitmap.new(width - 32, height - 32)
    refresh
    self.active = false
    self.index = -1
  end
 
  alias large_refresh refresh
  def refresh
    large_refresh
    self.height = 480
  end
 
  def update_cursor_rect
    if @index < 0
      self.cursor_rect.empty
      return
    end
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
    end
    cursor_width = self.width / @column_max - 32
    x = @index % @column_max * (cursor_width + 32)
    y = @index / @column_max * 116 - self.oy
    self.cursor_rect.set(x, y, cursor_width, 96)
  end
 
  def top_row
    return self.oy / 116
  end
 
  def top_row=(row)
    if row < 0
      row = 0
    end
    if row > row_max - 1
      row = row_max - 1
    end
    self.oy = row * 116
  end
 
  def page_row_max
    return 4
  end
end
 
class Scene_Battle
  def phase3_next_actor
    begin
      if @active_battler != nil
        @active_battler.blink = false
      end
      if @actor_index == ([$game_party.actors.size, 4].min - 1)
        start_phase4
        return
      end
      @actor_index += 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    end until @active_battler.inputable?
    phase3_setup_command_window
  end
 
end
 
class Game_Actor < Game_Battler
  def exist?
    return super == self.index < 4
  end
end