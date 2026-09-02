## Interface gráfica do usuário (GUI)

O jogador precisa ver informações como vida, pontuação e mensagens do jogo. Sem isso, ele está jogando no escuro. Na Unreal Engine, criamos esses elementos usando a classe `UUserWidget`.

Vamos começar com um exemplo prático: mostrar a vida do jogador na tela. Primeiro, crie um novo Widget Blueprint chamado `WBP_HUD`:

1. Clique com o botão direito no Content Browser
2. Escolha "User Interface" > "Widget Blueprint"
3. Nomeie como `WBP_HUD`

Dentro do Widget Editor:

1. Arraste um `Text Block` para a tela
2. No Details Panel, nomeie como `Text_Vida`
3. Defina o texto inicial como "Vida: 100"
4. Ajuste fonte, cor e tamanho conforme necessário

Agora vamos conectar isso ao código C++. No arquivo `Jogador.h`:

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
    // Vida atual do jogador
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Jogador")
    int32 Vida = 100;

    // Referência ao HUD
    UPROPERTY()
    class UUserWidget* HUD;

    // Widget class que vamos usar
    UPROPERTY(EditAnywhere, Category = "UI")
    TSubclassOf<class UUserWidget> HUDClass;

    virtual void BeginPlay() override;
};
```

E em `Jogador.cpp`:

```cpp
#include "Jogador.h"
#include "Blueprint/UserWidget.h"

void AJogador::BeginPlay()
{
    Super::BeginPlay();

    if (HUDClass)
    {
        HUD = CreateWidget<UUserWidget>(GetWorld(), HUDClass);
        if (HUD)
        {
            HUD->AddToViewport();
        }
    }
}
```

Um erro comum é esquecer de atribuir o `HUDClass` no Editor. Se você receber a mensagem:
```
Warning: Attempting to CreateWidget with null Class
```
Significa que você precisa:

1. Selecione o ator do jogador no Editor
2. No Details Panel, em "UI", defina `HUD Class` como `WBP_HUD`

Para atualizar dinamicamente o texto da vida, modifique o `WBP_HUD`:

1. Clique em "Graph" no Widget Editor
2. Crie uma nova função chamada `AtualizarVida`
3. Adicione um parâmetro do tipo `Integer` chamado `NovaVida`
4. Conecte ao `Text_Vida` e use o nó "Set Text" com um texto formatado

Em C++, para chamar essa função quando a vida mudar:

```cpp
void AJogador::PerderVida(int32 Dano)
{
    Vida -= Dano;
    
    if (HUD)
    {
        UFunction* Func = HUD->FindFunction("AtualizarVida");
        if (Func)
        {
            struct FParams { int32 NovaVida; };
            FParams Params = { Vida };
            HUD->ProcessEvent(Func, &Params);
        }
    }
}
```

Mas há uma maneira mais eficiente usando variáveis vinculadas. Em `WBP_HUD`:

1. No Designer, selecione `Text_Vida`
2. No Details Panel, em "Bind", clique no dropdown e crie uma nova vinculação
3. Nomeie como `GetVidaTexto`
4. No gráfico de vinculação, retorne um texto formatado como `FString::Printf(TEXT("Vida: %d"), Vida)`

E em `WBP_HUD.h`:

```cpp
UPROPERTY(meta = (BindWidget))
class UTextBlock* Text_Vida;

UFUNCTION(BlueprintCallable)
FText GetVidaTexto() const;
```

Isso atualizará automaticamente sempre que `Vida` mudar.

**Exercício**: Crie um widget de pontuação que:
1. Mostre "Pontos: X" no canto superior direito
2. Atualize automaticamente quando o jogador coletar moedas
3. Pisca em amarelo quando o jogador atinge um múltiplo de 100 pontos

**Solução**:

1. Crie `WBP_Pontuacao` com um `TextBlock` chamado `Text_Pontos`
2. Adicione vinculação para `GetPontosTexto` que formata a saída
3. No jogador, adicione:

```cpp
UPROPERTY(EditAnywhere)
int32 Pontos = 0;

void ColetarMoeda()
{
    Pontos += 10;
    if (Pontos % 100 == 0)
    {
        if (auto PontuacaoWidget = Cast<UPontuacaoWidget>(HUD))
        {
            PontuacaoWidget->Piscar();
        }
    }
}
```

4. Em `WBP_Pontuacao` implemente a função `Piscar()` que temporariamente muda a cor