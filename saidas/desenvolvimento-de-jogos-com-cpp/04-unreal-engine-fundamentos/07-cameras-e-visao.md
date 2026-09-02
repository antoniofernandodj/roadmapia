## Câmeras e visão

Em um jogo, a câmera é o olho do jogador. Ela define o que ele vê e como interage com o mundo. Na Unreal Engine, a câmera é um componente que pode ser adicionado a qualquer ator, permitindo controle preciso sobre o que é exibido na tela.

Vamos começar criando uma câmera básica. Abra o Content Browser e crie um novo Blueprint Class do tipo `Actor`. Nomeie-o como `BP_Camera`. Dentro do Editor de Blueprints, adicione um `Camera Component` ao seu ator. Para isso, clique em `Add Component` e selecione `Camera`. Agora, você pode configurar propriedades como o campo de visão (FOV) e a distância de renderização no `Details Panel`.

```cpp
// BP_Camera Blueprint
Components:
    - Camera (CameraComponent)
        Field of View: 90.0
        Auto Activate for Player: Yes
```

Salve e compile o Blueprint. Agora, arraste o `BP_Camera` para o Viewport e posicione-o onde deseja que a câmera fique. Para que a câmera seja ativada automaticamente quando o jogo começar, marque a opção `Auto Activate for Player` no `Camera Component`.

Se você executar o jogo agora, a câmera será ativada, mas o jogador não poderá controlá-la. Para adicionar controle, precisamos configurar o `Input Mapping`. Vá para `Edit > Project Settings > Input` e adicione novas ações de entrada, como `MoveForward`, `MoveRight`, `Turn`, e `LookUp`. Essas ações serão vinculadas às teclas `WASD` e ao movimento do mouse.

```cpp
// Input Mapping
Axis Mappings:
    MoveForward: W (Scale: 1.0), S (Scale: -1.0)
    MoveRight: A (Scale: -1.0), D (Scale: 1.0)
    Turn: MouseX (Scale: 1.0)
    LookUp: MouseY (Scale: -1.0)
```

Agora, precisamos conectar essas ações ao comportamento da câmera. Volte ao `BP_Camera` e abra o `Event Graph`. Adicione nós para capturar os eventos de entrada e conecte-os a funções que movem e rotacionam a câmera.

```cpp
// BP_Camera Event Graph
Event Tick:
    - MoveForward: Add Movement Input
    - MoveRight: Add Movement Input
    - Turn: Add Controller Yaw Input
    - LookUp: Add Controller Pitch Input
```

Se você tentar mover a câmera agora, ela pode se mover muito rápido ou lento demais. Para ajustar a sensibilidade, vá para `Edit > Project Settings > Input` e ajuste os valores de `Mouse Sensitivity`.

```cpp
// Input Settings
Mouse Sensitivity: 2.0
```

Executando o jogo, você deve ser capaz de mover e rotacionar a câmera livremente. No entanto, se a câmera estiver presa em uma parede ou objeto, você pode precisar configurar colisões. Adicione um `Capsule Component` ao `BP_Camera` e ajuste o raio e a altura para evitar que a câmera atravesse objetos.

```cpp
// BP_Camera Blueprint
Components:
    - Capsule (CapsuleComponent)
        Capsule Radius: 50.0
        Capsule Height: 200.0
```

Salve e compile novamente. Agora, a câmera deve evitar colisões com objetos na cena.

Um erro comum é esquecer de configurar a câmera como a câmera principal. Se você executar o jogo e não ver nada, verifique se a opção `Auto Activate for Player` está marcada no `Camera Component`.

Outro problema comum é a câmera se mover de forma estranha quando o jogador se aproxima de objetos. Isso pode ser corrigido ajustando o `Spring Arm Component`, que mantém a câmera a uma distância fixa do jogador e ajusta automaticamente a posição para evitar obstruções.

```cpp
// BP_Camera Blueprint
Components:
    - SpringArm (SpringArmComponent)
        Target Arm Length: 300.0
        bDoCollisionTest: Yes
```

Com essas configurações, você terá uma câmera funcional que pode ser controlada pelo jogador e evita obstáculos. Agora, vamos criar um exercício para praticar.

**Exercício:** Crie uma nova câmera que siga o jogador a uma distância fixa, mas permita que o jogador rotacione a câmera ao redor do jogador usando o mouse. Dica: Use o `Spring Arm Component` e conecte os eventos de entrada para rotacionar a câmera.

**Solução:**

1. Crie um novo Blueprint Class do tipo `Actor` e nomeie-o como `BP_FollowCamera`.
2. Adicione um `Spring Arm Component` e um `Camera Component` ao ator.
3. Configure o `Spring Arm Component` para ter um `Target Arm Length` de 500.0 e marque `bDoCollisionTest` como `Yes`.
4. No `Event Graph`, conecte os eventos `Turn` e `LookUp` para rotacionar o `Spring Arm Component`.
5. Posicione o `BP_FollowCamera` na cena e marque `Auto Activate for Player` no `Camera Component`.

```cpp
// BP_FollowCamera Blueprint
Components:
    - SpringArm (SpringArmComponent)
        Target Arm Length: 500.0
        bDoCollisionTest: Yes
    - Camera (CameraComponent)
        Auto Activate for Player: Yes
Event Graph:
    Turn: Add Controller Yaw Input (SpringArm)
    LookUp: Add Controller Pitch Input (SpringArm)
```

Agora, ao executar o jogo, a câmera seguirá o jogador e permitirá que ele rotacione a câmera ao redor do jogador.