# UI Custom com WGPU

Aplicações gráficas modernas exigem interfaces personalizadas que vão além dos toolkits tradicionais — seja por requisitos de performance, design único ou integração profunda com a engine gráfica. Este capítulo ensina a construir uma UI do zero usando WGPU, onde cada pixel é controlado diretamente pelo seu código, sem intermediários que limitem criatividade ou eficiência.

Você já domina os fundamentos de WGPU (pipelines, buffers, texturas) e estruturou um loop principal com Winit. Agora enfrentará o desafio real: transformar primitivas gráficas em componentes interativos que respondem a input, redimensionam dinamicamente e compõem hierarquias complexas. A ordem dos tópicos reflete o fluxo natural de desenvolvimento: começamos com a arquitetura básica (como organizar o rendering), passamos pelos blocos fundamentais (texto, input, layout), até chegar em técnicas avançadas como batch rendering e animações — cada trecho resolvendo um problema concreto que surgiu no anterior.

Ao final, você será capaz de criar interfaces performáticas com renderização direta na GPU, desde widgets simples até listas roláveis com centenas de elementos, tudo enquanto mantém 60 FPS mesmo em dispositivos com recursos limitados. A UI será sua — sem herdar limitações de sistemas prontos.

---

## Neste capítulo

1. [Arquitetura de UI Custom](01-arquitetura-de-ui-custom.md)
2. [Text Rendering Básico](02-text-rendering-basico.md)
3. [Input Handling](03-input-handling.md)
4. [Layout Básico](04-layout-basico.md)
5. [Styling Básico](05-styling-basico.md)
6. [Nested Components](06-nested-components.md)
7. [Scrolling Básico](07-scrolling-basico.md)
8. [Focus Management](08-focus-management.md)
9. [Clip Rectangles](09-clip-rectangles.md)
10. [Transparency e Blending](10-transparency-e-blending.md)
11. [Batch Rendering](11-batch-rendering.md)
12. [Caching de Texturas](12-caching-de-texturas.md)
13. [HiDPI Support](13-hidpi-support.md)
14. [Animations Básicas](14-animations-basicas.md)
15. [Debug Overlay](15-debug-overlay.md)
16. [IMEs Básicos](16-imes-basicos.md)
17. [Accessibility Básica](17-accessibility-basica.md)
18. [Localization Básica](18-localization-basica.md)
19. [Performance Considerations](19-performance-considerations.md)
20. [Comparação com Toolkits Existentes](20-comparacao-com-toolkits-existentes.md)

[↑ Sumário da obra](../README.md)