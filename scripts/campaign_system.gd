extends Node
class_name CampaignSystem

signal campaign_changed

const LEVELS := [
    {"name":"THE OUTSKIRTS","required_kills":0,"zone":"village"},
    {"name":"BAMBOO SHADOWS","required_kills":5,"zone":"bamboo"},
    {"name":"RIVER OF BLADES","required_kills":12,"zone":"river"},
    {"name":"DOJO OF ASH","required_kills":20,"zone":"dojo"},
    {"name":"CASTLE APPROACH","required_kills":30,"zone":"castle"},
    {"name":"SHADOW CITADEL","required_kills":45,"zone":"citadel"}
]

const MISSIONS := [
    {"id":"m1","title":"FIRST STEP","description":"Defeat 5 enemies.","type":"kills","target":5,"reward_xp":150,"reward_coins":75},
    {"id":"m2","title":"BAMBOO HUNT","description":"Reach the bamboo grove and defeat 7 enemies there.","type":"zone_kills","zone":"bamboo","target":7,"reward_xp":220,"reward_coins":110},
    {"id":"m3","title":"RIVER AMBUSH","description":"Survive the river ambush and defeat 10 enemies.","type":"zone_kills","zone":"river","target":10,"reward_xp":300,"reward_coins":150},
    {"id":"m4","title":"ASHES OF THE DOJO","description":"Clear the dojo and defeat 12 enemies.","type":"zone_kills","zone":"dojo","target":12,"reward_xp":400,"reward_coins":200},
    {"id":"m5","title":"CASTLE GATE","description":"Break through the castle approach and defeat 15 enemies.","type":"zone_kills","zone":"castle","target":15,"reward_xp":550,"reward_coins":275},
    {"id":"m6","title":"THE SHADOW COMMANDER","description":"Enter the citadel and defeat the Shadow Commander.","type":"boss","zone":"citadel","target":1,"reward_xp":1000,"reward_coins":600}
]

var current_level := 1
var current_mission := 0
var mission_progress := 0
var completed := {}
var zone_kills := {
    "village":0,
    "bamboo":0,
    "river":0,
    "dojo":0,
    "castle":0,
    "citadel":0
}
var last_kills := 0
var boss_done := false
var notice := ""

func _ready() -> void:
    add_to_group("campaign_system")

func _process(_delta: float) -> void:
    if GameState.kills != last_kills:
        last_kills = GameState.kills
        _refresh_level()
        _refresh_mission()

func register_zone_kill(zone:String) -> void:
    if not zone_kills.has(zone):
        zone_kills[zone]=0
    zone_kills[zone]=int(zone_kills[zone])+1
    _refresh_level()
    _refresh_mission()

func register_boss_defeated() -> void:
    boss_done = true
    if current_mission == 5:
        mission_progress = 1
        _complete_mission()

func _refresh_level() -> void:
    while current_level < LEVELS.size() and GameState.kills >= int(LEVELS[current_level].required_kills):
        current_level += 1
        notice = "NEW AREA UNLOCKED  //  " + str(LEVELS[current_level-1].name)
        campaign_changed.emit()

func _refresh_mission() -> void:
    if current_mission >= MISSIONS.size():
        return
    var m:Dictionary = MISSIONS[current_mission]
    if m.type == "kills":
        mission_progress=min(GameState.kills,int(m.target))
    elif m.type == "zone_kills":
        mission_progress=min(int(zone_kills.get(str(m.zone),0)),int(m.target))
    elif m.type == "boss":
        mission_progress=1 if boss_done else 0
    _check_mission()

func _check_mission() -> void:
    if current_mission >= MISSIONS.size():
        return
    var m:Dictionary = MISSIONS[current_mission]
    if mission_progress < int(m.target):
        return
    _complete_mission()

func _complete_mission() -> void:
    if current_mission >= MISSIONS.size():
        return
    var m:Dictionary = MISSIONS[current_mission]
    completed[str(m.id)] = true
    GameState.add_xp(int(m.reward_xp))
    GameState.coins += int(m.reward_coins)
    Progression.grant_skill_point()
    notice = "MISSION COMPLETE  //  " + str(m.title) + "  //  +%d XP  +%d COINS" % [int(m.reward_xp),int(m.reward_coins)]
    current_mission += 1
    mission_progress = 0
    campaign_changed.emit()

func get_zone_position(zone:String) -> Vector3:
    match zone:
        "village": return Vector3(0,0,-12)
        "bamboo": return Vector3(-19,0,18)
        "river": return Vector3(0,0,3)
        "dojo": return Vector3(23,0,21)
        "castle": return Vector3(-22,0,21)
        "citadel": return Vector3(0,0,-20)
    return Vector3.ZERO

func get_level_name() -> String:
    return str(LEVELS[clampi(current_level-1,0,LEVELS.size()-1)].name)

func get_mission_text() -> String:
    if current_mission >= MISSIONS.size():
        return "CAMPAIGN COMPLETE  //  SHADOWS DEFEATED"
    var m:Dictionary = MISSIONS[current_mission]
    if m.type == "boss":
        return "%s  //  %d/%d" % [m.title,mission_progress,int(m.target)]
    return "%s  //  %d/%d" % [m.title,mission_progress,int(m.target)]

func get_save_data() -> Dictionary:
    return {
        "current_level":current_level,
        "current_mission":current_mission,
        "mission_progress":mission_progress,
        "completed":completed,
        "zone_kills":zone_kills,
        "boss_done":boss_done
    }

func load_save_data(data) -> void:
    if data is Dictionary:
        current_level=int(data.get("current_level",1))
        current_mission=int(data.get("current_mission",0))
        mission_progress=int(data.get("mission_progress",0))
        boss_done=bool(data.get("boss_done",false))
        var c=data.get("completed",{})
        if c is Dictionary:
            completed=c.duplicate()
        var z=data.get("zone_kills",{})
        if z is Dictionary:
            for zone in zone_kills:
                zone_kills[zone]=int(z.get(zone,0))
