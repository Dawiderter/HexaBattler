@tool

class_name Hex extends Node3D

signal input_event(event: InputEvent, hex: Hex)

@onready var mesh = $Solid
@onready var hover_mesh = $Hover
@onready var collision_shape = $StaticBody3D/CollisionShape3D
@onready var cord_label = $CordLabel

enum CordDisplay { NONE, AXIAL, OFFSET }
@export_enum("None", "Axial", "Offset") var cord_display: int = 0:
    set(value):
        cord_display = value
        update_cord_display()

var height: float = 0.25:
    set(value):
        height = value
        update_mesh()

var radius: float = 0.5:
    set(value):
        radius = value
        update_mesh()
        
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
        
enum LockState { FREE, LOCKED, OCCUPIED }
var lock_by_minion: Minion = null;
var lock_state := LockState.FREE:
    set(value):
        lock_state = value
        update_lock_state()

func is_free():
    return lock_state == LockState.FREE
    
func lock_for(minion: Minion) -> void:
    lock_state = LockState.LOCKED
    lock_by_minion = minion

func occupy_for(minion: Minion) -> void:
    assert(
        (lock_by_minion == null and lock_state == LockState.FREE) 
        or (lock_by_minion == minion and lock_state == LockState.LOCKED)
    )
    lock_state = LockState.OCCUPIED
    lock_by_minion = minion

# Free the cell (Unit left or died)
func free_cell() -> void:
    lock_state = LockState.FREE
    lock_by_minion = null

func _ready() -> void:
    update_cord_display()
    update_mesh()
    update_lock_state()
    hover_mesh.visible = false

func update_lock_state():
    match lock_state:
        LockState.FREE:
            mesh.mesh.material.albedo_color = Color.BEIGE
        LockState.LOCKED:
            mesh.mesh.material.albedo_color = Color.YELLOW
        LockState.OCCUPIED:
            mesh.mesh.material.albedo_color = Color.CRIMSON
        _:
            push_error("Wrong lock_state: ", lock_state)

func update_mesh():
        var m = mesh.mesh
        m.top_radius = radius
        m.bottom_radius = radius
        m.height = height
        
        var mesh_collision_shape = m.create_convex_shape()
        collision_shape.shape = mesh_collision_shape
        
        var h = hover_mesh.mesh
        h.top_radius = radius
        h.bottom_radius = radius
        h.height = height * 3.0
    
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
    input_event.emit(event, self)

func _on_hex_mouse_entered():
    hover_mesh.visible = true

func _on_hex_mouse_exited():
    hover_mesh.visible = false
