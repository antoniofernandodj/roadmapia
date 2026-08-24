# WGPU Básico

Renderizar gráficos modernos em Rust exige uma ponte entre a segurança da linguagem e o acesso direto ao hardware gráfico. WGPU resolve esse dilema ao oferecer uma API segura que abstrai Vulkan, Metal e DirectX 12, mantendo o controle fino sobre a GPU. Este capítulo vem após a configuração básica de janelas com Winit porque agora precisamos preenchê-las com conteúdo visual — sem entender os fundamentos do WGPU, qualquer tentativa de renderização seria como construir uma casa sem alicerce.

O desafio começa com a complexidade inerente das GPUs modernas: pipelines programáveis, memória heterogênea e sincronização explícita entre CPU e GPU. WGPU não esconde essa complexidade, mas a organiza em componentes gerenciáveis. A `Instance` abre a porta para os backends gráficos, o `Adapter` representa o hardware físico, enquanto `Device` e `Queue` coordenam a execução real dos comandos. Cada peça deve ser montada na ordem correta, como um circuito elétrico onde um fio solto impede todo o sistema de funcionar.

A progressão dos tópicos segue o fluxo natural de uma aplicação gráfica: da configuração inicial até a submissão de comandos. Começamos criando a infraestrutura básica (Instance, Adapter, Device), depois configuramos a swap chain para exibição, construímos pipelines de renderização com shaders, e finalmente sincronizamos tudo com a janela Winit. Cada etapa revela erros comuns — como esquecer `#[repr(C)]` em estruturas de vértices ou não verificar os limites do hardware — com soluções práticas extraídas de projetos reais.

Ao final deste capítulo, você será capaz de configurar um pipeline de renderização completo em WGPU, desde a seleção do adaptador gráfico até a exibição de geometria 3D com shaders personalizados. Saberá diagnosticar problemas de compatibilidade de hardware, gerenciar recursos GPU com segurança de tipos, e otimizar a transferência de dados entre CPU e GPU. Mais importante: entenderá o "porquê" de cada decisão de API, não apenas o "como" das chamadas de função.

---

## Neste capítulo

1. [Arquitetura do WGPU](01-arquitetura-do-wgpu.md)
2. [Configuração Inicial](02-configuracao-inicial.md)
3. [Instance e Adapter](03-instance-e-adapter.md)
4. [Device e Queue](04-device-e-queue.md)
5. [Swap Chain Básica](05-swap-chain-basica.md)
6. [Pipeline de Renderização](06-pipeline-de-renderizacao.md)
7. [Vertex Buffers](07-vertex-buffers.md)
8. [Shaders Básicos](08-shaders-basicos.md)
9. [Render Pass](09-render-pass.md)
10. [Texturas Simples](10-texturas-simples.md)
11. [Uniform Buffers](11-uniform-buffers.md)
12. [Comandos Básicos](12-comandos-basicos.md)
13. [Sincronização Básica](13-sincronizacao-basica.md)
14. [Error Handling](14-error-handling.md)
15. [Debugging WGPU](15-debugging-wgpu.md)
16. [Multi-threading Básico](16-multi-threading-basico.md)
17. [Integração com Winit](17-integracao-com-winit.md)
18. [Limitações do WGPU](18-limitacoes-do-wgpu.md)
19. [Comparação com OpenGL](19-comparacao-com-opengl.md)
20. [Recursos Adicionais](20-recursos-adicionais.md)

[↑ Sumário da obra](../README.md)