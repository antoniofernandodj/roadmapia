# Projeto Final

Você passou semanas dominando C++ na Unreal Engine: criou personagens que pulam, inimigos que perseguem, itens que desaparecem quando coletados. Mas agora surge a dúvida: como transformar esses blocos isolados em um jogo completo? Este capítulo é a ponte entre exercícios fragmentados e um projeto real - a hora de integrar tudo que aprendeu em um sistema coeso.

O desafio começa antes da primeira linha de código. Sem um plano claro, você corre o risco de:

1. Implementar mecânicas desconexas que não conversam entre si
2. Perder semanas em sistemas secundários enquanto o core do jogo não funciona
3. Criar dependências circulares entre classes
4. Enfrentar bugs fantasmas porque nenhum sistema foi testado de forma integrada

Aqui não usaremos atalhos - você vai arquitetar um jogo 2D completo, desde o documento de design até a build final. Começaremos definindo os pilares do jogo (o que torna sua mecânica única?) e traduzindo isso para classes C++ específicas. Você aprenderá a:

- Estruturar seu código em camadas (lógica de jogo × renderização × input)
- Criar um gerenciador de níveis que carrega cenários dinamicamente
- Documentar diretamente no código com GameDesignDoc integrado
- Evitar o erro clássico de assets não encontrados em builds finais

À medida que avançarmos, cada sistema novo será integrado aos existentes. Quando implementar o sistema de IA, ele já se conectará automaticamente ao HUD que você criou antes. Ao adicionar efeitos sonoros, eles responderão aos eventos de coleta de itens já funcionais.

O capítulo culmina com técnicas profissionais de otimização - você não quer que seu jogo trave quando 20 inimigos aparecerem na tela, certo? Aprenderá a usar o Stat Unit para identificar gargalos e técnicas como object pooling para manter o FPS estável.

Ao final deste percurso, você terá não apenas um jogo funcional, mas um projeto arquitetado para escalar - pronto para adicionar novos níveis, inimigos e mecânicas sem reescrever tudo do zero. A diferença entre um amador e um profissional está em como os sistemas conversam entre si, e é exatamente isso que você dominará aqui.

---

## Neste capítulo

1. [Escolha do tema e planejamento](01-escolha-do-tema-e-planejamento.md)
2. [Desenvolvimento do protótipo](02-desenvolvimento-do-prototipo.md)
3. [Implementação de sistemas principais](03-implementacao-de-sistemas-principais.md)
4. [Criação de conteúdo](04-criacao-de-conteudo.md)
5. [Testes e ajustes](05-testes-e-ajustes.md)
6. [Otimização final](06-otimizacao-final.md)
7. [Preparação para publicação](07-preparacao-para-publicacao.md)
8. [Distribuição e plataformas](08-distribuicao-e-plataformas.md)
9. [Marketing e divulgação](09-marketing-e-divulgacao.md)
10. [Feedback e atualizações](10-feedback-e-atualizacoes.md)
11. [Monetização e economia](11-monetizacao-e-economia.md)
12. [Documentação do projeto](12-documentacao-do-projeto.md)
13. [Apresentação do projeto](13-apresentacao-do-projeto.md)
14. [Feedback final e melhorias](14-feedback-final-e-melhorias.md)
15. [Projeto prático: jogo completo](15-projeto-pratico-jogo-completo.md)

[↑ Sumário da obra](../README.md)