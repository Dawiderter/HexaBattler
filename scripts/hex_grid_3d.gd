@tool
extends Node3D

@export_range(1, 500) var width:  int = 10
@export_range(1, 500) var height: int = 10
@export_range(0.0, 1000.0) var hex_radius: float = 0.5
@export_tool_button("Generate Mesh", "Callable") var generate_mesh_action = generate_mesh
@export_tool_button("Clear Mesh", "Callable") var clear_mesh_action = clear_mesh
@export_enum("None", "Axial", "Offset") var cord_display: int = 0:
    set(value):
        cord_display = value
        for hex in hexes:
            hex.cord_display = value

@onready var hexes_container: Node3D = $HexesContainer
@onready var minion_container: Node3D = $MinionContainer
@onready var faction_a: Faction = $"MinionContainer/Faction A"
@onready var faction_b: Faction = $"MinionContainer/Faction B"

var hexes : Array[Hex] = []
var hex_scene = preload("res://scenes/hex.tscn")

var minion_scene = preload("res://scenes/minion.tscn")

func get_hex_offcord(offcord: Vector2i) -> Hex:
    var i = offcord.x + offcord.y * width
    return hexes[i]

func get_hex_axcord(axcord: Vector2i) -> Hex:
    var offcord = GridUtils.axcord_to_offcord(axcord)
    var i = offcord.x + offcord.y * width
    return hexes[i]

func clear_mesh():
    hexes.clear()
    for hex in hexes_container.get_children():
        hex.queue_free()
    hexes_container.get_children().clear()

func generate_mesh():
    clear_mesh()
    
    hexes.resize(height * width)
    
    for z in range(height):
        for x in range(width):
            var cords = Vector2i(x, z)
            
            var hex = hex_scene.instantiate() as Hex
            hexes_container.add_child(hex)
            hexes[x + z * width] = hex
            
            hex.connect("input_event", _on_hex_input_event)
            
            hex.radius = hex_radius
            hex.offcords = cords
            hex.cord_display = cord_display
            
            var position_2d = GridUtils.center_from_offcord(cords, hex_radius)
            hex.position.x = position_2d.x
            hex.position.z = position_2d.y
            
            if self.owner:
                hex.owner = self
    
    hexes_container.position.x = -(width * hex_radius * sqrt(3.0)/2.0)
    hexes_container.position.z = -(height * hex_radius * 3.0/4.0)
    
func spawn_minion(hex: Hex, faction: Faction):
        if !hex.is_free():
            push_warning("Can't spawn minion on nonfree tile")
            return
    
        var minion : Minion = minion_scene.instantiate()
        
        faction.add_child(minion)
        minion.set_color(faction.color)
        
        hex.occupy_for(minion)
        
        minion.position = hex.global_position
        minion.position.y += hex.height

func _on_hex_input_event(event: InputEvent, hex: Hex):
    if event is InputEventMouseButton &&  event.is_pressed():
        if event.button_index == MOUSE_BUTTON_LEFT:
            spawn_minion(hex, faction_a)
        if event.button_index == MOUSE_BUTTON_RIGHT:
            spawn_minion(hex, faction_b)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass
