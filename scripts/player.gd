extends CharacterBody3D

@export var move_speed := 6.5
@export var acceleration := 22.0
@export var friction := 28.0
@export var jump_velocity := 7.0
@export var dash_speed := 18.0
@export var max_health := 100.0
@export var max_stamina := 100.0

var health := 100.0
var stamina := 100.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var attack_cooldown := 0.0
var dash_cooldown := 0.0
var invulnerable := 0.0

func _ready() -> void:
    health = max_health
    stamina = max_stamina
    add_to_group("player")

func _physics_process(delta: float) -> void:
    attack_cooldown = maxf(attack_cooldown - delta, 0.0)
    dash_cooldown = maxf(dash_cooldown - delta, 0.0)
    invulnerable = maxf(invulnerable - delta, 0.0)

    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = -0.5

    var input_vec := Input.get_vector("move_left","move_right","move_forward","move_back")
    var direction := Vector3(input_vec.x,0,input_vec.y)
    if direction.length() > 1.0:
        direction = direction.normalized()

    if direction.length() > 0.05:
        var target := direction * move_speed
        velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
        velocity.z = move_toward(velocity.z, target.z, acceleration * delta)
        rotation.y = lerp_angle(rotation.y, atan2(-direction.x,-direction.z), minf(delta*12.0,1.0))
    else:
        velocity.x = move_toward(velocity.x, 0.0, friction * delta)
        velocity.z = move_toward(velocity.z, 0.0, friction * delta)

    if Input.is_action_just_pressed("attack"):
        attack()
    if Input.is_action_just_pressed("dash"):
        dash(direction)

    stamina = minf(max_stamina, stamina + delta * 18.0)
    move_and_slide()

func attack() -> void:
    if attack_cooldown > 0.0:
        return
    attack_cooldown = 0.42
    var hit_range := 2.6
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) <= hit_range:
            enemy.take_damage(28.0, global_position)

func dash(direction: Vector3) -> void:
    if dash_cooldown > 0.0 or stamina < 25.0:
        return
    dash_cooldown = 0.8
    stamina -= 25.0
    invulnerable = 0.28
    if direction.length() < 0.05:
        direction = -global_transform.basis.z
    velocity.x = direction.x * dash_speed
    velocity.z = direction.z * dash_speed

func take_damage(amount: float) -> void:
    if invulnerable > 0.0:
        return
    health = maxf(health - amount, 0.0)
    if health <= 0.0:
        _respawn()

func _respawn() -> void:
    health = max_health
    stamina = max_stamina
    global_position = Vector3(0,1,0)
