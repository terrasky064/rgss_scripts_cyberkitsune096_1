# Credit cyberkitsune096

class Game_Party
  attr_accessor   :music
  alias pre_music_initialize initialize
  def initialize
    pre_music_initialize
    @music = []
  end
end

class Scene_Map
  def call_battle
    # Clear battle calling flag
    $game_temp.battle_calling = false
    # Clear menu calling flag
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    # Make encounter count
    $game_player.make_encounter_count
    # Memorize map BGM and stop BGM
    $game_temp.map_bgm = $game_system.playing_bgm
    $game_system.bgm_stop
    # Play battle start SE
    $game_system.se_play($data_system.battle_start_se)
    # Play battle BGM
    file = $game_party.music[rand($game_party.music.size)]
    audio_file = RPG::AudioFile.new(file)
    $game_system.bgm_play(audio_file)
    # Straighten player position
    $game_player.straighten
    # Switch to battle screen
    $scene = Scene_Battle.new
  end
end