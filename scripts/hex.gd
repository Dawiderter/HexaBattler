@tool

class_name Hex extends Node3D

@onready var mesh = $Solid
@onready var hover_mesh = $Hover
@onready var collision_shape = $StaticBody3D/CollisionShape3D
@onready var cord_label = $CordLabel

enum CordDisplay { NONE, AXIAL, OFFSET }
@export_enum("None", "Axial", "Offset") var cord_display: int = 0:
    set(value):
        cord_display = value
        update_cord_display()

var radius: float = 0.5:
    set(value):
        radius = value
        update_radius()
        
var offcords : Vector2i:
    set(value):
        cord_label.text = str(value.x) + "," + str(value.y)
        axcords = GridUtils.offcord_to_axcord(value)
    get:
       return GridUtils.axcord_to_offcord(axcords) 

var axcords : Vector2i:
    set(value):
        axcords = value
        update_cord_display()
        

func _ready() -> void:
    update_cord_display()
    update_radius()
    hover_mesh.visible = false

func update_radius():
        var m = mesh.mesh
        m.top_radius = radius
        m.bottom_radius = radius
        
        var mesh_collision_shape = m.create_convex_shape()
        collision_shape.shape = mesh_collision_shape
        
        var h = hover_mesh.mesh
        h.top_radius = radius
        h.bottom_radius = radius
    
func update_cord_display():
    match cord_display:
        CordDisplay.NONE:
            cord_label.text = ""
        CordDisplay.AXIAL:
            cord_label.text = str(axcords.x) + "," + str(axcords.y)
        CordDisplay.OFFSET:
            cord_label.text = str(offcords.x) + "," + str(offcords.y)
        _:
            push_error("Wrong cord_siplay: ", cord_display)

func _on_hex_input_event(_camera, event, _pos, _normal, _shape_idx,):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            print("Clicked Hex: ", offcords)
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color.RED
            mesh.material_override = mat

func _on_hex_mouse_entered():
    hover_mesh.visible = true

func _on_hex_mouse_exited():
    hover_mesh.visible = false
