## Introdução ao desenvolvimento 2D

Desenvolver jogos 2D é uma jornada que combina criatividade e técnica. Enquanto jogos 3D envolvem complexidade geométrica e física, jogos 2D focam em simplicidade visual e mecânicas de jogo diretas. A Unreal Engine, embora conhecida por seu poder em jogos 3D, também oferece ferramentas robustas para criar experiências 2D envolventes.

### O que define um jogo 2D?

Um jogo 2D é caracterizado por sua representação gráfica em duas dimensões: largura e altura. Isso significa que todos os elementos do jogo — personagens, cenários, objetos — são desenhados em um plano bidimensional. A profundidade é sugerida através de técnicas artísticas, não por cálculos matemáticos de 3D.

Para ilustrar, imagine um jogo de plataforma clássico como Super Mario. O personagem se move horizontalmente e verticalmente, mas não há movimento para frente ou para trás no sentido de profundidade. Essa simplicidade permite que desenvolvedores se concentrem mais na jogabilidade e menos em desafios técnicos complexos.

### Componentes básicos de um jogo 2D

1. **Sprites**: São as imagens que representam personagens, objetos e cenários. Cada sprite é uma bitmap ou uma imagem vetorial que pode ser animada para criar movimento.
2. **Tilemaps**: São matrizes de tiles (blocos gráficos) que compõem o cenário. Eles são eficientes para criar mundos grandes e complexos sem consumir muitos recursos.
3. **Colisões**: Detectam quando dois objetos se tocam, essencial para mecânicas como pular sobre inimigos ou coletar itens.
4. **Câmera**: Controla o que o jogador vê na tela. Em jogos 2D, a câmera geralmente segue o personagem principal ou rola conforme o jogador avança.

### Criando um projeto 2D na Unreal Engine

Vamos começar criando um projeto básico 2D na Unreal Engine. Abra a Unreal Engine e selecione "New Project". Escolha a opção "2D" e nomeie o projeto como "MeuJogo2D". Clique em "Create".

```cpp
// Código básico para criar um sprite em C++
#include "Engine.h"

void AMeuJogo2DGameMode::BeginPlay()
{
    Super::BeginPlay();

    // Carregar um sprite
    UPaperSprite* MeuSprite = LoadObject<UPaperSprite>(nullptr, TEXT("/Game/Sprites/MeuSprite.MeuSprite"));
    if (MeuSprite)
    {
        // Criar um componente de sprite e adicionar ao ator
        UPaperSpriteComponent* SpriteComponent = NewObject<UPaperSpriteComponent>(this);
        SpriteComponent->SetSprite(MeuSprite);
        RootComponent = SpriteComponent;
    }
}
```

### Saída esperada

Após compilar e executar o código, você verá um sprite na tela. Este é o primeiro passo para construir seu jogo 2D.

### Erros comuns e correções

Um erro comum é esquecer de configurar o `RootComponent` para o `SpriteComponent`. Se você fizer isso, o sprite não será renderizado. A mensagem de erro será:

```
LogScript: Error: Attempted to access a null component.
```

Para corrigir, certifique-se de que `RootComponent` está sendo atribuído corretamente, como mostrado no código acima.

### Comparando com jogos 3D

Enquanto jogos 3D usam coordenadas (X, Y, Z), jogos 2D usam apenas (X, Y). Isso simplifica muitos aspectos, como cálculos de física e detecção de colisões. Por exemplo, em um jogo 2D, você pode usar uma simples verificação de limites para detectar colisões, enquanto em 3D, você precisaria de cálculos de interseção mais complexos.

### Exercício

Crie um novo sprite e o posicione em uma coordenada específica na tela. Dica: Use a função `SetWorldLocation` para definir a posição do sprite.

```cpp
void AMeuJogo2DGameMode::BeginPlay()
{
    Super::BeginPlay();

    UPaperSprite* MeuSprite = LoadObject<UPaperSprite>(nullptr, TEXT("/Game/Sprites/MeuSprite.MeuSprite"));
    if (MeuSprite)
    {
        UPaperSpriteComponent* SpriteComponent = NewObject<UPaperSpriteComponent>(this);
        SpriteComponent->SetSprite(MeuSprite);
        RootComponent = SpriteComponent;

        // Posicionar o sprite em (100, 50)
        SpriteComponent->SetWorldLocation(FVector(100.0f, 50.0f, 0.0f));
    }
}
```

### Solução comentada

No código acima, após criar o `SpriteComponent`, usamos `SetWorldLocation` para posicionar o sprite nas coordenadas (100, 50). Isso move o sprite para a posição desejada na tela. A coordenada Z é definida como 0.0f porque estamos trabalhando em 2D.