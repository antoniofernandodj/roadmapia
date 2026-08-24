## Serialização de Dados Gráficos

Quando trabalhamos com gráficos, frequentemente precisamos armazenar ou transmitir dados como malhas 3D, texturas ou configurações de materiais. O Rust oferece várias abordagens eficientes para serialização, cada uma com vantagens específicas para cenários gráficos.

Vamos começar com um caso concreto: uma malha 3D simples com vértices e índices:

```rust
#[derive(Debug)]
struct Mesh {
    vertices: Vec<[f32; 3]>, // Posições XYZ
    normals: Vec<[f32; 3]>, // Normais
    indices: Vec<u32>,      // Índices dos triângulos
}
```

### Serialização Binária com `bincode`

Para eficiência em tempo de execução, `bincode` é excelente por sua velocidade e tamanho compacto:

```rust
use bincode::{serialize, deserialize};

let mesh = Mesh {
    vertices: vec![[0.0, 0.0, 0.0], [1.0, 0.0, 0.0], [0.0, 1.0, 0.0]],
    normals: vec![[0.0, 0.0, 1.0]; 3],
    indices: vec![0, 1, 2],
};

let serialized = serialize(&mesh).unwrap();
println!("Tamanho serializado: {} bytes", serialized.len()); // 112 bytes

let deserialized: Mesh = deserialize(&serialized).unwrap();
assert_eq!(deserialized.vertices.len(), 3);
```

Erro comum ao trabalhar com `bincode`:
```rust
#[derive(Debug)]
struct Texture {
    pixels: Vec<[u8; 4]>,
    size: (u32, u32),
}

let texture = Texture {
    pixels: vec![[255, 0, 0, 255]; 1024*1024],
    size: (1024, 1024),
};

// Erro: the trait `bincode::internal::ser::Serialize` is not implemented for `(u32, u32)`
let serialized = serialize(&texture).unwrap();
```

A correção requer derivar ou implementar `Serialize`/`Deserialize` para todos os tipos:

```rust
#[derive(Debug, Serialize, Deserialize)]
struct Texture {
    pixels: Vec<[u8; 4]>,
    size: (u32, u32),
}
```

### JSON para Interoperabilidade

Quando a legibilidade ou interoperabilidade são importantes, `serde_json` é a escolha ideal:

```rust
use serde_json::{json, to_string_pretty};

let material = json!({
    "name": "rusted_iron",
    "albedo": [0.8, 0.3, 0.1],
    "roughness": 0.7,
    "metallic": true,
});

println!("{}", to_string_pretty(&material).unwrap());
```

Saída:
```json
{
  "albedo": [
    0.8,
    0.3,
    0.1
  ],
  "metallic": true,
  "name": "rusted_iron",
  "roughness": 0.7
}
```

### Formatos Especializados para Gráficos

Para dados gráficos específicos, `gltf` oferece suporte nativo:

```rust
use gltf::Gltf;

let gltf_data = include_bytes!("../assets/model.glb");
let gltf = Gltf::from_slice(gltf_data).unwrap();

for mesh in gltf.meshes() {
    println!("Mesh: {}", mesh.name().unwrap_or("unnamed"));
    for primitive in mesh.primitives() {
        println!(" - Primitive with {} vertices", primitive.vertices().count());
    }
}
```

### Zero-copy com `rkyv`

Para máxima performance em tempo de execução, `rkyv` permite desserialização sem cópia:

```rust
use rkyv::{Archive, Serialize, Deserialize};

#[derive(Archive, Serialize, Deserialize, Debug)]
#[archive(compare(PartialEq), check_bytes)]
struct Sprite {
    position: [f32; 2],
    size: [f32; 2],
    uv_rect: [f32; 4],
}

let sprite = Sprite {
    position: [10.0, 20.0],
    size: [32.0, 32.0],
    uv_rect: [0.0, 0.0, 1.0, 1.0],
};

let bytes = rkyv::to_bytes::<_, 256>(&sprite).unwrap();
let archived = rkyv::check_archived_root::<Sprite>(&bytes[..]).unwrap();

// Acesso direto sem desserialização!
println!("Sprite size: {:?}", archived.size); // [32.0, 32.0]
```

### Exercício Prático

Implemente serialização para uma cena contendo múltiplas malhas e materiais usando `serde` com um formato à sua escolha. Compare o tamanho e tempo de serialização entre JSON, bincode e rkyv.

Solução comentada:
```rust
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize)]
struct Scene {
    meshes: Vec<Mesh>,
    materials: Vec<Material>,
}

#[derive(Serialize, Deserialize)]
struct Material {
    name: String,
    albedo: [f32; 3],
    // ... outros campos
}

// Implementação para JSON:
let scene_json = serde_json::to_string(&scene)?;

// Implementação para bincode:
let scene_bin = bincode::serialize(&scene)?;

// Implementação para rkyv:
let scene_rkyv = rkyv::to_bytes::<_, 1024>(&scene)?;

// Comparação:
println!("JSON: {} bytes", scene_json.len());
println!("Bincode: {} bytes", scene_bin.len());
println!("Rkyv: {} bytes", scene_rkyv.len());
```