## Projeto prático: jogo de ação

Vamos criar um jogo de ação simples onde o jogador controla um personagem que pode se mover e atirar em inimigos que aparecem em ondas. O objetivo é sobreviver o maior tempo possível enquanto acumula pontuação por cada inimigo derrotado.

### Configuração inicial

Primeiro, crie um novo projeto na Unreal Engine usando o template "Side Scroller". Isso já configura um ambiente 2D com física e câmera adequados. No Content Browser, crie uma nova pasta chamada "Characters" para organizar nossos assets.

### Personagem do jogador

Crie uma nova classe C++ chamada `AActionHero` que herda de `ACharacter`. Esta classe será responsável pelo controle do jogador.

```cpp
#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "ActionHero.generated.h"

UCLASS()
class ACTIONGAME_API AActionHero : public ACharacter
{
    GENERATED_BODY()

public:
    AActionHero();

protected:
    virtual void BeginPlay() override;

public:	
    virtual void Tick(float DeltaTime) override;
    virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

    void MoveForward(float Value);
    void Shoot();
};
```

No arquivo `.cpp`, implemente os métodos básicos:

```cpp
AActionHero::AActionHero()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AActionHero::BeginPlay()
{
    Super::BeginPlay();
}

void AActionHero::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}

void AActionHero::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAxis("MoveForward", this, &AActionHero::MoveForward);
    PlayerInputComponent->BindAction("Shoot", IE_Pressed, this, &AActionHero::Shoot);
}

void AActionHero::MoveForward(float Value)
{
    AddMovementInput(FVector(1.0f, 0.0f, 0.0f), Value);
}

void AActionHero::Shoot()
{
    UE_LOG(LogTemp, Warning, TEXT("Shooting!"));
}
```

No Editor, configure os Inputs nas Project Settings:
- Mapeie "MoveForward" para as teclas A/D ou ←/→
- Mapeie "Shoot" para a barra de espaço

### Sistema de tiros

Crie uma nova classe `AProjectile` para representar os tiros:

```cpp
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Projectile.generated.h"

UCLASS()
class ACTIONGAME_API AProjectile : public AActor
{
    GENERATED_BODY()
    
public:    
    AProjectile();

protected:
    virtual void BeginPlay() override;

public:    
    virtual void Tick(float DeltaTime) override;

    UPROPERTY(VisibleAnywhere)
    class UStaticMeshComponent* Mesh;

    UPROPERTY(VisibleAnywhere)
    class UProjectileMovementComponent* ProjectileMovement;
};
```

Implemente o movimento do projétil:

```cpp
AProjectile::AProjectile()
{
    PrimaryActorTick.bCanEverTick = true;

    Mesh = CreateDefaultSubobject<UStaticMeshComponent>("Mesh");
    RootComponent = Mesh;

    ProjectileMovement = CreateDefaultSubobject<UProjectileMovementComponent>("ProjectileMovement");
    ProjectileMovement->InitialSpeed = 1000.0f;
    ProjectileMovement->MaxSpeed = 1000.0f;
}

void AProjectile::BeginPlay()
{
    Super::BeginPlay();
}

void AProjectile::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}
```

Modifique o método `Shoot` do `AActionHero` para instanciar projéteis:

```cpp
void AActionHero::Shoot()
{
    if (ProjectileClass)
    {
        FVector SpawnLocation = GetActorLocation() + GetActorForwardVector() * 100.0f;
        FRotator SpawnRotation = GetActorRotation();
        
        FActorSpawnParameters SpawnParams;
        SpawnParams.Owner = this;
        SpawnParams.Instigator = GetInstigator();
        
        GetWorld()->SpawnActor<AProjectile>(ProjectileClass, SpawnLocation, SpawnRotation, SpawnParams);
    }
}
```

### Sistema de inimigos

Crie uma classe `AEnemy` que persegue o jogador:

```cpp
#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "Enemy.generated.h"

UCLASS()
class ACTIONGAME_API AEnemy : public ACharacter
{
    GENERATED_BODY()

public:
    AEnemy();

protected:
    virtual void BeginPlay() override;

public:	
    virtual void Tick(float DeltaTime) override;

    UPROPERTY(EditAnywhere, Category="AI")
    float ChaseDistance = 500.0f;

private:
    class AActionHero* Player;
};
```

