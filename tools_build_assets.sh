#!/bin/bash
# NINJA - real asset reconstruction pipeline.
# Re-fetches licensed source assets (Git LFS public endpoint), extracts the
# Map.rar texture pack and converts every Blender/FBX source into runtime GLB.
# Idempotent: skips outputs that already exist as real binaries.
set -uo pipefail
cd "$(dirname "$0")"
BLENDER=${BLENDER:-/home/user/tools/blender-4.2.0-linux-x64/blender}
REPO="https://github.com/Ahmedbecett/Ninja-.git"

is_real() { [ -s "$1" ] && ! head -c 40 "$1" | grep -q "git-lfs.github.com"; }

lfs_get() { # oid size dest
  [ -s "$3" ] && ! head -c 40 "$3" | grep -q "git-lfs.github.com" && { echo "have $3"; return 0; }
  mkdir -p "$(dirname "$3")"
  resp=$(curl -s -X POST "$REPO/info/lfs/objects/batch" \
    -H "Accept: application/vnd.git-lfs+json" -H "Content-Type: application/vnd.git-lfs+json" \
    -d "{\"operation\":\"download\",\"transfers\":[\"basic\"],\"objects\":[{\"oid\":\"$1\",\"size\":$2}]}")
  href=$(python3 -c "import json,sys;print(json.load(sys.stdin)['objects'][0]['actions']['download']['href'])" <<<"$resp")
  [ -z "$href" ] && { echo "LFS FAIL $3"; return 1; }
  curl -sL "$href" -o "$3" && echo "fetched $3"
}

echo "== 1/5 LFS textures =="
python3 - <<'PY'
import os,re,json
lfs=[]
for dp,dn,fn in os.walk('.'):
    if '/.git' in dp: continue
    for f in fn:
        p=os.path.join(dp,f)
        if os.path.getsize(p)>5000: continue
        try: t=open(p,encoding='utf-8').read()
        except Exception: continue
        m=re.match(r"version https://git-lfs.github.com/spec/v1\noid sha256:([0-9a-f]+)\nsize (\d+)",t)
        if m: lfs.append((p,m.group(1),int(m.group(2))))
json.dump(lfs,open('/tmp/lfs_todo.json','w'))
print(len(lfs),"pointers")
PY
python3 - <<'PY'
import json,subprocess,os
REPO="https://github.com/Ahmedbecett/Ninja-.git"
for p,o,s in json.load(open('/tmp/lfs_todo.json')):
    if p.endswith(('22.blend','japanfuji.abc','ForestPack.7z','environment.unitypackage')): continue
    if os.path.getsize(p)>5000: continue
    resp=subprocess.run(['curl','-s','-X','POST',REPO+'/info/lfs/objects/batch',
      '-H','Accept: application/vnd.git-lfs+json','-H','Content-Type: application/vnd.git-lfs+json',
      '-d',json.dumps({"operation":"download","transfers":["basic"],"objects":[{"oid":o,"size":s}]})],
      capture_output=True,text=True).stdout
    try: href=json.loads(resp)['objects'][0]['actions']['download']['href']
    except Exception: print('LFS FAIL',p); continue
    subprocess.run(['curl','-sL',href,'-o',p])
    print('fetched',p)
PY

echo "== 2/5 Grass.glb source =="
lfs_get 5fc003e29d9914d07a211d82293f3260af1f4dffe07ab58f9a72ae48e90436fd 28146780 assets/world/grass/source/Grass.glb

echo "== 3/5 Map.rar textures =="
mkdir -p assets/world/textures
if ! is_real assets/world/textures/House_01.png && is_real Map.rar; then
  bsdtar -xf Map.rar -C assets/world/textures && for f in assets/world/textures/*; do mv "$f" "$(dirname "$f")/$(basename "$f" | tr ' ' '_')"; done
  echo extracted
fi

echo "== 4/5 character GLB =="
mkdir -p assets/imported/characters
for n in mikasanew2 Anime2; do
  if ! is_real "assets/imported/characters/$n.glb" && is_real "assets/characters/blender/$n.blend"; then
    $BLENDER --background "assets/characters/blender/$n.blend" --python-expr "import bpy; bpy.ops.export_scene.gltf(filepath='assets/imported/characters/$n.glb', export_format='GLB', export_animations=True, export_apply=True)" > /dev/null 2>&1 && echo "converted $n"
  fi
done

echo "== 5/5 grass pack + village map =="
if ! is_real assets/world/grass/Grass_pack.glb && is_real assets/world/grass/source/Grass.glb; then
  $BLENDER --background --python-expr "
import bpy
bpy.ops.import_scene.gltf(filepath='assets/world/grass/source/Grass.glb')
meshes=[ob for ob in bpy.data.objects if ob.type=='MESH']
skip={'Ground','Cube'}; seen=set(); keep=[]
for m in meshes:
    b=m.name.split('.')[0]
    if b in skip or b in seen: continue
    seen.add(b); keep.append(m)
bpy.ops.object.select_all(action='DESELECT')
for m in keep: m.select_set(True)
bpy.context.view_layer.objects.active=keep[0]
bpy.ops.export_scene.gltf(filepath='assets/world/grass/Grass_pack.glb', export_format='GLB', use_selection=True, export_apply=True, export_yup=True)
print('pack ok', len(keep))" 2>&1 | grep "pack ok"
fi
if ! is_real assets/imported/world/village_map.glb && is_real "Scene+game.FBX"; then
  mkdir -p assets/imported/world
  $BLENDER --background --python-expr "
import bpy, mathutils
bpy.ops.import_scene.fbx(filepath='Scene+game.FBX')
for name in ['Camera','Light','Cube']:
    ob=bpy.data.objects.get(name)
    if ob: bpy.data.objects.remove(ob,do_unlink=True)
ground=bpy.data.objects.get('Line002')
top=max((ground.matrix_world @ mathutils.Vector(c)).z for c in ground.bound_box)
xs=[];ys=[]
for ob in bpy.data.objects:
    if ob.type=='MESH':
        for c in ob.bound_box:
            v=ob.matrix_world @ mathutils.Vector(c); xs.append(v.x); ys.append(v.y)
cx=(min(xs)+max(xs))/2; cy=(min(ys)+max(ys))/2; factor=44.0/max(max(xs)-min(xs),max(ys)-min(ys))
root=bpy.data.objects.new('VillageMap',None); bpy.context.collection.objects.link(root)
for ob in list(bpy.data.objects):
    if ob.type=='MESH': ob.parent=root
root.scale=(factor,)*3; root.location=(-cx*factor,-cy*factor,-top*factor+0.03)
bpy.ops.object.select_all(action='DESELECT'); root.select_set(True)
for ob in root.children_recursive: ob.select_set(True)
bpy.context.view_layer.objects.active=root
bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
bpy.ops.export_scene.gltf(filepath='assets/imported/world/village_map.glb', export_format='GLB', export_apply=True, export_yup=True)
print('village ok')" 2>&1 | grep "village ok"
fi
mkdir -p assets/world/grass/source
printf '# Keep the 8k-node source GLB out of the Godot import pipeline.\n' > assets/world/grass/source/.gdignore
echo "== done =="
ls -la assets/world/grass assets/imported/characters assets/imported/world 2>/dev/null | grep -E "glb|:"
