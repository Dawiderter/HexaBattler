class_name HexState extends RefCounted

signal hex_state_changed(new_state: LockState)

enum LockState { FREE, LOCKED, OCCUPIED }
var lock_by_minion: MinionState = null;
var lock_state := LockState.FREE:
    set(value):
        lock_state = value
        hex_state_changed.emit(lock_state)

func is_free():
    return lock_state == LockState.FREE
    
func lock_for(minion: MinionState) -> void:
    lock_state = LockState.LOCKED
    lock_by_minion = minion

func occupy_for(minion: MinionState) -> void:
    assert(
        (lock_by_minion == null and lock_state == LockState.FREE) 
        or (lock_by_minion == minion and lock_state == LockState.LOCKED)
    )
    lock_state = LockState.OCCUPIED
    lock_by_minion = minion

# Free the cell (Unit left or died)
func free_cell() -> void:
    lock_state = LockState.FREE
    lock_by_minion = null
    
