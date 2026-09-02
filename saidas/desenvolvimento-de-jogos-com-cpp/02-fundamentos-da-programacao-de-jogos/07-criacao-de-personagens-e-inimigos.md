## Criação de personagens e inimigos

Um jogo de plataforma ou ação depende de personagens que o jogador pode controlar e inimigos que desafiam a habilidade do jogador. Vamos criar um personagem controlável e um inimigo básico usando C++ na Unreal Engine.

### Criando o Personagem Controlável

Primeiro, criamos uma classe para o personagem principal. No Unreal Engine, vá para `File > New C++ Class` e selecione `Character` como classe base. Nomeie a classe como `Jogador`.

```cpp
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "Jogador.generated.h"

UCLASS()
class MEUJOGO_API AJogador : public ACharacter
{
    GENERATED_BODY()

public:
    AJogador();

protected:
    virtual void BeginPlay() override;

public:
    virtual void Tick(float DeltaTime) override;
    virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

private:
    void MoverFrente(float Valor);
    void MoverLado(float Valor);
};
```

No arquivo `.cpp`, implementamos as funções:

```cpp
#include "Jogador.h"
#include "GameFramework/SpringArmComponent.h"
#include "Camera/CameraComponent.h"

AJogador::AJogador()
{
    PrimaryActorTick.bCanEverTick = true;

    SpringArm = CreateDefaultSubobject<USpringArmComponent>(TEXT("SpringArm"));
    SpringArm->SetupAttachment(RootComponent);
    SpringArm->TargetArmLength = 300.0f;

    Camera = CreateDefaultSubobject<UCameraComponent>(TEXT("Camera"));
    Camera->SetupAttachment(SpringArm);
}

void AJogador::BeginPlay()
{
    Super::BeginPlay();
}

void AJogador::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}

void AJogador::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAxis("MoverFrente", this, &AJogador::MoverFrente);
    PlayerInputComponent->BindAxis("MoverLado", this, &AJogador::MoverLado);
}

void AJogador::MoverFrente(float Valor)
{
    if (Valor != 0.0f)
    {
        AddMovementInput(GetActorForwardVector(), Valor);
    }
}

void AJogador::MoverLado(float Valor)
{
    if (Valor != 0.0f)
    {
        AddMovementInput(GetActorRightVector(), Valor);
    }
}
```

Este código cria um personagem que pode se mover para frente e para os lados usando as teclas configuradas no `Input Mapping` do Unreal Engine.

### Criando o Inimigo

Agora, criamos um inimigo básico que segue o jogador. Novamente, crie uma nova classe `Character` chamada `Inimigo`.

```cpp
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "Inimigo.generated.h"

UCLASS()
class MEUJOGO_API AInimigo : public ACharacter
{
    GENERATED_BODY()

public:
    AInimigo();

protected:
    virtual void BeginPlay() override;

public:
    virtual void Tick(float DeltaTime) override;

private:
    void SeguirJogador();
};
```

No arquivo `.cpp`, implementamos as funções:

```cpp
#include "Inimigo.h"
#include "Jogador.h"
#include "Kismet/GameplayStatics.h"

AInimigo::AInimigo()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AInimigo::BeginPlay()
{
    Super::BeginPlay();
}

void AInimigo::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    SeguirJogador();
}

void AInimigo::SeguirJogador()
{
    AJogador* Jogador = Cast<AJogador>(UGameplayStatics::GetPlayerCharacter(GetWorld(), 0));
    if (Jogador)
    {
        FVector Direcao = Jogador->GetActorLocation() - GetActorLocation();
        Direcao.Normalize();
        AddMovementInput(Direcao, 1.0f);
    }
}
```

Este código faz com que o inimigo siga o jogador continuamente. O inimigo calcula a direção para o jogador e se move nessa direção.

### Testando o Jogo

Compile o código e adicione uma instância de `Jogador` e `Inimigo` ao nível. Configure o `Input Mapping` para usar as teclas `W`, `A`, `S`, `D` para movimento. Execute o jogo e observe o personagem se mover e o inimigo seguir o jogador.

### Exercício

Modifique o código do inimigo para que ele pare de seguir o jogador quando estiver a uma certa distância. Implemente uma função que verifique a distância entre o inimigo e o jogador e pare o movimento se a distância for menor que 200 unidades.

```cpp
void AInimigo::SeguirJogador()
{
    AJogador* Jogador = Cast<AJogador>(UGameplayStatics::GetPlayerCharacter(GetWorld(), 0));
    if (Jogador)
    {
        FVector Direcao = Jogador->GetActorLocation() - GetActorLocation();
        float Distancia = Direcao.Size();
        if (Distancia > 200.0f)
        {
            Direcao.Normalize();
            AddMovementInput(Direcao, 1.0f);
        }
    }
}
```

Este código verifica a distância entre o inimigo e o jogador e só permite que o inimigo se mova se a distância for maior que 200 unidades.