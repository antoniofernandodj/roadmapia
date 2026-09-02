## Inteligência artificial básica

Um inimigo que fica parado no cenário não assusta ninguém. Vamos criar um comportamento simples onde um NPC persegue o jogador quando ele entra em um raio de detecção. Esta é a base para a maioria dos inimigos em jogos 2D.

No Unreal Engine, começamos criando um novo C++ class derivado de `ACharacter`. Vamos chamá-lo de `AEnemyCharacter`:

```cpp
// EnemyCharacter.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "EnemyCharacter.generated.h"

UCLASS()
class MYGAME_API AEnemyCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    AEnemyCharacter();
    
    UPROPERTY(EditAnywhere, Category = "AI")
    float DetectionRadius = 500.0f;

    UPROPERTY(EditAnywhere, Category = "AI")
    float MovementSpeed = 300.0f;

protected:
    virtual void Tick(float DeltaTime) override;

private:
    class APlayerCharacter* Player;
    void ChasePlayer(float DeltaTime);
};
```

A implementação fica no arquivo .cpp:

```cpp
// EnemyCharacter.cpp
#include "EnemyCharacter.h"
#include "PlayerCharacter.h"
#include "Kismet/GameplayStatics.h"

AEnemyCharacter::AEnemyCharacter()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AEnemyCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    if (!Player)
    {
        Player = Cast<APlayerCharacter>(UGameplayStatics::GetPlayerCharacter(this, 0));
        return;
    }

    float DistanceToPlayer = FVector::Dist(GetActorLocation(), Player->GetActorLocation());
    
    if (DistanceToPlayer <= DetectionRadius)
    {
        ChasePlayer(DeltaTime);
    }
}

void AEnemyCharacter::ChasePlayer(float DeltaTime)
{
    FVector Direction = (Player->GetActorLocation() - GetActorLocation()).GetSafeNormal();
    AddMovementInput(Direction, MovementSpeed * DeltaTime);
}
```

Este código faz três coisas principais:
1. No construtor, habilitamos o `Tick` para atualizações a cada frame
2. No `Tick`, verificamos a distância até o jogador
3. Se o jogador estiver dentro do raio de detecção, movemos o inimigo em sua direção

Quando você compilar e colocar este inimigo no nível, ele vai perseguir o jogador assim que entrar no raio de 500 unidades. Mas há um problema comum: se você não definir a `MovementSpeed` no editor, o inimigo não se moverá. O erro aparecerá no log:

```
LogTemp: Warning: MovementSpeed is zero, enemy won't move
```

Para corrigir, basta definir o valor no Editor do Unreal na aba "AI" do inimigo.

Vamos melhorar nosso inimigo com um comportamento mais interessante: ele deve parar de perseguir se o jogador sair do raio de detecção e voltar para sua posição inicial. Adicione estas propriedades ao header:

```cpp
UPROPERTY(EditAnywhere, Category = "AI")
FVector HomeLocation;

UPROPERTY(EditAnywhere, Category = "AI")
bool bShouldReturnHome = true;
```

E atualize o método `Tick`:

```cpp
void AEnemyCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    if (!Player)
    {
        Player = Cast<APlayerCharacter>(UGameplayStatics::GetPlayerCharacter(this, 0));
        HomeLocation = GetActorLocation(); // Guarda posição inicial
        return;
    }

    float DistanceToPlayer = FVector::Dist(GetActorLocation(), Player->GetActorLocation());
    
    if (DistanceToPlayer <= DetectionRadius)
    {
        ChasePlayer(DeltaTime);
    }
    else if (bShouldReturnHome)
    {
        FVector Direction = (HomeLocation - GetActorLocation()).GetSafeNormal();
        AddMovementInput(Direction, MovementSpeed * DeltaTime);
    }
}
```

Agora temos um inimigo que:
1. Persegue o jogador quando ele está próximo
2. Volta para sua posição inicial quando o jogador foge
3. Tem todos parâmetros ajustáveis no editor

Para testar seu entendimento, modifique o código para que o inimigo:
1. Tenha um pequeno atraso antes de começar a perseguir o jogador
2. Emita um som quando detecta o jogador
3. Mude de cor durante a perseguição

Aqui está a solução comentada:

```cpp
// Adicione no header:
UPROPERTY(EditAnywhere, Category = "AI")
float DetectionDelay = 0.5f;

UPROPERTY(EditAnywhere, Category = "AI")
USoundBase* DetectionSound;

UPROPERTY(EditAnywhere, Category = "AI")
FColor ChaseColor = FColor::Red;

private:
    float DetectionTimer = 0.0f;
    UMaterialInstanceDynamic* DynamicMaterial;
    FColor DefaultColor;
```

```cpp
// No construtor:
DynamicMaterial = CreateAndSetMaterial();
DefaultColor = DynamicMaterial->K2_GetVectorParameterValue("Color");

// No Tick:
if (DistanceToPlayer <= DetectionRadius)
{
    DetectionTimer += DeltaTime;
    if (DetectionTimer >= DetectionDelay)
    {
        if (DetectionTimer - DeltaTime < DetectionDelay)
        {
            UGameplayStatics::PlaySoundAtLocation(this, DetectionSound, GetActorLocation());
            DynamicMaterial->SetVectorParameterValue("Color", ChaseColor);
        }
        ChasePlayer(DeltaTime);
    }
}
else
{
    DetectionTimer = 0.0f;
    DynamicMaterial->SetVectorParameterValue("Color", DefaultColor);
    // Restante do código para voltar para casa
}
```

Esta implementação adiciona:
1. Um timer que conta até `DetectionDelay` antes de perseguir
2. Toca `DetectionSound` quando a detecção começa
3. Muda a cor do material durante a perseguição