## Gerenciamento de estados do jogo

Imagine um jogo simples que começa em um menu, entra na fase de gameplay quando o jogador pressiona "Iniciar", e volta ao menu quando o jogador perde. Como controlar essas transições sem criar um código confuso? É aí que entra o gerenciamento de estados.

Vamos começar com um problema real. Sem estados, seu código principal pode ficar assim:

```cpp
// CÓDIGO PROBLEMÁTICO - NÃO FAÇA ISSO
void AMeuJogo::Tick(float DeltaTime)
{
    if (bNoMenu)
    {
        // Desenha menu
        if (IsKeyPressed(EKeys::Enter))
        {
            bNoMenu = false;
            IniciarJogo();
        }
    }
    else
    {
        // Lógica do jogo
        if (Personagem->GetVida() <= 0)
        {
            bNoMenu = true;
            MostrarMenuGameOver();
        }
    }
}
```

O problema? À medida que adicionamos mais estados (pausa, configurações, cutscenes), o código vira um labirinto de `if-else`. A solução é usar um sistema de estados dedicado.

### Implementando um gerenciador básico de estados

Primeiro, definimos um enum para os estados:

```cpp
UENUM()
enum class EEstadoJogo : uint8
{
    Menu,
    Gameplay,
    GameOver,
    Pausa
};
```

Agora criamos a classe `GerenciadorEstados`:

```cpp
// Arquivo GerenciadorEstados.h
#pragma once

#include "CoreMinimal.h"
#include "UObject/NoExportTypes.h"
#include "GerenciadorEstados.generated.h"

UCLASS()
class MEUJOGO_API UGerenciadorEstados : public UObject
{
    GENERATED_BODY()
    
public:
    void MudarEstado(EEstadoJogo NovoEstado);
    EEstadoJogo GetEstadoAtual() const { return EstadoAtual; }

private:
    EEstadoJogo EstadoAtual = EEstadoJogo::Menu;
};
```

```cpp
// Arquivo GerenciadorEstados.cpp
#include "GerenciadorEstados.h"

void UGerenciadorEstados::MudarEstado(EEstadoJogo NovoEstado)
{
    // Primeiro, limpe o estado anterior
    switch (EstadoAtual)
    {
        case EEstadoJogo::Menu:
            // Limpeza do menu
            break;
        case EEstadoJogo::Gameplay:
            // Limpeza do gameplay
            break;
        // ... outros estados
    }

    EstadoAtual = NovoEstado;

    // Inicialize o novo estado
    switch (EstadoAtual)
    {
        case EEstadoJogo::Menu:
            // Mostrar elementos do menu
            break;
        case EEstadoJogo::Gameplay:
            // Iniciar lógica do jogo
            break;
        // ... outros estados
    }
}
```

### Integrando com o loop principal

No seu GameMode (a classe que controla as regras do jogo), adicione:

```cpp
// No arquivo MeuGameMode.h
UPROPERTY()
UGerenciadorEstados* GerenciadorEstados;

// No arquivo MeuGameMode.cpp
void AMeuGameMode::BeginPlay()
{
    Super::BeginPlay();
    
    GerenciadorEstados = NewObject<UGerenciadorEstados>(this);
    
    // Configurar estado inicial
    GerenciadorEstados->MudarEstado(EEstadoJogo::Menu);
}

void AMeuGameMode::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    
    switch (GerenciadorEstados->GetEstadoAtual())
    {
        case EEstadoJogo::Menu:
            // Atualização do menu
            break;
        case EEstadoJogo::Gameplay:
            // Atualização do gameplay
            break;
        // ... outros estados
    }
}
```

### Lidando com erros comuns

**Erro 1:** Esquecer de limpar o estado anterior
```
// Isso vai acumular objetos e causar vazamentos de memória
EstadoAtual = NovoEstado;  // ERRADO - falta limpar o estado antigo
```

**Solução:** Sempre faça a limpeza antes da atribuição, como mostrado no método `MudarEstado`.

**Erro 2:** Tentar acessar objetos de um estado inativo
```
// No estado Gameplay, tentando acessar um botão do menu
BotaoIniciar->SetVisibility(true);  // CRASH!
```

**Solução:** Verifique sempre o estado atual antes de agir:

```cpp
if (GerenciadorEstados->GetEstadoAtual() == EEstadoJogo::Menu)
{
    BotaoIniciar->SetVisibility(true);
}
```

### Exercício prático

Implemente um sistema de pausa usando estados:

1. Adicione um novo estado `Pausa` ao enum
2. Modifique o `GerenciadorEstados` para lidar com este estado
3. Crie uma função que alterna entre Gameplay e Pausa ao pressionar a tecla P

**Solução comentada:**

```cpp
// 1. Adicione ao enum
enum class EEstadoJogo : uint8
{
    // ... estados existentes
    Pausa
};

// 2. Modifique GerenciadorEstados.cpp
void UGerenciadorEstados::MudarEstado(EEstadoJogo NovoEstado)
{
    // ... limpeza existente
    
    // Adicione tratamento para Pausa
    case EEstadoJogo::Pausa:
        GetWorld()->GetFirstPlayerController()->SetPause(true);
        break;

    // ... inicialização existente
    
    case EEstadoJogo::Pausa:
        // Mostrar UI de pausa
        break;
}

// 3. No PlayerController ou GameMode
void AMeuPlayerController::SetupInputComponent()
{
    Super::SetupInputComponent();
    
    InputComponent->BindAction("Pausa", IE_Pressed, this, &AMeuPlayerController::TogglePausa);
}

void AMeuPlayerController::TogglePausa()
{
    if (GerenciadorEstados->GetEstadoAtual() == EEstadoJogo::Gameplay)
    {
        GerenciadorEstados->MudarEstado(EEstadoJogo::Pausa);
    }
    else if (GerenciadorEstados->GetEstadoAtual() == EEstadoJogo::Pausa)
    {
        GerenciadorEstados->MudarEstado(EEstadoJogo::Gameplay);
    }
}
```