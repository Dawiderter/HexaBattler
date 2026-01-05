@tool
extends Node3D

@export var width:  int = 10
@export var height: int = 10
@export var hex_radius: float = 0.5
@export_tool_button("Generate Mesh", "Callable") var generate_mesh_action = generate_mesh
@export_tool_button("Clear Mesh", "Callable") var clear_mesh_action = clear_mesh

@onready var hexes_container: Node3D = $HexesContainer

func clear_mesh():
    for hex in hexes_container.get_children():
        hex.queue_free()
    hexes_container.get_children().clear()

func generate_hex_mesh() -> Mesh:
    var mesh = CylinderMesh.new()
    mesh.radial_segments = 6
    mesh.top_radius = hex_radius * 0.95
    mesh.bottom_radius = hex_radius * 0.95
    mesh.height = 0.001
    return mesh

func generate_mesh():
    clear_mesh()

    var mesh = generate_hex_mesh()
    var coeff = sqrt(3) / 2
    var hex_diameter = 2 * hex_radius
    
    for z in range(height):
        for x in range(width):
            var mesh_instance_3d = MeshInstance3D.new()
            mesh_instance_3d.mesh = mesh
            
            var x_offset = coeff if (z % 2) else 0.0
            
            mesh_instance_3d.position.x = hex_diameter * (x * coeff+x_offset/2)
            mesh_instance_3d.position.z = hex_diameter * (3.0/4.0) * z
            hexes_container.add_child(mesh_instance_3d)
    pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
