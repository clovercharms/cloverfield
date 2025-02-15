extends Node

@export var mainAnimation: AnimationPlayer
@export var mainEnvironment: WorldEnvironment
@export var mainCamera: Camera3D

@export var fogCurve: Curve
@export var fogFadeInTime: float = 10

@export var lureScene: PackedScene
@export var minLureSpawnDistance: float = 15
@export var maxLureSpawnDistance: float = 30
@export var lureSpawnAmount: int = 60
@export var lureSpawnTime: float = 10

@export var lowShelfCurve: Curve
@export var pitchShiftCurve: Curve
@export var reverbCurve: Curve
@export var volumeCurve: Curve
@export var musicFadeTime: float = 10
const HzMultiplier = 1000 #curves can't go high enough for hertz, so multiply by this factor

var playedEver = false

var isFadingFog = false
var fogFade = 0

var isSpawningLures = false
var lureSpawnTimer = 0
var lureSpawnCount: int = 0
var lures: Array[Node] = []

var isFadingMusic = false
var musicFade = 0
var audioBusIndex = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#mainAnimation.play("jumpscare")
	
func _on_charm_summoner_catgirl_found() -> void:
	if playedEver:
		return
	if not WorldEvents.StartEvent("Anglerfish"):
		return
	playedEver = true
	mainAnimation.play("jumpscare")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	updateFog(delta)
	updateLureSpawns(delta)
	updateMusicFade(delta)

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

func startFadingMusic() -> void:
	musicFade = 0
	isFadingMusic = true;
	
	audioBusIndex = AudioServer.get_bus_index("Normal")
	
	var lowShelf = AudioEffectLowShelfFilter.new()
	lowShelf.cutoff_hz = lowShelfCurve.sample_baked(0) * HzMultiplier
	AudioServer.add_bus_effect(audioBusIndex, lowShelf, 0)
	
	var pitchShift = AudioEffectPitchShift.new()
	pitchShift.pitch_scale = pitchShiftCurve.sample_baked(0)
	AudioServer.add_bus_effect(audioBusIndex, pitchShift, 1)
	
	var reverb = AudioEffectReverb.new();
	reverb.hipass = reverbCurve.sample_baked(0);
	reverb.predelay_feedback = 0;
	AudioServer.add_bus_effect(audioBusIndex, reverb, 2)
	

func updateMusicFade(delta: float) -> void:
	if not isFadingMusic:
		return
	
	musicFade += delta
	
	if musicFade >= musicFadeTime:
		musicFade = musicFadeTime
		isFadingMusic = false
		AudioServer.set_bus_mute(audioBusIndex, true)
	
	var fadeProgress = musicFade / musicFadeTime
	
	AudioServer.set_bus_volume_db(audioBusIndex, volumeCurve.sample_baked(fadeProgress))
	AudioServer.get_bus_effect(audioBusIndex,0).cutoff_hz = lowShelfCurve.sample_baked(fadeProgress) * HzMultiplier
	AudioServer.get_bus_effect(audioBusIndex,1).pitch_scale = pitchShiftCurve.sample_baked(fadeProgress)
	AudioServer.get_bus_effect(audioBusIndex,2).hipass = reverbCurve.sample_baked(fadeProgress);

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
		spawnLureAtPoint(mainCamera.global_position + relativePos)

func cleanup() -> void:
	isFadingFog = false
	isFadingMusic = false
	isSpawningLures = false
	for lure in lures:
		lure.queue_free()
	
	mainEnvironment.environment.fog_enabled = false
	mainEnvironment.environment.volumetric_fog_density = 0
	
	AudioServer.set_bus_mute(audioBusIndex, false)
	AudioServer.set_bus_volume_db(audioBusIndex, 0)
	AudioServer.remove_bus_effect(audioBusIndex, 2)
	AudioServer.remove_bus_effect(audioBusIndex, 1)
	AudioServer.remove_bus_effect(audioBusIndex, 0)
	
	mainAnimation.play("RESET")
	WorldEvents.ClearCurrentEvent()
