extends Node3D

@export var amount = 100
@export var position_range = 20
@export var min_distance = 3.0

@onready var clover: PackedScene = preload("res://scenes/field/clover/clover.tscn")
var half_range = position_range / 2.0
var generated_positions: Array[Vector3] = []
var instances: Array[PackedScene] = []
var selection_active := false

var responses = preload("res://responses.csv")
var generic_messages = preload("res://generic_charms.csv")

#static var avatars: Array[Texture] = [
	#preload("res://assets/textures/avatars/0e748d5c03e9db4dcafbd0eb95cc04c5.png"),
	#preload("res://assets/textures/avatars/7bc5d82b2a758871c43a88c438a555d7.png"),
	#preload("res://assets/textures/avatars/37b1590dd0b8abdd195f6a316bfec185.png"),
	#preload("res://assets/textures/avatars/37cdacfcb198cc99a1f8e6e1ea9c8bf3.png"),
	#preload("res://assets/textures/avatars/a5e3a10c2a0fcfca7736df62b8c1ff23.png"),
	#preload("res://assets/textures/avatars/a199d21ed0a72874549a626190630f08.png"),
	#preload("res://assets/textures/avatars/a787a861b4a4781b7b5ba1c1df002909.png"),
	#preload("res://assets/textures/avatars/a_8aa68e655ee8d4b6cc50f1ab7c7516ee.png"),
	#preload("res://assets/textures/avatars/b3109c7e6e639d076b3e280b8ddf04d0.png"),
	#preload("res://assets/textures/avatars/f4e24f6258f24cbd94e139317d58c03a.png"),
	#preload("res://assets/textures/avatars/f7e694eb04dd6e04eb6fde8c9267fbbf.png"),
	#preload("res://assets/textures/avatars/pfp.png"),
#]

static var avatars = {
	"default" : preload("res://assets/textures/clovers/cloverrose.png"),
	"Awysu" : preload("res://assets/textures/avatars/awysu.jpg"),
	"Firebreath" : preload("res://assets/textures/avatars/firebreath.jpg"),
	"DWraith23" : preload("res://assets/textures/avatars/dwraith.png"),
	"Herbie Cucumber" : preload("res://assets/textures/avatars/herbie_cucumber.jpg"),
	"Necrozma" : preload("res://assets/textures/avatars/necrozma.png"),
	"EB" : preload("res://assets/textures/avatars/eb.png"),
	"That Guy Raz" : preload("res://assets/textures/avatars/raz.png")
}

static var bodies: Array[Texture] = [
	preload("res://assets/textures/clovers/clover.png"),
	preload("res://assets/textures/clovers/Base.png"),
	preload("res://assets/textures/clovers/base32ElectricBoogaloo.png"),
	preload("res://assets/textures/clovers/Chu.png"),
	preload("res://assets/textures/clovers/cloverrose.png"),
	preload("res://assets/textures/clovers/CloverTie.png"),
	preload("res://assets/textures/clovers/cloverRibbon_3.png"),
	preload("res://assets/textures/clovers/Base4.png"),
]

# Disable selection for all clovers on selection
func _toggle_selections(instance: CharacterBody3D, disabled: bool):
	for child in get_children():
		if child == instance: continue
		
		child.selection_disabled = disabled

func _ready():
	print(avatars.keys())
	
	for i in range(amount):
		@warning_ignore("confusable_local_usage", "shadowed_variable")
		var clover = clover.instantiate() as Node3D
		clover.camera = get_node("../Camera3D")
		clover.orbit_controls = get_node("../OrbitControls")
		# Disable selections on all clovers when one is selected
		clover.selected.connect(func(instance): _toggle_selections(instance, true))
		# Re-enable selections on deselect
		clover.deselected.connect(func(): _toggle_selections(null, false))
		#Set name and message (and avatar apparently)
		if i < responses.records.size():
			clover.get_node("Label/Name").text = responses.records[i][1]
			clover.get_node("Label/Message").text = responses.records[i][2].left(500)
			# Choo-choo-choose an avatar
			if responses.records[i][1] in avatars.keys():
				clover.avatar = avatars[responses.records[i][1]]
			else:
				clover.avatar = avatars["default"]
				clover.get_node("Label/Background2").visible = false
		else:
			clover.get_node("Label/Name").text = "Lucky Charm"
			clover.get_node("Label/Message").text = generic_messages.records[randi_range(0,generic_messages.records.size()-1)][0]
			clover.get_node("MiniLabel/Avatar").visible = false
			clover.get_node("MiniLabel/Arrow").visible = false
			clover.get_node("MiniLabel/Background").visible = false
			clover.get_node("Label/Background2").visible = false
			clover.get_node("Label/Avatar").visible = false
		# Choose random body
		clover.body = bodies[randi_range(0, bodies.size()-1)]
		
		

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
		if randi_range(0, 1) == 0:
			clover.get_node("Body").rotation.y = PI
		
		add_child(clover)
