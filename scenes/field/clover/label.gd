extends Node3D

var camera: Camera3D

var selected: bool:
    get: return get_parent().is_selected

func _ready():
    for child in get_children():
        (child as GeometryInstance3D).transparency = 1.0

func _on_clover_selected(instance):
    var tween = get_tree().create_tween()
    tween.set_parallel(true)
    
    tween.tween_property(
            self, "position:y", 1.75, 0.25
        ).set_ease(Tween.EASE_IN_OUT
        ).set_trans(Tween.TRANS_QUAD)
    
    for child in get_children():
        tween.tween_property(
            child, "transparency", 0.0, 0.25
        ).set_ease(Tween.EASE_IN_OUT
        ).set_trans(Tween.TRANS_QUAD)

func _on_clover_unsnapping():
    var tween = get_tree().create_tween()
    tween.set_parallel(true)
    
    tween.tween_property(self, "position:y", 1.5, 0.25
        ).set_ease(Tween.EASE_IN_OUT
        ).set_trans(Tween.TRANS_QUAD)
    
    for child in get_children():
        tween.tween_property(child, "transparency", 1.0, 0.25
        ).set_ease(Tween.EASE_IN_OUT
        ).set_trans(Tween.TRANS_QUAD)
