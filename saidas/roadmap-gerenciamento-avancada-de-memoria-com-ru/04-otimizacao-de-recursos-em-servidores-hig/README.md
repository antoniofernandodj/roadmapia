# Otimização de Recursos em Servidores High-Throughput

Servidores high-throughput enfrentam desafios únicos: cada microssegundo conta, cada byte alocado pode ser o gargalo, e a pressão sobre o GC (quando existe) é implacável. Este capítulo chega após o leitor dominar os fundamentos de ownership, borrowing e gerenciamento manual de memória em Rust — agora, aplicamos esse conhecimento em cenários onde 1% de otimização representa milhares de requisições adicionais por segundo.

O problema central é a tensão entre segurança de memória e latência previsível. Enquanto um servidor web comum pode se dar ao luxo de alocar dinamicamente para cada request, sistemas que processam 100K+ conexões simultâneas precisam de estratégias radicalmente diferentes. Aqui, até o `Vec::new()` vira suspeito quando chamado em hot paths.

Os tópicos evoluem da diagnose para a cirurgia: começamos identificando gargalos reais (como syscalls de TCP e fragmentação de buffers), passamos por técnicas de reuso de memória (pools, arenas) e chegamos à otimização agressiva com zero-cost abstractions. O fio condutor é o ciclo de vida da memória em sistemas sob pressão — como evitamos que ela vire lixo, como a reaproveitamos sem comprometer segurança, e como medimos cada decisão com dados concretos de profiling.

Ao final, você estará apto a:
- Projetar sistemas que sustentam 10x mais conexões com a mesma infraestrutura
- Substituir alocações dinâmicas por estratégias previsíveis de memory pooling
- Interpretar flamegraphs de servidores Rust para atacar gargalos reais
- Escrever serializers que competem com C++ em throughput sem abrir mão de safety

---

## Neste capítulo

1. [Desafios em Servidores High-Throughput](01-desafios-em-servidores-high-throughput.md)
2. [Otimização de Conexões TCP](02-otimizacao-de-conexoes-tcp.md)
3. [Gerenciamento de Buffers de Rede](03-gerenciamento-de-buffers-de-rede.md)
4. [Redução de Alocações em Servidores](04-reducao-de-alocacoes-em-servidores.md)
5. [Memory Pools para Servidores](05-memory-pools-para-servidores.md)
6. [Profiling em Servidores](06-profiling-em-servidores.md)
7. [Otimização de Serialização](07-otimizacao-de-serializacao.md)
8. [Concorrência e Memória em Servidores](08-concorrencia-e-memoria-em-servidores.md)
9. [Estudos de Caso: Servidores Rust](09-estudos-de-caso-servidores-rust.md)
10. [Melhores Práticas para Servidores](10-melhores-praticas-para-servidores.md)

[↑ Sumário da obra](../README.md)