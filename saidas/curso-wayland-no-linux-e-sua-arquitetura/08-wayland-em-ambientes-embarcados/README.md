# Wayland em ambientes embarcados

Sistemas embarcados impõem restrições que tornam o Xorg inviável: consumo excessivo de recursos, latência em dispositivos de entrada não tradicionais e complexidade na integração com hardware específico. Um terminal de pagamento com touchscreen resistivo, por exemplo, precisa responder a toques imprecisos em 200ms enquanto consome menos de 100MB de RAM - cenário onde o Wayland se torna obrigatório, não opcional.

Antes deste capítulo, você já configurou ambientes Wayland em desktops convencionais e desenvolveu aplicativos básicos. Agora enfrentará problemas reais de sistemas embarcados: GPUs Mali sem drivers padrão, touchscreens que reportam coordenadas invertidas e a necessidade de operar sem mouse ou teclado. O Weston mostrará sua verdadeira vantagem aqui - enquanto compositors como o Sway exigem 500MB só para inicializar, o Weston consegue rodar em 32MB com o backend DRM ajustado.

O caminho começa com a configuração mínima viável (trecho 1), onde você resolverá o erro "failed to initialize drm backend" que ocorre em 80% das placas ARM. A seguir (trecho 2), ajustará o weston.ini para ler eventos de um touchscreen que o sistema nem reconhece como dispositivo de entrada. A otimização de recursos (trecho 3) ensinará a reduzir o buffer de framebuffer para 16bpp em displays monocromáticos industriais.

Trechos 4 a 6 mergulham em casos reais: desde kiosks de shopping até equipamentos médicos com requisitos críticos de tempo. Você implementará a detecção de duplo-toque sem bibliotecas externas (trecho 7) e resolverá o erro "could not open /dev/input/event2" que persegue desenvolvedores de placas Allwinner. As ferramentas do trecho 8 serão sua arma contra problemas como touchscreens que enviam coordenadas (0,0) continuamente.

Ao final, você estará apto a:
- Configurar o Weston para inicializar em menos de 3s em hardware Cortex-A7
- Integrar touchscreens resistivos sem suporte nativo no libinput
- Diagnosticar falhas de composição em sistemas com múltiplos framebuffers
- Implementar interfaces touch-only sem dependências de desktop environments
- Reduzir o consumo de RAM para abaixo de 50MB em aplicações kiosk

---

## Neste capítulo

1. [Introdução a Wayland em embarcados](01-introducao-a-wayland-em-embarcados.md)
2. [Configurando Wayland para embarcados](02-configurando-wayland-para-embarcados.md)
3. [Otimização para recursos limitados](03-otimizacao-para-recursos-limitados.md)
4. [Compositors para sistemas embarcados](04-compositors-para-sistemas-embarcados.md)
5. [Desenvolvimento de aplicativos para embarcados](05-desenvolvimento-de-aplicativos-para-emba.md)
6. [Integração com hardware específico](06-integracao-com-hardware-especifico.md)
7. [Debugging em ambientes embarcados](07-debugging-em-ambientes-embarcados.md)
8. [Ferramentas para embarcados](08-ferramentas-para-embarcados.md)
9. [Problemas comuns em embarcados](09-problemas-comuns-em-embarcados.md)
10. [Solução de problemas em embarcados](10-solucao-de-problemas-em-embarcados.md)
11. [Exercícios práticos: embarcados](11-exercicios-praticos-embarcados.md)
12. [Casos de uso em embarcados](12-casos-de-uso-em-embarcados.md)
13. [Recapitulação e próximos passos](13-recapitulacao-e-proximos-passos.md)

[↑ Sumário da obra](../README.md)