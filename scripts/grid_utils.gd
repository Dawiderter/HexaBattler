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

static func axial_length(axcord: Vector2i) -> int:
    return (abs(axcord.x) + abs(axcord.x + axcord.y) + abs(axcord.y)) / 2
