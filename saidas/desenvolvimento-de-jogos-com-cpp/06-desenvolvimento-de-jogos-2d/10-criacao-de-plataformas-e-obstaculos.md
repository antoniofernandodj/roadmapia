## Criação de plataformas e obstáculos

Neste momento, você já tem um personagem que pode se mover pela tela, mas falta o elemento principal de um jogo de plataforma: as plataformas em si. Vamos criar um sistema onde o jogador precisa pular entre plataformas para progredir.

### Criando uma plataforma básica

Comece criando uma nova classe `APlatform` derivada de `AActor`:

```cpp
// Platform.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Platform.generated.h"

UCLASS()
class MYGAME_API APlatform : public AActor
{
    GENERATED_BODY()
    
public:
    APlatform();

protected:
    virtual void BeginPlay() override;

private:
    UPROPERTY(VisibleAnywhere)
    UStaticMeshComponent* PlatformMesh;
};
```

E a implementação:

```cpp
// Platform.cpp
#include "Platform.h"
#include "Components/StaticMeshComponent.h"

APlatform::APlatform()
{
    PrimaryActorTick.bCanEverTick = false;
    
    PlatformMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("PlatformMesh"));
    RootComponent = PlatformMesh;

    static ConstructorHelpers::FObjectFinder<UStaticMesh> PlatformAsset(
        TEXT("/Engine/BasicShapes/Cube"));
    
    if (PlatformAsset.Succeeded())
    {
        PlatformMesh->SetStaticMesh(PlatformAsset.Object);
        PlatformMesh->SetRelativeScale3D(FVector(3.0f, 3.0f, 0.2f));
    }
}

void APlatform::BeginPlay()
{
    Super::BeginPlay();
}
```

Este código cria uma plataforma usando um cubo básico do Unreal, achatado para parecer uma plataforma. Se você esquecer de definir o `RootComponent`, verá este erro:

```
LogActor: Warning: No root component found for APlatform. Actor won't be able to move or attach components.
```

### Adicionando colisão

Para que o personagem possa pisar na plataforma, precisamos configurar a colisão:

```cpp
// No construtor, após configurar a malha
PlatformMesh->SetCollisionProfileName(TEXT("BlockAll"));
PlatformMesh->SetGenerateOverlapEvents(false);
```

### Criando múltiplas plataformas

Em seu `GameMode`, você pode gerar plataformas programaticamente:

```cpp
// MyGameGameMode.h
public:
    UFUNCTION(BlueprintCallable)
    void GeneratePlatforms(int32 Count, float Spacing);

// MyGameGameMode.cpp
void AMyGameGameMode::GeneratePlatforms(int32 Count, float Spacing)
{
    for (int32 i = 0; i < Count; i++)
    {
        FVector Location(0.0f, i * Spacing, 50.0f);
        GetWorld()->SpawnActor<APlatform>(APlatform::StaticClass(), Location, FRotator::ZeroRotator);
    }
}
```

Chame esta função no `BeginPlay` do seu GameMode para criar 5 plataformas espaçadas:

```cpp
GeneratePlatforms(5, 300.0f);
```

### Plataformas móveis

Vamos criar uma plataforma que se move entre dois pontos:

```cpp
// MovingPlatform.h
UCLASS()
class MYGAME_API AMovingPlatform : public APlatform
{
    GENERATED_BODY()
    
public:
    AMovingPlatform();

protected:
    virtual void BeginPlay() override;
    virtual void Tick(float DeltaTime) override;

private:
    FVector StartLocation;
    UPROPERTY(EditAnywhere)
    FVector TargetOffset = FVector(0.0f, 300.0f, 0.0f);
    UPROPERTY(EditAnywhere)
    float Speed = 100.0f;
};
```

Implementação:

