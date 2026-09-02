## Integração com sistemas de janelas existentes

Quando um sistema operacional migra para o Wayland, surge um problema prático: como executar aplicações escritas para X11 no novo ambiente? A solução vem do **XWayland**, um servidor X11 que roda como cliente do compositor Wayland. Vejamos como isso funciona na prática:

### O que acontece quando um app X11 é executado

1. O compositor Wayland (como Weston ou Mutter) inicia o XWayland como um cliente especial
2. XWayland cria um socket X11 virtual em `/tmp/.X11-unix/X1` (normalmente)
3. Quando você executa um app X11 como `xterm`, ele se conecta ao XWayland
4. XWayland converte os comandos X11 em protocolo Wayland

```c
// Exemplo de como o XWayland é iniciado (simplificado)
int main() {
    // O compositor Wayland cria uma instância XWayland
    struct wl_client *xwayland_client = wl_client_create(display, wl_resource);
    
    // XWayland inicia seu próprio socket X11
    xwayland_init_socket("/tmp/.X11-unix/X1");
    
    // Processa requisições de clientes X11
    while (1) {
        xwayland_handle_events();
    }
}
```

O erro mais comum ocorre quando o XWayland não está configurado corretamente:

```
Error: Cannot open display: :0
```

A solução é verificar se:
1. O pacote `xwayland` está instalado
2. O compositor está configurado para lançar o XWayland (na maioria das distros modernas isso é padrão)

### Diferenças na renderização

Enquanto aplicativos nativos do Wayland desenham diretamente em buffers compartilhados:

```mermaid
graph LR
    A[App Wayland] -->|wl_surface| B[Compositor]
    B --> C[Tela]
```

Aplicativos X11 passam por uma camada adicional:

```mermaid
graph LR
    D[App X11] -->|X11 Protocol| E[XWayland]
    E -->|wl_surface| F[Compositor]
    F --> G[Tela]
```

Esta tradução tem custos:
- Latência adicional (10-20ms em média)
- Possíveis problemas de sincronização vertical (screen tearing)
- Limitações na integração com recursos modernos como HDR

### Configurando o XWayland

Na maioria dos compositors, o XWayland é ativado por padrão. Mas você pode forçar seu comportamento com variáveis de ambiente:

```bash
# Desativar completamente o XWayland
export WAYLAND_DISABLE_XWAYLAND=1

# Forçar aplicativos GTK a usar Wayland nativo
export GDK_BACKEND=wayland

# Forçar aplicativos Qt a usar Wayland
export QT_QPA_PLATFORM=wayland
```

Um teste prático para verificar a integração:

```bash
# Verificar se o XWayland está ativo
xeyes &  # Aplicativo X11 clássico
# Se os olhos seguirem o cursor, o XWayland está funcionando

# Verificar conexão
ls -l /tmp/.X11-unix/  # Deve mostrar o socket XWayland
```

### Exercício: Medindo o impacto do XWayland

1. Instale o `x11-apps` para ter aplicativos de teste:
   ```bash
   sudo apt install x11-apps
   ```

2. Execute um aplicativo nativo e um via XWayland, medindo o tempo de inicialização:
   ```bash
   time weston-terminal  # Nativo
   time xterm           # Via XWayland
   ```

3. Compare os resultados. Em um sistema moderno, você deve ver algo como:
   ```
   # Nativo
   real    0m0.012s
   
   # XWayland
   real    0m0.034s
   ```

**Solução comentada:** A diferença de tempo vem da sobrecarga adicional da camada de tradução X11→Wayland. Enquanto aplicativos nativos conversam diretamente com o compositor, os apps X11 precisam passar pelo XWayland, que:
1. Traduz chamadas X11 para Wayland
2. Gerencia recursos como fonts e pixmaps
3. Mantém compatibilidade com recursos obsoletos do X11