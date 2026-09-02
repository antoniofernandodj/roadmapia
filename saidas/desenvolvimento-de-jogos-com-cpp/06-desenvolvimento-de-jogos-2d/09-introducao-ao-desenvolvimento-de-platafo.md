## Introdução ao desenvolvimento de plataformas

Vamos começar criando um cenário básico para um jogo de plataformas 2D. O primeiro elemento essencial é uma plataforma estática onde o personagem poderá se movimentar. Na Unreal Engine, criaremos isso usando C++ puro.

### Criando uma plataforma básica

Primeiro, vamos definir a classe `APlatform` que herdará de `AActor`. Este será o bloco fundamental do nosso cenário:

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

A implementação no arquivo `.cpp`:

```cpp
// Platform.cpp
#include "Platform.h"
#include "Components/StaticMeshComponent.h"

APlatform::APlatform()
{
    PrimaryActorTick.bCanEverTick = false;
    
    PlatformMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("PlatformMesh"));
    RootComponent = PlatformMesh;

    static ConstructorHelpers::FObjectFinder<UStaticMesh> MeshAsset(
        TEXT("StaticMesh'/Engine/BasicShapes/Cube.Cube'"));
    if (MeshAsset.Succeeded())
    {
        PlatformMesh->SetStaticMesh(MeshAsset.Object);
        PlatformMesh->SetRelativeScale3D(FVector(5.0f, 1.0f, 0.2f));
    }
}
```

Este código cria uma plataforma retangular usando um cubo básico redimensionado. Se você esquecer de definir o `RootComponent`, receberá este erro comum:

```
LogActor: Warning: No root component found for APlatform. Actor won't be spawned!
```

### Configurando colisões

Para que o personagem possa interagir com a plataforma, precisamos configurar as colisões:

```cpp
// Adicione no construtor, após SetStaticMesh
PlatformMesh->SetCollisionProfileName(TEXT("BlockAllDynamic"));
PlatformMesh->SetGenerateOverlapEvents(false);
```

Isso fará com que a plataforma bloqueie qualquer objeto dinâmico (como o personagem) mas não dispare eventos de overlap.

### Criando múltiplas plataformas

Vamos agora criar um ator que gerará uma sequência de plataformas:

```cpp
// PlatformGenerator.h
UCLASS()
class MYGAME_API APlatformGenerator : public AActor
{
    GENERATED_BODY()
    
public:    
    APlatformGenerator();

protected:
    virtual void BeginPlay() override;

    UPROPERTY(EditAnywhere, Category="Platforms")
    int32 PlatformCount = 5;

    UPROPERTY(EditAnywhere, Category="Platforms")
    float PlatformSpacing = 300.0f;
};
```

Implementação:

```cpp
// PlatformGenerator.cpp
#include "PlatformGenerator.h"
#include "Platform.h"

APlatformGenerator::APlatformGenerator()
{
    PrimaryActorTick.bCanEverTick = false;
}

void APlatformGenerator::BeginPlay()
{
    Super::BeginPlay();
    
    for(int32 i = 0; i < PlatformCount; ++i)
    {
        FVector Location = GetActorLocation() + FVector(0.0f, i * PlatformSpacing, 0.0f);
        GetWorld()->SpawnActor<APlatform>(Location, FRotator::ZeroRotator);
    }
}
```

Este gerador criará 5 plataformas espaçadas horizontalmente. Se você tentar executar sem adicionar a classe `APlatform` à lista de classes spawnáveis, verá:

```
LogSpawn: Warning: Failed to spawn actor of class 'APlatform' because it is not in the spawnable classes list
```

Para corrigir, adicione no arquivo `MyGameGameModeBase.cpp`:

```cpp
#include "Platform.h"

void AMyGameGameModeBase::StartPlay()
{
    Super::StartPlay();
    
    DefaultPawnClass = AMyCharacter::StaticClass();
    APlatform::StaticClass();
}
```

### Plataformas móveis

Vamos tornar as plataformas mais interessantes adicionando movimento:

```cpp
// MovingPlatform.h
UCLASS()
class MYGAME_API AMovingPlatform : public APlatform
{
    GENERATED_BODY()
    
public:    
    AMovingPlatform();

protected:
    virtual void Tick(float DeltaTime) override;

    UPROPERTY(EditAnywhere, Category="Movement")
    float MovementDistance = 500.0f;

    UPROPERTY(EditAnywhere, Category="Movement")
    float MovementSpeed = 100.0f;

private:
    FVector StartLocation;
    bool bMovingForward = true;
};
```

Implementação:

```cpp
// MovingPlatform.cpp
#include "MovingPlatform.h"

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
    
    FVector CurrentLocation = GetActorLocation();
    float Direction = bMovingForward ? 1.0f : -1.0f;
    FVector TargetLocation = StartLocation + FVector(0.0f, 0.0f, MovementDistance * Direction);
    
    FVector NewLocation = FMath::VInterpConstantTo(
        CurrentLocation, 
        TargetLocation, 
        DeltaTime, 
        MovementSpeed);
    
    SetActorLocation(NewLocation);
    
    if(FVector::Dist(NewLocation, TargetLocation) < 5.0f)
    {
        bMovingForward = !bMovingForward;
    }
}
```

Este código faz a plataforma mover-se verticalmente entre dois pontos. O uso de `VInterpConstantTo` garante um movimento suave.

### Exercício prático

Modifique o `APlatformGenerator` para criar:
1. Uma plataforma estática inicial
2. Três plataformas móveis consecutivas
3. Uma plataforma estática final

As plataformas móveis devem mover-se horizontalmente com diferentes velocidades (100, 150 e 200 unidades por segundo).

**Solução comentada:**

```cpp
void APlatformGenerator::BeginPlay()
{
    Super::BeginPlay();
    
    // Plataforma estática inicial
    GetWorld()->SpawnActor<APlatform>(GetActorLocation(), FRotator::ZeroRotator);
    
    // Três plataformas móveis
    for(int32 i = 0; i < 3; ++i)
    {
        FVector Location = GetActorLocation() + FVector(0.0f, (i+1) * PlatformSpacing, 0.0f);
        AMovingPlatform* Platform = GetWorld()->SpawnActor<AMovingPlatform>(Location, FRotator::ZeroRotator);
        
        // Configura velocidades diferentes
        Platform->MovementSpeed = 100.0f + (i * 50.0f);
        Platform->MovementDistance = 200.0f;
    }
    
    // Plataforma estática final
    FVector FinalLocation = GetActorLocation() + FVector(0.0f, 4 * PlatformSpacing, 0.0f);
    GetWorld()->SpawnActor<APlatform>(FinalLocation, FRotator::ZeroRotator);
}
```