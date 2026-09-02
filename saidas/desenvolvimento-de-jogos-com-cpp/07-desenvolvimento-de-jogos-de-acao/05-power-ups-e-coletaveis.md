## Power-ups e coletáveis

Em jogos de ação, power-ups e coletáveis são elementos fundamentais para manter o jogador engajado e proporcionar momentos de recompensa. Vamos implementar um sistema onde o jogador pode coletar itens que temporariamente aumentam sua velocidade de movimento e outro que concede tiros mais poderosos.

Primeiro, crie uma nova classe `APowerUp` que será a base para todos os power-ups:

```cpp
UCLASS()
class ACTIONGAME_API APowerUp : public AActor
{
    GENERATED_BODY()
    
public:    
    APowerUp();

protected:
    virtual void BeginPlay() override;

    UPROPERTY(VisibleAnywhere, Category = "Components")
    class USphereComponent* CollisionComponent;

    UPROPERTY(VisibleAnywhere, Category = "Components")
    class UStaticMeshComponent* MeshComponent;

    UFUNCTION()
    void OnCollect(UPrimitiveComponent* OverlappedComponent, AActor* OtherActor, UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult& SweepResult);

    virtual void ApplyPowerUp(class AActionCharacter* Character);
};
```

Agora, implemente a classe:

```cpp
APowerUp::APowerUp()
{
    PrimaryActorTick.bCanEverTick = false;

    CollisionComponent = CreateDefaultSubobject<USphereComponent>(TEXT("CollisionComponent"));
    RootComponent = CollisionComponent;
    CollisionComponent->SetSphereRadius(50.0f);

    MeshComponent = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("MeshComponent"));
    MeshComponent->SetupAttachment(RootComponent);

    CollisionComponent->OnComponentBeginOverlap.AddDynamic(this, &APowerUp::OnCollect);
}

void APowerUp::BeginPlay()
{
    Super::BeginPlay();
}

void APowerUp::OnCollect(UPrimitiveComponent* OverlappedComponent, AActor* OtherActor, UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult& SweepResult)
{
    AActionCharacter* Character = Cast<AActionCharacter>(OtherActor);
    if (Character)
    {
        ApplyPowerUp(Character);
        Destroy();
    }
}

void APowerUp::ApplyPowerUp(AActionCharacter* Character)
{
    // Implementação base
}
```

Vamos criar dois power-ups específicos: `ASpeedBoost` e `APowerShot`.

Para o `ASpeedBoost`:

```cpp
UCLASS()
class ACTIONGAME_API ASpeedBoost : public APowerUp
{
    GENERATED_BODY()
    
public:    
    ASpeedBoost();

protected:
    virtual void ApplyPowerUp(class AActionCharacter* Character) override;

    UPROPERTY(EditDefaultsOnly, Category = "PowerUp")
    float SpeedMultiplier;

    UPROPERTY(EditDefaultsOnly, Category = "PowerUp")
    float Duration;
};
```

Implementação:

```cpp
ASpeedBoost::ASpeedBoost()
{
    SpeedMultiplier = 2.0f;
    Duration = 10.0f;
}

void ASpeedBoost::ApplyPowerUp(AActionCharacter* Character)
{
    if (Character)
    {
        Character->BoostSpeed(SpeedMultiplier, Duration);
    }
}
```

No seu personagem principal (`AActionCharacter`), adicione o método:

```cpp
void AActionCharacter::BoostSpeed(float Multiplier, float Duration)
{
    GetCharacterMovement()->MaxWalkSpeed *= Multiplier;
    
    FTimerHandle TimerHandle;
    GetWorldTimerManager().SetTimer(TimerHandle, [this, Multiplier]()
    {
        GetCharacterMovement()->MaxWalkSpeed /= Multiplier;
    }, Duration, false);
}
```

Para o `APowerShot`:

```cpp
UCLASS()
class ACTIONGAME_API APowerShot : public APowerUp
{
    GENERATED_BODY()
    
public:    
    APowerShot();

protected:
    virtual void ApplyPowerUp(class AActionCharacter* Character) override;

    UPROPERTY(EditDefaultsOnly, Category = "PowerUp")
    float DamageMultiplier;

    UPROPERTY(EditDefaultsOnly, Category = "PowerUp")
    float Duration;
};
```

Implementação:

```cpp
APowerShot::APowerShot()
{
    DamageMultiplier = 2.0f;
    Duration = 15.0f;
}

void APowerShot::ApplyPowerUp(AActionCharacter* Character)
{
    if (Character && Character->GetCurrentWeapon())
    {
        Character->GetCurrentWeapon()->BoostDamage(DamageMultiplier, Duration);
    }
}
```

Na classe `AWeapon`, adicione:

```cpp
void AWeapon::BoostDamage(float Multiplier, float Duration)
{
    BaseDamage *= Multiplier;
    
    FTimerHandle TimerHandle;
    GetWorldTimerManager().SetTimer(TimerHandle, [this, Multiplier]()
    {
        BaseDamage /= Multiplier;
    }, Duration, false);
}
```

Para coletáveis simples como moedas, crie uma classe `ACollectible`:

```cpp
UCLASS()
class ACTIONGAME_API ACollectible : public AActor
{
    GENERATED_BODY()
    
public:    
    ACollectible();

protected:
    virtual void BeginPlay() override;

    UPROPERTY(VisibleAnywhere, Category = "Components")
    class USphereComponent* CollisionComponent;

    UPROPERTY(VisibleAnywhere, Category = "Components")
    class UStaticMeshComponent* MeshComponent;

    UFUNCTION()
    void OnCollect(UPrimitiveComponent* OverlappedComponent, AActor* OtherActor, UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult& SweepResult);

    UPROPERTY(EditDefaultsOnly, Category = "Collectible")
    int32 Value;
};
```

Implementação:

```cpp
ACollectible::ACollectible()
{
    PrimaryActorTick.bCanEverTick = false;

    CollisionComponent = CreateDefaultSubobject<USphereComponent>(TEXT("CollisionComponent"));
    RootComponent = CollisionComponent;
    CollisionComponent->SetSphereRadius(25.0f);

    MeshComponent = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("MeshComponent"));
    MeshComponent->SetupAttachment(RootComponent);

    Value = 1;

    CollisionComponent->OnComponentBeginOverlap.AddDynamic(this, &ACollectible::OnCollect);
}

void ACollectible::BeginPlay()
{
    Super::BeginPlay();
}

void ACollectible::OnCollect(UPrimitiveComponent* OverlappedComponent, AActor* OtherActor, UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult& SweepResult)
{
    AActionCharacter* Character = Cast<AActionCharacter>(OtherActor);
    if (Character)
    {
        Character->AddScore(Value);
        Destroy();
    }
}
```

Para testar, crie algumas instâncias desses atores no nível e veja o comportamento ao coletá-los. O jogador deve ganhar velocidade temporariamente ao pegar o `ASpeedBoost`, aumentar o dano das armas com `APowerShot`, e acumular pontos com `ACollectible`.