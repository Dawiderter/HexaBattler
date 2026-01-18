class_name GameSimulation extends Node

var width:  int
var height: int

var hexes:    Array[HexState]
var minions:  Array[MinionState]
var factions: Array[Faction]

func get_hex_offcord(offcord: Vector2i) -> HexState:
    var i = offcord.x + offcord.y * width
    return hexes[i]

func get_hex_axcord(axcord: Vector2i) -> HexState:
    var offcord = GridUtils.axcord_to_offcord(axcord)
    var i = offcord.x + offcord.y * width
    return hexes[i]
    
func _ready():
    var faction_red = Faction.new()
    faction_red.color = Color.RED
    faction_red.debug_name = "Red"
    
    var faction_blue = Faction.new()
    faction_blue.color = Color.BLUE
    faction_blue.debug_name = "Blue"
    
    self.factions.push_back(faction_red)
    self.factions.push_back(faction_blue)

func reset(w: int, h: int) -> void:
    self.width  = w
    self.height = h
    self.hexes.resize(w * h)
    for i in range(self.hexes.size()):
        self.hexes[i] = HexState.new()

# For now:
#   minion -> success (if succesfully spawned the minion)
#   null   -> failure (if the hex was occupied or locked)
func spawn_minion(offcord: Vector2i, faction: Faction) -> MinionState:
    assert(0 <= offcord.x and offcord.x < width)
    assert(0 <= offcord.y and offcord.y < height)
    # assert(faction in factions)
    
    var hex = get_hex_offcord(offcord)
    if !hex.is_free():
        return null
        
    var minion = MinionState.new()
    minions.push_back(minion)
    minion.debug_name = faction.debug_name + " " + str(minions.size())
    minion.faction = faction
    minion.axcord = GridUtils.offcord_to_axcord(offcord)
    hex.occupy_for(minion)
    
    return minion
        
func find_closest_minion(axcord: Vector2i, faction_mask: Faction) -> MinionState:
    var closest : MinionState = null
    var closest_dist : int = 100_000_000
    for minion in minions:
        if minion.faction == faction_mask:
            continue
        var dist = GridUtils.axial_length(minion.axcord - axcord)
        if dist < closest_dist:
            closest_dist = dist
            closest = minion
    return closest
    
func do_minion_action(minion: MinionState):
    if minion.target == null:
        minion.target = find_closest_minion(minion.axcord, minion.faction)
    
    if minion.target == null:
        return
    
    
    
