extends Node3D
class_name GameDirector

@export var max_active_enemies := 8
var wave := 1
var spawn_timer := 2.0
var boss_spawned := false
var enemy_script = preload("res://scripts/enemy_ai.gd")
var archer_script = preload("res://scripts/shadow_archer.gd")
var boss_script = preload("res://scripts/boss_ai.gd")
var visual_script = preload("res://scripts/character_visual.gd")
var spawn_points := [
    Vector3(-10,1,-12), Vector3(10,1,-12), Vector3(-14,1,-2),
    Vector3(14,1,3), Vector3(-8,1,12), Vector3(9,1,11),
    Vector3(0,1,-16), Vector3(16,1,-8)
]

func _process(delta: float) -> void:
    spawn_timer=maxf(spawn_timer-delta,0.0)
    var active: int = get_tree().get_nodes_in_group("enemies").size()
    if GameState.kills>=45 and not boss_spawned:
        _spawn_boss()
        boss_spawned=true
    if active<min(max_active_enemies,3+wave) and spawn_timer<=0.0:
        _spawn_enemy()
        spawn_timer=maxf(1.25,3.2-wave*0.12)

func _spawn_enemy() -> void:
    var enemy:=CharacterBody3D.new()
    var use_archer:bool = wave >= 2 and (GameState.kills + wave) % 4 == 0
    enemy.set_script(archer_script if use_archer else enemy_script)
    get_parent().add_child(enemy)
    var shape:=CollisionShape3D.new()
    var capsule:=CapsuleShape3D.new()
    capsule.radius=0.42; capsule.height=1.8
    shape.shape=capsule
    enemy.add_child(shape)
    var visual:=Node3D.new()
    visual.name="Visual"
    visual.set_script(visual_script)
    visual.set("enemy",true)
    enemy.add_child(visual)
    var idx: int=(GameState.kills+wave+active_count())%spawn_points.size()
    enemy.global_position=spawn_points[idx]
    enemy.set("max_health",100.0+wave*12.0)
    if not use_archer:
        enemy.set("move_speed",2.5+minf(wave*0.08,1.4))
    wave=1+int(GameState.kills/5)

func active_count()->int:
    return get_tree().get_nodes_in_group("enemies").size()

func _spawn_boss() -> void:
    var boss:=CharacterBody3D.new()
    boss.name="ShadowCommander"
    boss.set_script(boss_script)
    get_parent().add_child(boss)
    var shape:=CollisionShape3D.new()
    var capsule:=CapsuleShape3D.new()
    capsule.radius=0.65; capsule.height=2.4
    shape.shape=capsule
    boss.add_child(shape)
    var visual:=Node3D.new()
    visual.name="Visual"
    visual.set_script(visual_script)
    visual.set("enemy",true)
    visual.scale=Vector3(1.25,1.25,1.25)
    boss.add_child(visual)
    boss.global_position=Vector3(0,1,-20)
