## Integração de sistemas

A integração de sistemas é o processo de fazer com que diferentes componentes de um jogo funcionem juntos de maneira harmoniosa. Em um jogo 2D de plataforma ou ação, esses componentes podem incluir física, inteligência artificial (IA) e interface do usuário (UI). Cada um desses sistemas opera de forma independente, mas precisa interagir corretamente para criar uma experiência de jogo coesa.

### Integrando Física

A física em um jogo de plataforma é responsável por simular o movimento e as interações dos objetos. No Unreal Engine, isso é gerenciado pelo sistema de física integrado, que pode ser controlado via C++. Vamos criar uma classe simples para um personagem que pode pular e se mover horizontalmente.

```cpp
#include "GameFramework/Character.h"
#include "Components/InputComponent.h"

class APlatformerCharacter : public ACharacter
{
public:
    // Construtor
    APlatformerCharacter();

    // Função chamada a cada frame
    virtual void Tick(float DeltaTime) override;

    // Função chamada para configurar entradas do jogador
    virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

protected:
    // Função para movimento horizontal
    void MoveHorizontal(float Value);

    // Função para pular
    void Jump();
};
```

Implementação das funções:

```cpp
#include "PlatformerCharacter.h"

APlatformerCharacter::APlatformerCharacter()
{
    PrimaryActorTick.bCanEverTick = true;
}

void APlatformerCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}

void APlatformerCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAxis("MoveHorizontal", this, &APlatformerCharacter::MoveHorizontal);
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &APlatformerCharacter::Jump);
}

void APlatformerCharacter::MoveHorizontal(float Value)
{
    if (Value != 0.0f)
    {
        AddMovementInput(FVector(1.0f, 0.0f, 0.0f), Value);
    }
}

void APlatformerCharacter::Jump()
{
    if (CanJump())
    {
        ACharacter::Jump();
    }
}
```

Este código permite que o personagem se mova horizontalmente e pule, utilizando as funções de física integradas do Unreal Engine. A função `AddMovementInput` aplica força ao personagem, enquanto `Jump` ativa o comportamento de salto.

### Integrando Inteligência Artificial

A inteligência artificial controla o comportamento dos inimigos e outros NPCs. Vamos criar um inimigo simples que segue o jogador quando ele está dentro de um determinado raio.

```cpp
#include "AIController.h"
#include "BehaviorTree/BehaviorTree.h"
#include "BehaviorTree/BlackboardComponent.h"

class APlatformerEnemy : public AAIController
{
public:
    // Construtor
    APlatformerEnemy();

    // Função chamada a cada frame
    virtual void Tick(float DeltaTime) override;

protected:
    // Referência ao jogador
    ACharacter* PlayerCharacter;

    // Raio de detecção
    float DetectionRadius;
};
```

Implementação das funções:

```cpp
#include "PlatformerEnemy.h"
#include "PlatformerCharacter.h"
#include "Kismet/GameplayStatics.h"

APlatformerEnemy::APlatformerEnemy()
{
    DetectionRadius = 1000.0f;
}

void APlatformerEnemy::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    if (!PlayerCharacter)
    {
        PlayerCharacter = Cast<APlatformerCharacter>(UGameplayStatics::GetPlayerCharacter(this, 0));
    }

    if (PlayerCharacter)
    {
        float Distance = FVector::Dist(PlayerCharacter->GetActorLocation(), GetPawn()->GetActorLocation());

        if (Distance <= DetectionRadius)
        {
            MoveToActor(PlayerCharacter);
        }
    }
}
```

Este código faz com que o inimigo siga o jogador quando ele está dentro do raio de detecção. A função `MoveToActor` é usada para mover o inimigo em direção ao jogador.

### Integrando Interface do Usuário

A interface do usuário (UI) é crucial para fornecer feedback ao jogador, como mostrar a pontuação ou a vida restante. Vamos criar um widget simples para exibir a vida do jogador.

```cpp
#include "UserWidget.h"
#include "TextBlock.h"

class UHealthWidget : public UUserWidget
{
public:
    // Construtor
    UHealthWidget(const FObjectInitializer& ObjectInitializer);

    // Função para atualizar o texto da vida
    void UpdateHealthText(int32 Health);

protected:
    // Referência ao TextBlock
    UPROPERTY(meta = (BindWidget))
    UTextBlock* HealthText;
};
```

