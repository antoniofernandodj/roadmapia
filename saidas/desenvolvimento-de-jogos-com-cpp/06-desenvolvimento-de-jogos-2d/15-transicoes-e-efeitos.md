## Transições e efeitos

Transições e efeitos visuais são essenciais para criar jogos 2D mais envolventes e dinâmicos. Eles podem ser usados para suavizar mudanças de cena, destacar eventos importantes ou simplesmente adicionar um toque de estilo ao seu jogo. Neste trecho, vamos explorar como implementar transições e efeitos visuais básicos usando C++ na Unreal Engine.

### Transições de Fade

Uma das transições mais comuns em jogos é o fade, onde a tela escurece ou clareia gradualmente. Para implementar isso, podemos usar um `UWidgetComponent` que cobre toda a tela com uma imagem preta e ajustar sua opacidade ao longo do tempo.

Primeiro, crie um novo widget chamado `FadeWidget` com um `Image` que cubra toda a tela e tenha a cor preta. Em seguida, vamos criar uma classe `AFadeActor` para controlar a transição:

```cpp
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Components/WidgetComponent.h"
#include "FadeActor.generated.h"

UCLASS()
class MYGAME_API AFadeActor : public AActor
{
    GENERATED_BODY()
    
public:    
    AFadeActor();

protected:
    virtual void BeginPlay() override;

public:    
    virtual void Tick(float DeltaTime) override;

    void FadeOut(float Duration);
    void FadeIn(float Duration);

private:
    UPROPERTY(VisibleAnywhere)
    UWidgetComponent* FadeWidgetComponent;

    float CurrentAlpha;
    float TargetAlpha;
    float FadeSpeed;
};
```

Agora, implemente os métodos na classe `AFadeActor`:

```cpp
#include "FadeActor.h"
#include "FadeWidget.h"

AFadeActor::AFadeActor()
{
    PrimaryActorTick.bCanEverTick = true;

    FadeWidgetComponent = CreateDefaultSubobject<UWidgetComponent>(TEXT("FadeWidget"));
    RootComponent = FadeWidgetComponent;
    FadeWidgetComponent->SetWidgetClass(UFadeWidget::StaticClass());
    FadeWidgetComponent->SetDrawSize(FVector2D(1920, 1080));
}

void AFadeActor::BeginPlay()
{
    Super::BeginPlay();
    CurrentAlpha = 0.0f;
    TargetAlpha = 0.0f;
    FadeSpeed = 0.0f;
}

void AFadeActor::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    if (CurrentAlpha != TargetAlpha)
    {
        CurrentAlpha = FMath::FInterpConstantTo(CurrentAlpha, TargetAlpha, DeltaTime, FadeSpeed);
        UFadeWidget* FadeWidget = Cast<UFadeWidget>(FadeWidgetComponent->GetUserWidgetObject());
        if (FadeWidget)
        {
            FadeWidget->SetOpacity(CurrentAlpha);
        }
    }
}

void AFadeActor::FadeOut(float Duration)
{
    TargetAlpha = 1.0f;
    FadeSpeed = 1.0f / Duration;
}

void AFadeActor::FadeIn(float Duration)
{
    TargetAlpha = 0.0f;
    FadeSpeed = 1.0f / Duration;
}
```

No widget `FadeWidget`, adicione um método para ajustar a opacidade:

```cpp
void UFadeWidget::SetOpacity(float Opacity)
{
    if (FadeImage)
    {
        FadeImage->SetOpacity(Opacity);
    }
}
```

Para usar o `AFadeActor`, basta spawná-lo no nível e chamar `FadeOut` ou `FadeIn` com a duração desejada:

```cpp
AFadeActor* FadeActor = GetWorld()->SpawnActor<AFadeActor>();
FadeActor->FadeOut(2.0f); // Escurece a tela em 2 segundos
```

### Efeitos de Tremor de Tela

Outro efeito visual comum é o tremor de tela, que pode ser usado para enfatizar impactos ou explosões. Para implementar isso, vamos criar uma função que aplica um deslocamento aleatório à posição da câmera.

Primeiro, adicione um método à sua classe de câmera:

```cpp
void AMyCameraActor::ShakeCamera(float Duration, float Intensity)
{
    ShakeDuration = Duration;
    ShakeIntensity = Intensity;
    OriginalLocation = GetActorLocation();
}
```

Em seguida, implemente o tremor no `Tick`:

```cpp
void AMyCameraActor::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    if (ShakeDuration > 0.0f)
    {
        FVector ShakeOffset = FMath::VRand() * ShakeIntensity;
        SetActorLocation(OriginalLocation + ShakeOffset);

        ShakeDuration -= DeltaTime;
        ShakeIntensity = FMath::FInterpTo(ShakeIntensity, 0.0f, DeltaTime, 5.0f);

        if (ShakeDuration <= 0.0f)
        {
            SetActorLocation(OriginalLocation);
        }
    }
}
```

Para usar o efeito, basta chamar `ShakeCamera` com a duração e intensidade desejadas:

```cpp
MyCameraActor->ShakeCamera(0.5f, 10.0f); // Tremor de 0.5 segundos com intensidade 10
```

### Exercício Prático

Implemente um efeito de flash na tela quando o personagem coleta um item. O flash deve ser uma breve explosão de luz branca que desaparece gradualmente. Use um `UWidgetComponent` semelhante ao fade, mas com uma cor branca e uma duração mais curta.

**Solução:**

1. Crie um novo widget chamado `FlashWidget` com um `Image` branco que cubra toda a tela.
2. Adicione um método `Flash` na classe do item coletável.
3. No método `Flash`, ajuste a opacidade do widget de 1.0 para 0.0 ao longo de 0.2 segundos.
4. Chame `Flash` quando o jogador coletar o item.

Este exercício combina os conceitos de fade e tremor de tela para criar um efeito visual impactante que melhora a experiência do jogador.