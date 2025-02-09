extends Node

@export var mainAnimation: AnimationPlayer
@export var mainEnvironment: WorldEnvironment
@export var mainCamera: Camera3D

@export var fogCurve: Curve
@export var fogFadeInTime: float = 10

@export var lureScene: PackedScene
@export var minLureSpawnDistance: float = 100
@export var maxLureSpawnDistance: float = 1000
@export var lureSpawnAmount: int = 100
@export var lureSpawnTime: float = 5

var isFadingFog = false
var fogFade = 0

var isSpawningLures = false
var lureSpawnTimer = 0
var lureSpawnCount: int = 0
var lures: Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mainAnimation.play("jumpscare")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	updateFog(delta)
	updateLureSpawns(delta)

func startFadingFog() -> void:
	fogFade = 0
	isFadingFog = true
	updateFog(0)

func updateFog(delta: float) -> void:
	if not isFadingFog:
		return
	
	fogFade += delta
	
	if fogFade >= fogFadeInTime:
		fogFade =  fogFadeInTime
		isFadingFog = false
	
	mainEnvironment.environment.volumetric_fog_density = fogCurve.sample_baked(fogFade / fogFadeInTime)

func startSpawningLures() -> void:
	lureSpawnTimer = 0
	lureSpawnCount = 0
	isSpawningLures = true

func spawnLureAtPoint(location: Vector3) -> void:
	var newLure = lureScene.instantiate()
	get_tree().get_current_scene().add_child(newLure)
	newLure.global_position = location
	print("spawned lure at ", location)
	lures.append(newLure)

func updateLureSpawns(delta: float) -> void:
	if not isSpawningLures:
		return
	
	lureSpawnTimer += delta;
	if lureSpawnTimer > lureSpawnTime:
		lureSpawnTimer = lureSpawnTime
		isSpawningLures = false
	
	var totalSpawn = ceili(lureSpawnTimer / lureSpawnTime * lureSpawnAmount)
	var spawnThisFrame = totalSpawn - lureSpawnCount
	assert(spawnThisFrame >= 0)
	lureSpawnCount = totalSpawn
	
	for i in spawnThisFrame:
		var rotator = Quaternion(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
		rotator = rotator.normalized()
		var relativePos = Vector3.RIGHT * rotator
		relativePos *= randf_range(minLureSpawnDistance, maxLureSpawnDistance)
		spawnLureAtPoint(mainCamera.position + relativePos)

func cleanup() -> void:
	isFadingFog = false
	isSpawningLures = false
	for lure in lures:
		lure.queue_free()
