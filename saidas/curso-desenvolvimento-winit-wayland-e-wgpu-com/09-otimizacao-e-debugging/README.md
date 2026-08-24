# Otimização e Debugging

Você terminou de implementar sua aplicação gráfica em Rust com WGPU e Wayland - os triângulos giram, a interface responde, os shaders compilam. Mas algo está errado: a cena mais complexa roda a 15 FPS no seu hardware topo de linha, o debug log está inundado de warnings de validação, e toda vez que você minimiza a janela, o compositor trava sem mensagem de erro. Pior: você não tem ferramentas para identificar onde estão os gargalos.

Este capítulo existe porque performance gráfica nunca é "só código correto" - é um equilíbrio entre CPU, GPU, memória e até o protocolo do compositor. Sem as técnicas certas, você estará cego: 90% das otimizações vêm de 10% do código, mas sem dados concretos, você vai perder semanas otimizando loops que impactam 0.1% do tempo de frame.

Começamos com profiling básico (trecho 1) - descobrir se o problema está na CPU ou GPU. Você vai aprender a ler flamegraphs que mostram exatamente qual função está consumindo 45ms em um frame de 16ms. Depois (trechos 2-4), mergulhamos no mundo GPU: draw calls desnecessários, pipelines mal configurados, stalls de sincronização que deixam seu hardware ocioso. A seção 5 revela armadilhas de gerenciamento de memória que causam alocações frequentes - um killer silencioso de performance.

Os trechos 6-9 são seu kit de otimização prática: desde agrupamento inteligente de draw calls até sistemas de LOD que poupam 80% dos pixels renderizados. Já as seções 10-13 transformam bugs em visualizações - imagine ver o frustum da câmera como linhas coloridas, ou logs que mostram exatamente qual textura falhou ao carregar.

O capítulo fecha com técnicas profissionais (trechos 14-20): desde hot reloading de shaders sem reiniciar a aplicação até integração contínua de profiling que detecta regressões antes delas chegarem ao repositório. Ao final, você não só corrigirá os 15 FPS atuais, mas terá um sistema de monitoramento que previne 90% dos problemas antes deles aparecerem - com dados reais, não palpites.

---

## Neste capítulo

1. [Profiling Básico](01-profiling-basico.md)
2. [GPU Profiling](02-gpu-profiling.md)
3. [CPU Bottlenecks](03-cpu-bottlenecks.md)
4. [GPU Bottlenecks](04-gpu-bottlenecks.md)
5. [Memory Management](05-memory-management.md)
6. [Pipeline Optimizations](06-pipeline-optimizations.md)
7. [Shader Optimizations](07-shader-optimizations.md)
8. [Batch Optimization](08-batch-optimization.md)
9. [LOD Systems](09-lod-systems.md)
10. [Culling Básico](10-culling-basico.md)
11. [Async Loading](11-async-loading.md)
12. [Hot Reloading](12-hot-reloading.md)
13. [Debug Rendering](13-debug-rendering.md)
14. [Logging Gráfico](14-logging-grafico.md)
15. [Crash Reporting](15-crash-reporting.md)
16. [Validation Layers](16-validation-layers.md)
17. [Debugging Wayland](17-debugging-wayland.md)
18. [Debugging WGPU](18-debugging-wgpu.md)
19. [Benchmarking](19-benchmarking.md)
20. [Continuous Profiling](20-continuous-profiling.md)

[↑ Sumário da obra](../README.md)