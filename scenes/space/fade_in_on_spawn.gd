extends Sprite3D

@export var fadeTimeMin: float = 0.5
@export var fadeTimeMax: float = 2

var rolledFadeTime = 1
var fadeTimer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rolledFadeTime = randf_range(fadeTimeMin, fadeTimeMax)
	modulate.a = 0;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fadeTimer = clamp(fadeTimer + delta, 0, rolledFadeTime)
	modulate.a = fadeTimer / rolledFadeTime
