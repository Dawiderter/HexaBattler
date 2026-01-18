class_name GameSimulation extends Node

var width:  int
var height: int

var hexes:    Array[HexState]
var factions: Array[Faction]

func get_hex_offcord(offcord: Vector2i) -> HexState:
    var i = offcord.x + offcord.y * width
    return hexes[i]

func get_hex_axcord(axcord: Vector2i) -> HexState:
    var offcord = GridUtils.axcord_to_offcord(axcord)
    var i = offcord.x + offcord.y * width
    return hexes[i]
    
func _ready():
    pass

func reset(w: int, h: int) -> void:
    self.width  = w
    self.height = h
    self.hexes.resize(w * h)
    for i in range(self.hexes.size()):
        self.hexes[i] = HexState.new()

# For now:
#   true  -> success (if succesfully spawned the minion)
#   false -> failure (if the hex was occupied or locked)
func spawn_minion(offcord: Vector2, faction: Faction) -> bool:
    assert(0 <= offcord.x and offcord.x < width)
    assert(0 <= offcord.y and offcord.y < height)
    # assert(faction in factions)
    
    var hex = get_hex_offcord(offcord)
    if !hex.is_free():
        return false
        
    var minion = MinionState.new()
    minion.faction = faction
    hex.occupy_for(minion)
    return true
        
    
