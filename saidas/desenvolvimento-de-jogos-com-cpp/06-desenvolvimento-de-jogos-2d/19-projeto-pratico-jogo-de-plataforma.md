## Projeto prático: jogo de plataforma

Neste projeto prático, vamos criar um jogo de plataforma simples utilizando Unreal Engine e C++. O objetivo é guiar você pela construção de um jogo funcional, desde a criação do personagem até a implementação de mecânicas básicas como movimentação, pulo e colisão.

### Criação do Personagem

Começamos definindo o personagem principal. Para isso, criamos uma nova classe chamada `AMyCharacter`, que herda de `ACharacter`. Esta classe já vem com componentes essenciais como `UCapsuleComponent` para colisão e `UCharacterMovementComponent` para movimentação.

```cpp
#include "GameFramework/Character.h"
#include "MyCharacter.generated.h"

UCLASS()
class MYPLATFORMER_API AMyCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    AMyCharacter();

protected:
    virtual void BeginPlay() override;

public:
    virtual void Tick(float DeltaTime) override;
    virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

    void MoveRight(float Value);
    void Jump();
};
```

No construtor da classe, configuramos o `RootComponent` para garantir que o personagem tenha uma base sólida para física e colisão.

```cpp
AMyCharacter::AMyCharacter()
{
    PrimaryActorTick.bCanEverTick = true;

    // Configuração do RootComponent
    RootComponent = GetCapsuleComponent();
    GetCapsuleComponent()->InitCapsuleSize(42.f, 96.0f);
    GetCapsuleComponent()->SetCollisionProfileName(TEXT("Pawn"));
}
```

### Movimentação e Controles

Agora, vamos implementar a movimentação do personagem. Para isso, precisamos vincular as entradas do jogador às funções de movimentação.

```cpp
void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAxis("MoveRight", this, &AMyCharacter::MoveRight);
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &AMyCharacter::Jump);
}

void AMyCharacter::MoveRight(float Value)
{
    if (Value != 0.0f)
    {
        AddMovementInput(FVector(1.0f, 0.0f, 0.0f), Value);
    }
}

void AMyCharacter::Jump()
{
    ACharacter::Jump();
}
```

### Criação de Plataformas

Para criar plataformas, utilizamos `UStaticMeshComponent`. Vamos definir uma nova classe chamada `APlatform` que será responsável por representar as plataformas no jogo.

```cpp
#include "GameFramework/Actor.h"
#include "Platform.generated.h"

UCLASS()
class MYPLATFORMER_API APlatform : public AActor
{
    GENERATED_BODY()

public:
    APlatform();

protected:
    virtual void BeginPlay() override;

public:
    virtual void Tick(float DeltaTime) override;

    UPROPERTY(VisibleAnywhere)
    UStaticMeshComponent* PlatformMesh;
};
```

No construtor, configuramos o `RootComponent` e adicionamos o componente de malha estática.

```cpp
APlatform::APlatform()
{
    PrimaryActorTick.bCanEverTick = true;

    PlatformMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("PlatformMesh"));
    RootComponent = PlatformMesh;
}
```

### Colisões e Interações

Para detectar quando o personagem pisa em uma plataforma, utilizamos o evento `OnComponentBeginOverlap`. Vamos modificar a classe `APlatform` para incluir essa funcionalidade.

```cpp
void APlatform::BeginPlay()
{
    Super::BeginPlay();

    PlatformMesh->OnComponentBeginOverlap.AddDynamic(this, &APlatform::OnOverlapBegin);
}

void APlatform::OnOverlapBegin(UPrimitiveComponent* OverlappedComp, AActor* OtherActor, UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult& SweepResult)
{
    if (OtherActor && OtherActor != this && OtherComp)
    {
        UE_LOG(LogTemp, Warning, TEXT("Personagem pisou na plataforma"));
    }
}
```

### Testando o Jogo

Agora que temos o personagem e as plataformas configuradas, podemos testar o jogo. Certifique-se de que o personagem pode se mover para a direita e esquerda, pular e interagir com as plataformas.

### Exercício Prático

Como exercício, crie uma plataforma móvel que se move horizontalmente entre dois pontos. Utilize `FMath::VInterpConstantTo` para suavizar o movimento. Implemente também uma plataforma que desaparece após alguns segundos usando `FTimerHandle`.

```cpp
void APlatform::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    FVector NewLocation = GetActorLocation();
    float DeltaHeight = FMath::Sin(GetWorld()->GetTimeSeconds());
    NewLocation.Y += DeltaHeight * 50.0f;
    SetActorLocation(NewLocation);
}
```

### Solução Comentada

Para criar a plataforma móvel, utilizamos a função `FMath::Sin` para gerar um movimento oscilatório. Para a plataforma que desaparece, configuramos um `FTimerHandle` para destruir a plataforma após um determinado tempo.

```cpp
FTimerHandle TimerHandle;
GetWorldTimerManager().SetTimer(TimerHandle, this, &APlatform::DestroyPlatform, 5.0f, false);

void APlatform::DestroyPlatform()
{
    Destroy();
}
```

Com isso, concluímos a criação de um jogo de plataforma básico. No próximo capítulo, exploraremos técnicas avançadas de desenvolvimento de jogos de ação.