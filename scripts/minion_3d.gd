class_name Minion3D extends Node3D

@onready var mesh: MeshInstance3D = $"MeshInstance3D"

func set_color(color: Color):
    mesh.mesh.material.albedo = color
