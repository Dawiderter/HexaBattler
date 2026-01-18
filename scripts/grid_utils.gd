@abstract class_name GridUtils extends Object

static func center_from_offcord(offcord: Vector2i, hex_radius: float) -> Vector2:
    var coeff = sqrt(3.0) / 2.0
    var hex_diameter = 2 * hex_radius
    
    var x_offset = coeff if (offcord.y % 2) else 0.0
    
    return Vector2(hex_diameter * (offcord.x * coeff+x_offset/2), hex_diameter * (3.0/4.0) * offcord.y)

# Adapted directly from https://www.redblobgames.com/grids/hexagons/#conversions-offset
static func offcord_to_axcord(offcord: Vector2i) -> Vector2i:
    var parity = offcord.y & 1
    var x = offcord.x - (offcord.y - parity) / 2
    var y = offcord.y
    return Vector2i(x,y)
    
static func axcord_to_offcord(axcord: Vector2i) -> Vector2i:
    var parity = axcord.y & 1
    var x = axcord.x + (axcord.y - parity) / 2
    var y = axcord.y
    return Vector2i(x,y)
    
static func axcord_to_cubecord(axcord: Vector2i) -> Vector3i:
    return Vector3i(axcord.x, axcord.y, - axcord.x - axcord.y)

static func cubecord_to_axcord(cubecord: Vector3i) -> Vector2i:
    return Vector2i(cubecord.x, cubecord.y)

static func axial_length(axcord: Vector2i) -> int:
    return (abs(axcord.x) + abs(axcord.x + axcord.y) + abs(axcord.y)) / 2
    
static func cube_length(cubecord: Vector3i) -> int:
    return (abs(cubecord.x) + abs(cubecord.y) + abs(cubecord.z)) / 2
    
static func cube_norm(cubecord: Vector3i) -> Vector3:
    var length := float(cube_length(cubecord))
    var normed := Vector3(cubecord) / length
    return normed
    
static func cube_round(cubecord: Vector3) -> Vector3i:
    var x := roundi(cubecord.x)
    var y := roundi(cubecord.y)
    var z := roundi(cubecord.z)
    
    var x_diff = abs(x - cubecord.x)
    var y_diff = abs(y - cubecord.y)
    var z_diff = abs(z - cubecord.z)
    
    if x_diff > y_diff and x_diff > z_diff:
        x = - y - z
    elif y_diff > z_diff:
        y = - x - z
    else:
        z = - x - y
        
    return Vector3i(x, y, z)    
    
static func get_neighbors(cubecord: Vector3i) -> Array[Vector3i]:
    var cube_direction_vectors = [
        Vector3i(+1, 0, -1), Vector3i(+1, -1, 0), Vector3i(0, -1, +1), 
        Vector3i(-1, 0, +1), Vector3i(-1, +1, 0), Vector3i(0, +1, -1), 
    ]

    var arr = []
    for dir in cube_direction_vectors:
        arr.push_back(cubecord + dir)

    return arr
    
    
    
    
    
    
    
    
    
