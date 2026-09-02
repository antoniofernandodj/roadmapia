## Renderização básica: sprites e texturas

Quando você vê um personagem se movendo na tela, o que está realmente acontecendo é uma sequência de imagens sendo desenhadas em posições ligeiramente diferentes a cada frame. No Unreal Engine, essas imagens são chamadas de **sprites** - elementos gráficos 2D que compõem os objetos do seu jogo.

Vamos criar um sprite simples para um personagem. Primeiro, precisamos de uma textura (arquivo de imagem). No Unreal Editor:

1. Clique com o botão direito na pasta Content
2. Selecione "Import to /Game"
3. Escolha um arquivo PNG (por exemplo, "Hero.png" de 64x64 pixels)

Agora vamos criar um Blueprint que usa este sprite. Crie um novo Blueprint do tipo "Actor" e adicione um componente "Paper Sprite":

```cpp
// No arquivo Hero.h
#include "PaperSpriteComponent.h"

UCLASS()
class MYGAME_API AHero : public AActor
{
    GENERATED_BODY()
    
public:
    AHero();
    
    UPROPERTY(VisibleAnywhere)
    UPaperSpriteComponent* Sprite;
};
```

```cpp
// No arquivo Hero.cpp
AHero::AHero()
{
    PrimaryActorTick.bCanEverTick = true;

    Sprite = CreateDefaultSubobject<UPaperSpriteComponent>(TEXT("Sprite"));
    RootComponent = Sprite;
    
    // Carrega a textura que importamos
    static ConstructorHelpers::FObjectFinder<UPaperSprite> SpriteAsset(TEXT("/Game/Hero.Hero"));
    if (SpriteAsset.Succeeded())
    {
        Sprite->SetSprite(SpriteAsset.Object);
    }
}
```

Um erro comum é esquecer de configurar o RootComponent, resultando neste erro:
```
LogScript: Error: No root component found for MyHero. Owning actor will be deleted
```
A solução é sempre definir um componente como raiz, como fizemos com `RootComponent = Sprite`.

Para entender como o sprite é renderizado, precisamos falar sobre o sistema de coordenadas:

1. **Coordenadas de mundo**: Posição absoluta no nível (em Unreal Units, onde 1uu = 1cm)
2. **Coordenadas de tela**: Posição relativa à janela de visualização
3. **Pivot point**: Ponto de ancoragem do sprite (geralmente centro ou base)

Vamos fazer nosso sprite se mover horizontalmente:

```cpp
// No Hero.cpp
void AHero::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    
    FVector NewLocation = GetActorLocation();
    NewLocation.X += 100.0f * DeltaTime; // Move 100 uu por segundo
    SetActorLocation(NewLocation);
}
```

A saída será um sprite movendo-se suavemente da esquerda para a direita. O parâmetro DeltaTime garante que o movimento seja consistente independente do FPS.

**Transformações importantes** que podemos aplicar a sprites:
- Translação (`SetActorLocation`)
- Rotação (`SetActorRotation`)
- Escala (`SetActorScale3D`)

Experimente modificar o código para girar o sprite enquanto ele se move:
```cpp
FRotator NewRotation = GetActorRotation();
NewRotation.Yaw += 180.0f * DeltaTime; // Gira 180 graus por segundo
SetActorRotation(NewRotation);
```

Para trabalhar com múltiplos sprites (como animações), criamos um Flipbook:

1. Importe uma série de imagens nomeadas sequencialmente (Hero_01.png, Hero_02.png...)
2. Clique com o botão direito e selecione "Paper2D > Sprite Flipbook"
3. No Blueprint, troque o PaperSpriteComponent por PaperFlipbookComponent

```cpp
// Substitua no Hero.h
UPROPERTY(VisibleAnywhere)
UPaperFlipbookComponent* Flipbook;

// E no construtor
Flipbook = CreateDefaultSubobject<UPaperFlipbookComponent>(TEXT("Flipbook"));
RootComponent = Flipbook;

static ConstructorHelpers::FObjectFinder<UPaperFlipbook> FlipbookAsset(TEXT("/Game/Hero_Anim.Hero_Anim"));
if (FlipbookAsset.Succeeded())
{
    Flipbook->SetFlipbook(FlipbookAsset.Object);
}
```

**Exercício**: Crie um sprite que:
1. Se mova verticalmente quando pressionar W/S
2. Gire 90 graus ao pressionar Espaço
3. Dobre de tamanho ao pressionar E

Solução comentada:
```cpp
// No Hero.h
void MoveVertical(float Value);
void Rotate90();
void DoubleSize();

// No Hero.cpp (adicionar ao SetupPlayerInputComponent)
PlayerInputComponent->BindAxis("MoveVertical", this, &AHero::MoveVertical);
PlayerInputComponent->BindAction("Rotate", IE_Pressed, this, &AHero::Rotate90);
PlayerInputComponent->BindAction("Enlarge", IE_Pressed, this, &AHero::DoubleSize);

void AHero::MoveVertical(float Value)
{
    FVector NewLocation = GetActorLocation();
    NewLocation.Y += Value * 100.0f * DeltaTime;
    SetActorLocation(NewLocation);
}

void AHero::Rotate90()
{
    FRotator NewRotation = GetActorRotation();
    NewRotation.Yaw += 90.0f;
    SetActorRotation(NewRotation);
}

void AHero::DoubleSize()
{
    FVector NewScale = GetActorScale3D() * 2.0f;
    SetActorScale3D(NewScale);
}
```