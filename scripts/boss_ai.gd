extends CharacterBody3D
class_name BossAI

@export var max_health := 650.0
@export var move_speed := 2.4
var health := 650.0
var target: Node3D
var attack_timer := 1.5
var special_timer := 4.0
var enraged := false

func _ready() -> void:
    health = max_health
    add_to_group("enemies")
    add_to_group("boss")

func _physics_process(delta: float) -> void:
    attack_timer = maxf(attack_timer-delta,0.0)
    special_timer = maxf(special_timer-delta,0.0)
    if not is_instance_valid(target):
        target = get_tree().get_first_node_in_group("player")
        return
    var offset := target.global_position-global_position
    var dist := offset.length()
    if dist > 2.6:
        var dir := offset.normalized()
        velocity.x = dir.x * move_speed
        velocity.z = dir.z * move_speed
        rotation.y = lerp_angle(rotation.y,atan2(-dir.x,-dir.z),delta*4.0)
    else:
        velocity.x = move_toward(velocity.x,0,16*delta)
        velocity.z = move_toward(velocity.z,0,16*delta)
        if attack_timer <= 0.0:
            attack_timer = 1.3 if not enraged else 0.8
            target.take_damage(26.0 if not enraged else 38.0)
    if special_timer <= 0.0:
        special_timer = 5.0
        var player := target
        if is_instance_valid(player):
            player.take_damage(45.0)
    move_and_slide()

func take_damage(amount: float, source: Vector3 = Vector3.ZERO) -> void:
    health -= amount
    if health <= max_health*0.35 and not enraged:
        enraged = true
        move_speed = 3.5
    if health <= 0.0:
        GameState.register_kill()
        QuestSystem.register_kill(true)
        GameState.add_xp(250)
        queue_free()
