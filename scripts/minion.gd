class_name MinionState extends RefCounted

var max_health: float
var health: float = max_health

var stat_attack_power: float
var stat_speed: float
var stat_range: int

var faction: Faction
var axcord: Vector2i
var target: MinionState

var debug_name: String

# Akcja
# - Jeżeli nie masz targetu, target = find_target:
# - Target jest w <stat_range>:
#   - try_attack
# - Target nie jest w <stat_range>:
#   - move_towards

func _ready() -> void:
    health = max_health

func take_damage(amount: float):
    assert(amount > 0.0)
    health -= amount
    if health <= 0:
        pass

    
