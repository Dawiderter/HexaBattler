class_name Minion extends Node3D

@export var max_health: float
@onready var health: float = max_health

@export var stat_attack_power: float
@export var stat_speed: float
@export var stat_range: int

@onready var mesh = $MeshInstance3D

# Akcja
# - Jeżeli nie masz targetu, target = find_target:
# - Target jest w <stat_range>:
#   - try_attack
# - Target nie jest w <stat_range>:
#   - move_towards

func _ready() -> void:
    var parent = get_parent()
    assert(parent != null and parent is Faction)

func take_damage(amount: float):
    assert(amount > 0.0)
    health -= amount
    if health <= 0:
        pass
    
func set_color(color: Color):
    mesh.mesh.material.albedo_color = color

    
