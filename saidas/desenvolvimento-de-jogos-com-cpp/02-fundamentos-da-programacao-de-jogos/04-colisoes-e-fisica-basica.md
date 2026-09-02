## Colisões e física básica

Em um jogo de plataforma, quando o personagem pula e cai no chão, ele para de cair. Quando ele caminha para a direita e encontra uma parede, ele para de se mover. Esses comportamentos são determinados por **colisões** e **física básica**, dois conceitos fundamentais para a interação entre objetos no jogo.

### Detectando colisões

Colisão é o evento que ocorre quando dois objetos ocupam o mesmo espaço no mundo do jogo. Para detectar colisões, precisamos verificar se as áreas ocupadas por esses objetos se sobrepõem. Na Unreal Engine, isso é feito usando **colisores** (colliders), que são formas geométricas simples como retângulos ou círculos que representam os limites físicos de um objeto.

Vamos criar um exemplo simples: um personagem que pode se mover horizontalmente e colidir com uma parede.

```cpp
#include "GameFramework/Actor.h"
#include "Components/BoxComponent.h"

class AMyCharacter : public AActor
{
    GENERATED_BODY()
    
public:
    AMyCharacter();

protected:
    virtual void BeginPlay() override;

public:
    virtual void Tick(float DeltaTime) override;

private:
    UBoxComponent* Collider;
    FVector Velocity;
};
```

```cpp
AMyCharacter::AMyCharacter()
{
    PrimaryActorTick.bCanEverTick = true;

    Collider = CreateDefaultSubobject<UBoxComponent>(TEXT("Collider"));
    RootComponent = Collider;
    Collider->InitBoxExtent(FVector(50.0f, 50.0f, 50.0f));

    Velocity = FVector(100.0f, 0.0f, 0.0f); // Move para a direita
}

void AMyCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    FVector NewLocation = GetActorLocation() + (Velocity * DeltaTime);
    SetActorLocation(NewLocation);
}
```

Neste código, o personagem se move para a direita indefinidamente. Para detectar colisões com uma parede, precisamos configurar a física básica.

### Configurando física básica

A física básica em jogos envolve aplicar forças como gravidade e velocidade, e responder a colisões. Na Unreal Engine, isso é feito usando **corpos rígidos** (rigid bodies) e **colisores**.

Vamos modificar o exemplo anterior para incluir uma parede que bloqueie o movimento do personagem.

```cpp
class AWall : public AActor
{
    GENERATED_BODY()
    
public:
    AWall();

protected:
    virtual void BeginPlay() override;

private:
    UBoxComponent* Collider;
};
```

```cpp
AWall::AWall()
{
    PrimaryActorTick.bCanEverTick = false;

    Collider = CreateDefaultSubobject<UBoxComponent>(TEXT("Collider"));
    RootComponent = Collider;
    Collider->InitBoxExtent(FVector(50.0f, 50.0f, 50.0f));
    Collider->SetCollisionProfileName(TEXT("BlockAll"));
}
```

Agora, vamos modificar o personagem para detectar colisões com a parede.

```cpp
void AMyCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    FVector NewLocation = GetActorLocation() + (Velocity * DeltaTime);
    FHitResult HitResult;
    SetActorLocation(NewLocation, true, &HitResult);

    if (HitResult.bBlockingHit)
    {
        Velocity = FVector::ZeroVector; // Para o movimento ao colidir
    }
}
```

Quando o personagem colide com a parede, a velocidade é zerada, interrompendo o movimento. A função `SetActorLocation` com o parâmetro `bSweep` ativado permite detectar colisões durante o movimento.

### Erro comum: esquecer de configurar perfis de colisão

Se você tentar rodar o código acima sem configurar os perfis de colisão, o personagem pode passar pela parede. Isso acontece porque os colisores não estão configurados para bloquear uns aos outros. Para corrigir isso, configure os perfis de colisão no Editor da Unreal Engine ou diretamente no código.

```cpp
Collider->SetCollisionProfileName(TEXT("BlockAll"));
```

### Exercício: adicionar gravidade

Modifique o código do personagem para incluir gravidade. Quando o personagem pula, ele deve subir e depois cair devido à gravidade. Para isso, adicione uma variável `Gravity` e atualize a velocidade no eixo Z a cada frame.

```cpp
void AMyCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    Velocity.Z -= Gravity * DeltaTime; // Aplica gravidade
    FVector NewLocation = GetActorLocation() + (Velocity * DeltaTime);
    FHitResult HitResult;
    SetActorLocation(NewLocation, true, &HitResult);

    if (HitResult.bBlockingHit)
    {
        Velocity = FVector::ZeroVector; // Para o movimento ao colidir
    }
}
```

Com isso, o personagem agora responde à gravidade e para quando colide com o chão.