Implementação das funções:

```cpp
#include "HealthWidget.h"

UHealthWidget::UHealthWidget(const FObjectInitializer& ObjectInitializer)
    : Super(ObjectInitializer)
{
}

void UHealthWidget::UpdateHealthText(int32 Health)
{
    if (HealthText)
    {
        HealthText->SetText(FText::AsNumber(Health));
    }
}
```

Este código cria um widget que exibe a vida do jogador. A função `UpdateHealthText` atualiza o texto exibido no widget.

### Integrando Todos os Sistemas

Agora que temos os sistemas de física, IA e UI funcionando individualmente, precisamos integrá-los. Vamos modificar a classe do personagem para incluir uma referência ao widget de vida e atualizá-lo conforme necessário.

```cpp
#include "PlatformerCharacter.h"
#include "HealthWidget.h"

class APlatformerCharacter : public ACharacter
{
public:
    // Construtor
    APlatformerCharacter();

    // Função chamada a cada frame
    virtual void Tick(float DeltaTime) override;

    // Função para receber dano
    void TakeDamage(int32 DamageAmount);

protected:
    // Vida do personagem
    int32 Health;

    // Referência ao widget de vida
    UPROPERTY(EditAnywhere, Category = "UI")
    TSubclassOf<UHealthWidget> HealthWidgetClass;

    // Instância do widget de vida
    UHealthWidget* HealthWidgetInstance;
};
```

Implementação das funções:

```cpp
#include "PlatformerCharacter.h"
#include "Blueprint/UserWidget.h"

APlatformerCharacter::APlatformerCharacter()
{
    Health = 100;

    if (HealthWidgetClass)
    {
        HealthWidgetInstance = CreateWidget<UHealthWidget>(GetWorld(), HealthWidgetClass);
        if (HealthWidgetInstance)
        {
            HealthWidgetInstance->AddToViewport();
            HealthWidgetInstance->UpdateHealthText(Health);
        }
    }
}

void APlatformerCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}

void APlatformerCharacter::TakeDamage(int32 DamageAmount)
{
    Health -= DamageAmount;
    if (HealthWidgetInstance)
    {
        HealthWidgetInstance->UpdateHealthText(Health);
    }
}
```

Este código integra o widget de vida ao personagem, atualizando-o sempre que o personagem recebe dano.

### Erro Comum e Correção

Um erro comum ao integrar sistemas é esquecer de inicializar variáveis ou widgets. Se você tentar atualizar o widget de vida sem antes criá-lo, o jogo pode travar ou não exibir nada. Certifique-se de que o widget seja criado e adicionado à viewport antes de tentar atualizá-lo.

```cpp
if (HealthWidgetClass)
{
    HealthWidgetInstance = CreateWidget<UHealthWidget>(GetWorld(), HealthWidgetClass);
    if (HealthWidgetInstance)
    {
        HealthWidgetInstance->AddToViewport();
        HealthWidgetInstance->UpdateHealthText(Health);
    }
}
```

### Exercício

Modifique o código do inimigo para que ele pare de seguir o jogador se a vida do jogador chegar a zero. Adicione uma função `IsPlayerAlive` que verifica se a vida do jogador é maior que zero e use-a na função `Tick` do inimigo.

**Solução:**

```cpp
bool APlatformerEnemy::IsPlayerAlive() const
{
    if (PlayerCharacter)
    {
        APlatformerCharacter* PlatformerPlayer = Cast<APlatformerCharacter>(PlayerCharacter);
        if (PlatformerPlayer)
        {
            return PlatformerPlayer->GetHealth() > 0;
        }
    }
    return false;
}

void APlatformerEnemy::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    if (!PlayerCharacter)
    {
        PlayerCharacter = Cast<APlatformerCharacter>(UGameplayStatics::GetPlayerCharacter(this, 0));
    }

    if (PlayerCharacter && IsPlayerAlive())
    {
        float Distance = FVector::Dist(PlayerCharacter->GetActorLocation(), GetPawn()->GetActorLocation());

        if (Distance <= DetectionRadius)
        {
            MoveToActor(PlayerCharacter);
        }
    }
}
```

Este código faz com que o inimigo pare de seguir o jogador se a vida do jogador chegar a zero, integrando ainda mais os sistemas de física, IA e UI.