extends CharacterBody3D

@export var max_health := 100.0
@export var move_speed := 2.7
@export var attack_range := 2.0
var health := 100.0
var target: Node3D
var attack_timer := 0.0

func _ready() -> void:
    health = max_health
    add_to_group("enemies")

func _physics_process(delta: float) -> void:
    attack_timer = maxf(attack_timer-delta,0.0)
    if not is_instance_valid(target):
        target = get_tree().get_first_node_in_group("player")
        return
    var offset := target.global_position - global_position
    var distance := offset.length()
    if distance > attack_range:
        var dir := offset.normalized()
        velocity.x = dir.x * move_speed
        velocity.z = dir.z * move_speed
        rotation.y = lerp_angle(rotation.y, atan2(-dir.x,-dir.z), delta*5.0)
    else:
        velocity.x = move_toward(velocity.x,0,12*delta)
        velocity.z = move_toward(velocity.z,0,12*delta)
        if attack_timer <= 0.0:
            attack_timer = 1.1
            if target.has_method("take_damage"):
                target.take_damage(12.0)
    move_and_slide()

func take_damage(amount: float, source: Vector3 = Vector3.ZERO) -> void:
    health -= amount
    if source != Vector3.ZERO:
        var knock := (global_position-source).normalized()
        velocity += knock*4.0
    if health <= 0.0:
        queue_free()
