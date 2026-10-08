extends CharacterBody3D

@export var move_speed := 6.5
@export var acceleration := 24.0
@export var friction := 30.0
@export var dash_speed := 19.0
@export var max_health := 100.0
@export var max_stamina := 100.0

var health := 100.0
var stamina := 100.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var dash_cooldown := 0.0
var invulnerable := 0.0
var mobile_move := Vector2.ZERO
var combat: CombatSystem
var visual: CharacterVisual
var camera_controller: CameraController
var shuriken_script = preload("res://scripts/shuriken.gd")

func _ready() -> void:
    health = max_health
    stamina = max_stamina
    add_to_group("player")
    combat = CombatSystem.new()
    add_child(combat)
    visual = get_node_or_null("Visual") as CharacterVisual
    camera_controller = get_node_or_null("CameraRig") as CameraController

func set_mobile_move(value: Vector2) -> void:
    mobile_move = value.limit_length(1.0)

func _physics_process(delta: float) -> void:
    combat.tick(delta)
    dash_cooldown = maxf(dash_cooldown-delta,0.0)
    invulnerable = maxf(invulnerable-delta,0.0)

    if not is_on_floor():
        velocity.y -= gravity*delta
    else:
        velocity.y = -0.5

    var raw := Input.get_vector("move_left","move_right","move_forward","move_back")
    if mobile_move.length() > 0.05:
        raw = mobile_move

    var basis := Basis(Vector3.UP, rotation.y)
    if camera_controller:
        basis = camera_controller.get_move_basis()
    var direction := basis * Vector3(raw.x,0,raw.y)
    direction.y = 0
    direction = direction.limit_length(1.0)

    if direction.length() > 0.05:
        var target := direction * move_speed
        velocity.x = move_toward(velocity.x,target.x,acceleration*delta)
        velocity.z = move_toward(velocity.z,target.z,acceleration*delta)
        rotation.y = lerp_angle(rotation.y,atan2(-direction.x,-direction.z),minf(delta*12.0,1.0))
    else:
        velocity.x = move_toward(velocity.x,0,friction*delta)
        velocity.z = move_toward(velocity.z,0,friction*delta)

    if Input.is_action_just_pressed("attack"):
        attack()
    if Input.is_action_just_pressed("dash"):
        dash(direction)
    if Input.is_action_just_pressed("shuriken"):
        throw_shuriken(direction)

    stamina = minf(max_stamina,stamina+delta*16.0)
    if visual:
        visual.animate_state(Vector2(velocity.x,velocity.z).length(),combat.attack_lock>0.0)
    move_and_slide()

func attack() -> void:
    if combat.try_attack(self,false):
        stamina = maxf(stamina-5.0,0.0)
        if visual:
            visual.animate_state(0,true)

func heavy_attack() -> void:
    if stamina < 18.0:
        return
    if combat.try_attack(self,true):
        stamina -= 18.0
        if visual:
            visual.animate_state(0,true)

func throw_shuriken(direction: Vector3) -> void:
    if stamina < 8.0 or GameState.shurikens <= 0:
        return
    if direction.length() < 0.05:
        direction = -global_transform.basis.z
    var projectile := Area3D.new()
    projectile.set_script(shuriken_script)
    get_parent().add_child(projectile)
    projectile.launch(global_position + Vector3(0,1.35,0) + direction*0.65, direction, self)
    stamina -= 8.0
    GameState.shurikens -= 1

func dash(direction: Vector3) -> void:
    if dash_cooldown > 0.0 or stamina < 25.0:
        return
    dash_cooldown = 0.75
    stamina -= 25.0
    invulnerable = 0.3
    if direction.length() < 0.05:
        direction = -global_transform.basis.z
    velocity.x = direction.x*dash_speed
    velocity.z = direction.z*dash_speed

func take_damage(amount: float) -> void:
    if invulnerable > 0.0:
        return
    health = maxf(health-amount,0.0)
    if visual:
        visual.hit_flash()
    VFX.impact(get_parent(),global_position)
    if health <= 0.0:
        _respawn()

func _respawn() -> void:
    health = max_health
    stamina = max_stamina
    global_position = Vector3(0,1,5)
    velocity = Vector3.ZERO
    GameState.combo = 0
