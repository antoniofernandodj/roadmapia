## Efeitos visuais avançados

Em jogos modernos, efeitos visuais como explosões, mágicas e fenômenos atmosféricos são criados com sistemas de partículas. Na Unreal Engine, esses efeitos são controlados programaticamente através da classe `UParticleSystemComponent`. Vamos criar um efeito de fogo que aumenta de intensidade quando o jogador se aproxima.

Primeiro, crie um novo C++ class derivado de `AActor` chamado `AFireEffect`. No arquivo `.h`:

```cpp
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "FireEffect.generated.h"

UCLASS()
class MYGAME_API AFireEffect : public AActor
{
    GENERATED_BODY()
    
public:    
    AFireEffect();

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Fire Effect")
    UParticleSystemComponent* ParticleSystem;

    UPROPERTY(EditAnywhere, Category = "Fire Effect")
    float MaxIntensityDistance = 300.0f;

protected:
    virtual void Tick(float DeltaTime) override;
};
```

No arquivo `.cpp`:

```cpp
#include "FireEffect.h"
#include "Particles/ParticleSystemComponent.h"
#include "Kismet/GameplayStatics.h"

AFireEffect::AFireEffect()
{
    PrimaryActorTick.bCanEverTick = true;
    
    ParticleSystem = CreateDefaultSubobject<UParticleSystemComponent>(TEXT("FireParticles"));
    RootComponent = ParticleSystem;

    static ConstructorHelpers::FObjectFinder<UParticleSystem> ParticleAsset(
        TEXT("/Game/Effects/P_Fire.P_Fire"));
    if (ParticleAsset.Succeeded())
    {
        ParticleSystem->SetTemplate(ParticleAsset.Object);
    }
}

void AFireEffect::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    APlayerController* PlayerController = UGameplayStatics::GetPlayerController(this, 0);
    if (!PlayerController) return;

    FVector PlayerLocation = PlayerController->GetPawn()->GetActorLocation();
    float Distance = FVector::Dist(GetActorLocation(), PlayerLocation);
    
    float Intensity = FMath::Clamp(1.0f - (Distance / MaxIntensityDistance), 0.1f, 1.0f);
    
    ParticleSystem->SetFloatParameter("Intensity", Intensity);
    ParticleSystem->SetFloatParameter("EmissionRate", Intensity * 50.0f);
}
```

Erro comum ao implementar esse código:
```
LogParticles: Error: ParticleSystemComponent cannot find parameter 'Intensity' in System '/Game/Effects/P_Fire.P_Fire'
```

Isso ocorre quando o parâmetro que tentamos modificar não está definido no sistema de partículas. Para corrigir, no editor da Unreal:

1. Abra o sistema de partículas `P_Fire`
2. Nos módulos do emissor, adicione um `Parameter Dynamic`
3. Defina os parâmetros "Intensity" e "EmissionRate"
4. Conecte esses parâmetros aos valores relevantes (como Scale Color/Rate)

Para um efeito mais complexo, podemos adicionar sons e luz dinâmica:

```cpp
// No arquivo .h
UPROPERTY(EditAnywhere, Category = "Fire Effect")
class UAudioComponent* FireSound;

UPROPERTY(EditAnywhere, Category = "Fire Effect")
class UPointLightComponent* FireLight;

// No construtor .cpp
FireSound = CreateDefaultSubobject<UAudioComponent>(TEXT("FireSound"));
FireSound->SetupAttachment(RootComponent);

FireLight = CreateDefaultSubobject<UPointLightComponent>(TEXT("FireLight"));
FireLight->SetupAttachment(RootComponent);
FireLight->SetLightColor(FLinearColor(1.0f, 0.5f, 0.1f));

// No Tick
FireSound->SetVolumeMultiplier(Intensity);
FireLight->SetIntensity(Intensity * 5000.0f);
```

**Exercício:** Modifique o efeito para que, quando o jogador estiver muito próximo (menos de 100 unidades), as partículas mudem de cor para azul, simulando uma chama mais quente. Use `ParticleSystem->SetColorParameter("Color", FLinearColor::Blue)` quando a distância for menor que o limiar.

Solução:
```cpp
void AFireEffect::Tick(float DeltaTime)
{
    // ... código anterior
    
    if (Distance < 100.0f)
    {
        ParticleSystem->SetColorParameter("Color", FLinearColor(0.1f, 0.3f, 1.0f));
    }
    else
    {
        ParticleSystem->SetColorParameter("Color", FLinearColor(1.0f, 0.5f, 0.1f));
    }
}
```