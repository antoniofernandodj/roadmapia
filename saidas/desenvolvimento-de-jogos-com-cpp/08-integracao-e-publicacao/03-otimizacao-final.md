## Otimização final

Quando seu jogo está funcional mas trava em cenas complexas, a otimização faz a diferença entre um protótipo e um produto final. Veja um caso real - um sistema de partículas que congela o jogo quando muitos efeitos ocorrem simultaneamente:

```cpp
// Sistema NÃO otimizado - cria nova partícula a cada chamada
void ASpawner::SpawnParticle() {
    AParticle* NewParticle = GetWorld()->SpawnActor<AParticle>(ParticleClass, GetActorLocation(), FRotator::ZeroRotator);
    NewParticle->Activate();
}
```

O problema aparece quando chamamos isso 60 vezes por segundo - cada `SpawnActor` aloca memória dinamicamente. A Unreal Engine mostra o erro: 
```
LogSpawn: Warning: SpawnActor failed because of collision at the spawn location [cheap]
```

A solução é um **object pooling** - criar partículas antecipadamente e reutilizá-las:

```cpp
// Pool de partículas otimizado
TArray<AParticle*> ParticlePool;

void ASpawner::BeginPlay() {
    Super::BeginPlay();
    
    // Pré-aloca 20 partículas
    for (int i = 0; i < 20; i++) {
        AParticle* Particle = GetWorld()->SpawnActor<AParticle>(ParticleClass, GetActorLocation(), FRotator::ZeroRotator);
        Particle->Deactivate(); // Começa desativado
        ParticlePool.Add(Particle);
    }
}

AParticle* ASpawner::GetAvailableParticle() {
    for (AParticle* Particle : ParticlePool) {
        if (!Particle->IsActive()) {
            return Particle;
        }
    }
    return nullptr; // Todas em uso
}
```

Outro gargalo comum são cálculos repetitivos. Considere esta implementação de detecção de inimigos:

```cpp
// Código original - recalcula distância todo frame
void AEnemyAI::Tick(float DeltaTime) {
    Super::Tick(DeltaTime);
    
    float DistanceToPlayer = FVector::Dist(GetActorLocation(), Player->GetActorLocation());
    if (DistanceToPlayer < DetectionRadius) {
        ChasePlayer();
    }
}
```

Mesmo quando o jogador está parado, o cálculo roda 60 vezes por segundo. A versão otimizada usa um **timer** e cache:

```cpp
// Versão otimizada - verifica a cada 0.5 segundos
void AEnemyAI::Tick(float DeltaTime) {
    Super::Tick(DeltaTime);
    
    TimeSinceLastCheck += DeltaTime;
    if (TimeSinceLastCheck >= 0.5f) {
        CachedDistance = FVector::Dist(GetActorLocation(), Player->GetActorLocation());
        TimeSinceLastCheck = 0.f;
    }
    
    if (CachedDistance < DetectionRadius) {
        ChasePlayer();
    }
}
```

Para texturas, a Unreal oferece níveis de detalhe (LODs). Configure no editor:
1. Selecione sua malha estática
2. Abra "Details" > "LOD Settings"
3. Defina "Number of LODs" para 3 ou 4
4. Ajuste os limites de distância para cada nível

Um erro frequente é esquecer de empacotar assets corretamente. Se o log mostra:
```
LogStreaming: Warning: Failed to read file '../../../Content/Textures/T_Background.uasset'
```
Significa que a referência está quebrada. Corrija com:

```cpp
// Carregamento correto usando referências diretas
UTexture2D* BackgroundTexture = LoadObject<UTexture2D>(nullptr, TEXT("/Game/Textures/T_Background.T_Background"));
if (!BackgroundTexture) {
    UE_LOG(LogTemp, Warning, TEXT("Texture failed to load!"));
}
```

Exercício: Implemente um sistema de pool para projéteis onde:
1. Crie 10 projéteis no BeginPlay
2. Reative projéteis quando o jogador atira
3. Desative quando colidem
4. Recicle projéteis ao invés de destruí-los

Solução comentada:

```cpp
// Declare no header
TArray<AProjectile*> ProjectilePool;

// Implementação
void AShooterCharacter::BeginPlay() {
    Super::BeginPlay();
    
    for (int i = 0; i < 10; i++) {
        AProjectile* Proj = GetWorld()->SpawnActor<AProjectile>(ProjectileClass, FVector::ZeroVector, FRotator::ZeroRotator);
        Proj->SetActorEnableCollision(false);
        Proj->SetActorHiddenInGame(true);
        ProjectilePool.Add(Proj);
    }
}

void AShooterCharacter::FireProjectile() {
    AProjectile* AvailableProj = nullptr;
    for (AProjectile* Proj : ProjectilePool) {
        if (Proj->IsHidden()) {
            AvailableProj = Proj;
            break;
        }
    }
    
    if (AvailableProj) {
        AvailableProj->SetActorLocation(GetActorLocation());
        AvailableProj->SetActorEnableCollision(true);
        AvailableProj->SetActorHiddenInGame(false);
        AvailableProj->LaunchProjectile(GetActorForwardVector());
    }
}

// Na classe AProjectile:
void AProjectile::OnHit() {
    SetActorEnableCollision(false);
    SetActorHiddenInGame(true);
}
```