# Desenvolvimento de Jogos de Ação

Um jogo de ação vive da resposta imediata do jogador a desafios dinâmicos. Os primeiros capítulos ensinaram você a criar objetos e movê-los na tela, mas um personagem que apenas se arrasta pela cena não sustenta nem um clone de Contra. Aqui, transformaremos esse esqueleto em um protagonista ágil que atira, esquiva e reage a ameaças - e que enfrenta inimigos com comportamentos tão complexos quanto os do jogador.

Para isso, começamos com o InputComponent, que traduz teclas em ações de jogo. Um botão "Atirar" não é só um comando: ele dispara um projétil, consome munição, ativa um cooldown e toca um som. Quando o jogador pressiona "W", o personagem não se move para frente - ele acelera gradualmente, com animação de corrida e partículas de poeira. Essas camadas de feedback são o que separa um protótipo técnico de uma experiência envolvente.

Com o personagem funcional, introduzimos inimigos que perseguem, atacam e exigem estratégia. Um inimigo patrulha entre waypoints até avistar o jogador, quando muda para comportamento agressivo. Isso requer sistemas de detecção de alcance, máquinas de estado simples e integração com o sistema de dano existente. O TakeDamage que você implementou para o jogador agora serve também para os NPCs - mas com regras próprias, como resistências a tipos de ataque.

Armas deixam de ser um método Fire no personagem e ganham classes dedicadas, com propriedades como spread, cadência e dano por projétil. Quando o jogador coleta um power-up, modificamos essas propriedades em tempo real - sem hardcode. O mesmo sistema que controla um upgrade temporário de velocidade servirá depois para efeitos de slow-motion em momentos dramáticos.

Todos esses sistemas convergem no HUD, onde mostramos vida, pontuação e indicadores de status. Um combo counter que recompensa sequências rápidas de acertos usa o mesmo TimerHandle que já aplicamos para recarga de armas. Quando o jogo fica muito difícil, um sistema adaptativo ajusta a saúde dos inimigos e a frequência de spawn - mas sem quebrar o balanceamento intencional de fases específicas.

Ao final deste capítulo, seu jogo terá:

- Controles responsivos com múltiplas camadas de feedback
- Inimigos com comportamentos distintos e máquinas de estado
- Sistema de armas modular com efeitos temporários
- Progressão mensurável via HUD e dificuldade dinâmica
- Tudo isso integrado através de eventos e delegates

O desafio não é mais fazer um cubo se mover na tela, mas orquestrar dezenas de interações que pareçam simples para o jogador - enquanto você gerencia a complexidade nos bastidores.

---

## Neste capítulo

1. [Introdução ao desenvolvimento de ação](01-introducao-ao-desenvolvimento-de-acao.md)
2. [Criação de personagens e inimigos](02-criacao-de-personagens-e-inimigos.md)
3. [Combate e armas](03-combate-e-armas.md)
4. [Sistema de pontuação e vidas](04-sistema-de-pontuacao-e-vidas.md)
5. [Power-ups e coletáveis](05-power-ups-e-coletaveis.md)
6. [Transições e efeitos](06-transicoes-e-efeitos.md)
7. [Gerenciamento de dificuldade](07-gerenciamento-de-dificuldade.md)
8. [Salvamento e carregamento de dados](08-salvamento-e-carregamento-de-dados.md)
9. [Debugging e testes básicos](09-debugging-e-testes-basicos.md)
10. [Projeto prático: jogo de ação](10-projeto-pratico-jogo-de-acao.md)

[↑ Sumário da obra](../README.md)