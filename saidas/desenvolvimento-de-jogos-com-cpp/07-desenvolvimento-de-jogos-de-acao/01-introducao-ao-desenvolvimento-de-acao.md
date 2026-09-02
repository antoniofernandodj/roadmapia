## Introdução ao desenvolvimento de ação

Um jogo de ação precisa responder instantaneamente aos comandos do jogador enquanto mantém o controle sobre múltiplos elementos na tela. Vamos implementar um protótipo com um personagem que pode se mover e atirar, demonstrando como estruturar esse fluxo em C++ com Unreal Engine.

Crie uma nova classe `AActionCharacter` derivada de `ACharacter`:

```cpp
// ActionCharacter.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "ActionCharacter.generated.h"

UCLASS()
class ACTIONGAME_API AActionCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    AActionCharacter();

    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;

    void MoveForward(float Value);
    void MoveRight(float Value);
    void StartShooting();
    void StopShooting();

private:
    bool bIsShooting;
    FTimerHandle ShootingTimer;
    void ShootProjectile();
};
```

E a implementação correspondente:

```cpp
// ActionCharacter.cpp
#include "ActionCharacter.h"
#include "Components/InputComponent.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "Projectile.h"

AActionCharacter::AActionCharacter()
{
    bIsShooting = false;
}

void AActionCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAxis("MoveForward", this, &AActionCharacter::MoveForward);
    PlayerInputComponent->BindAxis("MoveRight", this, &AActionCharacter::MoveRight);
    PlayerInputComponent->BindAction("Fire", IE_Pressed, this, &AActionCharacter::StartShooting);
    PlayerInputComponent->BindAction("Fire", IE_Released, this, &AActionCharacter::StopShooting);
}

void AActionCharacter::MoveForward(float Value)
{
    AddMovementInput(GetActorForwardVector(), Value);
}

void AActionCharacter::MoveRight(float Value)
{
    AddMovementInput(GetActorRightVector(), Value);
}

void AActionCharacter::StartShooting()
{
    bIsShooting = true;
    ShootProjectile();
    GetWorld()->GetTimerManager().SetTimer(ShootingTimer, this, &AActionCharacter::ShootProjectile, 0.1f, true);
}

void AActionCharacter::StopShooting()
{
    bIsShooting = false;
    GetWorld()->GetTimerManager().ClearTimer(ShootingTimer);
}

void AActionCharacter::ShootProjectile()
{
    if (!bIsShooting) return;

    FVector SpawnLocation = GetActorLocation() + GetActorForwardVector() * 100.f;
    FRotator SpawnRotation = GetActorRotation();
    
    AProjectile* Projectile = GetWorld()->SpawnActor<AProjectile>(
        AProjectile::StaticClass(), 
        SpawnLocation, 
        SpawnRotation
    );
    
    if (Projectile)
    {
        Projectile->SetOwner(this);
    }
}
```

A classe `AProjectile` (simplificada) seria:

```cpp
// Projectile.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Projectile.generated.h"

UCLASS()
class ACTIONGAME_API AProjectile : public AActor
{
    GENERATED_BODY()
    
public:    
    AProjectile();

    virtual void Tick(float DeltaTime) override;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly)
    class UStaticMeshComponent* Mesh;

    UPROPERTY(EditAnywhere)
    float Speed = 1000.f;

protected:
    virtual void BeginPlay() override;
};
```

```cpp
// Projectile.cpp
#include "Projectile.h"
#include "Components/StaticMeshComponent.h"

AProjectile::AProjectile()
{
    PrimaryActorTick.bCanEverTick = true;

    Mesh = CreateDefaultSubobject<UStaticMeshComponent>("Mesh");
    RootComponent = Mesh;
}

void AProjectile::BeginPlay()
{
    Super::BeginPlay();
    SetLifeSpan(2.0f); // Destrói após 2 segundos
}

void AProjectile::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    AddActorLocalOffset(FVector(Speed * DeltaTime, 0, 0));
}
```

**Configuração necessária no Editor:**

1. Crie os mapeamentos de entrada em `Edit > Project Settings > Input`:
   - Axis Mappings:
     - "MoveForward" com tecla W (Scale 1.0) e S (Scale -1.0)
     - "MoveRight" com tecla A (Scale -1.0) e D (Scale 1.0)
   - Action Mappings:
     - "Fire" com botão do mouse esquerdo

2. Atribua um mesh ao personagem e ao projétil no Blueprint derivado

**Erro comum e correção:**

Se você tentar compilar sem adicionar `#include "Components/InputComponent.h"`, receberá:
```
error C2027: use of undefined type 'UInputComponent'
```

A solução é incluir o cabeçalho correto, como mostrado no código acima.

**Exercício:** Modifique o código para que:
1. O personagem só possa atirar quando estiver no chão (use `IsFalling()`)
2. Cada tiro consuma 1 ponto de energia (comece com 10)
3. Recarregue energia (até 10) quando não estiver atirando

**Solução comentada:**

```cpp
// Adicione no ActionCharacter.h
UPROPERTY(EditAnywhere)
int32 Energy = 10;

// Modifique ShootProjectile()
void AActionCharacter::ShootProjectile()
{
    if (!bIsShooting || GetCharacterMovement()->IsFalling() || Energy <= 0) 
        return;

    Energy--;
    
    // ... resto da implementação existente ...
}

// Modifique StopShooting()
void AActionCharacter::StopShooting()
{
    bIsShooting = false;
    GetWorld()->GetTimerManager().ClearTimer(ShootingTimer);
    
    // Recarrega energia quando não está atirando
    if (!bIsShooting)
    {
        GetWorld()->GetTimerManager().SetTimer(
            ShootingTimer, 
            this, 
            &AActionCharacter::RechargeEnergy, 
            0.5f, 
            true
        );
    }
}

// Adicione nova função
void AActionCharacter::RechargeEnergy()
{
    if (Energy >= 10 || bIsShooting)
    {
        GetWorld()->GetTimerManager().ClearTimer(ShootingTimer);
        return;
    }
    Energy++;
}
```