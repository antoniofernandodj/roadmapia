## Sistemas de partículas avançados

Quando você precisa criar fogo que se espalha realisticamente, uma explosão com detritos voando ou mágicas especiais que deixam rastros luminosos, os sistemas de partículas são a ferramenta essencial na Unreal Engine. Vamos construir um sistema completo de chuva com respingos no chão, mostrando como controlar cada aspecto programaticamente.

Primeiro, crie um novo sistema de partículas no Content Browser (Add New > Particle System). Nomeie-o como "PS_Rain". Dentro dele, adicione dois emissores: um para a chuva caindo e outro para os respingos no chão.

```cpp
// RainParticleSystem.h
#pragma once

#include "CoreMinimal.h"
#include "Particles/ParticleSystemComponent.h"
#include "RainParticleSystem.generated.h"

UCLASS()
class MYGAME_API ARainParticleSystem : public AActor
{
    GENERATED_BODY()
    
public:
    ARainParticleSystem();
    
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Particles")
    UParticleSystemComponent* RainParticles;
    
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Particles")
    UParticleSystemComponent* SplashParticles;
    
    void AdjustIntensity(float NewIntensity);
};
```

O erro mais comum aqui é esquecer o `GENERATED_BODY()` macro, que faz o compilador reclamar:
```
error: 'GENERATED_BODY': is not a member of 'ARainParticleSystem'
```

A implementação controla o comportamento das partículas:

```cpp
// RainParticleSystem.cpp
#include "RainParticleSystem.h"
#include "Particles/ParticleSystem.h"

ARainParticleSystem::ARainParticleSystem()
{
    PrimaryActorTick.bCanEverTick = true;
    
    RainParticles = CreateDefaultSubobject<UParticleSystemComponent>(TEXT("RainParticles"));
    SplashParticles = CreateDefaultSubobject<UParticleSystemComponent>(TEXT("SplashParticles"));
    
    RootComponent = RainParticles;
    SplashParticles->AttachToComponent(RootComponent, FAttachmentTransformRules::KeepRelativeTransform);
    
    static ConstructorHelpers::FObjectFinder<UParticleSystem> RainAsset(TEXT("/Game/Effects/PS_Rain"));
    if (RainAsset.Succeeded())
    {
        RainParticles->SetTemplate(RainAsset.Object);
    }
    
    // Configurações iniciais
    RainParticles->SetRelativeScale3D(FVector(2.0f, 2.0f, 1.0f));
    SplashParticles->SetRelativeLocation(FVector(0.0f, 0.0f, -200.0f));
}

void ARainParticleSystem::AdjustIntensity(float NewIntensity)
{
    // Controla a taxa de emissão baseada na intensidade
    RainParticles->SetFloatParameter("EmissionRate", NewIntensity * 100.0f);
    SplashParticles->SetFloatParameter("SplashProbability", FMath::Clamp(NewIntensity, 0.1f, 1.0f));
}
```

Para ver o sistema em ação, crie um Blueprint que chame `AdjustIntensity` baseado na distância do jogador:

```cpp
// Chame em seu Blueprint ou código do jogador
ARainParticleSystem* RainSystem = GetWorld()->SpawnActor<ARainParticleSystem>();
RainSystem->AdjustIntensity(0.5f); // Chuva moderada
```

A saída esperada quando executado será:
1. Partículas de chuva caindo verticalmente
2. Efeitos de respingo aparecendo aleatoriamente no chão
3. Intensidade ajustável em tempo real

Principais parâmetros que você pode controlar via código:

| Parâmetro              | Efeito                           | Faixa típica |
|------------------------|----------------------------------|--------------|
| EmissionRate           | Quantidade de partículas         | 0-1000       |
| ParticleSize           | Tamanho individual               | 0.1-10.0     |
| VelocityScale          | Velocidade das partículas        | 0.1-5.0      |
| Lifetime               | Duração de cada partícula        | 0.5-10.0     |
| ColorOverLife          | Mudança de cor durante a vida    | 0-1 (alpha)  |

**Exercício:** Modifique o sistema para adicionar um terceiro emissor que crie pequenas poças de água no chão quando a chuva está muito intensa (intensidade > 0.8). As poças devem durar vários segundos e desaparecer gradualmente.

**Solução comentada:**
```cpp
// Adicione no header
UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Particles")
UParticleSystemComponent* PuddleParticles;

// No construtor
PuddleParticles = CreateDefaultSubobject<UParticleSystemComponent>(TEXT("PuddleParticles"));
PuddleParticles->AttachToComponent(RootComponent, FAttachmentTransformRules::KeepRelativeTransform);
PuddleParticles->SetRelativeLocation(FVector(0.0f, 0.0f, -200.0f));
PuddleParticles->SetAutoActivate(false);

// Modifique AdjustIntensity
void ARainParticleSystem::AdjustIntensity(float NewIntensity)
{
    RainParticles->SetFloatParameter("EmissionRate", NewIntensity * 100.0f);
    SplashParticles->SetFloatParameter("SplashProbability", FMath::Clamp(NewIntensity, 0.1f, 1.0f));
    
    if(NewIntensity > 0.8f && !PuddleParticles->IsActive())
    {
        PuddleParticles->Activate();
        PuddleParticles->SetFloatParameter("PuddleLifetime", 5.0f);
    }
    else if(NewIntensity <= 0.8f && PuddleParticles->IsActive())
    {
        PuddleParticles->Deactivate();
    }
}
```