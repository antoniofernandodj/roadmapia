## Introdução ao C++ na Unreal Engine

A Unreal Engine é conhecida por sua poderosa ferramenta de programação visual, os Blueprints, mas para projetos mais complexos ou quando você precisa de desempenho máximo, a integração com C++ é essencial. Neste trecho, vamos explorar como integrar código C++ na Unreal Engine, desde a configuração inicial até a execução de funções básicas.

### Configurando o Ambiente para C++

Antes de começar a escrever código C++, é importante garantir que seu ambiente de desenvolvimento esteja configurado corretamente. A Unreal Engine utiliza o Visual Studio como IDE padrão para desenvolvimento em C++. Para configurar:

1. Abra o Visual Studio Installer.
2. Certifique-se de que o pacote "Game development with C++" está instalado.
3. Na Unreal Engine, crie um novo projeto selecionando "C++" como tipo de projeto.

### Criando uma Nova Classe C++

Vamos começar criando uma nova classe C++ que representará um objeto simples no jogo, como um cubo que muda de cor quando tocado pelo jogador.

1. No Content Browser, clique com o botão direito e selecione "New C++ Class".
2. Escolha "Actor" como classe base.
3. Nomeie sua classe como `MyActor` e clique em "Create Class".

Isso criará dois arquivos: `MyActor.h` (o cabeçalho) e `MyActor.cpp` (a implementação). Abra ambos no Visual Studio.

### Escrevendo o Código Básico

No arquivo `MyActor.h`, adicione o seguinte código para declarar uma função que será chamada quando o jogador interagir com o objeto:

```cpp
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "MyActor.generated.h"

UCLASS()
class MYPROJECT_API AMyActor : public AActor
{
    GENERATED_BODY()
    
public:    
    AMyActor();

protected:
    virtual void BeginPlay() override;

public:    
    virtual void Tick(float DeltaTime) override;

    UFUNCTION(BlueprintCallable, Category = "Interaction")
    void ChangeColor();
};
```

No arquivo `MyActor.cpp`, implemente a função `ChangeColor`:

```cpp
#include "MyActor.h"
#include "Components/StaticMeshComponent.h"

AMyActor::AMyActor()
{
    PrimaryActorTick.bCanEverTick = true;

    Mesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Mesh"));
    RootComponent = Mesh;
}

void AMyActor::BeginPlay()
{
    Super::BeginPlay();
}

void AMyActor::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}

void AMyActor::ChangeColor()
{
    if (Mesh)
    {
        Mesh->SetMaterial(0, LoadObject<UMaterial>(nullptr, TEXT("/Game/Materials/RedMaterial.RedMaterial")));
    }
}
```

### Integrando com Blueprints

Agora que você tem uma classe C++ básica, vamos integrá-la com Blueprints para que você possa ver o objeto em ação.

1. No Content Browser, clique com o botão direito em `MyActor` e selecione "Create Blueprint class based on MyActor".
2. Nomeie o Blueprint como `BP_MyActor`.
3. Abra o Blueprint e arraste um `Static Mesh` para a cena.
4. No Event Graph, adicione um evento `BeginPlay` e conecte-o ao nó `ChangeColor`.

### Executando o Projeto

Compile o código e volte para a Unreal Engine. Arraste o Blueprint `BP_MyActor` para a cena e pressione "Play". Quando o jogo começar, o cubo deve mudar de cor para vermelho.

### Exercício Prático

Crie uma nova classe C++ chamada `MyCharacter` que herda de `ACharacter`. Implemente uma função `Jump` que faz o personagem pular quando uma tecla é pressionada. Integre essa função com Blueprints e teste no jogo.

### Solução

No arquivo `MyCharacter.h`:

```cpp
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "MyCharacter.generated.h"

UCLASS()
class MYPROJECT_API AMyCharacter : public ACharacter
{
    GENERATED_BODY()
    
public:    
    AMyCharacter();

protected:
    virtual void BeginPlay() override;

public:    
    virtual void Tick(float DeltaTime) override;

    UFUNCTION(BlueprintCallable, Category = "Movement")
    void Jump();
};
```

No arquivo `MyCharacter.cpp`:

```cpp
#include "MyCharacter.h"

AMyCharacter::AMyCharacter()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AMyCharacter::BeginPlay()
{
    Super::BeginPlay();
}

void AMyCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}

void AMyCharacter::Jump()
{
    ACharacter::Jump();
}
```

No Blueprint `BP_MyCharacter`, adicione um evento de entrada para a tecla de espaço e conecte-o ao nó `Jump`. Teste no jogo para ver o personagem pular.