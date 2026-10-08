extends CanvasLayer

var health_bar:ProgressBar
var stamina_bar:ProgressBar
var status:Label
var combat_status:Label
var quest_label:Label
var wave_label:Label
var equipment_label:Label
var coin_icon:TextureRect
var shuriken_icon:TextureRect
var boss_bar:ProgressBar
var boss_label:Label
var campaign_label:Label
var weapon_label:Label
var reward_label:Label

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
    coin_icon=TextureRect.new()
    coin_icon.texture=load("res://assets/ui/coin_icon.png")
    coin_icon.position=Vector2(338,201)
    coin_icon.size=Vector2(28,28)
    coin_icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    coin_icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    add_child(coin_icon)
    shuriken_icon=TextureRect.new()
    shuriken_icon.texture=load("res://assets/ui/shuriken_icon.svg")
    shuriken_icon.position=Vector2(338,235)
    shuriken_icon.size=Vector2(28,28)
    shuriken_icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    shuriken_icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    add_child(shuriken_icon)
    equipment_label=Label.new()
    equipment_label.position=Vector2(372,198)
    equipment_label.add_theme_font_size_override("font_size",15)
    add_child(equipment_label)
    boss_bar=ProgressBar.new()
    boss_bar.position=Vector2(390,32)
    boss_bar.size=Vector2(500,20)
    boss_bar.max_value=650.0
    boss_bar.show_percentage=false
    boss_bar.visible=false
    add_child(boss_bar)
    campaign_label=Label.new()
    campaign_label.position=Vector2(32,205)
    campaign_label.add_theme_font_size_override("font_size",16)
    add_child(campaign_label)
    weapon_label=Label.new()
    weapon_label.position=Vector2(32,260)
    weapon_label.add_theme_font_size_override("font_size",15)
    add_child(weapon_label)
    reward_label=Label.new()
    reward_label.position=Vector2(32,282)
    reward_label.add_theme_font_size_override("font_size",14)
    add_child(reward_label)
    boss_label=Label.new()
    boss_label.position=Vector2(390,56)
    boss_label.add_theme_font_size_override("font_size",14)
    boss_label.visible=false
    add_child(boss_label)
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
    if is_instance_valid(CampaignSystem):
        campaign_label.text="STAGE %d  //  %s\nMISSION  //  %s" % [CampaignSystem.current_level, CampaignSystem.get_level_name(), CampaignSystem.get_mission_text()]
    equipment_label.text="COINS %d    //    SHURIKEN %d    //    SKILL POINTS %d" % [GameState.coins,GameState.shurikens,Progression.skill_points]
    weapon_label.text="WEAPON  //  %s" % WeaponSystem.get_name()
    reward_label.text="GRAPHICS  //  %s" % GraphicsSettings.get_label()
    if CampaignSystem.notice != "":
        reward_label.text += "    //    " + CampaignSystem.notice
    var boss:=get_tree().get_first_node_in_group("boss")
    if is_instance_valid(boss):
        boss_bar.visible=true
        boss_label.visible=true
        boss_bar.max_value=boss.max_health
        boss_bar.value=boss.health
        boss_label.text="SHADOW COMMANDER  //  %d HP" % int(boss.health)
    else:
        boss_bar.visible=false
        boss_label.visible=false
