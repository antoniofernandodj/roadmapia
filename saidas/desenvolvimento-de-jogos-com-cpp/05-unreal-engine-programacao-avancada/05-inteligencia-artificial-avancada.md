## Inteligência artificial avançada

Um inimigo que segue o jogador em linha reta é fácil de implementar, mas rapidamente se torna previsível. Em um jogo de ação, queremos que os inimigos tomem decisões inteligentes: flanquear o jogador, buscar cobertura, ou recuar quando estiverem com pouca vida. Vamos implementar um sistema de máquina de estados finitos (FSM) combinado com árvores de comportamento (Behavior Trees) para criar IA convincente.

### Máquina de estados básica

Começaremos com um inimigo simples que alterna entre patrulha e perseguição. Criamos uma classe base `EnemyState`:

```cpp
// EnemyState.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "EnemyState.generated.h"

UCLASS(Abstract)
class UEnemyState : public UObject
{
    GENERATED_BODY()
    
public:
    virtual void Enter(class AEnemyAI* Enemy);
    virtual void Execute(class AEnemyAI* Enemy);
    virtual void Exit(class AEnemyAI* Enemy);
    
    UPROPERTY(EditAnywhere, Category = "AI")
    FString StateName;
};
```

A implementação padrão na classe base:

```cpp
// EnemyState.cpp
#include "EnemyState.h"

void UEnemyState::Enter(AEnemyAI* Enemy)
{
    UE_LOG(LogTemp, Warning, TEXT("%s enter state: %s"), 
           *Enemy->GetName(), *StateName);
}

void UEnemyState::Execute(AEnemyAI* Enemy) {}

void UEnemyState::Exit(AEnemyAI* Enemy)
{
    UE_LOG(LogTemp, Warning, TEXT("%s exit state: %s"), 
           *Enemy->GetName(), *StateName);
}
```

Agora implementamos dois estados concretos:

```cpp
// PatrolState.h
#pragma once

#include "EnemyState.h"
#include "PatrolState.generated.h"

UCLASS()
class UPatrolState : public UEnemyState
{
    GENERATED_BODY()
    
public:
    UPatrolState();
    
    virtual void Enter(AEnemyAI* Enemy) override;
    virtual void Execute(AEnemyAI* Enemy) override;
};
```

```cpp
// ChaseState.h
#pragma once

#include "EnemyState.h"
#include "ChaseState.generated.h"

UCLASS()
class UChaseState : public UEnemyState
{
    GENERATED_BODY()
    
public:
    UChaseState();
    
    virtual void Enter(AEnemyAI* Enemy) override;
    virtual void Execute(AEnemyAI* Enemy) override;
};
```

A implementação dos estados:

```cpp
// PatrolState.cpp
#include "PatrolState.h"
#include "EnemyAI.h"

UPatrolState::UPatrolState()
{
    StateName = "Patrol";
}

void UPatrolState::Enter(AEnemyAI* Enemy)
{
    Super::Enter(Enemy);
    Enemy->MoveToRandomPatrolPoint();
}

void UPatrolState::Execute(AEnemyAI* Enemy)
{
    if (Enemy->CanSeePlayer())
    {
        Enemy->ChangeState(Enemy->ChaseState);
    }
}

// ChaseState.cpp
#include "ChaseState.h"
#include "EnemyAI.h"

UChaseState::UChaseState()
{
    StateName = "Chase";
}

void UChaseState::Enter(AEnemyAI* Enemy)
{
    Super::Enter(Enemy);
    Enemy->SetMaxSpeed(600.f);
}

void UChaseState::Execute(AEnemyAI* Enemy)
{
    if (!Enemy->CanSeePlayer())
    {
        Enemy->ChangeState(Enemy->PatrolState);
    }
    else
    {
        Enemy->MoveToPlayer();
    }
}
```

### Implementando o controlador de IA

A classe `AEnemyAI` gerencia os estados:

```cpp
// EnemyAI.h
#pragma once

#include "CoreMinimal.h"
#include "AIController.h"
#include "EnemyAI.generated.h"

class UEnemyState;

UCLASS()
class AEnemyAI : public AAIController
{
    GENERATED_BODY()
    
public:
    AEnemyAI();
    
    UPROPERTY(EditDefaultsOnly, Category = "AI")
    UPatrolState* PatrolState;
    
    UPROPERTY(EditDefaultsOnly, Category = "AI")
    UChaseState* ChaseState;
    
    void ChangeState(UEnemyState* NewState);
    
    bool CanSeePlayer() const;
    void MoveToRandomPatrolPoint();
    void MoveToPlayer();
    
protected:
    virtual void BeginPlay() override;
    virtual void Tick(float DeltaSeconds) override;

private:
    UEnemyState* CurrentState;
    TArray<AActor*> PatrolPoints;
    float SightRadius = 2000.f;
};
```

