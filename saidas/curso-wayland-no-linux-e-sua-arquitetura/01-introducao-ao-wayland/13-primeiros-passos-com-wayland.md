## Primeiros passos com Wayland

Agora que você já sabe o que é Wayland e como ele se diferencia do X11, é hora de colocar a mão na massa e iniciar sua primeira sessão Wayland. Vamos começar verificando se seu sistema já está preparado para rodar o Wayland e, em seguida, explorar como iniciar uma sessão básica.

### Verificando o suporte a Wayland

Antes de tudo, é importante garantir que seu sistema tenha suporte ao Wayland. Em distribuições modernas como Ubuntu, Fedora e Arch Linux, o Wayland já vem habilitado por padrão, mas é sempre bom confirmar.

Para verificar se o Wayland está disponível no seu sistema, execute o seguinte comando no terminal:

```bash
ls /usr/share/wayland-sessions/
```

Se você vir arquivos como `gnome-wayland.desktop`, `kde-plasma-wayland.desktop`, ou algo similar, isso significa que o Wayland está instalado e pronto para uso. Se a lista estiver vazia, você precisará instalar os pacotes necessários. Em distribuições baseadas em Debian/Ubuntu, você pode fazer isso com:

```bash
sudo apt install weston wayland-protocols libwayland-client
```

### Selecionando a sessão Wayland

Com o Wayland instalado, o próximo passo é selecionar uma sessão Wayland no gerenciador de login. Dependendo do ambiente de desktop que você está usando, o processo pode variar levemente.

1. **GNOME**: No gerenciador de login GDM, você verá um ícone de engrenagem ou um menu suspenso que permite escolher entre "GNOME" (X11) e "GNOME on Wayland". Selecione "GNOME on Wayland".

2. **KDE Plasma**: No SDDM (Simple Desktop Display Manager), após inserir suas credenciais, clique no ícone de engrenagem e selecione "Plasma (Wayland)".

3. **Outros ambientes**: Para ambientes como Sway, Weston ou outros compositors Wayland, você pode selecionar a sessão correspondente no gerenciador de login.

Depois de selecionar a sessão Wayland, faça o login normalmente.

### Confirmando a sessão Wayland

Uma vez logado, é importante confirmar que você está realmente em uma sessão Wayland. Para isso, abra o terminal e execute:

```bash
echo $XDG_SESSION_TYPE
```

Se a saída for `wayland`, você está na sessão correta. Caso contrário, verifique se selecionou a opção correta no gerenciador de login.

### Testando o Wayland com Weston

Se você está em um ambiente de desktop que ainda não migrou completamente para o Wayland, ou se simplesmente quer testar o Wayland sem se comprometer com uma sessão completa, você pode usar o Weston, o compositor de referência do Wayland.

Para iniciar o Weston, execute:

```bash
weston
```

Isso abrirá uma nova sessão Wayland em uma janela ou em um novo terminal virtual, dependendo da sua configuração. O Weston é uma ótima ferramenta para experimentar o Wayland sem afetar sua sessão principal.

### Lidando com aplicativos X11

Um dos desafios iniciais ao usar o Wayland é a compatibilidade com aplicativos antigos que ainda dependem do X11. Felizmente, o XWayland está aí para ajudar. Ele permite que aplicativos X11 rodem em uma sessão Wayland, quase sem problemas.

Para verificar se o XWayland está funcionando corretamente, abra um terminal e execute:

```bash
xclock
```

Se o relógio X11 aparecer normalmente, o XWayland está configurado corretamente. Caso contrário, você pode precisar instalar o XWayland manualmente:

```bash
sudo apt install xwayland
```

### Solucionando problemas comuns

Ao iniciar sua primeira sessão Wayland, você pode encontrar alguns problemas comuns. Aqui estão alguns deles e como resolvê-los:

1. **Aplicativos não abrem**: Alguns aplicativos podem não funcionar corretamente em Wayland devido à falta de suporte nativo. Verifique se há uma versão atualizada do aplicativo ou considere usar o XWayland.

2. **Problemas com drivers de vídeo**: Wayland depende de drivers gráficos modernos. Se você estiver usando uma GPU antiga ou drivers proprietários, pode enfrentar problemas. Verifique se seus drivers estão atualizados e suportam OpenGL ES 2.0 ou Vulkan.

3. **Configurações de múltiplos monitores**: Configurações avançadas de múltiplos monitores podem não funcionar tão bem em Wayland quanto em X11. Experimente diferentes compositors ou ajustes nas configurações gráficas.

### Exercício prático

Para consolidar o que aprendemos até agora, aqui está um exercício simples:

1. Inicie uma sessão Wayland usando o Weston.
2. Verifique se você está realmente em uma sessão Wayland com `echo $XDG_SESSION_TYPE`.
3. Abra um aplicativo X11, como `xeyes`, e observe como ele se comporta.
4. Tente mover o aplicativo X11 entre monitores e veja se há alguma diferença em relação ao X11.

### Solução do exercício

1. Para iniciar o Weston, execute `weston` no terminal.
2. Verifique a sessão com `echo $XDG_SESSION_TYPE`. A saída deve ser `wayland`.
3. Execute `xeyes` e observe que ele abre normalmente, graças ao XWayland.
4. Ao mover o aplicativo entre monitores, você pode notar algumas diferenças sutis, como a falta de suporte a configurações avançadas de múltiplos monitores em alguns compositors Wayland.

Agora você está pronto para explorar mais a fundo o mundo do Wayland e aproveitar suas vantagens em termos de desempenho e segurança.