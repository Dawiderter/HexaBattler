@tool
extends Node3D

@export_range(1, 500) var width:  int = 10
@export_range(1, 500) var height: int = 10
@export_range(0.0, 1000.0) var hex_radius: float = 0.5
@export_tool_button("Generate Mesh", "Callable") var generate_mesh_action = generate_mesh
@export_tool_button("Clear Mesh", "Callable") var clear_mesh_action = clear_mesh

@onready var hexes_container: Node3D = $HexesContainer

var _shared_collision_shape: Shape3D

func clear_mesh():
    for hex in hexes_container.get_children():
        hex.queue_free()
    hexes_container.get_children().clear()

func _generate_hex_mesh() -> Mesh:
    var mesh = CylinderMesh.new()
    mesh.radial_segments = 6
    mesh.top_radius = hex_radius * 0.95
    mesh.bottom_radius = hex_radius * 0.95
    mesh.height = 0.25
    return mesh

# x and z are in grid coordinates
func get_hex_center(x: int, z: int) -> Vector2:
    var coeff = sqrt(3.0) / 2.0
    var hex_diameter = 2 * hex_radius
    
    var x_offset = coeff if (z % 2) else 0.0
    
    return Vector2(hex_diameter * (x * coeff+x_offset/2), hex_diameter * (3.0/4.0) * z)

func generate_mesh():
    clear_mesh()

    var mesh = _generate_hex_mesh()
    
    _shared_collision_shape = mesh.create_convex_shape()
    
    for z in range(height):
        for x in range(width):
            var mesh_instance_3d = MeshInstance3D.new()
            mesh_instance_3d.mesh = mesh
            
            var position_2d = get_hex_center(x, z)
            
            mesh_instance_3d.position.x = position_2d.x
            mesh_instance_3d.position.z = position_2d.y
            mesh_instance_3d.scale.y = randfn(1.0, 0.05)
            hexes_container.add_child(mesh_instance_3d)
            
            var body = StaticBody3D.new()
            mesh_instance_3d.add_child(body)
            
            var col = CollisionShape3D.new()
            col.shape = _shared_collision_shape
            body.add_child(col)
            
            if not Engine.is_editor_hint():
                body.input_event.connect(_on_hex_input_event.bind(mesh_instance_3d))
                body.mouse_entered.connect(_on_hex_mouse_entered.bind(mesh_instance_3d))
                body.mouse_exited.connect(_on_hex_mouse_exited.bind(mesh_instance_3d))
            
            if self.owner:
                body.owner = self
                col.owner = self
                mesh_instance_3d.owner = self
    
    hexes_container.position.x = -(width * hex_radius * sqrt(3.0)/2.0)
    hexes_container.position.z = -(height * hex_radius * 3.0/4.0)
    
func _on_hex_input_event(camera, event, pos, normal, shape_idx, hex_mesh):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            print("Clicked Hex: ", hex_mesh.name)
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color.RED
            hex_mesh.material_override = mat

func _on_hex_mouse_entered(hex_mesh):
    print("Hovering: ", hex_mesh.name)

func _on_hex_mouse_exited(hex_mesh):
    pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
