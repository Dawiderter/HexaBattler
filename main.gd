extends Node
@onready var hex_grid = $HexGrid3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    hex_grid.generate_mesh()
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass

func _on_grid_creation_ui_create_grid(width: int, height: int) -> void:
    hex_grid.width = width
    hex_grid.height = height
    hex_grid.generate_mesh()
    
    $GridCreationUi.visible = false
