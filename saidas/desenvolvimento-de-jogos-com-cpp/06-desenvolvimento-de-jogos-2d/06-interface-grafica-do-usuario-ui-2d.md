## Interface gráfica do usuário (UI) 2D

Em um jogo de plataforma, você precisa mostrar informações vitais ao jogador - vidas restantes, pontuação, itens coletados. Sem isso, o jogador fica "cego". Vamos criar um sistema simples de HUD (Heads-Up Display) que exibe essas informações na tela.

Primeiro, crie uma nova classe C++ chamada `HUDWidget` que herda de `UUserWidget`:

```cpp
// HUDWidget.h
#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "HUDWidget.generated.h"

UCLASS()
class MEUJOGO_API UHUDWidget : public UUserWidget
{
    GENERATED_BODY()
    
public:
    UFUNCTION(BlueprintCallable)
    void UpdateScore(int32 NewScore);
    
    UFUNCTION(BlueprintCallable)
    void UpdateLives(int32 NewLives);

private:
    UPROPERTY(meta = (BindWidget))
    class UTextBlock* ScoreText;

    UPROPERTY(meta = (BindWidget))
    class UTextBlock* LivesText;
};
```

A implementação:

```cpp
// HUDWidget.cpp
#include "HUDWidget.h"
#include "Components/TextBlock.h"

void UHUDWidget::UpdateScore(int32 NewScore)
{
    if (ScoreText)
    {
        ScoreText->SetText(FText::AsNumber(NewScore));
    }
}

void UHUDWidget::UpdateLives(int32 NewLives)
{
    if (LivesText)
    {
        LivesText->SetText(FText::AsNumber(NewLives));
    }
}
```

Crie agora um Widget Blueprint baseado nessa classe. Na Unreal Editor:
1. Clique direito em Content Browser → User Interface → Widget Blueprint
2. Nomeie como `WBP_HUD`
3. Abra o blueprint e adicione dois elementos Text no Canvas
4. Nomeie-os como `ScoreText` e `LivesText` (exatamente como no código)
5. Ajuste posição, tamanho e estilo conforme desejar

Para exibir o HUD no jogo, modifique sua classe de jogador:

```cpp
// MeuPersonagem.h
UPROPERTY(EditDefaultsOnly, Category = "UI")
TSubclassOf<class UHUDWidget> HUDWidgetClass;

UPROPERTY()
class UHUDWidget* HUDWidget;

// MeuPersonagem.cpp (no BeginPlay)
if (HUDWidgetClass)
{
    HUDWidget = CreateWidget<UHUDWidget>(GetWorld(), HUDWidgetClass);
    if (HUDWidget)
    {
        HUDWidget->AddToViewport();
        HUDWidget->UpdateScore(0);
        HUDWidget->UpdateLives(3);
    }
}
```

Um erro comum é esquecer de vincular os elementos no Blueprint com os nomes exatos do código. Se fizer isso, receberá o erro:

```
LogBlueprint: Error: [AssetLog] WBP_HUD: Graph Disconnected. Could not find a 
binding for BindWidget property ScoreText in widget WBP_HUD
```

Para corrigir, verifique se os nomes no Blueprint são idênticos aos declarados no código, incluindo maiúsculas/minúsculas.

Para elementos mais complexos como barras de vida, podemos usar `UProgressBar`:

```cpp
// No HUDWidget.h
UPROPERTY(meta = (BindWidget))
class UProgressBar* HealthBar;

// No HUDWidget.cpp
void UHUDWidget::UpdateHealth(float HealthPercent)
{
    if (HealthBar)
    {
        HealthBar->SetPercent(HealthPercent);
    }
}
```

No Blueprint:
1. Adicione um ProgressBar
2. Nomeie como `HealthBar`
3. Configure a cor e estilo visual

Para atualizar dinamicamente esses valores, conecte eventos do jogo aos métodos do HUD. Por exemplo, quando o jogador coleta um item:

```cpp
// Quando coletar moeda
Score++;
if (HUDWidget)
{
    HUDWidget->UpdateScore(Score);
}
```

**Exercício Prático**: Adicione um contador de tempo ao HUD que diminui a cada segundo. Quando chegar a zero, mostre "TEMPO ESGOTADO!" em vermelho.

Solução:

```cpp
// HUDWidget.h
UFUNCTION(BlueprintCallable)
void UpdateTime(int32 Seconds);

UPROPERTY(meta = (BindWidget))
class UTextBlock* TimeText;

// HUDWidget.cpp
void UHUDWidget::UpdateTime(int32 Seconds)
{
    if (TimeText)
    {
        if (Seconds <= 0)
        {
            TimeText->SetText(FText::FromString("TEMPO ESGOTADO!"));
            TimeText->SetColorAndOpacity(FSlateColor(FColor::Red));
        }
        else
        {
            TimeText->SetText(FText::AsNumber(Seconds));
        }
    }
}
```

Para chamar a cada segundo, use um `FTimerHandle` no seu GameMode.