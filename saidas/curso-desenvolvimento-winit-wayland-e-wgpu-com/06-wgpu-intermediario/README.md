# WGPU Intermediário

Você já domina os fundamentos do WGPU: criou pipelines básicos, desenhou triângulos na tela e entendeu como os shaders conversam com a CPU. Mas agora sua aplicação precisa escalar — objetos transparentes se sobrepõem de forma incorreta, cenas complexas travam com milhares de draw calls, e efeitos especiais parecem impossíveis sem truques manuais. Este capítulo é a ponte entre o "funciona" e o "funciona bem".

O problema central é a comunicação eficiente com a GPU. Cada chamada de API tem um custo, cada recurso mal gerenciado acumula overhead, e cada técnica avançada exige coordenação precisa entre estágios do pipeline. Começamos com estados avançados de renderização (blending, depth testing) porque são a base visual — sem eles, nem adianta otimizar o resto. Bind groups e texturas vêm em seguida para organizar os recursos que esses estados consomem. Quando você dominar depth/stencil buffers e framebuffers múltiplos, estará pronto para técnicas como deferred shading.

A segunda metade do capítulo é sobre desempenho bruto. Compute shaders quebram o paradigma de "só renderização", instanced rendering reduz chamadas repetitivas, e vertex pulling elimina gargalos de CPU. Gerenciamento de recursos e pipeline caching evitam recriações desnecessárias, enquanto multi-queue e queries (timestamp, occlusion) fornecem métricas para validar suas otimizações. MSAA e passes múltiplos fecham o ciclo, mostrando como combinar tudo para efeitos visuais complexos.

Ao final, você será capaz de:
- Ordenar objetos transparentes corretamente com blending e depth testing
- Organizar bind groups para minimizar trocas de estado durante o rendering
- Criar sistemas de materiais com texturas array e mipmaps automáticos
- Implementar técnicas avançadas como instancing e compute shaders
- Diagnosticar gargalos com timestamp queries e occlusion culling
- Projetar pipelines especializados para cenários de renderização específicos

Cada técnica aqui resolve um problema real que aparece quando sua cena passa de 10 para 10.000 objetos — e todas conversam entre si. O pipeline de renderização que você vai montar será tão eficiente quanto sua peça mais fraca.

---

## Neste capítulo

1. [Pipeline States Avançados](01-pipeline-states-avancados.md)
2. [Bind Groups e Layouts](02-bind-groups-e-layouts.md)
3. [Texturas Avançadas](03-texturas-avancadas.md)
4. [Depth e Stencil](04-depth-e-stencil.md)
5. [Framebuffers Múltiplos](05-framebuffers-multiplos.md)
6. [Compute Shaders Básicos](06-compute-shaders-basicos.md)
7. [Instanced Rendering](07-instanced-rendering.md)
8. [Vertex Pulling](08-vertex-pulling.md)
9. [Resource Management](09-resource-management.md)
10. [Pipeline Caching](10-pipeline-caching.md)
11. [Multi-queue](11-multi-queue.md)
12. [Timestamp Queries](12-timestamp-queries.md)
13. [Occlusion Queries](13-occlusion-queries.md)
14. [MSAA](14-msaa.md)
15. [Render Passes Múltiplas](15-render-passes-multiplas.md)
16. [Dynamic Uniforms](16-dynamic-uniforms.md)
17. [Buffer Mapping](17-buffer-mapping.md)
18. [Pipeline Specialization](18-pipeline-specialization.md)
19. [Debug Groups](19-debug-groups.md)
20. [Error Handling Avançado](20-error-handling-avancado.md)

[↑ Sumário da obra](../README.md)