## Power-ups e coletáveis

Um jogo de plataforma fica sem graça sem itens para coletar e habilidades especiais. Vamos implementar um sistema onde o jogador pode pegar moedas para aumentar sua pontuação e power-ups que dão habilidades temporárias, como invencibilidade ou pulo duplo.

Primeiro, crie uma classe `ACollectible` base para todos os itens coletáveis:

```cpp
// Collectible.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Collectible.generated.h"

UCLASS()
class PLATFORMER2D_API ACollectible : public AActor
{
    GENERATED_BODY()
    
public:    
    ACollectible();

protected:
    virtual void BeginPlay() override;
    
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly)
    class UPaperSpriteComponent* SpriteComponent;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly)
    class UCapsuleComponent* CollisionComponent;

    UFUNCTION()
    void OnOverlapBegin(UPrimitiveComponent* OverlappedComp, 
                       AActor* OtherActor, 
                       UPrimitiveComponent* OtherComp, 
                       int32 OtherBodyIndex, 
                       bool bFromSweep, 
                       const FHitResult& SweepResult);
};
```

A implementação básica:

```cpp
// Collectible.cpp
#include "Collectible.h"
#include "Components/CapsuleComponent.h"
#include "PaperSpriteComponent.h"
#include "PlatformerCharacter.h"

ACollectible::ACollectible()
{
    PrimaryActorTick.bCanEverTick = false;

    CollisionComponent = CreateDefaultSubobject<UCapsuleComponent>(TEXT("CollisionComp"));
    CollisionComponent->InitCapsuleSize(20.0f, 20.0f);
    CollisionComponent->SetCollisionProfileName(TEXT("OverlapAllDynamic"));
    RootComponent = CollisionComponent;

    SpriteComponent = CreateDefaultSubobject<UPaperSpriteComponent>(TEXT("SpriteComp"));
    SpriteComponent->SetupAttachment(RootComponent);
    SpriteComponent->SetRelativeLocation(FVector(0.0f, 0.0f, 10.0f));

    CollisionComponent->OnComponentBeginOverlap.AddDynamic(this, &ACollectible::OnOverlapBegin);
}

void ACollectible::BeginPlay()
{
    Super::BeginPlay();
}

void ACollectible::OnOverlapBegin(UPrimitiveComponent* OverlappedComp, 
                                AActor* OtherActor, 
                                UPrimitiveComponent* OtherComp, 
                                int32 OtherBodyIndex, 
                                bool bFromSweep, 
                                const FHitResult& SweepResult)
{
    if (APlatformerCharacter* Player = Cast<APlatformerCharacter>(OtherActor))
    {
        // Base class does nothing - children implement specific behavior
        Destroy();
    }
}
```

Agora vamos criar uma moeda coletável que aumenta a pontuação:

```cpp
// Coin.h
#include "Collectible.h"
#include "Coin.generated.h"

UCLASS()
class PLATFORMER2D_API ACoin : public ACollectible
{
    GENERATED_BODY()

public:
    ACoin();

protected:
    virtual void BeginPlay() override;

    UPROPERTY(EditAnywhere, Category = "Coin")
    int32 ScoreValue = 10;

    virtual void OnOverlapBegin(UPrimitiveComponent* OverlappedComp, 
                              AActor* OtherActor, 
                              UPrimitiveComponent* OtherComp, 
                              int32 OtherBodyIndex, 
                              bool bFromSweep, 
                              const FHitResult& SweepResult) override;
};
```

Implementação da moeda:

```cpp
// Coin.cpp
#include "Coin.h"
#include "PlatformerCharacter.h"
#include "Kismet/GameplayStatics.h"

ACoin::ACoin()
{
    static ConstructorHelpers::FObjectFinder<UPaperSprite> CoinSprite(TEXT("/Game/Sprites/Coin_Sprite"));
    if (CoinSprite.Succeeded())
    {
        SpriteComponent->SetSprite(CoinSprite.Object);
    }
}

void ACoin::OnOverlapBegin(UPrimitiveComponent* OverlappedComp, 
                         AActor* OtherActor, 
                         UPrimitiveComponent* OtherComp, 
                         int32 OtherBodyIndex, 
                         bool bFromSweep, 
                         const FHitResult& SweepResult)
{
    if (APlatformerCharacter* Player = Cast<APlatformerCharacter>(OtherActor))
    {
        Player->AddScore(ScoreValue);
        UGameplayStatics::PlaySound2D(this, CollectSound);
        Destroy();
    }
}
```

Para um power-up de invencibilidade temporária:

```cpp
// InvincibilityPowerUp.h
#include "Collectible.h"
#include "InvincibilityPowerUp.generated.h"

UCLASS()
class PLATFORMER2D_API AInvincibilityPowerUp : public ACollectible
{
    GENERATED_BODY()

public:
    AInvincibilityPowerUp();

protected:
    UPROPERTY(EditAnywhere, Category = "PowerUp")
    float Duration = 5.0f;

    virtual void OnOverlapBegin(UPrimitiveComponent* OverlappedComp, 
                              AActor* OtherActor, 
                              UPrimitiveComponent* OtherComp, 
                              int32 OtherBodyIndex, 
                              bool bFromSweep, 
                              const FHitResult& SweepResult) override;
};
```

