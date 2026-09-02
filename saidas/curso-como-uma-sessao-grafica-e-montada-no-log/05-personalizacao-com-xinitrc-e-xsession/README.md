# Personalização com .xinitrc e .xsession

Você já tentou iniciar sua sessão gráfica no Linux e descobriu que o teclado está no layout errado, o papel de parede não carrega ou os monitores estão espelhados quando deveriam ser estendidos? Esses problemas — e muitos outros — têm solução nos arquivos `.xinitrc` e `.xsession`, que controlam como seu ambiente gráfico inicia.

Antes deste capítulo, você aprendeu sobre gerenciadores de login (como LightDM ou GDM) e a diferença entre iniciar uma sessão com `startx` versus um login gráfico. Agora, vamos usar esses conceitos para dominar a personalização fina da sua sessão. O segredo está em dois arquivos:

1. `.xinitrc` é seu aliado quando você inicia o Xorg manualmente com `startx` — ele decide qual ambiente gráfico rodar e quais configurações aplicar antes disso. Esquecer um `&` aqui pode travar sua inicialização.

2. `.xsession` entra em ação quando você usa um gerenciador de login gráfico. Ele tem uma sintaxe mais flexível, mas exige atenção às variáveis de ambiente que programas como GNOME ou KDE precisam.

No decorrer do capítulo, você vai desde configurar um teclado ABNT2 até gerenciar monitores com `xrandr`, tudo enquanto evita os erros mais comuns:

- A tela preta que acontece quando você esquece `exec` no `.xinitrc`
- O misterioso "Cannot open display" ao executar comandos fora do contexto X
- Temas GTK/Qt que não aplicam porque faltou `export`

Ao final, você será capaz de criar perfis de inicialização diferentes para:
- Um workspace minimalista com i3wm e teclado em dvorak
- Uma sessão KDE com monitores em posições específicas
- Um ambiente híbrido que mistura XFCE com composição via Picom

Tudo isso testado de forma segura em um display alternativo (`:1`) antes de aplicar na sua sessão principal. A personalização real começa aqui.

---

## Neste capítulo

1. [Entendendo .xinitrc e .xsession](01-entendendo-xinitrc-e-xsession.md)
2. [Sintaxe básica dos arquivos de inicialização](02-sintaxe-basica-dos-arquivos-de-inicializ.md)
3. [Iniciando ambientes gráficos específicos](03-iniciando-ambientes-graficos-especificos.md)
4. [Configurando variáveis de ambiente](04-configurando-variaveis-de-ambiente.md)
5. [Executando comandos na inicialização](05-executando-comandos-na-inicializacao.md)
6. [Gerenciando múltiplos monitores](06-gerenciando-multiplos-monitores.md)
7. [Configurações de teclado e mouse](07-configuracoes-de-teclado-e-mouse.md)
8. [Temas e aparência via arquivos de inicialização](08-temas-e-aparencia-via-arquivos-de-inicia.md)
9. [Arquivos de exemplo para diferentes ambientes](09-arquivos-de-exemplo-para-diferentes-ambi.md)
10. [Solucionando problemas com arquivos de inicialização](10-solucionando-problemas-com-arquivos-de-i.md)

[↑ Sumário da obra](../README.md)