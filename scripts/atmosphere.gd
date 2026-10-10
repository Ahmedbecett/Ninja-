extends Node3D

# NINJA: Sunset Atmosphere matching Mount Fuji art direction
var time_of_day := 0.28 # Golden sunset hour
var cycle_speed := 0.00008
var environment: WorldEnvironment
var sun_light: DirectionalLight3D
var rim_light: DirectionalLight3D

# Sunset color palette inspired by Mount Fuji reference art
const SUNSET_SUN_COLOR := Color(1.0, 0.75, 0.44, 1.0)
const SUNSET_SKY_TOP := Color(0.35, 0.22, 0.45, 1.0)
const SUNSET_HORIZON := Color(0.95, 0.52, 0.32, 1.0)
const SUNSET_FOG_COLOR := Color(0.72, 0.42, 0.40, 1.0)

func _ready() -> void:
    environment = get_parent().get_node_or_null("Environment")
    sun_light = get_parent().get_node_or_null("MoonLight")
    rim_light = get_parent().get_node_or_null("RimLight")
    _apply_sunset_palette()
    _build_falling_sakura_petals()

func _apply_sunset_palette() -> void:
    if sun_light:
        sun_light.light_color = SUNSET_SUN_COLOR
        sun_light.light_energy = 1.85
        sun_light.rotation_degrees = Vector3(-18.0, 145.0, 0.0) # Warm low sunset angle
        sun_light.shadow_enabled = true
        sun_light.shadow_bias = 0.03
    
    if rim_light:
        rim_light.light_color = Color(1.0, 0.62, 0.38, 1.0)
        rim_light.light_energy = 0.65
        rim_light.rotation_degrees = Vector3(15.0, -35.0, 0.0)

    if environment and environment.environment:
        var env := environment.environment
        env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
        env.ambient_light_color = Color(0.48, 0.32, 0.38, 1.0)
        env.ambient_light_energy = 0.95
        env.fog_enabled = true
        env.fog_light_color = SUNSET_FOG_COLOR
        env.fog_density = 0.0045
        env.fog_aerial_perspective = 0.65
        env.tonemap_mode = Environment.TONE_MAPPER_ACES
        env.tonemap_exposure = 1.15
        env.glow_enabled = true
        env.glow_intensity = 0.45
        env.glow_bloom = 0.18

func _process(delta: float) -> void:
    time_of_day = fmod(time_of_day + delta * cycle_speed, 1.0)

func _build_falling_sakura_petals() -> void:
    # Gentle falling sakura petals floating across the mountain breeze
    var petals := GPUParticles3D.new()
    petals.name = "SakuraPetals"
    petals.amount = 260
    petals.lifetime = 6.0
    petals.visibility_aabb = AABB(Vector3(-40, -5, -40), Vector3(80, 25, 80))
    
    var proc := ParticleProcessMaterial.new()
    proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    proc.emission_box_extents = Vector3(35, 12, 35)
    proc.direction = Vector3(-0.6, -0.4, 0.4).normalized()
    proc.initial_velocity_min = 1.2
    proc.initial_velocity_max = 2.8
    proc.gravity = Vector3(-0.2, -0.4, 0.1)
    proc.scale_min = 0.04
    proc.scale_max = 0.08
    petals.process_material = proc
    
    var petal_mat := StandardMaterial3D.new()
    petal_mat.albedo_color = Color(0.98, 0.65, 0.78, 0.9)
    petal_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    petal_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    
    var quad := QuadMesh.new()
    quad.size = Vector2(0.08, 0.12)
    quad.material = petal_mat
    petals.draw_pass_1 = quad
    petals.position = Vector3(0, 8, 0)
    add_child(petals)
