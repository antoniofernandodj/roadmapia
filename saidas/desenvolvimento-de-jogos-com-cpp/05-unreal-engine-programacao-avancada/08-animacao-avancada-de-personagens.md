## Animação avançada de personagens

Imagine que seu personagem está correndo em um jogo de plataforma, mas quando ele para, a transição é brusca - os pés escorregam, o corpo parece deslizar. Isso acontece quando falta um sistema de animação entre estados (Idle → Run → Stop). Veja como resolver com Animation Blueprints e C++:

```cpp
// CharacterAnimInstance.h
UCLASS()
class MYGAME_API UCharacterAnimInstance : public UAnimInstance
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Animation")
    float Speed;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Animation")
    bool bIsJumping;

    virtual void NativeUpdateAnimation(float DeltaTime) override;
};

// CharacterAnimInstance.cpp
void UCharacterAnimInstance::NativeUpdateAnimation(float DeltaTime)
{
    Super::NativeUpdateAnimation(DeltaTime);

    ACharacter* OwnerCharacter = Cast<ACharacter>(TryGetPawnOwner());
    if (OwnerCharacter)
    {
        Speed = OwnerCharacter->GetVelocity().Size();
        bIsJumping = OwnerCharacter->GetMovementComponent()->IsFalling();
    }
}
```

Este código cria variáveis que serão usadas no Animation Blueprint para controlar transições. O segredo está em `NativeUpdateAnimation`, chamado a cada frame para atualizar os valores.

No Unreal Editor, crie um Animation Blueprint que usa esta classe como parent. Configure as transições com condições baseadas em `Speed` e `bIsJumping`:

1. No Graph do Animation Blueprint, adicione um State Machine
2. Crie estados como Idle, Run, Jump
3. Defina transições usando regras como:
   - Idle → Run: Speed > 10
   - Run → Idle: Speed < 5
   - Any → Jump: bIsJumping == true

O erro mais comum aparece quando esquecemos de conectar o Animation Blueprint ao personagem:
```
LogAnimation: Error: No AnimBlueprint assigned to CharacterMesh!
```

Corrija no Blueprint do personagem, na seção Mesh:
1. Selecione o SkeletalMesh
2. Em Anim Class, selecione seu Animation Blueprint

Para animações mais complexas como ataques combados, usamos Montages:
```cpp
// No header da classe do personagem
UPROPERTY(EditDefaultsOnly, Category = "Combat")
UAnimMontage* AttackMontage;

// Na função de ataque
void AMyCharacter::Attack()
{
    if(AttackMontage && !GetMesh()->GetAnimInstance()->IsAnyMontagePlaying())
    {
        PlayAnimMontage(AttackMontage);
    }
    else
    {
        UE_LOG(LogTemp, Warning, TEXT("Attack montage not set or already playing!"));
    }
}
```

Para sincronizar eventos de animação com lógica de jogo (como aplicar dano no frame exato do golpe), usamos Notifies:

1. Crie um AnimNotify no editor de animação
2. Adicione ao AttackMontage no frame desejado
3. Implemente em C++:
```cpp
UCLASS()
class MYGAME_API UAttackHitNotify : public UAnimNotify
{
    GENERATED_BODY()
    
    virtual void Notify(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation) override
    {
        if (MeshComp && MeshComp->GetOwner())
        {
            AMyCharacter* Character = Cast<AMyCharacter>(MeshComp->GetOwner());
            if (Character)
            {
                Character->ApplyDamage();
            }
        }
    }
};
```

A técnica final é o Blend Space para movimentos multidirecionais. Crie um Blend Space no editor:

1. Importe animações de corrida em várias direções
2. Configure os eixos (X: Direction, Y: Speed)
3. No código, atualize a direção:
```cpp
// No CharacterAnimInstance
UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Animation")
float Direction;

void UCharacterAnimInstance::NativeUpdateAnimation(float DeltaTime)
{
    // Código anterior...
    
    FVector Velocity = OwnerCharacter->GetVelocity();
    FRotator Rotation = OwnerCharacter->GetActorRotation();
    Direction = CalculateDirection(Velocity, Rotation);
}
```

**Exercício**: Crie um sistema onde o personagem:
1. Transicione suavemente entre caminhar e correr baseado no input
2. Tenha um ataque especial que só pode ser executado após 3 ataques normais
3. Mude a animação de corrida quando estiver com menos de 30% de vida

Solução:
```cpp
// No Character.h
UPROPERTY(VisibleAnywhere, BlueprintReadOnly)
int32 ComboCounter;

UPROPERTY(VisibleAnywhere, BlueprintReadOnly)
float Health;

// No Character.cpp
void AMyCharacter::Attack()
{
    if(ComboCounter >= 3 && SpecialAttackMontage)
    {
        PlayAnimMontage(SpecialAttackMontage);
        ComboCounter = 0;
    }
    else if(AttackMontage)
    {
        PlayAnimMontage(AttackMontage);
        ComboCounter++;
    }
}

// No AnimInstance
void UCharacterAnimInstance::NativeUpdateAnimation(float DeltaTime)
{
    // Código existente...
    
    AMyCharacter* MyCharacter = Cast<AMyCharacter>(TryGetPawnOwner());
    if(MyCharacter)
    {
        Health = MyCharacter->GetHealth();
        
        // No Blend Space, crie uma condição para usar animação diferente quando Health < 30
        bIsInjured = (Health < 30.0f);
    }
}
```