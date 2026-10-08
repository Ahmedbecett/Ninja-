extends Node

var unlocked_skills := {
    "double_dash": false,
    "heavy_strike": true,
    "counter": false
}

var skill_points := 0

func grant_skill_point() -> void:
    skill_points += 1

func unlock(skill: String) -> bool:
    if skill_points <= 0 or not unlocked_skills.has(skill) or unlocked_skills[skill]:
        return false
    unlocked_skills[skill] = true
    skill_points -= 1
    return true
