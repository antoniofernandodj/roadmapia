## Otimização avançada de desempenho

Um jogo que roda a 10 FPS é injogável, mesmo com a melhor arte e design. Na Unreal Engine, quando milhares de atores, partículas e efeitos disputam recursos, otimizar não é luxo - é necessidade.

**O problema real:** Um sistema de spawn de inimigos que congela o jogo quando muitos aparecem simultaneamente:

```cpp
// Classe problemática - Anti-padrão
void AEnemySpawner::SpawnWave(int32 EnemyCount)
{
    for (int32 i = 0; i < EnemyCount; i++) 
    {
        AEnemy* NewEnemy = GetWorld()->SpawnActor<AEnemy>(EnemyClass, GetRandomSpawnLocation(), FRotator::ZeroRotator);
        NewEnemy->Initialize(); // Custo pesado
    }
}
```

Quando executado com `SpawnWave(50)`, o frame rate cai de 60 para 15 FPS durante o spawn, causando um gargalo perceptível.

### Pooling de Objetos

A solução é pré-alocar inimigos e reutilizá-los, evitando alocação/desalocação constante. Implementamos um **Object Pool**:

```cpp
// EnemyPool.h
UCLASS()
class AEnemyPool : public AActor
{
    GENERATED_BODY()
    
public:
    void InitializePool(int32 PoolSize);
    AEnemy* GetEnemy();
    void ReturnEnemy(AEnemy* Enemy);

private:
    TArray<AEnemy*> AvailableEnemies;
    TArray<AEnemy*> ActiveEnemies;
};

// EnemyPool.cpp
void AEnemyPool::InitializePool(int32 PoolSize)
{
    AvailableEnemies.Empty();
    for (int32 i = 0; i < PoolSize; i++)
    {
        AEnemy* Enemy = GetWorld()->SpawnActor<AEnemy>(EnemyClass, FVector::ZeroVector, FRotator::ZeroRotator);
        Enemy->SetActorHiddenInGame(true);
        Enemy->SetActorEnableCollision(false);
        AvailableEnemies.Add(Enemy);
    }
}

AEnemy* AEnemyPool::GetEnemy()
{
    if (AvailableEnemies.Num() == 0) return nullptr;
    
    AEnemy* Enemy = AvailableEnemies.Pop();
    ActiveEnemies.Add(Enemy);
    Enemy->SetActorHiddenInGame(false);
    Enemy->SetActorEnableCollision(true);
    return Enemy;
}

void AEnemyPool::ReturnEnemy(AEnemy* Enemy)
{
    if (ActiveEnemies.Remove(Enemy) > 0)
    {
        Enemy->ResetState();
        Enemy->SetActorHiddenInGame(true);
        Enemy->SetActorEnableCollision(false);
        AvailableEnemies.Add(Enemy);
    }
}
```

Agora o spawner usa o pool:

```cpp
void AEnemySpawner::SpawnWave(int32 EnemyCount)
{
    for (int32 i = 0; i < EnemyCount; i++)
    {
        AEnemy* NewEnemy = EnemyPool->GetEnemy();
        if (NewEnemy)
        {
            NewEnemy->SetActorLocation(GetRandomSpawnLocation());
            NewEnemy->Initialize();
        }
    }
}
```

**Resultado:** Mesmo `SpawnWave(50)` mantém 60 FPS estáveis. O custo de inicialização fica na criação do pool, não durante o jogo.

### Otimização de Colisão

Outro gargalo comum: cálculos desnecessários de colisão. Um inimigo com:

```cpp
UCapsuleComponent* Collision = CreateDefaultSubobject<UCapsuleComponent>(TEXT("Collision"));
Collision->SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
```

Verifica colisão contra tudo, sempre. Melhor:

```cpp
Collision->SetCollisionEnabled(ECollisionEnabled::QueryOnly);
Collision->SetCollisionResponseToAllChannels(ECR_Ignore);
Collision->SetCollisionResponseToChannel(ECC_Pawn, ECR_Overlap);
Collision->SetCollisionResponseToChannel(ECC_Projectile, ECR_Block);
```

Isso reduz 80% dos testes de colisão, mantendo apenas os necessários.

### Técnicas de LOD (Level of Detail)

Para objetos distantes, reduzimos a complexidade:

```cpp
// No construtor do ator
UStaticMeshComponent* Mesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Mesh"));
Mesh->SetDetailMode(EDetailMode::DM_High);

// No Tick
void AComplexActor::Tick(float DeltaTime)
{
    float DistanceToPlayer = FVector::Dist(GetActorLocation(), PlayerLocation);
    if (DistanceToPlayer > LODDistanceThreshold)
    {
        Mesh->SetDetailMode(EDetailMode::DM_Low);
        SetActorTickInterval(0.5f); // Atualiza menos
    }
    else
    {
        Mesh->SetDetailMode(EDetailMode::DM_High);
        SetActorTickInterval(0.0f); // Atualiza todo frame
    }
}
```

**Erro comum:** Esquecer de redefinir o `TickInterval` pode fazer objetos nunca voltarem ao LOD alto. Sempre teste ambos os casos.

### Exercício Prático

Implemente um `ProjectilePool` para tiros de jogador, com:
1. Pool inicial de 20 projéteis
2. Método `FireProjectile` que reusa ou expande o pool se necessário
3. Retorno automático ao pool após 3 segundos

**Solução comentada:**

```cpp
// ProjectilePool.h
UCLASS()
class AProjectilePool : public AActor
{
    // ... declarações comuns
    
public:
    UFUNCTION(BlueprintCallable)
    void FireProjectile(const FVector& Location, const FRotator& Rotation);

private:
    UFUNCTION()
    void ReturnProjectile(AProjectile* Projectile);
    
    TArray<AProjectile*> ProjectilePool;
};

// ProjectilePool.cpp
void AProjectilePool::FireProjectile(const FVector& Location, const FRotator& Rotation)
{
    AProjectile* Projectile = nullptr;
    
    // Encontra projétil inativo
    for (AProjectile* Proj : ProjectilePool)
    {
        if (!Proj->IsActive())
        {
            Projectile = Proj;
            break;
        }
    }
    
    // Se não encontrou, cria novo
    if (!Projectile && ProjectilePool.Num() < 100) // Limite de expansão
    {
        Projectile = GetWorld()->SpawnActor<AProjectile>(ProjectileClass, Location, Rotation);
        Projectile->OnProjectileEnd.BindUObject(this, &AProjectilePool::ReturnProjectile);
        ProjectilePool.Add(Projectile);
    }
    
    if (Projectile)
    {
        Projectile->Launch(Location, Rotation);
        GetWorld()->GetTimerManager().SetTimer(Projectile->TimerHandle, [this, Projectile]()
        {
            ReturnProjectile(Projectile);
        }, 3.0f, false);
    }
}

void AProjectilePool::ReturnProjectile(AProjectile* Projectile)
{
    Projectile->Deactivate();
}
```