```cpp
// EnemyAI.cpp
#include "EnemyAI.h"
#include "EnemyState.h"
#include "PatrolState.h"
#include "ChaseState.h"
#include "BehaviorTree/BlackboardComponent.h"
#include "Kismet/GameplayStatics.h"

AEnemyAI::AEnemyAI()
{
    PatrolState = CreateDefaultSubobject<UPatrolState>(TEXT("PatrolState"));
    ChaseState = CreateDefaultSubobject<UChaseState>(TEXT("ChaseState"));
}

void AEnemyAI::BeginPlay()
{
    Super::BeginPlay();
    UGameplayStatics::GetAllActorsWithTag(GetWorld(), "PatrolPoint", PatrolPoints);
    ChangeState(PatrolState);
}

void AEnemyAI::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    if (CurrentState)
    {
        CurrentState->Execute(this);
    }
}

void AEnemyAI::ChangeState(UEnemyState* NewState)
{
    if (CurrentState)
    {
        CurrentState->Exit(this);
    }
    
    CurrentState = NewState;
    
    if (CurrentState)
    {
        CurrentState->Enter(this);
    }
}

bool AEnemyAI::CanSeePlayer() const
{
    APawn* PlayerPawn = UGameplayStatics::GetPlayerPawn(this, 0);
    if (!PlayerPawn) return false;
    
    return FVector::Dist(GetPawn()->GetActorLocation(), 
                         PlayerPawn->GetActorLocation()) < SightRadius;
}

void AEnemyAI::MoveToRandomPatrolPoint()
{
    if (PatrolPoints.Num() == 0) return;
    
    int32 RandomIndex = FMath::RandRange(0, PatrolPoints.Num() - 1);
    MoveToActor(PatrolPoints[RandomIndex]);
}

void AEnemyAI::MoveToPlayer()
{
    APawn* PlayerPawn = UGameplayStatics::GetPlayerPawn(this, 0);
    if (PlayerPawn)
    {
        MoveToActor(PlayerPawn);
    }
}
```

### Integrando com Behavior Trees

Para comportamentos mais complexos, combinaremos nossa FSM com Behavior Trees. Primeiro, criamos um Blackboard com as chaves necessárias:

```
- bCanSeePlayer (bool)
- PlayerLocation (Vector)
- CurrentState (String)
```

E um Behavior Tree simples:

1. Selector principal:
   - Sequence (Patrulha)
     - MoveTo (próximo ponto de patrulha)
     - Wait (2 segundos)
   - Sequence (Perseguição)
     - MoveTo (PlayerLocation)
     - Wait (0.5 segundos)

Atualizamos o EnemyAI para sincronizar com a BT:

```cpp
// No EnemyAI.h
UPROPERTY(EditDefaultsOnly, Category = "AI")
UBehaviorTree* BehaviorTree;

// No EnemyAI.cpp
void AEnemyAI::BeginPlay()
{
    Super::BeginPlay();
    UGameplayStatics::GetAllActorsWithTag(GetWorld(), "PatrolPoint", PatrolPoints);
    
    if (BehaviorTree)
    {
        RunBehaviorTree(BehaviorTree);
        Blackboard->SetValueAsString("CurrentState", "Patrol");
    }
    
    ChangeState(PatrolState);
}

void AEnemyAI::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    
    if (Blackboard)
    {
        Blackboard->SetValueAsBool("bCanSeePlayer", CanSeePlayer());
        
        APawn* PlayerPawn = UGameplayStatics::GetPlayerPawn(this, 0);
        if (PlayerPawn)
        {
            Blackboard->SetValueAsVector("PlayerLocation", 
                                        PlayerPawn->GetActorLocation());
        }
    }
    
    if (CurrentState)
    {
        CurrentState->Execute(this);
    }
}
```

### Erro comum: esquecer de inicializar estados

Se tentarmos executar sem criar os estados, receberemos o erro:

```
LogScript: Error: Accessed None trying to read property PatrolState
```

A solução é garantir a criação no construtor, como mostrado anteriormente.

### Exercício: Implementar estado de fuga

Implemente um terceiro estado onde o inimigo foge do jogador quando sua vida está baixa. O estado deve:
1. Ser ativado quando a vida do inimigo estiver abaixo de 30%
2. Fazer o inimigo se mover para longe do jogador
3. Voltar para o estado de patrulha após 5 segundos

Solução:

```cpp
// FleeState.h
#pragma once

#include "EnemyState.h"
#include "FleeState.generated.h"

UCLASS()
class UFleeState : public UEnemyState
{
    GENERATED_BODY()
    
public:
    UFleeState();
    
    virtual void Enter(AEnemyAI* Enemy) override;
    virtual void Execute(AEnemyAI* Enemy) override;
    
private:
    float FleeTime;
};
```

```cpp
// FleeState.cpp
#include "FleeState.h"
#include "EnemyAI.h"

UFleeState::UFleeState()
{
    StateName = "Flee";
}

void UFleeState::Enter(AEnemyAI* Enemy)
{
    Super::Enter(Enemy);
    FleeTime = 0.f;
    Enemy->SetMaxSpeed(800.f);
}

void UFleeState::Execute(AEnemyAI* Enemy)
{
    FleeTime += Enemy->GetWorld()->GetDeltaSeconds();
    
    if (FleeTime >= 5.f || Enemy->GetHealth() > 0.3f)
    {
        Enemy->ChangeState(Enemy->PatrolState);
    }
    else
    {
        APawn* PlayerPawn = UGameplayStatics::GetPlayerPawn(Enemy, 0);
        if (PlayerPawn)
        {
            FVector FleeDirection = Enemy->GetPawn()->GetActorLocation() - 
                                   PlayerPawn->GetActorLocation();
            FleeDirection.Normalize();
            Enemy->MoveToLocation(Enemy->GetPawn()->GetActorLocation() + 
                                 FleeDirection * 1000.f);
        }
    }
}

// Adicione no EnemyAI.h
UPROPERTY(EditDefaultsOnly, Category = "AI")
UFleeState* FleeState;

// No construtor do EnemyAI.cpp
FleeState = CreateDefaultSubobject<UFleeState>(TEXT("FleeState"));

// Modifique o Execute do PatrolState e ChaseState
// para verificar a vida e mudar para FleeState quando necessário
```