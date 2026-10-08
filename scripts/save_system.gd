extends Node

const SAVE_PATH := "user://ninja_save.json"

func save_game() -> bool:
    var data := {
        "version": 1,
        "level": GameState.level,
        "xp": GameState.xp,
        "coins": GameState.coins,
        "kills": GameState.kills,
        "skills": Progression.unlocked_skills,
        "skill_points": Progression.skill_points,
        "quest": QuestSystem.get_save_data()
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(data))
    file.close()
    return true

func load_game() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return false
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return false
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) != TYPE_DICTIONARY:
        return false
    GameState.level = int(parsed.get("level",1))
    GameState.xp = int(parsed.get("xp",0))
    GameState.coins = int(parsed.get("coins",0))
    GameState.kills = int(parsed.get("kills",0))
    Progression.skill_points = int(parsed.get("skill_points",0))
    var skills = parsed.get("skills",{})
    if skills is Dictionary:
        for key in skills:
            if Progression.unlocked_skills.has(key):
                Progression.unlocked_skills[key] = bool(skills[key])
    QuestSystem.load_save_data(parsed.get("quest",{}))
    return true

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        save_game()
