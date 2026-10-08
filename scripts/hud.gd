extends CanvasLayer

var health_bar: ProgressBar
var stamina_bar: ProgressBar
var status: Label

func _ready() -> void:
    health_bar = ProgressBar.new()
    health_bar.position = Vector2(32,32)
    health_bar.size = Vector2(300,24)
    health_bar.max_value = 100
    add_child(health_bar)

    stamina_bar = ProgressBar.new()
    stamina_bar.position = Vector2(32,62)
    stamina_bar.size = Vector2(300,18)
    stamina_bar.max_value = 100
    add_child(stamina_bar)

    status = Label.new()
    status.position = Vector2(32,92)
    status.text = "NINJA // FOUNDATION"
    status.add_theme_font_size_override("font_size",18)
    add_child(status)

func _process(_delta: float) -> void:
    var player := get_tree().get_first_node_in_group("player")
    if is_instance_valid(player):
        health_bar.value = player.health
        stamina_bar.value = player.stamina
