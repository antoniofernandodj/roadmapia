## Boas práticas de desenvolvimento

Quando seu código de jogo cresce além de algumas centenas de linhas, manutenção se torna um desafio. Considere este trecho típico de um sistema de movimento de personagem:

```cpp
void APlayerCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    
    if (bIsMovingRight && !bIsAttacking) 
    {
        AddMovementInput(FVector(1,0,0), 1);
        GetSprite()->SetFlipbook(RunAnimation);
    }
    else if (bIsMovingLeft && !bIsAttacking)
    {
        AddMovementInput(FVector(-1,0,0), 1);
        GetSprite()->SetFlipbook(RunAnimation);
    }
    else
    {
        GetSprite()->SetFlipbook(IdleAnimation);
    }
    
    if (bIsJumping)
    {
        Jump();
    }
}
```

O código funciona, mas apresenta três problemas críticos:
1. Lógica de movimento misturada com animação
2. Condicionais aninhadas dificultam expansão
3. Valores hardcoded dificultam ajustes

**Princípio da Responsabilidade Única (SRP)**

Cada classe deve ter uma única responsabilidade. Vamos refatorar separando movimento e animação:

```cpp
// PlayerMovementComponent.h
UCLASS()
class UPlayerMovementComponent : public UActorComponent
{
    GENERATED_BODY()
public:
    void MoveRight(float Value);
    void MoveLeft(float Value);
    void Jump();

private:
    bool bIsMovingRight = false;
    bool bIsMovingLeft = false;
};

// PlayerAnimationComponent.h
UCLASS()
class UPlayerAnimationComponent : public UActorComponent
{
    GENERATED_BODY()
public:
    void UpdateAnimation(bool bIsMoving, bool bIsAttacking);

private:
    UPaperFlipbook* RunAnimation;
    UPaperFlipbook* IdleAnimation;
};
```

**Injeção de Dependência**

Evite acoplamento direto entre componentes. O padrão Observer resolve:

```cpp
// PlayerCharacter.h
UCLASS()
class APlayerCharacter : public ACharacter
{
    GENERATED_BODY()
public:
    UPROPERTY(VisibleAnywhere)
    UPlayerMovementComponent* MovementComp;

    UPROPERTY(VisibleAnywhere)
    UPlayerAnimationComponent* AnimationComp;

    UFUNCTION()
    void OnMovementChanged(bool bIsMoving);
};

// PlayerCharacter.cpp
void APlayerCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    MovementComp->OnMovementChanged.AddDynamic(AnimationComp, &UPlayerAnimationComponent::UpdateAnimation);
}
```

**Constantes e Configurações**

Valores mágicos devem ser parametrizados. Crie um Data Asset:

```cpp
// PlayerSettings.h
UCLASS()
class UPlayerSettings : public UDataAsset
{
    GENERATED_BODY()
public:
    UPROPERTY(EditDefaultsOnly)
    float MoveSpeed = 500.0f;

    UPROPERTY(EditDefaultsOnly)
    float JumpVelocity = 1000.0f;
};

// Uso no código
MovementComp->Move(PlayerSettings->MoveSpeed);
```

**Tratamento de Erros**

Erros comuns como acesso nulo devem ser verificados:

```cpp
if (!AnimationComp)
{
    UE_LOG(LogTemp, Error, TEXT("Animation component is missing!"));
    return;
}
```

A saída no Output Log seria:
```
LogTemp: Error: Animation component is missing!
```

**Exercício Prático**

Refatore este código de ataque usando boas práticas:

```cpp
void AEnemy::Attack()
{
    if (Player && !bIsDead && Stamina > 0 && !bIsStunned) 
    {
        PlaySound(AttackSound);
        Player->TakeDamage(DamageAmount);
        Stamina -= 10;
        PlayAnimation(AttackAnimation);
    }
}
```

**Solução Comentada**

```cpp
// EnemyCombatComponent.h
UCLASS()
class UEnemyCombatComponent : public UActorComponent
{
    GENERATED_BODY()
public:
    bool CanAttack() const;
    void PerformAttack();

    UPROPERTY(EditDefaultsOnly)
    float DamageAmount = 20.0f;

    UPROPERTY(EditDefaultsOnly)
    float StaminaCost = 10.0f;
};

// EnemyCombatComponent.cpp
bool UEnemyCombatComponent::CanAttack() const
{
    return Stamina > 0 && !bIsStunned && !bIsDead;
}

void UEnemyCombatComponent::PerformAttack()
{
    if (!CanAttack()) return;
    
    OnAttackStarted.Broadcast();
    Stamina -= StaminaCost;
}
```