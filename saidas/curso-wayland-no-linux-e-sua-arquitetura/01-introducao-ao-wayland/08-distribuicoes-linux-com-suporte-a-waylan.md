## Distribuições Linux com suporte a Wayland

O Wayland está presente em várias distribuições Linux modernas, embora o nível de suporte e integração possa variar. Abaixo estão algumas das principais distribuições que oferecem suporte nativo ao Wayland, seja como padrão ou como uma opção configurável.

### Fedora

A Fedora foi uma das primeiras distribuições a adotar o Wayland como padrão, começando com o Fedora 25 em 2016. A Fedora utiliza o GNOME como ambiente de desktop principal, que possui uma implementação robusta do Wayland. Para verificar se você está usando o Wayland no Fedora, execute:

```bash
echo $XDG_SESSION_TYPE
```

Se a saída for `wayland`, então você está em uma sessão Wayland.

### Ubuntu

O Ubuntu começou a oferecer suporte ao Wayland a partir da versão 17.10, mas o X11 continuou sendo o padrão até a versão 21.04, quando o Wayland se tornou o padrão para novos instaladores. No entanto, o Ubuntu ainda permite escolher entre Wayland e X11 no momento do login. Para alternar entre eles, basta selecionar a opção desejada no menu de sessão do GDM (GNOME Display Manager).

### Arch Linux

O Arch Linux, conhecido por sua filosofia de flexibilidade e personalização, oferece suporte ao Wayland através de vários ambientes de desktop, incluindo GNOME, KDE Plasma e Sway. No Arch, você precisa instalar manualmente o compositor Wayland de sua escolha. Por exemplo, para usar o Sway:

```bash
sudo pacman -S sway
```

### Debian

O Debian começou a incluir suporte ao Wayland a partir da versão 9 (Stretch), mas o X11 ainda é o padrão. No entanto, você pode facilmente habilitar o Wayland instalando um compositor como o Weston ou usando ambientes de desktop que suportam Wayland, como GNOME ou KDE Plasma.

### openSUSE

O openSUSE oferece suporte ao Wayland desde a versão Leap 42.2, com o GNOME e KDE Plasma como principais ambientes de desktop. O openSUSE Tumbleweed, uma versão rolling release, geralmente possui as últimas atualizações e melhorias para o suporte ao Wayland.

### Gentoo

O Gentoo, conhecido por sua flexibilidade e controle sobre o sistema, permite que os usuários configurem manualmente o Wayland. Você pode instalar compositors como Weston ou Sway e configurar seu ambiente de desktop para usar o Wayland.

### Outras Distribuições

Outras distribuições como Manjaro, Elementary OS e Pop!_OS também oferecem suporte ao Wayland, embora o grau de integração e facilidade de uso possa variar. Em geral, distribuições baseadas em Ubuntu ou Debian tendem a ter um suporte mais consistente devido à ampla adoção do GNOME e KDE Plasma.

### Verificando o Suporte ao Wayland

Para verificar se sua distribuição suporta Wayland, você pode usar o seguinte comando:

```bash
ls /usr/share/wayland-sessions/
```

Se o diretório existir e listar sessões disponíveis, então seu sistema suporta Wayland.

### Conclusão

O suporte ao Wayland está crescendo rapidamente entre as distribuições Linux, com muitas delas adotando-o como padrão ou oferecendo-o como uma opção configurável. Embora o X11 ainda seja amplamente utilizado, o Wayland representa o futuro dos sistemas gráficos no Linux, oferecendo melhor desempenho e segurança.