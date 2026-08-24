# Unsafe Code e Otimização

Em sistemas de alto desempenho, mesmo Rust — com seu sistema de ownership e verificações em tempo de compilação — pode impor limites desnecessários em cenários onde o controle absoluto sobre a memória é crítico. Este capítulo surge quando você já domina borrow checking, lifetimes e estruturas de dados seguras, mas esbarra em gargalos de performance que exigem operações abaixo do nível de abstração seguro. O problema central é: como quebrar temporariamente as garantias de segurança do Rust sem introduzir vulnerabilidades ou comportamentos indefinidos?

A ordem dos trechos reflete a jornada de um engenheiro que precisa justificar, implementar e validar unsafe code. Começamos com critérios objetivos para decidir quando unsafe é a resposta certa (1), seguidos pelas técnicas para manipular memória manualmente sem corromper o heap (2). Aprofundamos em ponteiros brutos (3) e na integração com código C via FFI (4), onde unsafe é inevitável. Exploramos como concorrência e unsafe interagem (5) — um terreno especialmente perigoso — antes de abordar auditoria (6) e benchmarking (7) para validar as escolhas. Os estudos de caso (8) mostram padrões reais de otimização, enquanto as armadilhas (9) e melhores práticas (10) consolidam o conhecimento.

Ao final, você será capaz de: identificar situações onde unsafe traz benefícios tangíveis, escrever blocos `unsafe` com invariantes verificáveis, interoperar com outras linguagens sem vazamentos de memória, e medir o impacto real dessas otimizações em cenários de alta carga. Tudo isso mantendo a segurança efetiva do sistema através de encapsulamento e testes direcionados.

---

## Neste capítulo

1. [Quando Usar Unsafe Code](01-quando-usar-unsafe-code.md)
2. [Manipulação Segura de Memória](02-manipulacao-segura-de-memoria.md)
3. [Ponteiros Brutos e Performance](03-ponteiros-brutos-e-performance.md)
4. [FFI e Gerenciamento de Memória](04-ffi-e-gerenciamento-de-memoria.md)
5. [Unsafe e Concorrência](05-unsafe-e-concorrencia.md)
6. [Auditoria de Unsafe Code](06-auditoria-de-unsafe-code.md)
7. [Benchmarking Unsafe vs Safe](07-benchmarking-unsafe-vs-safe.md)
8. [Estudos de Caso: Unsafe Code](08-estudos-de-caso-unsafe-code.md)
9. [Armadilhas Comuns em Unsafe Code](09-armadilhas-comuns-em-unsafe-code.md)
10. [Melhores Práticas para Unsafe Code](10-melhores-praticas-para-unsafe-code.md)

[↑ Sumário da obra](../README.md)