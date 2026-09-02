## Câmeras e visão 2D

Em um jogo de plataforma como o nosso protótipo, a câmera precisa seguir o personagem suavemente, mantendo-o sempre visível enquanto mostra o cenário ao redor. Vamos implementar um sistema de câmera 2D básico mas eficaz, usando as ferramentas da Unreal Engine.

Comece criando uma nova classe `CameraActor` no seu projeto. O código essencial para uma câmera que segue o jogador fica assim:

```cpp
// No arquivo CameraActor.h
#include "GameFramework/SpringArmComponent.h"
#include "Camera/CameraComponent.h"

UCLASS()
class YOURGAME_API ACameraActor : public AActor
{
    GENERATED_BODY()
    
public:
    ACameraActor();
    
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly)
    USpringArmComponent* SpringArm;
    
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly)
    UCameraComponent* Camera;
    
    void FollowPlayer(AActor* Player);
};
```

E na implementação:

```cpp
// No arquivo CameraActor.cpp
ACameraActor::ACameraActor()
{
    PrimaryActorTick.bCanEverTick = true;
    
    SpringArm = CreateDefaultSubobject<USpringArmComponent>(TEXT("SpringArm"));
    RootComponent = SpringArm;
    SpringArm->TargetArmLength = 500.f;
    SpringArm->bEnableCameraLag = true;
    SpringArm->CameraLagSpeed = 3.f;
    
    Camera = CreateDefaultSubobject<UCameraComponent>(TEXT("Camera"));
    Camera->SetupAttachment(SpringArm);
}

void ACameraActor::FollowPlayer(AActor* Player)
{
    if (Player)
    {
        FVector NewLocation = Player->GetActorLocation();
        NewLocation.Z = GetActorLocation().Z; // Mantém a altura original
        SetActorLocation(NewLocation);
    }
}
```

Um erro comum é esquecer de configurar o `RootComponent` da câmera. Se você tentar compilar sem esta linha, receberá o erro:

```
error: 'RootComponent' was not declared in this scope
```

A solução é garantir que `SpringArm` seja definido como `RootComponent`, como mostrado no código acima.

Para usar esta câmera no seu nível, você precisa:

1. Adicione um `ACameraActor` ao seu nível (pode ser via Blueprint ou código)
2. No seu PlayerController ou GameMode, chame o método `FollowPlayer` a cada frame:

```cpp
// No Tick do seu PlayerController ou GameMode
if (CameraActor && PlayerCharacter)
{
    CameraActor->FollowPlayer(PlayerCharacter);
}
```

A saída será uma câmera que segue o personagem suavemente, com um leve atraso que dá sensação de peso ao movimento (graças ao `CameraLagSpeed`).

Para limitar a área que a câmera pode percorrer (útil em fases com limites definidos), modifique o método `FollowPlayer`:

```cpp
void ACameraActor::FollowPlayer(AActor* Player)
{
    if (Player)
    {
        FVector NewLocation = Player->GetActorLocation();
        NewLocation.Z = GetActorLocation().Z;
        
        // Limites da câmera
        NewLocation.X = FMath::Clamp(NewLocation.X, -1000.f, 1000.f);
        NewLocation.Y = FMath::Clamp(NewLocation.Y, -500.f, 500.f);
        
        SetActorLocation(NewLocation);
    }
}
```

**Exercício:** Crie uma câmera que amplia o zoom quando o personagem corre e retorna ao normal quando anda. Dica: modifique o `TargetArmLength` do `SpringArm` baseado na velocidade do personagem.

**Solução:**

```cpp
// No método FollowPlayer, após atualizar a posição
float Speed = Player->GetVelocity().Size();
float TargetZoom = Speed > 500.f ? 700.f : 500.f;
SpringArm->TargetArmLength = FMath::FInterpTo(
    SpringArm->TargetArmLength,
    TargetZoom,
    GetWorld()->GetDeltaSeconds(),
    5.f
);
```

Este código verifica a velocidade do personagem e ajusta o zoom gradualmente usando interpolação suave (`FInterpTo`), evitando mudanças bruscas na visualização.