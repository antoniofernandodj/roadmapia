## Implementação de sistemas principais

Um jogo de ação 2D precisa de três sistemas fundamentais: física para movimentação e colisões, IA para comportamentos dos inimigos e UI para feedback ao jogador. Vamos implementá-los em C++ puro, integrando com a Unreal Engine.

### Sistema de Física

O problema central: como fazer um personagem andar e pular com comportamento físico realista? Na Unreal, isso começa com a classe `UCharacterMovementComponent`. Veja o erro comum ao tentar movimentar um personagem sem configurá-lo corretamente:

```cpp
// Character.h
UCLASS()
class AMyCharacter : public ACharacter
{
    GENERATED_BODY()
    
public:
    void MoveForward(float Value);
};

// Character.cpp
void AMyCharacter::MoveForward(float Value)
{
    AddMovementInput(FVector::ForwardVector, Value);
}
```

Ao tentar mover o personagem, você receberia:
```
LogCharacterMovement: No MovementComponent was found on MyCharacter. 
Please add a UCharacterMovementComponent to your character.
```

A solução é herdar de `ACharacter` (que já inclui o componente) e configurar os parâmetros físicos:

```cpp
// Character.h
UCLASS()
class AMyCharacter : public ACharacter
{
    GENERATED_BODY()
    
public:
    UPROPERTY(EditAnywhere, Category = "Movement")
    float JumpVelocity = 600.f;
    
    virtual void SetupPlayerInputComponent() override;
};

// Character.cpp
void AMyCharacter::SetupPlayerInputComponent()
{
    Super::SetupPlayerInputComponent();
    
    InputComponent->BindAxis("MoveForward", this, &AMyCharacter::MoveForward);
    InputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);
}

void AMyCharacter::MoveForward(float Value)
{
    if (Value != 0.0f)
    {
        AddMovementInput(GetActorForwardVector(), Value);
    }
}
```

### Sistema de IA

Para inimigos que perseguem o jogador, usamos o `AIController` com `Behavior Trees`. Um erro frequente é tentar acessar o jogador sem configurar o `Blackboard`:

```cpp
// EnemyAIController.cpp
void AEnemyAIController::BeginPlay()
{
    Super::BeginPlay();
    
    APawn* PlayerPawn = UGameplayStatics::GetPlayerPawn(GetWorld(), 0);
    if (PlayerPawn)
    {
        GetBlackboardComponent()->SetValueAsObject("Player", PlayerPawn);
    }
}
```

Sem a configuração prévia no Blackboard, você receberá:
```
LogBehaviorTree: Blackboard key 'Player' not found
```

A implementação completa requer:

1. Criar um `BlackboardData` com a chave "Player" do tipo `Object`
2. Criar um `BehaviorTree` que usa esse Blackboard
3. Configurar o AIController no inimigo:

```cpp
// Enemy.h
UCLASS()
class AEnemy : public ACharacter
{
    GENERATED_BODY()
    
public:
    virtual void PossessedBy(AController* NewController) override;
};

// Enemy.cpp
void AEnemy::PossessedBy(AController* NewController)
{
    Super::PossessedBy(NewController);
    
    if (AAIController* AIController = Cast<AAIController>(NewController))
    {
        AIController->RunBehaviorTree(BehaviorTree);
    }
}
```

### Sistema de UI

Para mostrar vida e pontuação, criamos um `UUserWidget` em C++. O erro clássico é esquecer de chamar `AddToViewport()`:

```cpp
// GameHUD.h
UCLASS()
class UGameHUD : public UUserWidget
{
    GENERATED_BODY()
    
public:
    UPROPERTY(meta = (BindWidget))
    class UTextBlock* ScoreText;
    
    void UpdateScore(int32 NewScore);
};

// GameHUD.cpp
void UGameHUD::UpdateScore(int32 NewScore)
{
    if (ScoreText)
    {
        ScoreText->SetText(FText::AsNumber(NewScore));
    }
}

// GameMode.cpp
void AMyGameMode::BeginPlay()
{
    Super::BeginPlay();
    
    UGameHUD* HUD = CreateWidget<UGameHUD>(GetWorld(), HUDClass);
    if (HUD)
    {
        HUD->AddToViewport(); // ESSENCIAL!
    }
}
```

Sem essa linha, o HUD é criado mas não aparece na tela.

### Exercício Prático

Implemente um sistema de coleta de itens que:
1. Detecta colisão entre o personagem e um ator "Item"
2. Incrementa a pontuação no HUD
3. Toca um som de coleta
4. Destroi o item coletado

Solução comentada:

```cpp
// Item.h
UCLASS()
class AItem : public AActor
{
    GENERATED_BODY()
    
public:
    UFUNCTION()
    void OnOverlap(AActor* OverlappedActor, AActor* OtherActor);
};

// Item.cpp
void AItem::OnOverlap(AActor* OverlappedActor, AActor* OtherActor)
{
    if (AMyCharacter* Character = Cast<AMyCharacter>(OtherActor))
    {
        Character->AddScore(PointsValue);
        UGameplayStatics::PlaySound2D(this, CollectSound);
        Destroy();
    }
}

// Character.cpp
void AMyCharacter::AddScore(int32 Points)
{
    Score += Points;
    if (HUDRef)
    {
        HUDRef->UpdateScore(Score);
    }
}
```