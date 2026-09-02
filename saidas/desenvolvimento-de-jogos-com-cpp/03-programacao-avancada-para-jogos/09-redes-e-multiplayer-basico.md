## Redes e multiplayer básico

Imagine tentar jogar um jogo multiplayer onde cada jogador vê personagens em posições diferentes - um pesadelo de sincronização. O problema fundamental do multiplayer é manter todos os clientes consistentes com o estado do jogo. Vamos resolver isso criando um jogo simples onde dois jogadores controlam personagens na mesma arena.

Primeiro, crie um novo projeto C++ na Unreal Engine com o template "Side Scroller". Adicione uma nova classe `MultiplayerCharacter` derivada de `Character`:

```cpp
// MultiplayerCharacter.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "MultiplayerCharacter.generated.h"

UCLASS()
class YOURPROJECT_API AMultiplayerCharacter : public ACharacter
{
    GENERATED_BODY()
    
public:
    AMultiplayerCharacter();
    
    virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;
    
    UFUNCTION(Server, Reliable, WithValidation)
    void Server_MoveForward(float Value);
    
    UFUNCTION(Client, Reliable)
    void Client_UpdatePosition(FVector NewPosition);
    
private:
    void MoveForward(float Value);
};
```

A implementação mostra como lidar com movimento em rede:

```cpp
// MultiplayerCharacter.cpp
#include "MultiplayerCharacter.h"

AMultiplayerCharacter::AMultiplayerCharacter()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AMultiplayerCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);
    PlayerInputComponent->BindAxis("MoveForward", this, &AMultiplayerCharacter::MoveForward);
}

void AMultiplayerCharacter::MoveForward(float Value)
{
    if (GetLocalRole() == ROLE_AutonomousProxy)
    {
        Server_MoveForward(Value);
    }
}

bool AMultiplayerCharacter::Server_MoveForward_Validate(float Value)
{
    return FMath::Abs(Value) <= 1.0f;
}

void AMultiplayerCharacter::Server_MoveForward_Implementation(float Value)
{
    FVector Direction = FVector(Value * 100.0f * GetWorld()->GetDeltaSeconds(), 0, 0);
    AddMovementInput(Direction);
    
    Client_UpdatePosition(GetActorLocation());
}

void AMultiplayerCharacter::Client_UpdatePosition_Implementation(FVector NewPosition)
{
    if (GetLocalRole() == ROLE_SimulatedProxy)
    {
        SetActorLocation(NewPosition);
    }
}
```

O erro mais comum é esquecer de marcar as funções de rede com os macros corretos. Se você esquecer `_Implementation`, receberá o erro:

```
error: 'void AMultiplayerCharacter::Server_MoveForward(float)' marked 'override' does not override
```

Na configuração do mapa, adicione dois PlayerStarts e configure o GameMode para usar nossa nova classe de personagem:

```cpp
// MultiplayerGameMode.h
UCLASS()
class YOURPROJECT_API AMultiplayerGameMode : public AGameModeBase
{
    GENERATED_BODY()
    
public:
    AMultiplayerGameMode();
};
```

```cpp
// MultiplayerGameMode.cpp
#include "MultiplayerGameMode.h"
#include "MultiplayerCharacter.h"

AMultiplayerGameMode::AMultiplayerGameMode()
{
    DefaultPawnClass = AMultiplayerCharacter::StaticClass();
}
```

Para testar localmente, pressione Play e selecione "Number of Players: 2". Você verá dois personagens controlados separadamente. O primeiro jogador controla com WASD, o segundo com IJKL (adicione esses mapeamentos no Project Settings).

Um problema comum é a "guerra dos inputs", onde ambos os clientes tentam controlar o mesmo personagem. Isso acontece quando não verificamos `GetLocalRole()`. Sem essa verificação, você verá personagens "tremendo" ou movendo-se erraticamente.

Para sincronizar variáveis automaticamente, use a replicação:

```cpp
// MultiplayerCharacter.h
UCLASS()
class YOURPROJECT_API AMultiplayerCharacter : public ACharacter
{
    // ...
    
    UPROPERTY(Replicated)
    float Health;
    
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override;
};
```

```cpp
// MultiplayerCharacter.cpp
void AMultiplayerCharacter::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const
{
    Super::GetLifetimeReplicatedProps(OutLifetimeProps);
    DOREPLIFETIME(AMultiplayerCharacter, Health);
}
```

Exercício: Implemente um sistema de pontuação multiplayer onde:
1. Cada jogador tem sua pontuação replicada
2. Ao colidir com um objeto (crie um Actor simples), a pontuação aumenta
3. Todos os jogadores veem as pontuações atualizadas

Solução:

```cpp
// ScoreActor.h
UCLASS()
class YOURPROJECT_API AScoreActor : public AActor
{
    GENERATED_BODY()
    
public:    
    AScoreActor();
    
    UFUNCTION()
    void OnOverlap(AActor* OverlappedActor, AActor* OtherActor);
};

// ScoreActor.cpp
#include "ScoreActor.h"
#include "MultiplayerCharacter.h"

AScoreActor::AScoreActor()
{
    PrimaryActorTick.bCanEverTick = false;
    
    auto Collision = CreateDefaultSubobject<USphereComponent>("Collision");
    RootComponent = Collision;
    Collision->OnComponentBeginOverlap.AddDynamic(this, &AScoreActor::OnOverlap);
}

void AScoreActor::OnOverlap(AActor* OverlappedActor, AActor* OtherActor)
{
    if (auto Character = Cast<AMultiplayerCharacter>(OtherActor))
    {
        if (Character->HasAuthority())
        {
            Character->AddScore();
            Destroy();
        }
    }
}
```

```cpp
// MultiplayerCharacter.h
// Adicione:
UFUNCTION(Server, Reliable)
void Server_AddScore();

// MultiplayerCharacter.cpp
void AMultiplayerCharacter::AddScore()
{
    if (GetLocalRole() == ROLE_AutonomousProxy)
    {
        Server_AddScore();
    }
}

void AMultiplayerCharacter::Server_AddScore_Implementation()
{
    Score++;
    OnRep_Score();
}

void AMultiplayerCharacter::OnRep_Score()
{
    // Atualiza UI local
}
```