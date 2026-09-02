# Fundamentos da Programação de Jogos

Imagine que você está criando um jogo e o personagem simplesmente não se move quando você pressiona as teclas, ou os inimigos passam reto pelos obstáculos como se fossem fantasmas. Pior: o jogo trava porque está tentando processar tudo de uma vez, sem organizar cada etapa. Esses são os problemas que o capítulo **Fundamentos da Programação de Jogos** resolve.  

Você já aprendeu a sintaxe básica do C++ e como a Unreal Engine estrutura projetos. Agora é hora de aplicar esse conhecimento para fazer um jogo funcional. O capítulo começa com o **loop principal**, o coração de qualquer jogo — sem ele, nada acontece. Depois, você conecta as entradas do teclado e mouse ao loop, fazendo o personagem reagir. Mas de que adianta o movimento se não aparece na tela? A **renderização básica** ensina a desenhar sprites e controlar suas transformações.  

Só que objetos precisam interagir: um pulo deve parar no chão, um tiro precisa acertar o inimigo. A **física e colisões** trazem essa realidade. E um jogo sem feedback é mudo — **sons e música** entram aqui. Mas como controlar se o jogador está no menu, em jogo ou na tela de Game Over? O **gerenciamento de estados** organiza isso.  

Cada tópico é um tijolo: o loop mantém o jogo vivo, a entrada dá controle ao jogador, a renderização mostra o mundo, a física torna tudo sólido, o áudio dá vida e os estados organizam o fluxo. Ao final do capítulo, você terá um protótipo funcional com personagem controlável, inimigos básicos, colisões, sons simples e transição entre estados — tudo rodando a 60 FPS, sem travamentos ou bugs visíveis.  

Os próximos capítulos construirão sobre isso, adicionando IA complexa, efeitos visuais e sistemas de progressão. Mas primeiro, você precisa dominar esses fundamentos — são eles que diferenciam um projeto que "mexe" de um jogo de verdade.

---

## Neste capítulo

1. [O loop principal do jogo](01-o-loop-principal-do-jogo.md)
2. [Entrada do usuário: teclado e mouse](02-entrada-do-usuario-teclado-e-mouse.md)
3. [Renderização básica: sprites e texturas](03-renderizacao-basica-sprites-e-texturas.md)
4. [Colisões e física básica](04-colisoes-e-fisica-basica.md)
5. [Sons e música em jogos](05-sons-e-musica-em-jogos.md)
6. [Gerenciamento de estados do jogo](06-gerenciamento-de-estados-do-jogo.md)
7. [Criação de personagens e inimigos](07-criacao-de-personagens-e-inimigos.md)
8. [Sistema de pontuação e vidas](08-sistema-de-pontuacao-e-vidas.md)
9. [Interface gráfica do usuário (GUI)](09-interface-grafica-do-usuario-gui.md)
10. [Salvamento e carregamento de dados](10-salvamento-e-carregamento-de-dados.md)
11. [Debugging e testes básicos](11-debugging-e-testes-basicos.md)
12. [Introdução à orientação a objetos](12-introducao-a-orientacao-a-objetos.md)
13. [Classes e objetos](13-classes-e-objetos.md)
14. [Construtores e destrutores](14-construtores-e-destrutores.md)
15. [Encapsulamento e modificadores de acesso](15-encapsulamento-e-modificadores-de-acesso.md)
16. [Herança e polimorfismo](16-heranca-e-polimorfismo.md)
17. [Sobrecarga de operadores](17-sobrecarga-de-operadores.md)
18. [Templates e genéricos](18-templates-e-genericos.md)
19. [Manipulação de arquivos](19-manipulacao-de-arquivos.md)
20. [Exceções e tratamento de erros](20-excecoes-e-tratamento-de-erros.md)

[↑ Sumário da obra](../README.md)