extends Node3D
class_name GameDirector

@export var enemy_scene: PackedScene
@export var boss_scene: PackedScene
@export var max_active_enemies := 8
var wave := 1
var spawn_timer := 0.0
var boss_spawned := false
var spawn_points := [
    Vector3(-10,1,-12), Vector3(10,1,-12), Vector3(-14,1,-2),
    Vector3(14,1,3), Vector3(-8,1,12), Vector3(9,1,11),
    Vector3(0,1,-16), Vector3(16,1,-8)
]

func _ready() -> void:
    spawn_timer = 2.0

func _process(delta: float) -> void:
    spawn_timer = maxf(spawn_timer-delta,0.0)
    var active := get_tree().get_nodes_in_group("enemies").size()
    if GameState.kills >= 15 and not boss_spawned and boss_scene:
        _spawn_boss()
        boss_spawned = true
    if active < min(max_active_enemies, 3 + wave) and spawn_timer <= 0.0 and enemy_scene:
        _spawn_enemy()
        spawn_timer = maxf(1.2, 3.5 - wave * 0.15)

func _spawn_enemy() -> void:
    var enemy := enemy_scene.instantiate()
    get_parent().add_child(enemy)
    var idx := (GameState.kills + wave + get_tree().get_nodes_in_group("enemies").size()) % spawn_points.size()
    enemy.global_position = spawn_points[idx]
    enemy.max_health = 100.0 + wave * 12.0
    enemy.move_speed = 2.5 + minf(wave * 0.08,1.4)
    wave = 1 + int(GameState.kills / 5)

func _spawn_boss() -> void:
    var boss := boss_scene.instantiate()
    get_parent().add_child(boss)
    boss.global_position = Vector3(0,1,-20)
