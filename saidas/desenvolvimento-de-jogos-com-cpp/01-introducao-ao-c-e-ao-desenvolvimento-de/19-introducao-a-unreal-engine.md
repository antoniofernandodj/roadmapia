## Introdução à Unreal Engine

Imagine abrir pela primeira vez um estúdio de cinema digital. Você vê telas de edição, bibliotecas de assets, controles de câmera e iluminação - tudo integrado. A Unreal Engine é exatamente isso para jogos: um ambiente completo onde você constrói mundos interativos sem começar do zero.

Na tela inicial, três áreas principais dominam o espaço de trabalho:

1. **Viewport** - Sua janela para o mundo do jogo. Ao arrastar com o botão direito, você gira a câmera; com o scroll do mouse, zoom in/out. É aqui que você posiciona personagens e objetos.

2. **Content Browser** (aba inferior) - A biblioteca de assets. Pasta `StarterContent` contém modelos 3D, materiais e sons pré-fabricados. Arraste um cubo para o Viewport e ele aparece instantaneamente no jogo.

3. **Details Panel** (lado direito) - As propriedades do objeto selecionado. Se você clicar no cubo que acabou de criar, verá opções como Location (X=0, Y=0, Z=0) e Scale (1,1,1). Mude Z para 100 e o cubo voará para cima.

Vamos criar um exemplo prático. Selecione o cubo e no Details Panel:
1. Em Physics, marque "Simulate Physics"
2. Clique no ícone de play (topo da tela)

O cubo agora cai realisticamente, demonstrando o sistema de física integrado. Para pará-lo, pressione ESC.

Erro comum: esquecer de salvar o nível. Se você fechar sem salvar, verá a mensagem:
```
The current level has unsaved changes. Would you like to save before exiting?
[Don't Save] [Cancel] [Save]
```

Sempre dê um nome descritivo ao salvar (File > Save Current). Níveis sem nome aparecem como "Untitled" e são fáceis de perder.

A barra de ferramentas superior contém atalhos essenciais:
- **Cinematics** - Para criar cutscenes
- **Build** - Compila luzes e caminhos para IA
- **Play** - Testa o jogo na janela atual

Experimente adicionar luz: arraste uma "PointLight" do Content Browser para perto do cubo. No Details Panel, ajuste a propriedade "Intensity" para 5000. O cubo agora é iluminado dinamicamente.

O Blueprint Editor (aberto com duplo clique em qualquer Blueprint) merece atenção especial. Embora estejamos focando em C++, os Blueprints são complementares. Eles usam nós visuais para lógica, enquanto nosso código C++ oferece desempenho e controle.

Para ver o poder da integração, crie um material básico:
1. No Content Browser, clique direito > Materials & Textures > Material
2. Nomeie como "GlowingRed"
3. Dê duplo clique e na janela que abre, clique no nó "Constant3Vector"
4. Conecte-o ao "Base Color" e ajuste para vermelho (R=1, G=0, B=0)
5. Salve e feche, depois arraste o material para o cubo

O cubo agora brilha em vermelho - uma demonstração simples do pipeline de renderização.

Por fim, o **World Outliner** (canto superior direito) lista todos os objetos na cena. Renomeie seu cubo para "PlayerCube" clicando nele no Outliner. Isso evita confusão quando a cena ficar complexa.

Exercício: Crie uma cena com:
1. Um plano (em Shapes, drag "Plane" para o Viewport)
2. 10 cubos empilhados (set Location Z incremental)
3. Uma luz direcional (em Lights, "DirectionalLight")
4. Todos cubos com física ativada
5. Aperte Play e observe a torre desmoronar

Solução comentada:
- O plano serve como chão (ajuste Scale para 10,10,1)
- Cada cubo deve ter Location Z aumentando em 100 unidades (0, 100, 200...)
- A luz direcional simula o sol (rotation Y=45 para sombras diagonais)
- Ative "Simulate Physics" em cada cubo no Details Panel
- A física integrada calcula automaticamente colisões e gravidade