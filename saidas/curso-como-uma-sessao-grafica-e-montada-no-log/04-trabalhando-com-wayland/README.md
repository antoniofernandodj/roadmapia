# Trabalhando com Wayland

Quando você inicia uma sessão gráfica no Linux, o servidor gráfico é o componente central que gerencia a exibição de janelas, o tratamento de eventos de entrada (como teclado e mouse) e a comunicação entre aplicativos e o hardware gráfico. Tradicionalmente, o Xorg tem sido o padrão, mas seu design centralizado e complexo traz desafios de segurança e eficiência. O Wayland surge como uma alternativa moderna, eliminando a necessidade de um servidor gráfico centralizado e permitindo que aplicativos se comuniquem diretamente com o compositor, o que simplifica a arquitetura e melhora o isolamento entre processos.

Neste capítulo, exploraremos o Wayland desde sua arquitetura fundamental até configurações práticas em ambientes populares como GNOME, KDE e Sway. Você aprenderá como o Wayland difere do Xorg em termos de segurança, desempenho e compatibilidade, e como configurar e solucionar problemas em sessões gráficas baseadas no Wayland. 

Começamos com uma comparação detalhada entre as arquiteturas do Wayland e do Xorg, destacando por que o Wayland é mais seguro e eficiente, mas também como ele depende do XWayland para manter compatibilidade com aplicativos legados. Em seguida, exploramos os compositors Wayland mais comuns, como Mutter, KWin, Weston e Sway, entendendo suas características e diferenças.

Depois, mergulhamos em configurações práticas para o GNOME e o KDE no Wayland, incluindo como verificar a sessão ativa, habilitar o Wayland no GDM e SDDM, e resolver problemas comuns como a configuração de drivers NVIDIA e a substituição de arquivos `.xprofile` por alternativas modernas. Você também aprenderá a usar o Sway, um compositor i3-like para Wayland, e como ele replica funcionalidades populares do i3wm.

A compatibilidade com aplicativos X11 é um tópico crucial, e dedicamos uma seção inteira ao XWayland, explicando como ele funciona como uma ponte entre aplicativos legados e compositors Wayland, além de como configurar variáveis de ambiente para controlar o backend gráfico de aplicativos GTK e Qt.

Finalmente, abordamos questões de segurança, captura de tela e gravação de sessões no Wayland, destacando como o protocolo reforça a privacidade e o controle sobre permissões. O capítulo termina com orientações para alternar entre Xorg e Wayland e solucionar problemas comuns, como configuração de múltiplos monitores e permissões de captura de tela.

Ao final deste capítulo, você estará apto a configurar e personalizar sessões gráficas no Wayland, resolver problemas de compatibilidade e entender as vantagens e desafios dessa tecnologia moderna em relação ao Xorg.

---

## Neste capítulo

1. [Arquitetura do Wayland vs Xorg](01-arquitetura-do-wayland-vs-xorg.md)
2. [Compositors Wayland mais comuns](02-compositors-wayland-mais-comuns.md)
3. [Configurando o GNOME no Wayland](03-configurando-o-gnome-no-wayland.md)
4. [Configurando o KDE no Wayland](04-configurando-o-kde-no-wayland.md)
5. [Sway: um compositor i3-like para Wayland](05-sway-um-compositor-i3-like-para-wayland.md)
6. [Compatibilidade XWayland](06-compatibilidade-xwayland.md)
7. [Configurações de segurança no Wayland](07-configuracoes-de-seguranca-no-wayland.md)
8. [Gravação de tela e captura no Wayland](08-gravacao-de-tela-e-captura-no-wayland.md)
9. [Alternando entre Xorg e Wayland](09-alternando-entre-xorg-e-wayland.md)
10. [Solucionando problemas comuns no Wayland](10-solucionando-problemas-comuns-no-wayland.md)

[↑ Sumário da obra](../README.md)