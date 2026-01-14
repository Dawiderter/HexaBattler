class_name Timeline extends Node

var queue : Array[Dictionary] = []
var time = 0

func _ready() -> void:
    pass
    
func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("ui_accept"):
        pop_next()
        
func plan_wake(after: int, target: Object, ...data):
    assert(after >= 0)
    
    data.push_front(self)
    queue.push_back({
        "time": time + after,
        "target": target,
        "data": data
    })
    sort_wakes()

func time_until_next() -> int:
    var dict = queue.back()
    assert(dict != null)
    
    var t = dict["time"] - time
    assert(t >= 0)
    
    return t

func pop_next():
    var dict = queue.pop_back()
    
    if dict == null:
        push_warning("The timeline is empty")
        return
    
    var target = dict["target"]
    var next_time = dict["time"]
    var data = dict["data"]
    
    assert(next_time >= time)
    time = next_time
    
    target.wake.callv(data)

func sort_wakes():
    queue.sort_custom(func(a,b): return a["time"] > b["time"])