Implemente a perseguição:

```cpp
AEnemy::AEnemy()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AEnemy::BeginPlay()
{
    Super::BeginPlay();
    Player = Cast<AActionHero>(GetWorld()->GetFirstPlayerController()->GetPawn());
}

void AEnemy::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    if (Player && FVector::Dist(Player->GetActorLocation(), GetActorLocation()) < ChaseDistance)
    {
        FVector Direction = (Player->GetActorLocation() - GetActorLocation()).GetSafeNormal();
        AddMovementInput(Direction, 1.0f);
    }
}
```

### Sistema de spawn

Crie um `AEnemySpawner` para gerenciar a criação de inimigos:

```cpp
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "EnemySpawner.generated.h"

UCLASS()
class ACTIONGAME_API AEnemySpawner : public AActor
{
    GENERATED_BODY()
    
public:    
    AEnemySpawner();

protected:
    virtual void BeginPlay() override;

    void SpawnEnemy();

    UPROPERTY(EditAnywhere, Category="Spawning")
    TSubclassOf<class AEnemy> EnemyClass;

    UPROPERTY(EditAnywhere, Category="Spawning")
    float SpawnInterval = 2.0f;

    FTimerHandle SpawnTimerHandle;
};
```

Implemente o spawn periódico:

```cpp
AEnemySpawner::AEnemySpawner()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AEnemySpawner::BeginPlay()
{
    Super::BeginPlay();
    GetWorldTimerManager().SetTimer(SpawnTimerHandle, this, &AEnemySpawner::SpawnEnemy, SpawnInterval, true);
}

void AEnemySpawner::SpawnEnemy()
{
    if (EnemyClass)
    {
        FVector SpawnLocation = GetActorLocation() + FMath::RandPointInBox(FBox(FVector(-200, -200, 0), FVector(200, 200, 0)));
        FRotator SpawnRotation = FRotator::ZeroRotator;
        
        GetWorld()->SpawnActor<AEnemy>(EnemyClass, SpawnLocation, SpawnRotation);
    }
}
```

### Sistema de pontuação

Crie uma classe `AGameModeBase` para gerenciar o estado do jogo:

```cpp
#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "ActionGameGameModeBase.generated.h"

UCLASS()
class ACTIONGAME_API AActionGameGameModeBase : public AGameModeBase
{
    GENERATED_BODY()

public:
    AActionGameGameModeBase();

    void AddScore(int32 Points);

protected:
    virtual void BeginPlay() override;

    UPROPERTY(VisibleAnywhere)
    int32 Score = 0;
};
```

Implemente a lógica de pontuação:

```cpp
AActionGameGameModeBase::AActionGameGameModeBase()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AActionGameGameModeBase::BeginPlay()
{
    Super::BeginPlay();
}

void AActionGameGameModeBase::AddScore(int32 Points)
{
    Score += Points;
    UE_LOG(LogTemp, Warning, TEXT("Current Score: %d"), Score);
}
```

Modifique o `AProjectile` para detectar colisões com inimigos:

```cpp
void AProjectile::BeginPlay()
{
    Super::BeginPlay();
    Mesh->OnComponentHit.AddDynamic(this, &AProjectile::OnHit);
}

void AProjectile::OnHit(UPrimitiveComponent* HitComp, AActor* OtherActor, UPrimitiveComponent* OtherComp, FVector NormalImpulse, const FHitResult& Hit)
{
    if (OtherActor && OtherActor != this && OtherActor->IsA(AEnemy::StaticClass()))
    {
        OtherActor->Destroy();
        AActionGameGameModeBase* GameMode = Cast<AActionGameGameModeBase>(GetWorld()->GetAuthGameMode());
        if (GameMode)
        {
            GameMode->AddScore(10);
        }
        Destroy();
    }
}
```

### Exercício final

Implemente um sistema de vidas para o jogador. O jogador deve perder uma vida ao ser tocado por um inimigo e o jogo deve terminar quando as vidas acabarem. Mostre o número de vidas restantes na tela usando um widget de HUD.