extends CharacterBody3D
class_name ShadowArcher

@export var max_health:=80.0
@export var move_speed:=2.2
@export var attack_range:=11.0
var health:=80.0
var target:Node3D
var attack_timer:=2.0
var projectile_script=preload("res://scripts/arrow.gd")

func _ready()->void:
    health=max_health
    add_to_group("enemies")
    add_to_group("ranged_enemies")

func _physics_process(delta:float)->void:
    attack_timer=maxf(attack_timer-delta,0.0)
    if not is_instance_valid(target):
        target=get_tree().get_first_node_in_group("player")
        return
    var offset:Vector3=target.global_position-global_position
    var dist:float=offset.length()
    var dir:Vector3=offset.normalized()
    if dist>attack_range:
        velocity.x=dir.x*move_speed
        velocity.z=dir.z*move_speed
    elif dist<5.0:
        velocity.x=-dir.x*move_speed
        velocity.z=-dir.z*move_speed
    else:
        velocity.x=move_toward(velocity.x,0,12*delta)
        velocity.z=move_toward(velocity.z,0,12*delta)
    rotation.y=lerp_angle(rotation.y,atan2(-dir.x,-dir.z),delta*5.0)
    if attack_timer<=0.0 and dist<=attack_range:
        attack_timer=2.2
        var arrow:=Area3D.new()
        arrow.set_script(projectile_script)
        get_parent().add_child(arrow)
        arrow.launch(global_position+Vector3(0,1.35,0),dir,self)
    move_and_slide()

func take_damage(amount:float,source:Vector3=Vector3.ZERO)->void:
    health-=amount
    VFX.impact(get_parent(),global_position)
    if health<=0.0:
        GameState.register_kill()
        QuestSystem.register_kill(false)
        queue_free()
