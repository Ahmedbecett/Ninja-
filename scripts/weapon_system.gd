extends Node
class_name WeaponSystem

signal weapon_changed

const WEAPONS := {
    "KAGE_BLADE": {"name":"KAGE BLADE","damage":1.0,"speed":1.0,"range":2.8,"stamina":1.0,"unlock_kills":0},
    "TWIN_KATANA": {"name":"TWIN KATANA","damage":1.16,"speed":1.10,"range":2.9,"stamina":1.08,"unlock_kills":12},
    "ASH_KATANA": {"name":"ASH KATANA","damage":1.34,"speed":0.96,"range":3.0,"stamina":1.18,"unlock_kills":20},
    "SHADOW_BLADE": {"name":"SHADOW BLADE","damage":1.58,"speed":1.12,"range":3.25,"stamina":1.10,"unlock_kills":30},
    "CITADEL_RELIC": {"name":"CITADEL RELIC","damage":1.90,"speed":1.18,"range":3.4,"stamina":1.05,"unlock_kills":45}
}

var equipped := "KAGE_BLADE"
var unlocked := {"KAGE_BLADE":true}

func _ready() -> void:
    _refresh_unlocks()

func _process(_delta: float) -> void:
    _refresh_unlocks()

func _refresh_unlocks() -> void:
    for id in WEAPONS:
        var data:Dictionary = WEAPONS[id]
        if GameState.kills >= int(data.unlock_kills):
            unlocked[id] = true

func equip(id:String) -> bool:
    _refresh_unlocks()
    if not WEAPONS.has(id) or not unlocked.get(id,false):
        return false
    equipped = id
    weapon_changed.emit()
    return true

func get_current() -> Dictionary:
    return WEAPONS.get(equipped, WEAPONS["KAGE_BLADE"])

func get_damage(base:float) -> float:
    return base * float(get_current().damage)

func get_attack_lock(base:float) -> float:
    return base / maxf(float(get_current().speed),0.1)

func get_stamina_cost(base:float) -> float:
    return base * float(get_current().stamina)

func get_range() -> float:
    return float(get_current().range)

func cycle_weapon() -> void:
    _refresh_unlocks()
    var ids:Array=WEAPONS.keys()
    var start:int=ids.find(equipped)
    for step in range(1,ids.size()+1):
        var idx:int=(start+step)%ids.size()
        var id:String=ids[idx]
        if unlocked.get(id,false):
            equipped=id
            weapon_changed.emit()
            return

func get_name() -> String:
    return str(get_current().name)

func get_save_data() -> Dictionary:
    return {"equipped":equipped,"unlocked":unlocked.duplicate()}

func load_save_data(data) -> void:
    if data is Dictionary:
        var saved_unlocked=data.get("unlocked",{})
        if saved_unlocked is Dictionary:
            for id in WEAPONS:
                if bool(saved_unlocked.get(id,false)):
                    unlocked[id]=true
        var saved_equipped=str(data.get("equipped","KAGE_BLADE"))
        if unlocked.get(saved_equipped,false):
            equipped=saved_equipped
