# Configurando Wayland em Linux

Se você está lendo este capítulo, já deve ter experimentado os limites do X11: travamentos inexplicáveis ao conectar um segundo monitor, latência perceptível em aplicações gráficas modernas ou a frustração de configurar escalas HiDPI diferentes para cada tela. O Wayland surge não como uma evolução, mas como uma reimaginação completa de como o Linux lida com gráficos, desde os drivers até os pixels na tela — e é essa arquitetura que o torna ao mesmo tempo mais eficiente e mais desafiador para configurar.

Antes de mergulhar nas configurações, você precisava entender os fundamentos da arquitetura Wayland (cobertos nos capítulos anteriores): a relação entre clientes, compositors e protocolos, a ausência de um servidor central como o Xorg, e por que o acesso direto a dispositivos (DRM/KMS) exige permissões específicas. Agora, colocaremos isso em prática. 

O capítulo começa com os pré-requisitos — um checklist técnico que evita horas de troubleshooting. Por exemplo, tentar iniciar uma sessão Wayland sem estar no grupo `video` resulta em um erro silencioso: o compositor simplesmente não consegue acessar a placa gráfica. Depois, avançamos para a instalação em Ubuntu e Debian, onde você verá como a mesma tarefa tem nuances distintas: no Ubuntu, o GDM já vem pré-configurado para tentar sessões Wayland, enquanto no Debian estável, você precisará negociar com pacotes mais antigos e configurações manuais.

A configuração do display manager é onde muitos tropeçam. Um erro comum é modificar o arquivo errado no GDM ou esquecer de atualizar o initramfs após alterar parâmetros do kernel — detalhes que fazem a diferença entre um ambiente estável e um que falha silenciosamente na inicialização. 

Com o ambiente básico funcionando, exploramos compositors específicos (GNOME, KDE Plasma, Sway), cada um com suas armadilhas: o GNOME exige configurações via D-Bus, o KDE precisa de variáveis de ambiente para aplicações Qt/GTK mistas, e o Sway — minimalista por natureza — demanda um arquivo de configuração declarativo onde até o gerenciamento de energia é manual.

Ao final deste capítulo, você será capaz de:
- Diagnosticar e corrigir falhas de inicialização do Wayland relacionadas a drivers e permissões
- Configurar sessões Wayland em diferentes display managers (GDM, LightDM)
- Adaptar compositors para cenários reais: múltiplos monitores com escalas diferentes, otimização de desempenho em hardware específico
- Escolher o compositor adequado para seu fluxo de trabalho, entendendo as compensações de cada um

---

## Neste capítulo

1. [Pré-requisitos para instalação do Wayland](01-pre-requisitos-para-instalacao-do-waylan.md)
2. [Instalando Wayland em Ubuntu](02-instalando-wayland-em-ubuntu.md)
3. [Instalando Wayland em Debian](03-instalando-wayland-em-debian.md)
4. [Configurando o display manager para Wayland](04-configurando-o-display-manager-para-wayl.md)
5. [Escolhendo um compositor Wayland](05-escolhendo-um-compositor-wayland.md)
6. [Configurando o GNOME com Wayland](06-configurando-o-gnome-com-wayland.md)
7. [Configurando o KDE Plasma com Wayland](07-configurando-o-kde-plasma-com-wayland.md)
8. [Configurando o Sway como compositor](08-configurando-o-sway-como-compositor.md)
9. [Configurações básicas do ambiente Wayland](09-configuracoes-basicas-do-ambiente-waylan.md)
10. [Configurações avançadas do ambiente Wayland](10-configuracoes-avancadas-do-ambiente-wayl.md)
11. [Gerenciando sessões Wayland](11-gerenciando-sessoes-wayland.md)
12. [Autenticação e segurança em sessões Wayland](12-autenticacao-e-seguranca-em-sessoes-wayl.md)
13. [Configurando múltiplos monitores em Wayland](13-configurando-multiplos-monitores-em-wayl.md)
14. [Otimizando desempenho em Wayland](14-otimizando-desempenho-em-wayland.md)
15. [Monitorando recursos em Wayland](15-monitorando-recursos-em-wayland.md)
16. [Exercícios práticos: configurando Wayland](16-exercicios-praticos-configurando-wayland.md)
17. [Solução de problemas de configuração](17-solucao-de-problemas-de-configuracao.md)
18. [Ferramentas para diagnóstico de configuração](18-ferramentas-para-diagnostico-de-configur.md)
19. [Melhores práticas para configuração](19-melhores-praticas-para-configuracao.md)
20. [Recapitulação e próximos passos](20-recapitulacao-e-proximos-passos.md)

[↑ Sumário da obra](../README.md)