extends Node
@onready var hex_grid = $HexGrid3D
@onready var game_simulation = $GameSimulation

var is_paused = true
var time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    hex_grid.generate_mesh()
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if Input.is_action_just_pressed("ui_accept"):
        is_paused = not is_paused
        time = game_simulation.time_until_next()
    
    if not is_paused:
        time -= 5 * delta 
        while time <= 0:
            game_simulation.pop_action()
            time = game_simulation.time_until_next()

func _on_grid_creation_ui_create_grid(width: int, height: int) -> void:
    hex_grid.width = width
    hex_grid.height = height
    hex_grid.generate_mesh()
    
    $GridCreationUi.visible = false
