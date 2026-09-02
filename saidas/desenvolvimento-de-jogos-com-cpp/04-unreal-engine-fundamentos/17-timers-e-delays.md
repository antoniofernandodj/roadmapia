## Timers e delays

Imagine um inimigo em seu jogo que precisa atirar a cada 3 segundos, ou um power-up que desaparece após 10 segundos na tela. Sem timers, você precisaria criar contadores manuais no Tick, poluindo seu código e desperdiçando ciclos de CPU. A Unreal Engine oferece um sistema robusto para lidar com ações temporizadas.

### FTimerHandle: O coração do sistema

O mecanismo básico envolve dois componentes principais:
1. `FTimerHandle` - um identificador para controlar o timer
2. `GetWorld()->GetTimerManager()` - o gerenciador central de timers

Vamos implementar um projetil que se autodestrói após 5 segundos:

```cpp
// No cabeçalho (.h)
FTimerHandle DestroyTimerHandle;

// Na implementação (.cpp)
void AProjectile::BeginPlay()
{
    Super::BeginPlay();
    
    GetWorld()->GetTimerManager().SetTimer(
        DestroyTimerHandle,      // Handle para controle
        this,                    // Objeto dono
        &AProjectile::DestroySelf, // Função a chamar
        5.0f,                    // Tempo em segundos
        false                    // Não repetir
    );
}

void AProjectile::DestroySelf()
{
    Destroy();
}
```

Se você esquecer de declarar o `FTimerHandle` como membro da classe, receberá o erro:
```
error C2065: 'DestroyTimerHandle': undeclared identifier
```

### Timer com repetição

Para criar um atirador que dispare a cada 2 segundos:

```cpp
// No cabeçalho
FTimerHandle ShootingTimerHandle;
void ShootProjectile();

// Na implementação
void AShooter::BeginPlay()
{
    Super::BeginPlay();
    
    GetWorld()->GetTimerManager().SetTimer(
        ShootingTimerHandle,
        this,
        &AShooter::ShootProjectile,
        2.0f,    // Intervalo
        true     // Repetir
    );
}
```

Se tentar chamar `ShootProjectile` sem declarar a função, o erro será:
```
error C3867: 'AShooter::ShootProjectile': non-standard syntax; use '&' to create a pointer to member
```

### Cancelando timers

Para interromper um timer em execução:

```cpp
void AShooter::StopShooting()
{
    GetWorld()->GetTimerManager().ClearTimer(ShootingTimerHandle);
}
```

Se tentar limpar um handle inválido, não ocorrerá erro - o sistema simplesmente ignora.

### Delays simples

Para ações únicas após um delay, sem precisar de handle:

```cpp
void APowerUp::Activate()
{
    // Executa Deactivate() após 10 segundos
    GetWorld()->GetTimerManager().SetTimer(
        FTimerHandle(),  // Handle anônimo
        this,
        &APowerUp::Deactivate,
        10.0f,
        false
    );
}
```

### Verificando timers ativos

Para saber se um timer está em execução:

```cpp
if (GetWorld()->GetTimerManager().IsTimerActive(DestroyTimerHandle))
{
    // Timer está ativo
}
```

### Erro comum: Timer em objetos destruídos

Um erro frequente é tentar chamar um timer após o objeto ter sido destruído. Isso causa um crash com:

```
Access violation reading location 0x00000000
```

Solução: sempre limpe os timers no destruidor:

```cpp
AProjectile::~AProjectile()
{
    GetWorld()->GetTimerManager().ClearTimer(DestroyTimerHandle);
}
```

### Exemplo completo: Inimigo que atira

```cpp
// Enemy.h
UCLASS()
class AMYPROJECT_API AEnemy : public AActor
{
    GENERATED_BODY()
public:
    void StartShooting();
    void StopShooting();

private:
    FTimerHandle ShootingTimerHandle;
    void Shoot();
};

// Enemy.cpp
void AEnemy::StartShooting()
{
    GetWorld()->GetTimerManager().SetTimer(
        ShootingTimerHandle,
        this,
        &AEnemy::Shoot,
        3.0f,
        true,
        0.0f  // Tempo inicial (dispara imediatamente)
    );
}

void AEnemy::Shoot()
{
    // Lógica para criar e disparar projétil
    UE_LOG(LogTemp, Warning, TEXT("Enemy fired at %f"), GetWorld()->GetTimeSeconds());
}

void AEnemy::StopShooting()
{
    GetWorld()->GetTimerManager().ClearTimer(ShootingTimerHandle);
}
```

Saída esperada no log:
```
LogTemp: Warning: Enemy fired at 0.000000
LogTemp: Warning: Enemy fired at 3.000000
LogTemp: Warning: Enemy fired at 6.000000
```

### Exercício: Coletável temporizado

Crie um ator `ATimedCollectible` que:
1. Aparece na cena por padrão
2. Quando coletado pelo jogador, desaparece e reaparece após 15 segundos
3. Mostra no log o tempo exato de cada reaparição

**Solução comentada:**

```cpp
// TimedCollectible.h
UCLASS()
class AMYPROJECT_API ATimedCollectible : public AActor
{
    GENERATED_BODY()
public:
    void OnCollected();

private:
    FTimerHandle RespawnTimerHandle;
    void Respawn();
    UStaticMeshComponent* Mesh;
};

// TimedCollectible.cpp
ATimedCollectible::ATimedCollectible()
{
    Mesh = CreateDefaultSubobject<UStaticMeshComponent>("Mesh");
    RootComponent = Mesh;
    Mesh->SetCollisionEnabled(ECollisionEnabled::QueryOnly);
}

void ATimedCollectible::OnCollected()
{
    Mesh->SetVisibility(false);
    Mesh->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    
    GetWorld()->GetTimerManager().SetTimer(
        RespawnTimerHandle,
        this,
        &ATimedCollectible::Respawn,
        15.0f,
        false
    );
}

void ATimedCollectible::Respawn()
{
    Mesh->SetVisibility(true);
    Mesh->SetCollisionEnabled(ECollisionEnabled::QueryOnly);
    UE_LOG(LogTemp, Log, TEXT("Collectible respawned at %f"), GetWorld()->GetTimeSeconds());
}
```