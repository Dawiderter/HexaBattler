class_name GameSimulation extends Node

signal minion_state_moved(minion: MinionState)
signal minion_state_damaged(minion: MinionState)

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
    
func get_hex_cubecord(cubecord: Vector3i) -> HexState:
    var axcord = GridUtils.cubecord_to_axcord(cubecord)
    return get_hex_axcord(axcord)
    
func is_cubecord_in_bounds(cubecord: Vector3i) -> bool:
    var offcord = GridUtils.axcord_to_offcord(GridUtils.cubecord_to_axcord(cubecord))
    return 0 <= offcord.x and offcord.x < width and 0 <= offcord.y and offcord.y < height
    
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
        
func find_closest_minion_and_move(axcord: Vector2i, faction_mask: Faction):
    var starting_pos = GridUtils.axcord_to_cubecord(axcord)
    
    # This queue should only contain cubecord coordinates
    var bfs_queue:  Array[Vector2i] = [starting_pos]
    var prev_queue: Dictionary      = {starting_pos: null}
    var visited:    Array[Vector2i] = [starting_pos]

    while not bfs_queue.is_empty():
        var curr = bfs_queue.pop_front()

        if curr in visited:
            continue

        visited.append(curr)

        var hex = get_hex_cubecord(curr)
        if curr != starting_pos and hex.lock_by_minion != null:
            var minion = hex.lock_by_minion
            if minion.faction != minion.faction_mask:
                return {"minion": minion, "move_towards_enemy": _backtrack_bfs_search(starting_pos, curr, prev_queue)}

        for neighbor in GridUtils.get_neighbors(curr):
            if is_cubecord_in_bounds(neighbor):
                bfs_queue.push_back(neighbor)
                prev_queue[neighbor] = curr

    return null
    
func _backtrack_bfs_search(starting_pos: Vector2i, curr: Vector2i, prev_queue: Dictionary) -> Vector2i:
    while prev_queue[curr] != starting_pos:
        curr = prev_queue[curr]
    return curr
    
func do_minion_action(minion: MinionState):
    if minion.target == null or minion.target.is_dead():
        minion.target = find_closest_minion(minion.axcord, minion.faction)
    
    if minion.target == null:
        push_action(1, minion)
        return
    
    assert(not minion.is_dead())
        
    var target_pos := GridUtils.axcord_to_cubecord(minion.target.axcord)
    var current_pos := GridUtils.axcord_to_cubecord(minion.axcord)
    
    if GridUtils.cube_length(target_pos - current_pos) <= 1:
        # Attack
        minion.target.take_damage(minion.stat_attack_power)
        if minion.target.is_dead():
            cancel_actions(minion.target)
            for hex in hexes:
                if hex.lock_by_minion == minion.target:
                    hex.free_cell()
        
        minion_state_damaged.emit(minion.target)
    else:
        # Try to move forward
        var dir := GridUtils.cube_norm(target_pos - current_pos)
        var diri := GridUtils.cube_round(dir)
        var new_pos = GridUtils.cubecord_to_axcord(current_pos + diri)
        
        var hex = get_hex_axcord(new_pos)
        if hex.is_free():
            var prev_hex = get_hex_axcord(minion.axcord)
            prev_hex.free_cell()
            
            hex.occupy_for(minion)
            
            minion.axcord = new_pos
            minion_state_moved.emit(minion)
    
    push_action(1, minion)

func cancel_actions(target: MinionState):
    queue = queue.filter(func(a): return a.target != target)

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
    
    
    
    
