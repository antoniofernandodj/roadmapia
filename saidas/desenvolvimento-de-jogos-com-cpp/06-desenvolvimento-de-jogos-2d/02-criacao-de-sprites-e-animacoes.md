## Criação de sprites e animações

Sprites são os elementos visuais fundamentais em jogos 2D. Vamos criar um personagem que pode ser animado para andar, pular e realizar outras ações. Na Unreal Engine, trabalhamos com sprites através da classe `UPaperSpriteComponent`.

Primeiro, crie um novo C++ class derivando de `Actor` (se ainda não tiver um projeto 2D configurado, volte ao capítulo anterior). Chamaremos nossa classe de `SpriteCharacter`:

```cpp
// SpriteCharacter.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "PaperSpriteComponent.h"
#include "SpriteCharacter.generated.h"

UCLASS()
class MEUJOGO2D_API ASpriteCharacter : public AActor
{
    GENERATED_BODY()
    
public:
    ASpriteCharacter();

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Sprite")
    UPaperSpriteComponent* SpriteComponent;

protected:
    virtual void BeginPlay() override;
};
```

A implementação no arquivo .cpp:

```cpp
// SpriteCharacter.cpp
#include "SpriteCharacter.h"

ASpriteCharacter::ASpriteCharacter()
{
    PrimaryActorTick.bCanEverTick = true;

    // Cria o componente de sprite
    SpriteComponent = CreateDefaultSubobject<UPaperSpriteComponent>(TEXT("SpriteComponent"));
    
    // Define como root component
    RootComponent = SpriteComponent;
    
    // Configuração básica do sprite
    SpriteComponent->SetSpriteColor(FLinearColor::White);
    SpriteComponent->SetRelativeRotation(FRotator(0.0f, 0.0f, -90.0f)); // Ajuste para visão 2D
}
```

ERRO COMUM: Se você esquecer de definir `RootComponent = SpriteComponent`, receberá o erro:
```
LogActor: Warning: No root component found for ASpriteCharacter. Actor won't be able to move or attach components.
```

Para ver seu sprite na tela, vá para o editor e arraste uma instância da classe `SpriteCharacter` para o nível. Mas ainda não verá nada - precisamos atribuir um sprite real.

### Carregando um sprite

Na pasta Content do seu projeto, crie uma pasta Sprites e importe uma imagem (PNG recomendado). No editor, selecione a imagem e clique em "Create Sprite".

Agora modifique o construtor para carregar o sprite automaticamente:

```cpp
ASpriteCharacter::ASpriteCharacter()
{
    // ... (código anterior)
    
    // Carrega o sprite automaticamente
    static ConstructorHelpers::FObjectFinder<UPaperSprite> SpriteAsset(TEXT("/Game/Sprites/MyCharacterSprite.MyCharacterSprite"));
    if (SpriteAsset.Succeeded())
    {
        SpriteComponent->SetSprite(SpriteAsset.Object);
    }
    else
    {
        UE_LOG(LogTemp, Warning, TEXT("Failed to load sprite!"));
    }
}
```

### Criando animações

Para animar nosso personagem, usaremos flipbooks - sequências de sprites que formam uma animação. Crie uma pasta Animations e importe várias imagens para uma sequência de animação.

No editor:
1. Selecione todas as sprites da animação
2. Clique em Paper2D > Create Flipbook
3. Nomeie como "Run_Flipbook"

Agora vamos adicionar animação ao nosso código:

```cpp
// Adicione no .h
UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Animation")
class UPaperFlipbookComponent* FlipbookComponent;

// Modifique o construtor no .cpp
ASpriteCharacter::ASpriteCharacter()
{
    PrimaryActorTick.bCanEverTick = true;

    FlipbookComponent = CreateDefaultSubobject<UPaperFlipbookComponent>(TEXT("FlipbookComponent"));
    RootComponent = FlipbookComponent;

    // Carrega flipbook de corrida
    static ConstructorHelpers::FObjectFinder<UPaperFlipbook> RunFlipbookAsset(TEXT("/Game/Animations/Run_Flipbook.Run_Flipbook"));
    if (RunFlipbookAsset.Succeeded())
    {
        FlipbookComponent->SetFlipbook(RunFlipbookAsset.Object);
    }
}
```

### Controlando animações

Vamos adicionar um método para trocar animações:

```cpp
// No .h
UFUNCTION(BlueprintCallable, Category = "Animation")
void SetAnimation(UPaperFlipbook* NewAnimation);

// Implementação no .cpp
void ASpriteCharacter::SetAnimation(UPaperFlipbook* NewAnimation)
{
    if(FlipbookComponent && NewAnimation)
    {
        FlipbookComponent->SetFlipbook(NewAnimation);
    }
}
```

Agora você pode criar diferentes flipbooks (Idle, Run, Jump) e trocá-los conforme as ações do jogador.

### Exercício prático

1. Crie um personagem com três animações: Idle (parado), Run (correndo) e Jump (pulando)
2. Implemente um controle básico que:
   - Muda para Run quando a tecla D é pressionada
   - Muda para Jump quando Espaço é pressionado
   - Volta para Idle quando nenhuma tecla está pressionada

Solução comentada:

```cpp
// No .h
public:
    UPROPERTY(EditAnywhere, BlueprintReadOnly)
    UPaperFlipbook* IdleAnimation;

    UPROPERTY(EditAnywhere, BlueprintReadOnly)
    UPaperFlipbook* RunAnimation;

    UPROPERTY(EditAnywhere, BlueprintReadOnly)
    UPaperFlipbook* JumpAnimation;

    void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;

private:
    void MoveRight(float Value);
    void Jump();

// No .cpp (adicionar após construtor)
void ASpriteCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);
    
    PlayerInputComponent->BindAxis("MoveRight", this, &ASpriteCharacter::MoveRight);
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &ASpriteCharacter::Jump);
}

void ASpriteCharacter::MoveRight(float Value)
{
    if(Value != 0.0f)
    {
        SetAnimation(RunAnimation);
    }
    else
    {
        SetAnimation(IdleAnimation);
    }
}

void ASpriteCharacter::Jump()
{
    SetAnimation(JumpAnimation);
    // Aqui você implementaria a física real do pulo
}
```

Lembre-se de configurar as inputs no Project Settings e atribuir os flipbooks no editor para cada instância do personagem.