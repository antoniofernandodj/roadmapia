## Interface gráfica do usuário (UI)

Em jogos, a interface do usuário é como um painel de controle - mostra informações vitais como pontuação, vida e inventário, sem interromper a ação principal. Na Unreal Engine, criamos esses elementos usando o sistema UMG (Unreal Motion Graphics), que permite construir interfaces com componentes visuais arrastáveis.

### Criando seu primeiro HUD

Vamos começar com um exemplo prático: um contador de moedas para um jogo de plataforma. Primeiro, crie um novo Widget Blueprint:

1. No Content Browser, clique em "Add New" → "User Interface" → "Widget Blueprint"
2. Nomeie como "WBP_CoinCounter"
3. Dê duplo clique para abrir o editor UMG

Dentro do editor, você verá uma tela em branco (Canvas Panel) onde podemos adicionar elementos. Arraste um "Text Block" da paleta de widgets para a tela:

```cpp
// Na classe do seu personagem (ex: MyCharacter.cpp)
void AMyCharacter::AddCoin()
{
    CoinsCollected++;
    if (CoinCounterWidget) // Verifica se o widget existe
    {
        CoinCounterWidget->UpdateCoinDisplay(CoinsCollected);
    }
}
```

Configure o Text Block no Details Panel:
- Content → Text: "Moedas: 0"
- Appearance → Font Size: 32
- Color → Color: Amarelo (FFFF00FF)

Agora precisamos conectar esse widget ao jogo. Crie uma variável no Blueprint do seu personagem:

1. Abra o Blueprint do personagem
2. Na aba "Variables", clique em "+"
3. Nomeie como "CoinCounterWidget"
4. Defina o tipo como "WBP_CoinCounter" (o widget que criamos)

No Event Graph do personagem, adicione:

```cpp
// No construtor do seu personagem
AMyCharacter::AMyCharacter()
{
    // Cria o widget quando o personagem é criado
    CoinCounterWidget = CreateWidget<UCoinCounterWidget>(GetWorld(), CoinCounterWidgetClass);
    if (CoinCounterWidget)
    {
        CoinCounterWidget->AddToViewport();
    }
}
```

### Atualizando a UI dinamicamente

Para fazer o contador atualizar quando o jogador coleta moedas, vamos:

1. No Widget Blueprint "WBP_CoinCounter", clique em "Graph"
2. Crie uma nova função chamada "UpdateCoinDisplay"
3. Adicione um parâmetro do tipo "Integer" chamado "NewCount"
4. Conecte o grafo:

```
[Entrada UpdateCoinDisplay] → [Set Text (do TextBlock)] → [Format Text: "Moedas: {0}" usando NewCount]
```

Quando testar o jogo, você verá o erro comum:
```
LogBlueprint: Error: Attempted to access None using a safe context.
```

Isso acontece quando tentamos atualizar um widget que ainda não foi criado. A solução é verificar se o widget existe antes de usá-lo:

```cpp
void AMyCharacter::AddCoin()
{
    CoinsCollected++;
    if (CoinCounterWidget) // Verifica se o widget existe
    {
        CoinCounterWidget->UpdateCoinDisplay(CoinsCollected);
    }
}
```

### Elementos UI essenciais

Além do Text Block, a UMG oferece vários componentes:

1. **Progress Bar**: Ideal para barras de vida
   - Exemplo: `HealthBar->SetPercent(CurrentHealth/MaxHealth)`

2. **Image**: Para exibir ícones ou fundos
   - Pode ser animado trocando a textura

3. **Button**: Para menus interativos
   - Conecte ao evento "OnClicked" no Event Graph

4. **Vertical/Horizontal Box**: Organiza widgets automaticamente

### Exercício: Criando um menu de pausa

Crie um widget que:
1. Aparece quando pressionamos a tecla P
2. Contém:
   - Texto "JOGO PAUSADO" (tamanho 48, cor branca)
   - Botão "CONTINUAR" (verde) que despausa o jogo
   - Botão "SAIR" (vermelho) que fecha o jogo

Solução comentada:

1. Crie um novo Widget Blueprint chamado "WBP_PauseMenu"
2. Adicione os elementos visuais
3. No Blueprint do Game Mode:
   ```cpp
   void AMyGameMode::PauseGame()
   {
       if (PauseMenuWidget)
       {
           PauseMenuWidget->RemoveFromParent();
           PauseMenuWidget = nullptr;
           UGameplayStatics::SetGamePaused(GetWorld(), false);
       }
       else
       {
           PauseMenuWidget = CreateWidget<UPauseMenuWidget>(GetWorld(), PauseMenuWidgetClass);
           if (PauseMenuWidget)
           {
               PauseMenuWidget->AddToViewport();
               UGameplayStatics::SetGamePaused(GetWorld(), true);
           }
       }
   }
   ```
4. Configure um Input Action para a tecla P no Project Settings
5. Conecte o botão "CONTINUAR" para chamar PauseGame()
6. Conecte o botão "SAIR" para chamar `UKismetSystemLibrary::QuitGame()`