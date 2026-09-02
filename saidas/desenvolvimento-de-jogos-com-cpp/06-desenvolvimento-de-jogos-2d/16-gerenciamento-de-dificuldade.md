## Gerenciamento de dificuldade

Um jogo de plataforma fica entediante quando é muito fácil e frustrante quando é muito difícil. O segredo está em aumentar gradualmente os desafios enquanto o jogador melhora suas habilidades. Vamos implementar um sistema que ajusta três elementos principais: velocidade dos inimigos, frequência de obstáculos e tempo de reação.

Comece criando uma classe `DifficultyManager` no seu projeto Unreal:

```cpp
// DifficultyManager.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "DifficultyManager.generated.h"

UCLASS()
class PLATFORMER2D_API ADifficultyManager : public AActor
{
    GENERATED_BODY()
    
public:    
    ADifficultyManager();

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Difficulty")
    float InitialDifficulty = 1.0f;
    
    UPROPERTY(BlueprintReadOnly, Category = "Difficulty")
    float CurrentDifficulty;
    
    UFUNCTION(BlueprintCallable)
    void UpdateDifficulty(float PlayerScore);
    
protected:
    virtual void BeginPlay() override;
};
```

A implementação controla como a dificuldade escala:

```cpp
// DifficultyManager.cpp
#include "DifficultyManager.h"

ADifficultyManager::ADifficultyManager()
{
    PrimaryActorTick.bCanEverTick = false;
}

void ADifficultyManager::BeginPlay()
{
    Super::BeginPlay();
    CurrentDifficulty = InitialDifficulty;
}

void ADifficultyManager::UpdateDifficulty(float PlayerScore)
{
    // Fórmula de progressão não-linear
    CurrentDifficulty = InitialDifficulty + FMath::LogX(3, PlayerScore + 1);
    
    // Limita a dificuldade máxima
    CurrentDifficulty = FMath::Min(CurrentDifficulty, 5.0f);
}
```

Erro comum: esquecer de adicionar o manager ao nível. Você verá este erro no Output Log:
```
LogActor: Warning: Failed to find ADifficultyManager in level
```

Corrija adicionando o actor ao seu nível através do editor ou via código no GameMode:

```cpp
// No seu GameMode.cpp
void APlatformerGameMode::StartPlay()
{
    Super::StartPlay();
    
    // Spawna o gerenciador de dificuldade
    DifficultyManager = GetWorld()->SpawnActor<ADifficultyManager>();
}
```

Aplique a dificuldade aos inimigos modificando sua classe:

```cpp
// Enemy.cpp
void AEnemy::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    
    // Obtém referência ao gerenciador
    ADifficultyManager* Manager = Cast<ADifficultyManager>(
        UGameplayStatics::GetActorOfClass(GetWorld(), ADifficultyManager::StaticClass()));
    
    if(Manager)
    {
        // Aplica velocidade baseada na dificuldade
        float MoveSpeed = BaseMoveSpeed * Manager->CurrentDifficulty;
        AddMovementInput(FVector::ForwardVector, MoveSpeed * DeltaTime);
    }
}
```

Para obstáculos, crie uma função que gera mais desafios conforme a dificuldade aumenta:

```cpp
// ObstacleSpawner.cpp
void AObstacleSpawner::SpawnObstacles()
{
    if(DifficultyManager)
    {
        // Aumenta a quantidade de obstáculos
        int32 ObstacleCount = FMath::CeilToInt(BaseObstacleCount * DifficultyManager->CurrentDifficulty);
        
        for(int32 i = 0; i < ObstacleCount; i++)
        {
            // Posiciona obstáculos com espaçamento reduzido
            FVector Location = GetActorLocation() + FVector(0, i * (1000 / DifficultyManager->CurrentDifficulty), 0);
            GetWorld()->SpawnActor<AObstacle>(ObstacleClass, Location, FRotator::ZeroRotator);
        }
    }
}
```

Veja como fica a progressão na prática:

```
Dificuldade 1.0: [Inimigo]-   -   -[Inimigo]  
Dificuldade 2.5: [Inimigo]- -[Inimigo]-[Inimigo]
Dificuldade 4.0: [Inimigo][Inimigo]-[Inimigo][Inimigo]
```

Para testar rapidamente diferentes curvas de dificuldade, adicione esta função de debug:

```cpp
// Console command para simular dificuldade
void APlatformerPlayerController::DebugSetDifficulty(float NewDifficulty)
{
    if(ADifficultyManager* Manager = Cast<ADifficultyManager>(
        UGameplayStatics::GetActorOfClass(GetWorld(), ADifficultyManager::StaticClass())))
    {
        Manager->CurrentDifficulty = NewDifficulty;
        GEngine->AddOnScreenDebugMessage(-1, 5.f, FColor::Green, 
            FString::Printf(TEXT("Dificuldade ajustada para: %.2f"), NewDifficulty));
    }
}
```

Ative no console do jogo com:
```
DebugSetDifficulty 2.3
```

**Exercício**: Implemente um sistema que reduza temporariamente a dificuldade quando o jogador perde uma vida, criando um "respiro". A solução deve:
1. Reduzir CurrentDifficulty em 30% por 5 segundos
2. Retornar gradualmente ao valor original
3. Mostrar um efeito visual (dica: use UWidgetComponent)

Solução comentada:

```cpp
// DifficultyManager.h
FTimerHandle DifficultyResetHandle;

UFUNCTION(BlueprintCallable)
void TemporaryDifficultyReduction(float ReductionPercent, float Duration);

// DifficultyManager.cpp
void ADifficultyManager::TemporaryDifficultyReduction(float ReductionPercent, float Duration)
{
    float OriginalDifficulty = CurrentDifficulty;
    CurrentDifficulty *= (1 - ReductionPercent);
    
    GetWorld()->GetTimerManager().SetTimer(DifficultyResetHandle, 
        [this, OriginalDifficulty]()
        {
            CurrentDifficulty = OriginalDifficulty;
        }, 
        Duration, false);
    
    // Dispara evento para UI
    OnDifficultyReduced.Broadcast(Duration);
}
```