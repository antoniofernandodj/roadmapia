# Trabalhando com Xorg

Você liga o computador, digita sua senha na tela de login, e... nada. O sistema não inicia a interface gráfica, ou ela aparece com resoluções estranhas, teclado configurado errado, ou rodando com desempenho horrível. O problema sempre está no mesmo lugar: o servidor gráfico Xorg, que faz a ponte entre seu hardware e as aplicações visuais.

Antes de chegar aqui, você já aprendeu como os gerenciadores de login como LightDM e GDM preparam o terreno para a sessão gráfica. Agora é hora de entender o motor principal - o Xorg - que transforma comandos abstratos em pixels na tela. Sem essa base, qualquer tentativa de personalização será como apertar botões aleatórios: pode até funcionar, mas você não saberia porquê.

Este capítulo começa desmontando o Xorg peça por peça, mostrando como ele coordena drivers de vídeo, monitores e dispositivos de entrada. Você verá como um erro simples (como esquecer a variável `DISPLAY`) impede totalmente uma aplicação gráfica de funcionar, e como corrigi-lo na prática. 

Depois, mergulhamos nos arquivos de configuração - não apenas o tradicional `xorg.conf`, mas principalmente os fragmentos modulares em `/etc/X11/xorg.conf.d/` que as distribuições modernas preferem. Você aprenderá a ler o log do Xorg como um detetive, identificando por que aquele monitor 4K não está funcionando na resolução esperada.

A metade do capítulo é pura mão na massa: configurar múltiplos monitores com `xrandr`, ajustar teclado ABNT2, calibrar a aceleração do mouse para jogos, e até forçar o VSync para eliminar tearing gráfico. Tudo com exemplos reais que você pode testar imediatamente.

Quando chegar na seção de drivers proprietários (NVIDIA, AMD), você já terá base para entender por que alguns requerem configurações especiais no Xorg, e como diagnosticar conflitos. O mesmo vale para sessões multiusuário - agora você saberá por que cada usuário precisa de seu próprio `DISPLAY :X`.

Ao final deste capítulo, você será capaz de diagnosticar e consertar sozinho problemas como:
- Tela preta após o login
- Teclado escrevendo símbolos errados
- Mouse absurdamente rápido ou lento
- Janelas "rasgando" durante movimentos
- Falhas ao conectar um projetor
- Sessões gráficas travando aleatoriamente

Tudo isso porque entenderá não apenas o "como", mas o "porquê" de cada configuração do Xorg - desde o arquivo de configuração até o driver de vídeo em uso.

---

## Neste capítulo

1. [Entendendo a arquitetura do Xorg](01-entendendo-a-arquitetura-do-xorg.md)
2. [Arquivos de configuração do Xorg](02-arquivos-de-configuracao-do-xorg.md)
3. [Configurando monitores e resoluções](03-configurando-monitores-e-resolucoes.md)
4. [Trabalhando com drivers de vídeo](04-trabalhando-com-drivers-de-video.md)
5. [Configurando teclado e mouse](05-configurando-teclado-e-mouse.md)
6. [Configurações de aceleração gráfica](06-configuracoes-de-aceleracao-grafica.md)
7. [Xorg.conf: opções avançadas](07-xorg-conf-opcoes-avancadas.md)
8. [Sessões multiusuário com Xorg](08-sessoes-multiusuario-com-xorg.md)
9. [Alternando entre versões do Xorg](09-alternando-entre-versoes-do-xorg.md)
10. [Solucionando problemas comuns no Xorg](10-solucionando-problemas-comuns-no-xorg.md)

[↑ Sumário da obra](../README.md)