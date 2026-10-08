# NINJA

A serious third-person 3D ninja action game built with Godot 4.4.1 for Android and desktop testing.

## Current gameplay foundation

- Third-person camera with touch swipe rotation.
- Mobile virtual joystick with real movement input.
- Light/heavy sword attacks and 3-step combo system.
- Dash with stamina cost and temporary invulnerability.
- Enemy AI with chase, attack, stagger and scaling difficulty.
- Dynamic enemy director that keeps encounters active.
- Shadow Commander boss encounter after progression milestones.
- Procedural night environment with rocks, trees, fog, lighting and collision.
- Character visuals built from modular 3D parts instead of placeholder capsules.
- Hit flashes and combat impact effects.
- XP, levels, coins, kills and combo tracking.
- Mission progression with rewards and skill points.
- Persistent save/load using user:// storage.
- Android export workflow with Godot 4.4.1 export templates.

## Build

The repository includes a GitHub Actions Android pipeline that validates the Godot project and exports a debug APK.

Godot's Android export requires installed export templates; Google Play distribution later requires a signed release build/AAB. See the official Godot Android export documentation.

## Direction

The project is being developed as a real game foundation, not a static mockup. The next production layers are content expansion, authored animation/assets, weapons, bosses, missions, progression depth, audio, optimization and release packaging.
