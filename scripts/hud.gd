extends CanvasLayer

var health_bar:ProgressBar
var stamina_bar:ProgressBar
var status:Label
var combat_status:Label
var quest_label:Label
var wave_label:Label

func _ready()->void:
    health_bar=_bar(Vector2(32,32),Vector2(300,24),100)
    stamina_bar=_bar(Vector2(32,62),Vector2(300,18),100)
    status=Label.new()
    status.position=Vector2(32,92)
    status.text="NINJA // SHADOW PROTOCOL"
    status.add_theme_font_size_override("font_size",18)
    add_child(status)
    combat_status=Label.new()
    combat_status.position=Vector2(32,122)
    combat_status.add_theme_font_size_override("font_size",16)
    add_child(combat_status)
    quest_label=Label.new()
    quest_label.position=Vector2(32,150)
    quest_label.add_theme_font_size_override("font_size",15)
    add_child(quest_label)
    wave_label=Label.new()
    wave_label.position=Vector2(32,178)
    wave_label.add_theme_font_size_override("font_size",15)
    add_child(wave_label)

func _bar(pos:Vector2,size:Vector2,maxv:float)->ProgressBar:
    var b:=ProgressBar.new()
    b.position=pos;b.size=size;b.max_value=maxv;b.show_percentage=false
    add_child(b)
    return b

func _process(_delta:float)->void:
    var p:=get_tree().get_first_node_in_group("player")
    if is_instance_valid(p):
        health_bar.value=p.health
        stamina_bar.value=p.stamina
    combat_status.text="LEVEL %d   XP %d   COINS %d   KILLS %d   COMBO %d" % [GameState.level,GameState.xp,GameState.coins,GameState.kills,GameState.combo]
    quest_label.text="MISSION  //  "+QuestSystem.get_active_text()
    wave_label.text="HOSTILES  //  %d" % get_tree().get_nodes_in_group("enemies").size()
