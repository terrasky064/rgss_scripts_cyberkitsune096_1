# Credit Cyberkitsune096
class Game_Battler
  attr_accessor :contact_damage
  attr_accessor :contact_hp_damage
  attr_accessor :contact_hp_damage_percent
  attr_accessor :contact_sp_damage
  attr_accessor :contact_sp_damage_percent
  
  #
  alias rough_skin_initialize initialize
  def initialize
    rough_skin_initialize
    @contact_damage = false
    @contact_hp_damage = 0
    @contact_hp_damage_percent = 50
    @contact_sp_damage = 0
    @contact_sp_damage_percent = 50
  end

  # Attack effects
  alias contact_attack_effect
  def contact_attack_effect(attacker)
    attack = contact_attack_effect(attacker)
    if self.contact_damage == true
      attacker.contact_hp_damage = (self.damage.to_i * self.contact_hp_damage_percent)/100
      attacker.contact_sp_damage = (self.damage.to_i * self.contact_sp_damage_percent)/100
    end
    return attack
  end
end