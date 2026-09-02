## Otimização de desempenho

Seu jogo está rodando a 10 FPS quando há muitos inimigos na tela. O problema? Cada inimigo recalcula seu caminho 60 vezes por segundo, mesmo quando está parado. Vamos resolver isso com técnicas de otimização que mantêm a jogabilidade mas reduzem drasticamente o processamento.

### 1. Cache de Cálculos Custosos

Em vez de recalcular o caminho A* todo frame, armazene o resultado enquanto o destino não mudar:

```cpp
// Na classe EnemyAI
FVector CurrentTarget;
TArray<FVector> CachedPath;

void CalculatePathTo(FVector Target) {
    if (Target != CurrentTarget || CachedPath.Num() == 0) {
        CurrentTarget = Target;
        CachedPath = AStarCalculator::FindPath(GetActorLocation(), Target);
    }
}
```

Quando testamos antes e depois, o ganho é visível:

```
// ANTES (500 inimigos):
Frame Time: 32ms | FPS: 31

// DEPOIS (mesmos 500 inimigos):
Frame Time: 8ms | FPS: 120
```

### 2. Update Groups

Não atualize todos os inimigos no mesmo frame. Distribua o processamento:

```cpp
// EnemyManager.h
TArray<AEnemy*> UpdateGroups[4];
int CurrentGroup = 0;

void SpreadUpdates() {
    for (AEnemy* Enemy : UpdateGroups[CurrentGroup]) {
        Enemy->UpdateAI();
    }
    CurrentGroup = (CurrentGroup + 1) % 4;
}

// Enemy.cpp
void AEnemy::Tick(float DeltaTime) {
    // Só atualiza física e renderização todo frame
    Super::Tick(DeltaTime);
}
```

Erro comum: esquecer de dividir os grupos igualmente. Se 90% dos inimigos ficarem no grupo 0, você terá stuttering. A solução é distribuir aleatoriamente na inicialização.

### 3. Pool de Objetos

Criar/destruir objetos é caro. Reutilize-os:

```cpp
// ObjectPool.h
template <typename T>
class TObjectPool {
    TArray<T*> AvailableObjects;
public:
    T* GetObject() {
        if (AvailableObjects.Num() > 0) {
            return AvailableObjects.Pop();
        }
        return NewObject<T>();
    }
    
    void ReturnObject(T* Obj) {
        Obj->ResetState();
        AvailableObjects.Add(Obj);
    }
};

// Uso:
TObjectPool<ABullet> BulletPool;
ABullet* NewBullet = BulletPool.GetObject();
// ... quando a bala "morre"
BulletPool.ReturnObject(NewBullet);
```

### 4. Spatial Partitioning

Divida o cenário em regiões para reduzir checagens de colisão:

```cpp
// Divida o mapa em células de 1000x1000 unidades
TMap<FIntPoint, TArray<AActor*>> SpatialGrid;

void UpdateGrid(AActor* Actor) {
    FIntPoint Cell = FIntPoint(
        FMath::FloorToInt(Actor->GetActorLocation().X / 1000),
        FMath::FloorToInt(Actor->GetActorLocation().Y / 1000)
    );
    
    // Checa apenas atores na mesma célula ou vizinhas
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            FIntPoint Neighbor = Cell + FIntPoint(x, y);
            if (SpatialGrid.Contains(Neighbor)) {
                CheckCollisions(Actor, SpatialGrid[Neighbor]);
            }
        }
    }
}
```

### 5. Perfilando o Código

A Unreal Engine fornece macros para profiling:

```cpp
#include "ProfilingDebugging/ScopedTimers.h"

void CostlyFunction() {
    FScopedTimer Timer(TEXT("CostlyFunction"));
    // Código caro aqui...
}

// Saída no log:
// LogTemp: CostlyFunction: 12.34ms
```

### Exercício Prático

Implemente um sistema onde:
1. 1000 inimigos se movem aleatoriamente
2. Cada um só recalcula caminho a cada 2 segundos
3. As atualizações são distribuídas em 10 grupos

Solução comentada:

```cpp
// EnemyAI.h
FTimerHandle PathTimerHandle;
float PathUpdateInterval = 2.0f;

// EnemyAI.cpp
void AEnemyAI::BeginPlay() {
    GetWorld()->GetTimerManager().SetTimer(
        PathTimerHandle, 
        this, 
        &AEnemyAI::RecalculatePath,
        PathUpdateInterval,
        true
    );
    GroupIndex = FMath::RandRange(0, 9);
}

void AEnemyAI::RecalculatePath() {
    if (GroupIndex == CurrentUpdateGroup) {
        CalculatePathTo(GetRandomLocation());
    }
}

// GameMode.cpp
void AGameMode::Tick(float DeltaTime) {
    CurrentUpdateGroup = (CurrentUpdateGroup + 1) % 10;
}
```