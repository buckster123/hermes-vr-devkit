# Performance Budgets

Hard targets for maintaining 90 FPS on Quest 3/3S.

## Frame Budget

| Target | Budget | Notes |
|--------|--------|-------|
| Frame time | 11.1 ms | At 90 Hz |
| CPU time | < 5 ms | Leave headroom for tracking, audio, OS |
| GPU time | < 6 ms | Mobile GPU is the typical bottleneck |

## Rendering Budgets

| Metric | Target | Enforcement |
|--------|--------|-------------|
| Draw calls | < 100 per eye | ~200 total; merge static meshes |
| Tris per frame | < 500k total | LOD groups, impostors |
| Texture memory | < 1 GB | Compress to ETC2/ASTC, use mipmaps |
| Material variants | < 50 unique | Share ShaderMaterials, vary uniforms |
| Physics bodies | < 100 active | Use Area3D for triggers |
| Bones per vertex | < 4 | Limit skinning complexity |

## Texture Guidelines

| Texture Type | Resolution | Format | Mipmaps |
|--------------|------------|--------|---------|
| Diffuse / Albedo | 1024x1024 max | ETC2_RGBA | Yes |
| Normal map | 512x512 max | ETC2_RGB | Yes |
| Emissive | 256x256 | ETC2_RGB | No |
| Lightmap | 2048x2048 | RGB8 | Yes |

## gltfpack Optimization Levels

| Object Distance | Simplification | gltfpack Flag |
|-----------------|----------------|---------------|
| < 2 m (near) | 90-100% | `-si 0.9` or omit |
| 2-10 m (mid) | 70-80% | `-si 0.8` |
| > 10 m (far) | 40-50% | `-si 0.5` |

## LOD Strategy

```gdscript
@export var lod_distances: Array[float] = [5.0, 15.0, 30.0]
@export var lod_meshes: Array[Mesh] = []

func _process(delta: float) -> void:
    var dist := global_position.distance_to(get_viewport().get_camera_3d().global_position)
    for i in range(lod_distances.size()):
        if dist < lod_distances[i]:
            $MeshInstance3D.mesh = lod_meshes[i]
            return
    visible = false
```

## Material Adjustments for Mobile Renderer

```gdscript
var mat: StandardMaterial3D = mesh.material_override
mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
mat.roughness = 0.8
mat.metallic = 0.0
```

## Mobile Renderer Limitations

| Feature | Available? | Alternative |
|---------|-----------|-------------|
| Glow / Bloom | Yes | Use sparingly |
| SSAO | **No** | Bake AO to textures |
| Real-time GI | **No** | Bake lightmaps |
| SSR | **No** | Use planar reflections or baked |
| SDFGI | **No** | Bake lighting |
