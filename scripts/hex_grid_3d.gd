@tool
extends Node3D

@export_range(1, 500) var width:  int = 10
@export_range(1, 500) var height: int = 10
@export_range(0.0, 1000.0) var hex_radius: float = 0.5
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

# x and z are in grid coordinates
func get_hex_center(x: int, z: int) -> Vector2:
    var coeff = sqrt(3.0) / 2.0
    var hex_diameter = 2 * hex_radius
    
    var x_offset = coeff if (z % 2) else 0.0
    
    return Vector2(hex_diameter * (x * coeff+x_offset/2), hex_diameter * (3.0/4.0) * z)

func generate_mesh():
    clear_mesh()

    var mesh = generate_hex_mesh()
    
    for z in range(height):
        for x in range(width):
            var mesh_instance_3d = MeshInstance3D.new()
            mesh_instance_3d.mesh = mesh
            
            var position_2d = get_hex_center(x, z)
            
            mesh_instance_3d.position.x = position_2d.x
            mesh_instance_3d.position.z = position_2d.y
            hexes_container.add_child(mesh_instance_3d)
    pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
