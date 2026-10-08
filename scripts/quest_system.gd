extends Node
class_name QuestSystem

var active_id := "first_blood"
var progress := 0
var completed: Dictionary = {}

var quests := {
    "first_blood": {"title":"FIRST BLOOD","description":"Eliminate 5 hostile shinobi.","target":5,"reward_xp":100,"reward_coins":50},
    "survivor": {"title":"SURVIVOR","description":"Reach a 12 kill streak.","target":12,"reward_xp":250,"reward_coins":120},
    "warlord": {"title":"WARLORD","description":"Defeat the shadow commander.","target":1,"reward_xp":500,"reward_coins":300}
}

func _ready() -> void:
    add_to_group("quest_system")

func register_kill(is_boss := false) -> void:
    if is_boss:
        if not completed.has("warlord"):
            _complete("warlord")
    if active_id == "first_blood":
        progress += 1
    elif active_id == "survivor":
        progress = max(progress, GameState.combo)
    _check_active()

func _check_active() -> void:
    if not quests.has(active_id) or completed.has(active_id):
        return
    if progress >= int(quests[active_id].target):
        _complete(active_id)

func _complete(id: String) -> void:
    completed[id] = true
    var q: Dictionary = quests[id]
    GameState.add_xp(int(q.reward_xp))
    GameState.coins += int(q.reward_coins)
    Progression.grant_skill_point()
    var next := ["first_blood","survivor","warlord"]
    var idx := next.find(id)
    if idx >= 0 and idx + 1 < next.size():
        active_id = next[idx+1]
        progress = 0

func get_active_text() -> String:
    if not quests.has(active_id):
        return ""
    var q: Dictionary = quests[active_id]
    return "%s  %d/%d" % [q.title, progress, int(q.target)]

func get_save_data() -> Dictionary:
    return {"active_id":active_id,"progress":progress,"completed":completed}

func load_save_data(data) -> void:
    if data is Dictionary:
        active_id = str(data.get("active_id","first_blood"))
        progress = int(data.get("progress",0))
        var c = data.get("completed",{})
        if c is Dictionary:
            completed = c.duplicate()
