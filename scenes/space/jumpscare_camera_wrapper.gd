extends Node3D

#the normal gameplay camera you want to transition out of
@export var TrackingCamera: Camera3D

func PositionForJumpscare():
	global_transform = TrackingCamera.global_transform;
