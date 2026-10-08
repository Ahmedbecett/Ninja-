extends Node

var level := 1
var xp := 0
var coins := 0
var kills := 0
var combo := 0
var combo_timer := 0.0
var shurikens := 12
var story_progress := 0

func _ready() -> void:
    add_to_group("game_state")

func add_xp(amount: int) -> void:
    xp += amount
    while xp >= level * 100:
        xp -= level * 100
        level += 1

func register_kill() -> void:
    kills += 1
    coins += 10
    combo += 1
    combo_timer = 3.0
    add_xp(25)

func _process(delta: float) -> void:
    if combo_timer > 0.0:
        combo_timer -= delta
    else:
        combo = 0
