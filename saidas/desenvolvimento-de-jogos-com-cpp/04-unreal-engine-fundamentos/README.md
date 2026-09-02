# Unreal Engine: Fundamentos

Abrir a Unreal Engine pela primeira vez pode ser assustador. Janelas, painéis e menus se espalham pela tela, enquanto termos como "Viewport" e "Blueprint" parecem exigir um dicionário paralelo. Este capítulo surge logo após a introdução ao C++ porque, mesmo em projetos nativos, 70% do trabalho diário acontece no editor visual - e dominá-lo é pré-requisito para integrar código eficientemente.

O problema central é transformar essa complexidade inicial em fluência. Começamos mapeando a interface (qual painel controla o quê) como um piloto aprende o cockpit antes de voar. Em seguida, criamos projetos reais - não apenas clicando em templates, mas entendendo como cada escolha afeta a estrutura de pastas e configurações padrão. A armadilha aqui é clássica: pular essa etapa e depois perder horas procurando onde a Engine escondeu determinada configuração.

Com o projeto aberto, introduzimos Blueprints, a ponte entre design e programação. É aqui que muitos desenvolvedores C++ tradicionais travam - subestimam o sistema visual até precisarem modificar um componente criado por um designer. Mostramos como um Actor simples ganha vida com componentes de malha e colisão, preparando o terreno para a integração com classes C++ mais adiante.

Luzes, câmeras e física compõem o vocabulário básico de qualquer cena. Uma luz mal configurada pode arruinar meses de trabalho artístico, assim como uma câmera sem Spring Arm produzirá movimentos robóticos. Demonstramos esses erros na prática - com screenshots das mensagens de erro exatas que aparecem quando um objeto sem colisão cai infinitamente no vácuo.

Ao final deste capítulo, você será capaz de: navegar na interface sem perder-se nos menus, configurar projetos com a estrutura correta para seu gênero de jogo, prototipar mecânicas básicas combinando Blueprints e componentes, e diagnosticar erros comuns de física e renderização. Tudo isso com um pé no visual (Blueprints) e outro no código (C++), antecipando a integração profunda que virá nos próximos capítulos.

---

## Neste capítulo

1. [Interface da Unreal Engine](01-interface-da-unreal-engine.md)
2. [Criação de projetos](02-criacao-de-projetos.md)
3. [Introdução aos Blueprints](03-introducao-aos-blueprints.md)
4. [Criação de atores e componentes](04-criacao-de-atores-e-componentes.md)
5. [Materiais e texturas](05-materiais-e-texturas.md)
6. [Iluminação básica](06-iluminacao-basica.md)
7. [Câmeras e visão](07-cameras-e-visao.md)
8. [Física básica](08-fisica-basica.md)
9. [Colisões e triggers](09-colisoes-e-triggers.md)
10. [Sons e música](10-sons-e-musica.md)
11. [Interface gráfica do usuário (UI)](11-interface-grafica-do-usuario-ui.md)
12. [Gerenciamento de cenas](12-gerenciamento-de-cenas.md)
13. [Introdução ao C++ na Unreal Engine](13-introducao-ao-c-na-unreal-engine.md)
14. [Criação de classes C++](14-criacao-de-classes-c.md)
15. [Expondo variáveis e funções](15-expondo-variaveis-e-funcoes.md)
16. [Eventos e delegates](16-eventos-e-delegates.md)
17. [Timers e delays](17-timers-e-delays.md)
18. [Gerenciamento de assets](18-gerenciamento-de-assets.md)
19. [Projeto prático: jogo básico](19-projeto-pratico-jogo-basico.md)

[↑ Sumário da obra](../README.md)