extends Node3D

func attach_to_timeline(tl: Timeline):
    tl.plan_wake(1, self, "Hello.")
    
func wake(tl: Timeline, text: String):
    print("Got notified with:", text)
    var new_text = text + "Hello."
    tl.plan_wake(1, self, new_text)
