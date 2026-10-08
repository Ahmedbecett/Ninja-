extends Node3D

var time_of_day := 0.18
var cycle_speed := 0.004
var environment: WorldEnvironment
var moon: DirectionalLight3D
var rim: DirectionalLight3D

func _ready() -> void:
    environment=get_parent().get_node_or_null("Environment")
    moon=get_parent().get_node_or_null("MoonLight")
    rim=get_parent().get_node_or_null("RimLight")
    _build_rain()

func _process(delta:float) -> void:
    time_of_day=fmod(time_of_day+delta*cycle_speed,1.0)
    var sun_angle=time_of_day*TAU
    if moon:
        moon.rotation_degrees=Vector3(-42.0+sin(sun_angle)*30.0, -25.0+cos(sun_angle)*50.0, 0)
        moon.light_energy=0.22+0.55*maxf(0.0,cos(sun_angle))
    if rim:
        rim.light_energy=0.08+0.25*maxf(0.0,sin(sun_angle))
    if environment and environment.environment:
        var night=1.0-maxf(0.0,cos(sun_angle))
        environment.environment.ambient_light_energy=0.35+0.35*(1.0-night)
        environment.environment.fog_density=0.006+night*0.010

func _build_rain()->void:
    var rain:=GPUParticles3D.new()
    rain.amount=380
    rain.lifetime=1.5
    rain.visibility_aabb=AABB(Vector3(-30,0,-30),Vector3(60,22,60))
    var process:=ParticleProcessMaterial.new()
    process.direction=Vector3(0,-1,0)
    process.initial_velocity_min=11.0
    process.initial_velocity_max=16.0
    process.gravity=Vector3(0,-2.5,0)
    process.scale_min=0.035
    process.scale_max=0.07
    process.emission_shape=ParticleProcessMaterial.EMISSION_SHAPE_BOX
    process.emission_box_extents=Vector3(28,10,28)
    rain.process_material=process
    var mesh:=BoxMesh.new()
    mesh.size=Vector3(0.025,0.7,0.025)
    rain.draw_pass_1=mesh
    rain.position=Vector3(0,11,0)
    add_child(rain)
