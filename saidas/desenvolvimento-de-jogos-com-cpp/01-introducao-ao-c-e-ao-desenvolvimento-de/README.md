# Introdução ao C++ e ao Desenvolvimento de Jogos

Desenvolver jogos exige controle preciso sobre performance e recursos do sistema - algo que linguagens de alto nível frequentemente comprometem em favor da simplicidade. C++ oferece o equilíbrio crucial: abstração suficiente para produtividade, com acesso direto ao hardware quando necessário. Este capítulo chega primeiro porque estabelece as bases - sem compreender variáveis, loops e funções, tentar programar mecânicas de jogo seria como construir sem alicerces.

Começamos desvendando por que estúdios AAA e a própria Unreal Engine confiam em C++, mostrando como características como gerenciamento manual de memória se traduzem em quadros por segundo mais altos. A configuração do ambiente não é apenas "instalar ferramentas" - é preparar uma linha de produção profissional, onde cada alerta do compilador ajuda a prevenir bugs que arruinariam sessões de gameplay.

À medida que exploramos estruturas de controle e funções, os exemplos não são exercícios acadêmicos - são sistemas mínimos viáveis de jogos. Um `if` que determina se o jogador coletou um power-up, um `for` que gera inimigos em waves, funções que calculam dano com base em atributos. Quando chegamos a arrays e strings, já estamos manipulando inventários e diálogos.

Ponteiros e alocação dinâmica, frequentemente assustadores para iniciantes, são apresentados através de casos reais: gerenciar pools de objetos de jogo para evitar instanciação custosa durante a gameplay. A transição para a Unreal Engine acontece naturalmente quando o código puro de C++ encontra os editores visuais - mostrando como as classes que você escreve ganham vida no viewport.

Ao final deste capítulo, você será capaz de:
- Programar sistemas básicos de jogos usando estruturas de controle e funções em C++
- Gerenciar dados do jogo com arrays, strings e estruturas
- Interagir com a API da Unreal Engine através de código nativo
- Diagnosticar erros comuns de compilação e runtime
- Organizar projetos seguindo convenções profissionais da indústria

---

## Neste capítulo

1. [O que é C++ e por que usá-lo em jogos?](01-o-que-e-c-e-por-que-usa-lo-em-jogos.md)
2. [Configurando o ambiente de desenvolvimento](02-configurando-o-ambiente-de-desenvolvimen.md)
3. [Estrutura básica de um programa C++](03-estrutura-basica-de-um-programa-c.md)
4. [Comentários e boas práticas de codificação](04-comentarios-e-boas-praticas-de-codificac.md)
5. [Tipos de dados e variáveis](05-tipos-de-dados-e-variaveis.md)
6. [Operadores aritméticos e lógicos](06-operadores-aritmeticos-e-logicos.md)
7. [Estruturas de controle: if e else](07-estruturas-de-controle-if-e-else.md)
8. [Estruturas de controle: switch](08-estruturas-de-controle-switch.md)
9. [Loops: for](09-loops-for.md)
10. [Loops: while e do-while](10-loops-while-e-do-while.md)
11. [Funções: declaração e chamada](11-funcoes-declaracao-e-chamada.md)
12. [Parâmetros e retorno de funções](12-parametros-e-retorno-de-funcoes.md)
13. [Escopo e tempo de vida das variáveis](13-escopo-e-tempo-de-vida-das-variaveis.md)
14. [Arrays e vetores](14-arrays-e-vetores.md)
15. [Strings em C++](15-strings-em-c.md)
16. [Estruturas e uniões](16-estruturas-e-unioes.md)
17. [Ponteiros e referências](17-ponteiros-e-referencias.md)
18. [Alocação dinâmica de memória](18-alocacao-dinamica-de-memoria.md)
19. [Introdução à Unreal Engine](19-introducao-a-unreal-engine.md)
20. [Criando o primeiro projeto na Unreal Engine](20-criando-o-primeiro-projeto-na-unreal-eng.md)

[↑ Sumário da obra](../README.md)