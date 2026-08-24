# Técnicas de Otimização de Desempenho

Em sistemas de alta performance, cada nanossegundo e byte contam. Quando sua aplicação Rust precisa processar milhões de requisições por segundo ou manipular gigabytes de dados com latência previsível, o compilador sozinho não basta. Este capítulo chega depois que você já domina lifetimes, ownership e estruturas de dados, para enfrentar problemas reais: buffers que duplicam memória desnecessariamente, serializações que criam overhead, cache misses que arruínam seu throughput.

A ordem dos tópicos segue o ciclo de vida de um dado na memória: começamos com otimizações de compilação (inlining) e arranjo físico dos structs, avançamos para técnicas zero-copy e alocação em arenas, até chegar em alocadores customizados que desafiam o padrão do sistema. Na reta final, abordamos prefetching, SIMD e casos reais como otimizações em parsers de JSON e motores de jogos — sempre medindo com `perf` e `flamegraph`.

Ao final, você redesenhará estruturas para caber em cache lines, substituirá alocações dinâmicas por arenas estáticas e dominará `unsafe` onde ele realmente traz ganhos (com benchmarks que o justifiquem). Tudo com código testado em servidores WebSocket e bancos de dados in-memory, não em exemplos acadêmicos.

---

## Neste capítulo

1. [Inlining e Otimização de Compilador](01-inlining-e-otimizacao-de-compilador.md)
2. [Layout de Memória em Estruturas](02-layout-de-memoria-em-estruturas.md)
3. [Zero-Copy Serialization](03-zero-copy-serialization.md)
4. [Arenas de Alocação](04-arenas-de-alocacao.md)
5. [Custom Allocators em Rust](05-custom-allocators-em-rust.md)
6. [Otimização de Cache Line](06-otimizacao-de-cache-line.md)
7. [Prefetching em Rust](07-prefetching-em-rust.md)
8. [SIMD e Otimização de Memória](08-simd-e-otimizacao-de-memoria.md)
9. [Estudos de Caso: Otimizações Extremas](09-estudos-de-caso-otimizacoes-extremas.md)
10. [Melhores Práticas de Otimização](10-melhores-praticas-de-otimizacao.md)

[↑ Sumário da obra](../README.md)