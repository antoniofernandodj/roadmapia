## Hot Reloading

Criar uma textura, compilar um shader ou carregar um modelo 3D são operações custosas que normalmente exigem reiniciar a aplicação a cada alteração. Hot reloading resolve esse problema recarregando assets em tempo real, mantendo o estado da aplicação. Vamos implementar um sistema básico para texturas e shaders em Rust com WGPU.

### Monitorando Arquivos

O primeiro passo é detectar quando um arquivo é modificado. Usaremos a crate `notify` para monitorar mudanças no sistema de arquivos:

```rust
use notify::{RecommendedWatcher, RecursiveMode, Watcher};
use std::path::Path;

fn setup_asset_watcher(asset_dir: &Path) -> notify::Result<RecommendedWatcher> {
    let mut watcher = notify::recommended_watcher(|res| {
        match res {
            Ok(event) => println!("Arquivo modificado: {:?}", event),
            Err(e) => eprintln!("Erro ao monitorar: {:?}", e),
        }
    })?;
    
    watcher.watch(asset_dir, RecursiveMode::Recursive)?;
    Ok(watcher)
}
```

Teste com um arquivo de exemplo (`textures/rock.png`):

```bash
$ touch textures/rock.png
Arquivo modificado: Notice(Modify(Data(Any))) # Saída esperada
```

### Recarregando Texturas

Para recarregar texturas, precisamos:
1. Manter uma referência ao `wgpu::Device`
2. Recriar a textura quando o arquivo mudar
3. Atualizar os bind groups que a referenciam

```rust
struct TextureHotReload {
    path: PathBuf,
    texture: wgpu::Texture,
    bind_group: wgpu::BindGroup,
}

impl TextureHotReload {
    async fn new(device: &wgpu::Device, path: impl AsRef<Path>) -> Self {
        let texture = load_texture(device, path.as_ref()).await;
        let bind_group = create_bind_group(device, &texture);
        
        Self { path: path.as_ref().to_owned(), texture, bind_group }
    }

    async fn reload(&mut self, device: &wgpu::Device) -> Result<(), anyhow::Error> {
        let new_texture = load_texture(device, &self.path).await;
        self.texture = new_texture;
        self.bind_group = create_bind_group(device, &self.texture);
        Ok(())
    }
}
```

Erro comum: esquecer de recriar o bind group após atualizar a textura. O WGPU não atualiza referências automaticamente:

```rust
// ERRADO: apenas atualiza a textura, bind group continua referenciando a versão antiga
texture.reload(device).await;
render_pass.set_bind_group(0, &texture.bind_group, &[]); // Usa textura obsoleta
```

### Shaders em Tempo Real

Para shaders, o processo é similar mas requer recompilação:

```rust
struct HotShader {
    path: PathBuf,
    module: wgpu::ShaderModule,
    last_modified: std::time::SystemTime,
}

impl HotShader {
    fn new(device: &wgpu::Device, path: impl AsRef<Path>) -> Self {
        let source = std::fs::read_to_string(path.as_ref()).unwrap();
        let module = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: None,
            source: wgpu::ShaderSource::Wgsl(source.into()),
        });
        
        Self {
            path: path.as_ref().to_owned(),
            module,
            last_modified: std::fs::metadata(path.as_ref()).unwrap().modified().unwrap(),
        }
    }

    fn check_reload(&mut self, device: &wgpu::Device) -> bool {
        let modified = std::fs::metadata(&self.path).unwrap().modified().unwrap();
        if modified > self.last_modified {
            let source = std::fs::read_to_string(&self.path).unwrap();
            self.module = device.create_shader_module(wgpu::ShaderModuleDescriptor {
                label: None,
                source: wgpu::ShaderSource::Wgsl(source.into()),
            });
            self.last_modified = modified;
            true
        } else {
            false
        }
    }
}
```

Problema frequente: erros de sintaxe no shader quebram o recarregamento. Adicione tratamento de erros:

```rust
fn check_reload(&mut self, device: &wgpu::Device) -> Result<bool, String> {
    let modified = std::fs::metadata(&self.path).map_err(|e| e.to_string())?.modified().map_err(|e| e.to_string())?;
    if modified > self.last_modified {
        let source = std::fs::read_to_string(&self.path).map_err(|e| e.to_string())?;
        
        // Validação antecipada (WGPU só valida na criação do pipeline)
        if let Err(e) = naga::front::wgsl::parse_str(&source) {
            return Err(format!("Erro no shader {}: {}", self.path.display(), e));
        }
        
        self.module = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: None,
            source: wgpu::ShaderSource::Wgsl(source.into()),
        });
        self.last_modified = modified;
        Ok(true)
    } else {
        Ok(false)
    }
}
```

### Integração com o Loop Principal

Combine tudo no loop de renderização:

```rust
let mut textures = HashMap::new();
textures.insert("rock", TextureHotReload::new(&device, "textures/rock.png").await);

let mut shaders = HashMap::new();
shaders.insert("main", HotShader::new(&device, "shaders/main.wgsl"));

event_loop.run(move |event, _, control_flow| {
    match event {
        Event::MainEventsCleared => {
            // Verifica atualizações a cada frame
            for texture in textures.values_mut() {
                if let Err(e) = texture.reload(&device) {
                    eprintln!("Falha ao recarregar textura: {}", e);
                }
            }
            
            for shader in shaders.values_mut() {
                if let Ok(true) = shader.check_reload(&device) {
                    println!("Shader recarregado: {}", shader.path.display());
                    // Precisa reconstruir o pipeline aqui
                }
            }
            
            // Renderização normal continua...
        }
        _ => (),
    }
});
```

### Exercício: Hot Reload para Modelos 3D

Implemente um sistema de hot reload para modelos 3D no formato `.obj`:
1. Monitore a pasta `models/`
2. Recarregue o modelo quando modificado
3. Atualize os vertex buffers

**Solução:**

```rust
struct ModelHotReload {
    path: PathBuf,
    vertex_buffer: wgpu::Buffer,
    index_buffer: wgpu::Buffer,
    last_modified: SystemTime,
}

impl ModelHotReload {
    async fn new(device: &wgpu::Device, path: impl AsRef<Path>) -> Self {
        let (vertex_buffer, index_buffer) = load_model(device, path.as_ref()).await;
        Self {
            path: path.as_ref().to_owned(),
            vertex_buffer,
            index_buffer,
            last_modified: std::fs::metadata(path.as_ref()).unwrap().modified().unwrap(),
        }
    }

    async fn reload(&mut self, device: &wgpu::Device) -> Result<(), anyhow::Error> {
        let modified = std::fs::metadata(&self.path)?.modified()?;
        if modified > self.last_modified {
            let (new_vertex, new_index) = load_model(device, &self.path).await;
            self.vertex_buffer = new_vertex;
            self.index_buffer = new_index;
            self.last_modified = modified;
        }
        Ok(())
    }
}

async fn load_model(device: &wgpu::Device, path: &Path) -> (wgpu::Buffer, wgpu::Buffer) {
    let obj = tobj::load_obj(path, true).unwrap();
    // Conversão para vértices WGPU...
}
```