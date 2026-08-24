# Fundamentos de Gerenciamento de Memória em Rust

Em sistemas de alto desempenho, o gerenciamento de memória é a linha tênue entre velocidade e caos. Considere um servidor web processando 50.000 requisições por segundo: cada alocação desnecessária, cada cópia oculta, cada vazamento imperceptível multiplicado por milhares torna-se um gargalo. Rust oferece ferramentas para domar esse problema **em tempo de compilação**, mas exige compreensão profunda dos mecanismos sob o capô. 

Este capítulo assume familiaridade com sintaxe básica de Rust (variáveis, funções, estruturas) e experiência prática com dores de gerenciamento manual de memória em linguagens como C/C++ ou gerenciada como Go/Java. Você já sabe **por que** precisa controlar memória - agora vamos explorar **como** Rust transforma esse controle em garantias matemáticas.

Os trechos começam com **ownership** e **borrowing**, os alicerces que eliminam coletor de lixo e ponteiros nulos. Depois, **lifetimes** desvendam como o compilador rastreia a validade das referências sem custo de execução. Com essa base, exploramos os detalhes de **alocação**: quando Rust move dados em vez de copiar, como **smart pointers** como `Box` e `Rc` delegam responsabilidades, e onde as coleções padrão (`Vec`, `HashMap`) alocam implicitamente.

A segunda metade é prática: **benchmarking** revela gargalos reais, enquanto **profiling** com ferramentas como `perf` e `DTrace` expõe padrões de alocação invisíveis no código. Finalmente, aplicamos esses conhecimentos em **padrões de design** específicos para servidores (pools de alocação, arenas) e aplicações desktop (cache de recursos), sempre contrastando com **unsafe code** para casos onde o desempenho justifica assumir riscos.

Ao final, você será capaz de:
- Decidir entre `String`, `&str` e `Cow` baseado em padrões de uso
- Identificar cópias ocultas em cadeias de iteradores
- Substituir alocações dinâmicas por arenas em hotspots críticos
- Medir o impacto de escolhas de memória com benchmarks reproduzíveis
- Usar unsafe de forma controlada para otimizações verificáveis

---

## Neste capítulo

1. [Revisão de Ownership e Borrowing](01-revisao-de-ownership-e-borrowing.md)
2. [Lifetimes em Funções e Estruturas](02-lifetimes-em-funcoes-e-estruturas.md)
3. [Tipos de Dados e Alocação de Memória](03-tipos-de-dados-e-alocacao-de-memoria.md)
4. [Moves e Cópias em Rust](04-moves-e-copias-em-rust.md)
5. [Gerenciamento de Memória com Smart Pointers](05-gerenciamento-de-memoria-com-smart-point.md)
6. [Coleções Padrão e Alocação Dinâmica](06-colecoes-padrao-e-alocacao-dinamica.md)
7. [Estratégias para Minimizar Alocações](07-estrategias-para-minimizar-alocacoes.md)
8. [Benchmarking Simples em Rust](08-benchmarking-simples-em-rust.md)
9. [Safe vs Unsafe: Visão Geral](09-safe-vs-unsafe-visao-geral.md)
10. [Casos de Uso para Unsafe Code](10-casos-de-uso-para-unsafe-code.md)
11. [Introdução a Profiling em Rust](11-introducao-a-profiling-em-rust.md)
12. [Ferramentas de Profiling: Perf](12-ferramentas-de-profiling-perf.md)
13. [Ferramentas de Profiling: DTrace](13-ferramentas-de-profiling-dtrace.md)
14. [Análise de Desempenho com Criterion](14-analise-de-desempenho-com-criterion.md)
15. [Otimização de Estruturas de Dados](15-otimizacao-de-estruturas-de-dados.md)
16. [Padrões de Design para Eficiência](16-padroes-de-design-para-eficiencia.md)
17. [Gerenciamento de Recursos em Servidores](17-gerenciamento-de-recursos-em-servidores.md)
18. [Gerenciamento de Recursos em Desktop](18-gerenciamento-de-recursos-em-desktop.md)
19. [Estudos de Caso: Aplicações Reais](19-estudos-de-caso-aplicacoes-reais.md)
20. [Próximos Passos e Recursos](20-proximos-passos-e-recursos.md)

[↑ Sumário da obra](../README.md)