extends Label

var frames = 10;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	frames -= 1
	if frames != 0:
		return
	set_text("FPS %d" % Engine.get_frames_per_second())
	frames = 10
	pass