Implementação do power-up:

```cpp
// InvincibilityPowerUp.cpp
#include "InvincibilityPowerUp.h"
#include "PlatformerCharacter.h"
#include "Components/TimelineComponent.h"

AInvincibilityPowerUp::AInvincibilityPowerUp()
{
    static ConstructorHelpers::FObjectFinder<UPaperSprite> PowerUpSprite(TEXT("/Game/Sprites/PowerUp_Sprite"));
    if (PowerUpSprite.Succeeded())
    {
        SpriteComponent->SetSprite(PowerUpSprite.Object);
        SpriteComponent->SetSpriteColor(FLinearColor::Blue);
    }
}

void AInvincibilityPowerUp::OnOverlapBegin(UPrimitiveComponent* OverlappedComp, 
                                         AActor* OtherActor, 
                                         UPrimitiveComponent* OtherComp, 
                                         int32 OtherBodyIndex, 
                                         bool bFromSweep, 
                                         const FHitResult& SweepResult)
{
    if (APlatformerCharacter* Player = Cast<APlatformerCharacter>(OtherActor))
    {
        Player->ActivateInvincibility(Duration);
        Destroy();
    }
}
```

No personagem do jogador, adicione:

```cpp
// PlatformerCharacter.h
public:
    UFUNCTION(BlueprintCallable)
    void ActivateInvincibility(float Duration);

    UFUNCTION(BlueprintCallable)
    void AddScore(int32 Amount);

    UPROPERTY(BlueprintReadOnly)
    bool bIsInvincible = false;

private:
    FTimerHandle InvincibilityTimerHandle;

    UFUNCTION()
    void EndInvincibility();
```

Implementação:

```cpp
// PlatformerCharacter.cpp
void APlatformerCharacter::ActivateInvincibility(float Duration)
{
    bIsInvincible = true;
    GetWorld()->GetTimerManager().SetTimer(InvincibilityTimerHandle, 
                                         this, 
                                         &APlatformerCharacter::EndInvincibility, 
                                         Duration, 
                                         false);
    
    // Visual feedback
    SpriteComponent->SetSpriteColor(FLinearColor::Yellow);
}

void APlatformerCharacter::EndInvincibility()
{
    bIsInvincible = false;
    SpriteComponent->SetSpriteColor(FLinearColor::White);
}

void APlatformerCharacter::AddScore(int32 Amount)
{
    CurrentScore += Amount;
    OnScoreChanged.Broadcast(CurrentScore);
}
```

Erro comum: esquecer de configurar a colisão corretamente pode fazer os itens não serem coletados. A mensagem de erro será:

```
LogCollision: Warning: Collision Enabled (NoCollision) on 'Coin_1' but overlapping is enabled.
```

Para corrigir, sempre defina o perfil de colisão no construtor:

```cpp
CollisionComponent->SetCollisionProfileName(TEXT("OverlapAllDynamic"));
```

**Exercício**: Crie um power-up de pulo duplo que permite ao jogador pular uma segunda vez no ar. O power-up deve durar 10 segundos e mostrar um efeito visual diferente no personagem.

**Solução**:

```cpp
// DoubleJumpPowerUp.h
UCLASS()
class PLATFORMER2D_API ADoubleJumpPowerUp : public ACollectible
{
    // Similar ao InvincibilityPowerUp, com Duration = 10.0f
};

// DoubleJumpPowerUp.cpp
void ADoubleJumpPowerUp::OnOverlapBegin(...)
{
    if (APlatformerCharacter* Player = Cast<APlatformerCharacter>(OtherActor))
    {
        Player->ActivateDoubleJump(Duration);
        Destroy();
    }
}

// PlatformerCharacter.h
public:
    UFUNCTION(BlueprintCallable)
    void ActivateDoubleJump(float Duration);

    UPROPERTY(BlueprintReadOnly)
    bool bHasDoubleJump = false;

private:
    FTimerHandle DoubleJumpTimerHandle;
    UFUNCTION()
    void EndDoubleJump();

// PlatformerCharacter.cpp
void APlatformerCharacter::ActivateDoubleJump(float Duration)
{
    bHasDoubleJump = true;
    GetWorldTimerManager().SetTimer(DoubleJumpTimerHandle, 
                                  this, 
                                  &APlatformerCharacter::EndDoubleJump, 
                                  Duration, 
                                  false);
    SpriteComponent->SetSpriteColor(FLinearColor::Green);
}

void APlatformerCharacter::EndDoubleJump()
{
    bHasDoubleJump = false;
    SpriteComponent->SetSpriteColor(FLinearColor::White);
}

// Modifique também a lógica de pulo para verificar bHasDoubleJump
```