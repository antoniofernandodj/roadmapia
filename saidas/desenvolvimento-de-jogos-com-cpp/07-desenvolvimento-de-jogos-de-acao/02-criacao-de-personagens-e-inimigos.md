## Criação de personagens e inimigos

Um jogo de ação precisa de dois elementos fundamentais: o personagem controlado pelo jogador e os inimigos que ele enfrentará. Vamos criar ambos usando C++ na Unreal Engine, começando pelo personagem principal.

### Criando o personagem do jogador

Na Unreal Engine, personagens são criados através da classe `ACharacter`, que já inclui componentes essenciais como movimento e colisão. Veja como criar uma classe básica:

```cpp
// Hero.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "Hero.generated.h"

UCLASS()
class ACTIONGAME_API AHero : public ACharacter
{
    GENERATED_BODY()

public:
    AHero();

    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;

    void MoveForward(float Value);
    void MoveRight(float Value);
    void StartJump();
    void StopJump();
};
```

A implementação fica no arquivo .cpp:

```cpp
// Hero.cpp
#include "Hero.h"
#include "Components/InputComponent.h"

AHero::AHero()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AHero::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAxis("MoveForward", this, &AHero::MoveForward);
    PlayerInputComponent->BindAxis("MoveRight", this, &AHero::MoveRight);
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &AHero::StartJump);
    PlayerInputComponent->BindAction("Jump", IE_Released, this, &AHero::StopJump);
}

void AHero::MoveForward(float Value)
{
    AddMovementInput(GetActorForwardVector(), Value);
}

void AHero::MoveRight(float Value)
{
    AddMovementInput(GetActorRightVector(), Value);
}

void AHero::StartJump()
{
    bPressedJump = true;
}

void AHero::StopJump()
{
    bPressedJump = false;
}
```

Erro comum: esquecer de configurar os mapeamentos de entrada no projeto. Se você tentar mover o personagem e nada acontecer, verifique em Edit > Project Settings > Input:

```
Action Mappings:
- Jump: Space Bar

Axis Mappings:
- MoveForward: W (Scale 1.0), S (Scale -1.0)
- MoveRight: A (Scale -1.0), D (Scale 1.0)
```

### Criando inimigos básicos

Para inimigos, usaremos uma classe derivada de `ACharacter` com comportamento simples de perseguição:

```cpp
// Enemy.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "Enemy.generated.h"

UCLASS()
class ACTIONGAME_API AEnemy : public ACharacter
{
    GENERATED_BODY()

public:
    AEnemy();

    virtual void Tick(float DeltaTime) override;

    UPROPERTY(EditAnywhere, Category = "AI")
    float DetectionRange = 1000.0f;

    UPROPERTY(EditAnywhere, Category = "AI")
    float MovementSpeed = 300.0f;

private:
    AActor* Target = nullptr;
};
```

Implementação:

```cpp
// Enemy.cpp
#include "Enemy.h"
#include "Hero.h"
#include "Kismet/GameplayStatics.h"

AEnemy::AEnemy()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AEnemy::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    if (!Target)
    {
        Target = UGameplayStatics::GetPlayerCharacter(GetWorld(), 0);
        return;
    }

    float Distance = FVector::Dist(GetActorLocation(), Target->GetActorLocation());
    
    if (Distance < DetectionRange)
    {
        FVector Direction = (Target->GetActorLocation() - GetActorLocation()).GetSafeNormal();
        AddMovementInput(Direction, MovementSpeed * DeltaTime);
    }
}
```

Esse inimigo básico detecta o jogador quando ele está dentro do alcance (`DetectionRange`) e se move na direção dele. A velocidade é controlada por `MovementSpeed`.

### Adicionando colisão e dano

Vamos modificar o inimigo para causar dano ao tocar no jogador:

```cpp
// Enemy.cpp (adição)
void AEnemy::NotifyActorBeginOverlap(AActor* OtherActor)
{
    Super::NotifyActorBeginOverlap(OtherActor);

    if (AHero* Hero = Cast<AHero>(OtherActor))
    {
        Hero->TakeDamage(10.0f, FDamageEvent(), nullptr, this);
        Destroy(); // Inimigo se destrói após causar dano
    }
}
```

No hero, adicione:

```cpp
// Hero.h (adição)
public:
    virtual float TakeDamage(float DamageAmount, FDamageEvent const& DamageEvent,
        AController* EventInstigator, AActor* DamageCauser) override;
```

```cpp
// Hero.cpp (adição)
float AHero::TakeDamage(float DamageAmount, FDamageEvent const& DamageEvent,
    AController* EventInstigator, AActor* DamageCauser)
{
    // Implemente sua lógica de vida aqui
    UE_LOG(LogTemp, Warning, TEXT("Hero took %f damage!"), DamageAmount);
    return DamageAmount;
}
```

### Exercício prático

1. Crie um novo inimigo que patrulha entre dois pontos ao invés de perseguir o jogador
2. Implemente um sistema onde o inimigo atira projéteis quando o jogador está a uma certa distância
3. Adicione um pequeno delay entre os tiros (cooldown)

Solução parcial para o item 1:

```cpp
// PatrollingEnemy.h
UPROPERTY(EditAnywhere, Category = "AI")
FVector PointA;

UPROPERTY(EditAnywhere, Category = "AI")
FVector PointB;

bool bMovingToA = false;
```

```cpp
// PatrollingEnemy.cpp
void APatrollingEnemy::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    FVector TargetPoint = bMovingToA ? PointA : PointB;
    FVector Direction = (TargetPoint - GetActorLocation()).GetSafeNormal();
    AddMovementInput(Direction, MovementSpeed * DeltaTime);

    if (FVector::Dist(GetActorLocation(), TargetPoint) < 50.0f)
    {
        bMovingToA = !bMovingToA;
    }
}
```