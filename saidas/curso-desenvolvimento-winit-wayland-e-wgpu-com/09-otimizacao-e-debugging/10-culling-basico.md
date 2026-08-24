## Culling Básico

Renderizar objetos que estão fora da visão da câmera é um desperdício de recursos GPU. O frustum culling resolve isso descartando geometria que está completamente fora do volume visível (o frustum) antes mesmo de enviá-la para renderização. Vamos implementar uma versão simples que funciona com objetos individuais, sem hierarquias espaciais complexas.

Primeiro, precisamos representar o frustum da câmera. Em 3D, ele é uma pirâmide truncada definida por seis planos (near, far, left, right, top, bottom):

```rust
#[derive(Debug)]
struct Frustum {
    planes: [Plane; 6],
}

impl Frustum {
    fn from_matrix(matrix: &Mat4) -> Self {
        let planes = [
            // Left
            Plane::from_coefficients(matrix.row(3) + matrix.row(0)),
            // Right
            Plane::from_coefficients(matrix.row(3) - matrix.row(0)),
            // Bottom
            Plane::from_coefficients(matrix.row(3) + matrix.row(1)),
            // Top
            Plane::from_coefficients(matrix.row(3) - matrix.row(1)),
            // Near
            Plane::from_coefficients(matrix.row(3) + matrix.row(2)),
            // Far
            Plane::from_coefficients(matrix.row(3) - matrix.row(2)),
        ];
        Frustum { planes }
    }
}
```

O erro clássico aqui é esquecer de normalizar os planos. Se você não fizer isso, a distância do ponto ao plano será calculada incorretamente:

```rust
struct Plane {
    normal: Vec3,
    distance: f32,
}

impl Plane {
    fn from_coefficients(coeff: Vec4) -> Self {
        let normal = coeff.xyz();
        let length = normal.length();
        Plane {
            normal: normal / length,
            distance: coeff.w / length,
        }
    }
}
```

Para testar se um objeto está dentro do frustum, verificamos sua bounding sphere contra todos os planos:

```rust
impl Frustum {
    fn contains_sphere(&self, center: Vec3, radius: f32) -> bool {
        self.planes.iter().all(|plane| {
            let distance = plane.normal.dot(center) + plane.distance;
            distance >= -radius
        })
    }
}
```

Agora, no loop de renderização, antes de enviar cada objeto para a GPU, fazemos o teste:

```rust
let view_proj = camera.projection() * camera.view();
let frustum = Frustum::from_matrix(&view_proj);

for object in &scene.objects {
    if frustum.contains_sphere(object.bounds.center, object.bounds.radius) {
        render_object(object);
    }
}
```

Um erro comum é esquecer de atualizar o frustum quando a câmera se move. Se você ver objetos desaparecendo aleatoriamente, verifique se está recalculando o frustum a cada frame:

```rust
// ERRADO: frustum calculado apenas uma vez
let frustum = Frustum::from_matrix(&camera.projection() * camera.view());

// CORRETO: recalcular a cada frame
fn update(&mut self) {
    self.frustum = Frustum::from_matrix(&self.camera.projection() * self.camera.view());
}
```

Para debug, podemos visualizar o frustum e as bounding spheres:

```rust
// Debug draw frustum planes
for plane in &frustum.planes {
    draw_plane(plane.normal, plane.distance, Color::RED);
}

// Debug draw object bounds
for object in &scene.objects {
    draw_sphere(object.bounds.center, object.bounds.radius, Color::GREEN);
}
```

Exercício: Implemente um sistema que renderiza 10.000 cubos espalhados aleatoriamente em um grid 3D, com frustum culling. Meça o FPS com e sem culling para ver a diferença.

Solução comentada:

```rust
fn setup_scene() -> Scene {
    let mut scene = Scene::new();
    let mut rng = rand::thread_rng();

    for x in -15..15 {
        for y in -15..15 {
            for z in -15..15 {
                let position = Vec3::new(
                    x as f32 * 2.0,
                    y as f32 * 2.0,
                    z as f32 * 2.0,
                );
                scene.add_object(Object {
                    bounds: BoundingSphere {
                        center: position,
                        radius: 1.0,
                    },
                    // ... outros campos do objeto
                });
            }
        }
    }
    scene
}

fn main() {
    let scene = setup_scene();
    let mut camera = Camera::new();
    let mut renderer = Renderer::new();

    loop {
        camera.update();
        let frustum = Frustum::from_matrix(&camera.view_proj());

        let mut visible_objects = 0;
        for object in &scene.objects {
            if frustum.contains_sphere(object.bounds.center, object.bounds.radius) {
                renderer.draw(object);
                visible_objects += 1;
            }
        }

        println!("Objetos visíveis: {}/{}", visible_objects, scene.objects.len());
    }
}
```