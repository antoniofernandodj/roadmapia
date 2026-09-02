## Comunidade e recursos para aprender Wayland

Quando você encontra um problema específico com Wayland - como um aplicativo que não abre ou um comportamento gráfico inesperado - o primeiro passo é verificar se já existe solução conhecida. A comunidade Wayland é ativa em vários canais:

1. **Lista de discussão oficial**: O canal primário para desenvolvedores é a lista wayland-devel@lists.freedesktop.org. Um erro comum é enviar perguntas básicas aqui - esta lista é focada em desenvolvimento do protocolo, não em suporte ao usuário final. Para problemas de configuração, prefira:

2. **Fóruns de distribuições**: Cada distro tem seu fórum principal:
   - Ubuntu: [https://ubuntuforums.org/](https://ubuntuforums.org/) (use a tag "Wayland")
   - Fedora: [https://discussion.fedoraproject.org/](https://discussion.fedoraproject.org/)
   - Arch: [https://bbs.archlinux.org/](https://bbs.archlinux.org/)

Exemplo de busca eficaz no fórum do Arch usando `grep` no terminal:
```bash
curl -s https://bbs.archlinux.org/viewtopic.php?id=123456 | grep -A 10 "cursor invisible"
```

3. **Documentação oficial**: O repositório [https://gitlab.freedesktop.org/wayland/wayland](https://gitlab.freedesktop.org/wayland/wayland) contém:
   - Protocolos core em `/protocol/`
   - Tutoriais em `/doc/`
   - Exemplos em `/tests/`

Para extrair a documentação dos protocolos instalados localmente:
```bash
wayland-scanner client-header /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml
```

4. **Canais IRC e Matrix**: 
   - `#wayland` no irc.libera.chat (ou via Matrix em #wayland:libera.chat)
   - `#sway` para usuários do compositor Sway
   - `#wlroots` para desenvolvimento de compositors

Ao perguntar nestes canais, inclua sempre:
- Saída de `echo $XDG_SESSION_TYPE`
- Versão do compositor (`weston --version` ou equivalente)
- Mensagem de erro exata

5. **Bug tracking**: Problemas específicos de implementação devem ser reportados no GitLab do projeto relevante:
   - Bugs no protocolo: [https://gitlab.freedesktop.org/wayland/wayland/-/issues](https://gitlab.freedesktop.org/wayland/wayland/-/issues)
   - Bugs no Weston: [https://gitlab.freedesktop.org/wayland/weston/-/issues](https://gitlab.freedesktop.org/wayland/weston/-/issues)

6. **Blogs técnicos**: Desenvolvedores ativos frequentemente publicam artigos detalhados:
   - Blog de Drew DeVault (Sway): [https://drewdevault.com/](https://drewdevault.com/)
   - Blog de Daniel Stone (ex-mantenedor do Wayland): [https://blog.ffwll.ch/](https://blog.ffwll.ch/)
   - Wiki do Gentoo sobre Wayland: [https://wiki.gentoo.org/wiki/Wayland](https://wiki.gentoo.org/wiki/Wayland)

7. **Stack Overflow**: Use as tags [wayland] e [xwayland] para questões de programação. Exemplo de pergunta bem formulada:

> "Meu aplicativo GTK3 não exibe menus popup sob Wayland (funciona no X11). Já verifiquei:  
> - GDK_BACKEND=wayland está definido  
> - weston-info mostra xdg_shell v6 suportado  
> Mensagem de erro: 'gtk_menu_popup_at_widget: assertion 'GTK_IS_MENU(menu)' failed'"

**Exercício**: Encontre a especificação atual do protocolo xdg-shell e identifique quais versões são suportadas pelo seu compositor. Poste os resultados no formato:

```bash
$ weston-info | grep -A 5 xdg_shell
interface: 'xdg_shell', version: 6
```

**Solução**:
1. Instale `weston` se não tiver: `sudo apt install weston`
2. Inicie o Weston em outro VT: `weston --tty=2`
3. Execute: `weston-info | grep -A 5 xdg_shell`
4. Compare com a especificação em `/usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml`

A saída mostrará algo como:
```
interface: 'xdg_shell', version: 6
```
Indicando que seu compositor suporta até a versão 6 do protocolo xdg-shell.