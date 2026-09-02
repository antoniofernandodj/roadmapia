## Debugging e testes básicos

Seu personagem atira, mas os projéteis desaparecem antes de atingir o inimigo. O placar de pontos atualiza às vezes, mas não sempre. Esses problemas são comuns em jogos de ação e exigem ferramentas específicas para diagnóstico. Vamos resolver um caso real passo a passo.

**Problema concreto**: Um projétil que deveria viajar 1000 unidades some após 300. Começamos inspecionando a classe `AProjectile`:

```cpp
void AProjectile::BeginPlay()
{
    Super::BeginPlay();
    SetLifeSpan(3.0f); // Auto-destruir após 3 segundos
}

void AProjectile::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    FVector Movement = GetActorForwardVector() * Speed * DeltaTime;
    AddActorWorldOffset(Movement, true);
}
```

A primeira suspeita é o `SetLifeSpan`. Removemos essa linha e testamos - o projétil agora viaja indefinidamente, passando do alvo. Claramente não era o problema original.

Adicionamos um debug draw para visualizar o trajeto:

```cpp
void AProjectile::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    FVector Start = GetActorLocation();
    FVector Movement = GetActorForwardVector() * Speed * DeltaTime;
    AddActorWorldOffset(Movement, true);
    
    // Debug
    DrawDebugLine(GetWorld(), Start, GetActorLocation(), 
        FColor::Green, false, 2.0f, 0, 1.0f);
}
```

A linha verde aparece, mas ainda desaparece prematuramente. O console mostra o aviso:

```
LogCollision: Warning: Projectile_1 collided with Unknown at X=320 Y=150 Z=50
```

Isso revela o verdadeiro problema - colisão com um objeto invisível. Ativamos a visualização de colisões com `show collision` no console e descobrimos um `BoxComponent` esquecido no mapa.

**Solução definitiva**:
1. Modificamos a colisão para ignorar objetos invisíveis:
```cpp
ProjectileCollision->SetCollisionResponseToChannel(
    ECC_Visibility, ECR_Ignore);
```
2. Adicionamos logs detalhados:
```cpp
UE_LOG(LogTemp, Warning, TEXT("Projectile at %s"), 
    *GetActorLocation().ToString());
```

**Teste de dano falhando**:
Quando o projétil acerta, o inimigo não toma dano. Verificamos a função `TakeDamage`:

```cpp
float AEnemy::TakeDamage(float Damage, FDamageEvent const&, 
    AController* EventInstigator, AActor* DamageCauser)
{
    Health -= Damage;
    if(Health <= 0) Destroy();
    return Damage; 
}
```

O problema aparece quando adicionamos um breakpoint - a função nunca é chamada. A solução está no setup da colisão:

```cpp
// No construtor do projétil:
CollisionComp->OnComponentHit.AddDynamic(
    this, &AProjectile::OnHit);

void AProjectile::OnHit(UPrimitiveComponent* HitComp, 
    AActor* OtherActor, UPrimitiveComponent* OtherComp, 
    FVector NormalImpulse, const FHitResult& Hit)
{
    OtherActor->TakeDamage(Damage, FDamageEvent(), 
        GetInstigatorController(), this);
}
```

**Exercício**: Implemente um sistema que:
1. Loga a posição de cada inimigo gerado
2. Desenha um círculo vermelho em inimigos com menos de 30% de vida
3. Pausa o jogo por 0.5s quando o jogador toma dano

**Solução comentada**:
```cpp
// 1. Log de posição no SpawnEnemy
UE_LOG(LogEnemy, Log, TEXT("Enemy spawned at %s"), 
    *GetActorLocation().ToString());

// 2. No Tick do inimigo
if(Health/MaxHealth < 0.3f)
{
    DrawDebugCircle(GetWorld(), GetActorLocation(), 
        50.0f, 24, FColor::Red, false, -1.0f, 0, 2.0f);
}

// 3. No TakeDamage do jogador
UGameplayStatics::SetGamePaused(GetWorld(), true);
FTimerHandle UnpauseHandle;
GetWorld()->GetTimerManager().SetTimer(UnpauseHandle, [](){
    UGameplayStatics::SetGamePaused(GetWorld(), false);
}, 0.5f, false);
```