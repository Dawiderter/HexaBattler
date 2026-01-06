extends Node
@onready var hex_grid = $Grid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    hex_grid.generate_mesh()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
