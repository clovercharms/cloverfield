extends Node3D

@export var amount = 100
@export var position_range = 10
@export var min_distance = 0.7

@onready var clover: PackedScene = preload("res://clover.tscn")
var half_range = position_range / 2.0
var generated_positions: Array[Vector3] = []
var instances: Array[PackedScene] = []
var selection_active := false

static var avatars: Array[Texture] = [
	preload("res://assets/textures/0e748d5c03e9db4dcafbd0eb95cc04c5.png"),
	preload("res://assets/textures/7bc5d82b2a758871c43a88c438a555d7.png"),
	preload("res://assets/textures/37b1590dd0b8abdd195f6a316bfec185.png"),
	preload("res://assets/textures/37cdacfcb198cc99a1f8e6e1ea9c8bf3.png"),
	preload("res://assets/textures/a5e3a10c2a0fcfca7736df62b8c1ff23.png"),
	preload("res://assets/textures/a199d21ed0a72874549a626190630f08.png"),
	preload("res://assets/textures/a787a861b4a4781b7b5ba1c1df002909.png"),
	preload("res://assets/textures/a_8aa68e655ee8d4b6cc50f1ab7c7516ee.png"),
	preload("res://assets/textures/b3109c7e6e639d076b3e280b8ddf04d0.png"),
	preload("res://assets/textures/f4e24f6258f24cbd94e139317d58c03a.png"),
	preload("res://assets/textures/f7e694eb04dd6e04eb6fde8c9267fbbf.png"),
	preload("res://assets/textures/pfp.png"),
]

# Disable selection for all clovers on selection
func _toggle_selections(instance: CharacterBody3D, disabled: bool):
	for child in get_children():
		if child == instance: continue
		
		child.selection_disabled = disabled

func _ready():
	for i in range(amount):
		@warning_ignore("confusable_local_usage", "shadowed_variable")
		var clover = clover.instantiate() as Node3D
		clover.camera = get_node("../Camera3D")
		# Disable selections on all clovers when one is selected
		clover.selected.connect(func(instance): _toggle_selections(instance, true))
		# Re-enable selections on deselect
		clover.deselected.connect(func(): _toggle_selections(null, false))
		# Choose random avatar
		clover.avatar = avatars[randi_range(0, avatars.size()-1)]
		
		# Keep generating random spawn positions until atleast min_distance from
		# other clovers in the field
		while true:
			var random_position = Vector3(
				randf_range(-half_range, half_range),
				0.5,
				randf_range(-half_range, half_range)
			)
			
			var distance_threshold_reached = false
			for generated_position in generated_positions:
				if generated_position.distance_to(random_position) < min_distance:
					distance_threshold_reached = true
					break
			
			if !distance_threshold_reached:
				clover.position = random_position
				generated_positions.append(random_position)
				break
		
		# Randomize orientation
		#if randi_range(0, 1) == 0:
			#clover.get_node("Body").rotation.y = PI
		
		add_child(clover)
