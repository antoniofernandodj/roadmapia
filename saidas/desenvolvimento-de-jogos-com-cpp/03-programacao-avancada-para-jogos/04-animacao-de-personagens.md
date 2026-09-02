## Animação de personagens

Um personagem estático que desliza pelo cenário sem movimento natural quebra a imersão do jogo. Vamos criar um sistema completo de animação para um personagem 2D na Unreal Engine usando C++, desde a configuração dos sprites até a transição entre estados de movimento.

Primeiro, precisamos preparar os assets de animação. Na pasta Content do seu projeto, crie uma estrutura como:

```
Content/
└── Characters/
    └── Hero/
        ├── Sprites/
        │   ├── Idle.png
        │   ├── Run1.png
        │   ├── Run2.png
        │   └── Jump.png
        └── Animations/
            ├── Hero_Idle.uasset
            ├── Hero_Run.uasset
            └── Hero_Jump.uasset
```

Vamos criar a classe base do personagem. No arquivo `HeroCharacter.h`:

```cpp
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "HeroCharacter.generated.h"

UCLASS()
class PLATFORMER_API AHeroCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    AHeroCharacter();

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Animation")
    class UPaperFlipbookComponent* SpriteComponent;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Animation")
    class UPaperFlipbook* IdleAnimation;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Animation")
    class UPaperFlipbook* RunAnimation;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Animation")
    class UPaperFlipbook* JumpAnimation;

protected:
    virtual void BeginPlay() override;
    virtual void Tick(float DeltaTime) override;
    virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

private:
    void UpdateAnimation();
    FVector PreviousVelocity;
};
```

A implementação em `HeroCharacter.cpp`:

```cpp
#include "HeroCharacter.h"
#include "PaperFlipbookComponent.h"

AHeroCharacter::AHeroCharacter()
{
    PrimaryActorTick.bCanEverTick = true;
    
    SpriteComponent = CreateDefaultSubobject<UPaperFlipbookComponent>(TEXT("SpriteComponent"));
    SpriteComponent->SetupAttachment(RootComponent);
    SpriteComponent->SetRelativeRotation(FRotator(0.0f, 0.0f, -90.0f)); // Ajuste para 2D
}

void AHeroCharacter::BeginPlay()
{
    Super::BeginPlay();
    PreviousVelocity = FVector::ZeroVector;
}

void AHeroCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    UpdateAnimation();
}

void AHeroCharacter::UpdateAnimation()
{
    FVector CurrentVelocity = GetVelocity();
    
    if (!CurrentVelocity.Equals(PreviousVelocity, 0.1f))
    {
        if (CurrentVelocity.IsNearlyZero(1.0f))
        {
            SpriteComponent->SetFlipbook(IdleAnimation);
        }
        else if (!GetCharacterMovement()->IsFalling())
        {
            SpriteComponent->SetFlipbook(RunAnimation);
        }
        else
        {
            SpriteComponent->SetFlipbook(JumpAnimation);
        }
        
        // Inverte o sprite conforme a direção
        if (CurrentVelocity.X < 0.0f)
        {
            SpriteComponent->SetRelativeScale3D(FVector(1.0f, -1.0f, 1.0f));
        }
        else if (CurrentVelocity.X > 0.0f)
        {
            SpriteComponent->SetRelativeScale3D(FVector(1.0f, 1.0f, 1.0f));
        }
        
        PreviousVelocity = CurrentVelocity;
    }
}
```

Um erro comum é esquecer de configurar o `Paper2D` no arquivo `Build.cs`. Se você receber o erro:

```
error LNK2019: unresolved external symbol "__declspec(dllimport) class UClass * __cdecl UPaperFlipbook::StaticClass(void)" 
```

Adicione ao seu `Platformer.Build.cs`:

```csharp
PublicDependencyModuleNames.AddRange(new string[] { 
    "Core", 
    "CoreUObject", 
    "Engine", 
    "InputCore",
    "Paper2D" // Adicione esta linha
});
```

Para testar as animações, crie um Blueprint baseado na sua classe `HeroCharacter` e atribua os flipbooks correspondentes. Quando você mover o personagem, ele automaticamente alternará entre as animações de idle, corrida e pulo.

Vamos adicionar um sistema de animação mais sofisticado com blend spaces. No mesmo projeto, crie uma nova classe `HeroAnimInstance.h`:

```cpp
#pragma once

#include "CoreMinimal.h"
#include "Animation/AnimInstance.h"
#include "HeroAnimInstance.generated.h"

UCLASS()
class PLATFORMER_API UHeroAnimInstance : public UAnimInstance
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Animation")
    float Speed;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Animation")
    bool IsJumping;

    virtual void NativeUpdateAnimation(float DeltaSeconds) override;
};
```

E sua implementação:

```cpp
#include "HeroAnimInstance.h"
#include "HeroCharacter.h"

void UHeroAnimInstance::NativeUpdateAnimation(float DeltaSeconds)
{
    Super::NativeUpdateAnimation(DeltaSeconds);

    AHeroCharacter* Owner = Cast<AHeroCharacter>(TryGetPawnOwner());
    if (Owner)
    {
        Speed = Owner->GetVelocity().Size();
        IsJumping = Owner->GetCharacterMovement()->IsFalling();
    }
}
```

Para conectar tudo, modifique o `HeroCharacter.h` para incluir:

```cpp
UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Animation")
class UHeroAnimInstance* AnimInstance;
```

E no `HeroCharacter.cpp`, atualize o `BeginPlay()`:

```cpp
void AHeroCharacter::BeginPlay()
{
    Super::BeginPlay();
    PreviousVelocity = FVector::ZeroVector;
    
    if (UAnimInstance* Anim = GetMesh()->GetAnimInstance())
    {
        AnimInstance = Cast<UHeroAnimInstance>(Anim);
    }
}
```

**Exercício:** Crie uma animação de ataque que é ativada quando o jogador pressiona o botão de ação. A animação deve interromper o movimento durante sua execução e retornar ao estado anterior ao terminar.

**Solução:**

Adicione ao `HeroCharacter.h`:

```cpp
UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Animation")
class UPaperFlipbook* AttackAnimation;

UFUNCTION(BlueprintCallable, Category = "Animation")
void PlayAttackAnimation();
```

Implementação no `HeroCharacter.cpp`:

```cpp
void AHeroCharacter::PlayAttackAnimation()
{
    if (AttackAnimation && !GetCharacterMovement()->IsFalling())
    {
        SpriteComponent->SetFlipbook(AttackAnimation);
        GetCharacterMovement()->DisableMovement();
        
        // Configura um timer para voltar à animação normal
        FTimerHandle TimerHandle;
        GetWorld()->GetTimerManager().SetTimer(TimerHandle, [this]() {
            UpdateAnimation();
            GetCharacterMovement()->SetMovementMode(MOVE_Walking);
        }, AttackAnimation->GetTotalDuration(), false);
    }
}
```

Conecte a uma entrada no `SetupPlayerInputComponent`:

```cpp
PlayerInputComponent->BindAction("Attack", IE_Pressed, this, &AHeroCharacter::PlayAttackAnimation);
```