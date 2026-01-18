class_name GameSimulation extends Node

signal minion_state_changed(minion: MinionState)

var width:  int
var height: int

var hexes:    Array[HexState]
var minions:  Dictionary[int, MinionState]
var factions: Array[Faction]

var highest_minion_id := 0

var queue : Array[Dictionary] = []
var time = 0

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
    
    minion.id = highest_minion_id + 1
    highest_minion_id = minion.id
    
    minions[minion.id] = minion
    minion.debug_name = faction.debug_name + " " + str(minions.size())
    minion.faction = faction
    minion.axcord = GridUtils.offcord_to_axcord(offcord)
    hex.occupy_for(minion)
    
    push_action(0, minion)
    
    return minion
        
func find_closest_minion(axcord: Vector2i, faction_mask: Faction) -> MinionState:
    var closest : MinionState = null
    var closest_dist : int = 100_000_000
    for minion_id in minions:
        var minion = minions[minion_id]
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
        
    var target_pos := GridUtils.axcord_to_cubecord(minion.target.axcord)
    var current_pos := GridUtils.axcord_to_cubecord(minion.axcord)
    
    var dir := GridUtils.cube_norm(target_pos - current_pos)
    var diri := GridUtils.cube_round(dir)
    var new_pos = GridUtils.cubecord_to_axcord(current_pos + diri)
    
    var hex = get_hex_axcord(new_pos)
    if hex.is_free():
        var prev_hex = get_hex_axcord(minion.axcord)
        prev_hex.free_cell()
        
        hex.occupy_for(minion)
        
        minion.axcord = new_pos
        minion_state_changed.emit(minion)
    
    push_action(1, minion)

func push_action(after: int, target: MinionState):
    assert(after >= 0)

    queue.push_back({
        "time": time + after,
        "target": target,
    })
    sort_actions()

func time_until_next() -> int:
    var dict = queue.back()
    assert(dict != null)
    
    var t = dict["time"] - time
    assert(t >= 0)
    
    return t

func pop_action():
    var dict = queue.pop_back()
    
    if dict == null:
        push_warning("The timeline is empty")
        return
    
    var target = dict.target
    var next_time = dict.time
    
    assert(next_time >= time)
    time = next_time
    
    do_minion_action(target)

func sort_actions():
    queue.sort_custom(func(a,b): return a.time > b.time or (a.time == b.time and a.target.id > b.target.id))
    
    
    
    
