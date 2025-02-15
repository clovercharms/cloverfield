extends Node3D

@export var amount = 100
@export var position_range = 20
@export var min_distance = 3.0
@export var bow: Bow

@onready var clover: PackedScene = preload("res://scenes/field/clover/clover.tscn")

# State
var half_range = position_range / 2.0
var generated_positions: Array[Vector3] = []
var instances: Array[PackedScene] = []
var selection_active := false
var messages_read := 0

# Responses
var responses = preload("res://responses.csv")
var generic_messages = preload("res://generic_charms.csv")
const DEFAULT_NAME := "Lucky Charm"
const DEFAULT_AVATAR := preload("res://assets/textures/clovers/cloverrose.png")

static var avatars = {
    0: preload("res://assets/textures/avatars/awysu.jpg"),
    1: preload("res://assets/textures/avatars/firebreath.jpg"),
    4: preload("res://assets/textures/avatars/dwraith.png"),
    5: preload("res://assets/textures/avatars/herbie_cucumber.jpg"),
    7: preload("res://assets/textures/avatars/necrozma.png"),
    11: preload("res://assets/textures/avatars/eb.png"),
    12: preload("res://assets/textures/avatars/raz.png"),
    14: preload("res://assets/textures/avatars/14.png"),
    16: preload("res://assets/textures/avatars/16.png"),
    18: preload("res://assets/textures/avatars/18.png"),
    19: preload("res://assets/textures/avatars/19.png"),
    22: preload("res://assets/textures/avatars/22.png"),
    27: preload("res://assets/textures/avatars/27.png"),
    33: preload("res://assets/textures/avatars/33.jpg"),
    34: preload("res://assets/textures/avatars/34.jpeg"),
    38: preload("res://assets/textures/avatars/38.png"),
    40: preload("res://assets/textures/avatars/40.jpg"),
    42: preload("res://assets/textures/avatars/42.JPG")
}

static var art = {
    0: preload("res://assets/textures/art/0.jpg"),
    1: preload("res://assets/textures/art/1.jpg"),
    4: preload("res://assets/textures/art/4.jpg"),
    5: preload("res://assets/textures/art/5.jpg"),
    7: preload("res://assets/textures/art/7.png"),
    11: preload("res://assets/textures/art/11.png"),
    12: preload("res://assets/textures/art/12.png"),
    17: preload("res://assets/textures/art/17.png"),
    18: preload("res://assets/textures/art/18.png"),
    21: preload("res://assets/textures/art/21.png"),
    24: preload("res://assets/textures/art/24.png"),
    25: preload("res://assets/textures/art/25.png"),
    26: preload("res://assets/textures/art/26.png"),
    27: preload("res://assets/textures/art/27.png"),
    28: preload("res://assets/textures/art/28.jpg"),
    29: preload("res://assets/textures/art/29.png"),
    30: preload("res://assets/textures/art/30.png"),
    32: preload("res://assets/textures/art/32.png"),
    35: preload("res://assets/textures/art/35.png"),
    37: preload("res://assets/textures/art/37.png"),
    42: preload("res://assets/textures/art/42.jpeg")
}

static var bodies: Array[Body] = [
    Body.new(
        preload("res://assets/textures/clovers/Base.png"),
        preload("res://assets/textures/clovers/dizzy/Base.png"),
    ),
    Body.new(
        preload("res://assets/textures/clovers/base32ElectricBoogaloo.png"),
        preload("res://assets/textures/clovers/dizzy/base32ElectricBoogaloo.png"),
    ),
    Body.new(
        preload("res://assets/textures/clovers/Chu.png"),
        preload("res://assets/textures/clovers/dizzy/Chu.png"),
    ),
    Body.new(
        preload("res://assets/textures/clovers/cloverrose.png"),
        preload("res://assets/textures/clovers/dizzy/cloverrose.png"),
    ),
    Body.new(
        preload("res://assets/textures/clovers/CloverTie.png"),
        preload("res://assets/textures/clovers/dizzy/CloverTie.png"),
    ),
    Body.new(
        preload("res://assets/textures/clovers/cloverRibbon_3.png"),
        preload("res://assets/textures/clovers/dizzy/cloverRibbon_3.png"),
    ),
    Body.new(
        preload("res://assets/textures/clovers/Base4.png"),
        preload("res://assets/textures/clovers/dizzy/Base4.png"),
    )
]

# Disable selection for all clovers on selection
func _toggle_selections(instance: CharacterBody3D, disabled: bool):
    bow.disabled = disabled
    for child in get_children():
        if child == instance: continue
        
        child.selection_disabled = disabled

func _update_counter():
    (get_node("../Counter") as Label).text = "Messages read: %s/%s" % \
        [messages_read, responses.records.size() + 1]

func _ready():
    _update_counter()
    
    for i in range(amount):
        @warning_ignore("confusable_local_usage", "shadowed_variable")
        var clover = clover.instantiate() as Node3D
        clover.camera = get_node("../Camera3D")
        clover.orbit_controls = get_node("../OrbitControls")
        # Disable selections on all clovers when one is selected
        clover.selected.connect(func(instance): _toggle_selections(instance, true))
        clover.selected.connect(func(instance):
            if (instance as Clover).has_been_selected:
                return
            messages_read += 1
            _update_counter()
        )
        # Re-enable selections on deselect
        clover.deselected.connect(func(): _toggle_selections(null, false))
        #Set name and message (and avatar apparently)
        if i < responses.records.size():
            clover.name = responses.records[i][1]
            if art.has(i):
                clover.art = art[i]
            if !clover.name:
                clover.name = DEFAULT_NAME
            clover.get_node("Label/Name").text = clover.name
            clover.get_node("Label/Message").text = responses.records[i][2]
            
            # Choo-choo-choose an avatar
            if avatars.has(i):
                clover.avatar = avatars[i]
            else:
                clover.avatar = DEFAULT_AVATAR
            
            if clover.art == null:
                clover.get_node("Label/Art").visible = false
                clover.get_node("Label/ArtBorder").visible = false
        else:
            # Mark as dummy to disable interactivity
            clover.is_dummy = true
            
            # Set attributes
            clover.get_node("Label/Name").text = DEFAULT_NAME
            clover.get_node("Label/Message").text = \
                generic_messages.records[
                    randi_range(0,generic_messages.records.size()-1)
                ][0]
            clover.get_node("MiniLabel").visible = false
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
