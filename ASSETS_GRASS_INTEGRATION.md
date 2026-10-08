# NINJA — Grass.glb integration

The project now contains a runtime integration for the supplied real 3D grass asset.

Required asset path:

assets/world/grass/Grass.glb

The integration script is scripts/grass_asset_integration.gd.

It loads the real GLB only when present, selects vegetation meshes by source names, keeps a bounded number of instances for Android performance, shares imported mesh/material resources, randomizes placement, and falls back to the existing procedural vegetation when the binary is absent.

Grass.mtl and Grass.abc are source/export files and are not required by Godot at runtime. textures.rar is also not required when using the self-contained GLB because the supplied GLB already contains embedded image resources.

The supplied GLB has a large scene hierarchy, so NINJA does not display the complete hierarchy. It selects a bounded set of vegetation meshes for gameplay.

Important: the 28 MB Grass.glb binary cannot safely be inserted through the repository's normal GitHub text-file API. The code integration is committed separately; the original binary must be uploaded to assets/world/grass/Grass.glb using a binary-capable Git/LFS upload before the real grass appears in the Android build.