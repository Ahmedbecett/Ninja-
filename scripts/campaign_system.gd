extends Node

signal campaign_changed

const LEVELS := [
    {"name":"THE OUTSKIRTS","required_kills":0,"zone":"village"},
    {"name":"BAMBOO SHADOWS","required_kills":5,"zone":"bamboo"},
    {"name":"RIVER OF BLADES","required_kills":12,"zone":"river"},
    {"name":"DOJO OF ASH","required_kills":20,"zone":"dojo"},
    {"name":"CASTLE APPROACH","required_kills":30,"zone":"castle"},
    {"name":"SHADOW CITADEL","required_kills":45,"zone":"citadel"},
    {"name":"THE BURNING SHRINE","required_kills":55,"zone":"citadel"},
    {"name":"DAWN OF THE SHOGUN","required_kills":70,"zone":"citadel"}
]

const MISSIONS := [
    {"id":"m1","title":"FIRST STEP","story":"The ashes still smoke. Kurogane's raiders patrol the outskirts of your burned village. Draw your blade, last of the Kage clan.","description":"Defeat 5 enemies.","type":"kills","target":5,"reward_xp":150,"reward_coins":75},
    {"id":"m2","title":"BAMBOO HUNT","story":"An old hunter whispers that raiders hide among the bamboo. The grove swallows sound - strike before they hear your footsteps.","description":"Reach the bamboo grove and defeat 7 enemies there.","type":"zone_kills","zone":"bamboo","target":7,"reward_xp":220,"reward_coins":110},
    {"id":"m3","title":"RIVER AMBUSH","story":"The river road carries stolen shrine gold to the citadel. Ambush the escort at the bridge and let the current take their arrows.","description":"Survive the river ambush and defeat 10 enemies.","type":"zone_kills","zone":"river","target":10,"reward_xp":300,"reward_coins":150},
    {"id":"m4","title":"ASHES OF THE DOJO","story":"Your master's dojo stands occupied. The archers who burned it still train in its courtyard. Show them what their fire created.","description":"Clear the dojo and defeat 12 enemies.","type":"zone_kills","zone":"dojo","target":12,"reward_xp":400,"reward_coins":200},
    {"id":"m5","title":"CASTLE GATE","story":"Beyond the castle gate lies the citadel road. The garrison has never been broken. Tonight it will be.","description":"Break through the castle approach and defeat 15 enemies.","type":"zone_kills","zone":"castle","target":15,"reward_xp":550,"reward_coins":275},
    {"id":"m6","title":"THE SHADOW COMMANDER","story":"Kurogane's second - the Shadow Commander - waits in the citadel court. He carries the scroll with your clan's name. End him.","description":"Enter the citadel and defeat the Shadow Commander.","type":"boss","zone":"citadel","target":1,"reward_xp":1000,"reward_coins":600},
    {"id":"m7","title":"EMBERS OF WAR","story":"The scroll names a traitor: the Iron Shogun himself ordered your clan erased. The citadel burns with his reinforcements. Cut through them.","description":"Defeat 55 enemies in total.","type":"kills","target":55,"reward_xp":1200,"reward_coins":700},
    {"id":"m8","title":"THE BURNING SHRINE","story":"The shrine of your ancestors is being desecrated for its relic blade. Drive the defilers from the citadel shrine.","description":"Defeat 8 enemies at the citadel shrine.","type":"zone_kills","zone":"citadel","target":8,"reward_xp":1400,"reward_coins":800},
    {"id":"m9","title":"WHISPERS OF THE COURT","story":"A dying captain confesses: the Shogun fears the dawn ritual that could expose him. His court assassins hunt you first. Survive.","description":"Defeat 12 more enemies in the citadel.","type":"zone_kills","zone":"citadel","target":12,"reward_xp":1600,"reward_coins":900},
    {"id":"m10","title":"THE LAST LANTERN","story":"One lantern still burns above the gate where your family fell. Carry it to the shrine and the clans will rise with you. Clear the path.","description":"Defeat 16 enemies in the citadel.","type":"zone_kills","zone":"citadel","target":16,"reward_xp":1800,"reward_coins":1000},
    {"id":"m11","title":"MARCH OF DAWN","story":"The clans march at first light. Until then, hold the citadel fields alone against the Shogun's last legion.","description":"Defeat 70 enemies in total.","type":"kills","target":70,"reward_xp":2200,"reward_coins":1200},
    {"id":"m12","title":"PEACE AT DAWN","story":"The Iron Shogun is exposed, his legion scattered. Lay your blade on the shrine steps and let the dawn keep your name. The shadow protocol ends.","description":"Defeat 80 enemies in total.","type":"kills","target":80,"reward_xp":3000,"reward_coins":2000}
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
    if str(m.get("story", "")) != "":
        notice = notice + "\n" + str(m.story)
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
