class_name Minion3D extends Node3D

@onready var mesh: MeshInstance3D = $"MeshInstance3D"
@onready var debug_name: Label3D = $DebugName

func set_color(color: Color):
    mesh.mesh.material.albedo_color = color

func set_debug_name(new_name: String):
    debug_name.text = new_name