```cpp
// MovingPlatform.cpp
AMovingPlatform::AMovingPlatform()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AMovingPlatform::BeginPlay()
{
    Super::BeginPlay();
    StartLocation = GetActorLocation();
}

void AMovingPlatform::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    
    FVector TargetLocation = StartLocation + TargetOffset;
    FVector CurrentLocation = GetActorLocation();
    FVector Direction = (TargetLocation - CurrentLocation).GetSafeNormal();
    
    FVector Movement = Direction * Speed * DeltaTime;
    
    if (FVector::DistSquared(CurrentLocation + Movement, StartLocation) > 
        FVector::DistSquared(TargetLocation, StartLocation))
    {
        Movement = TargetLocation - CurrentLocation;
        TargetOffset = -TargetOffset;
    }
    
    SetActorLocation(CurrentLocation + Movement);
}
```

### Obstáculos perigosos

Para criar um obstáculo que causa dano quando tocado:

```cpp
// Hazard.h
UCLASS()
class MYGAME_API AHazard : public AActor
{
    GENERATED_BODY()
    
public:
    AHazard();

    UFUNCTION()
    void OnOverlapBegin(UPrimitiveComponent* OverlappedComponent, AActor* OtherActor, 
        UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep, 
        const FHitResult& SweepResult);

protected:
    virtual void BeginPlay() override;

private:
    UPROPERTY(VisibleAnywhere)
    UStaticMeshComponent* HazardMesh;
};
```

Implementação:

```cpp
// Hazard.cpp
AHazard::AHazard()
{
    HazardMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("HazardMesh"));
    RootComponent = HazardMesh;

    static ConstructorHelpers::FObjectFinder<UStaticMesh> HazardAsset(
        TEXT("/Engine/BasicShapes/Cube"));
    
    if (HazardAsset.Succeeded())
    {
        HazardMesh->SetStaticMesh(HazardAsset.Object);
        HazardMesh->SetRelativeScale3D(FVector(1.0f, 1.0f, 0.2f));
    }
    
    HazardMesh->SetCollisionProfileName(TEXT("OverlapAll"));
    HazardMesh->OnComponentBeginOverlap.AddDynamic(this, &AHazard::OnOverlapBegin);
}

void AHazard::BeginPlay()
{
    Super::BeginPlay();
}

void AHazard::OnOverlapBegin(UPrimitiveComponent* OverlappedComponent, AActor* OtherActor, 
    UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep, 
    const FHitResult& SweepResult)
{
    if (OtherActor && OtherActor != this)
    {
        // Implemente a lógica de dano aqui
        UE_LOG(LogTemp, Warning, TEXT("Player hit hazard!"));
    }
}
```

### Exercício prático

Crie um sistema onde plataformas aparecem e desaparecem em intervalos regulares. A plataforma deve:
1. Ficar visível por 3 segundos
2. Desaparecer por 2 segundos
3. Repetir este ciclo indefinidamente

Use `FTimerHandle` para controlar os tempos e `SetActorHiddenInGame` para alternar a visibilidade.

**Solução:**

```cpp
// BlinkingPlatform.h
UCLASS()
class MYGAME_API ABlinkingPlatform : public APlatform
{
    GENERATED_BODY()
    
public:
    ABlinkingPlatform();

protected:
    virtual void BeginPlay() override;

private:
    FTimerHandle VisibilityTimer;
    bool bIsVisible;
    
    void ToggleVisibility();
};

// BlinkingPlatform.cpp
ABlinkingPlatform::ABlinkingPlatform() : bIsVisible(true) {}

void ABlinkingPlatform::BeginPlay()
{
    Super::BeginPlay();
    GetWorld()->GetTimerManager().SetTimer(VisibilityTimer, this, 
        &ABlinkingPlatform::ToggleVisibility, 3.0f, true);
}

void ABlinkingPlatform::ToggleVisibility()
{
    bIsVisible = !bIsVisible;
    SetActorHiddenInGame(!bIsVisible);
    SetActorEnableCollision(bIsVisible);
    
    float NextToggleTime = bIsVisible ? 3.0f : 2.0f;
    GetWorld()->GetTimerManager().SetTimer(VisibilityTimer, this, 
        &ABlinkingPlatform::ToggleVisibility, NextToggleTime, false);
}
```