## Gerenciamento de cenas 2D

Imagine que seu jogo precisa alternar entre diferentes telas: um menu principal, a fase do jogo e uma tela de game over. Cada uma dessas telas é uma "cena" (ou "level" na Unreal Engine) que contém seus próprios elementos. Veja como implementar esse sistema na prática.

Comece criando três níveis básicos no Editor da Unreal:
1. `MainMenuLevel` - Contém botões e fundo do menu
2. `GameLevel` - O nível jogável principal
3. `GameOverLevel` - Tela de fim de jogo

Na classe `UGameInstance` (que persiste entre níveis), adicione:

```cpp
// No arquivo MyGameInstance.h
public:
    UFUNCTION(BlueprintCallable, Category = "Scenes")
    void LoadMainMenu();

    UFUNCTION(BlueprintCallable, Category = "Scenes")
    void StartGame();

    UFUNCTION(BlueprintCallable, Category = "Scenes")
    void ShowGameOver();
```

Implemente os métodos no arquivo `.cpp`:

```cpp
void UMyGameInstance::LoadMainMenu()
{
    UGameplayStatics::OpenLevel(GetWorld(), "MainMenuLevel");
}

void UMyGameInstance::StartGame()
{
    UGameplayStatics::OpenLevel(GetWorld(), "GameLevel");
}

void UMyGameInstance::ShowGameOver()
{
    UGameplayStatics::OpenLevel(GetWorld(), "GameOverLevel");
}
```

Erro comum: esquecer de adicionar os níveis à lista de níveis do projeto (File > Project Settings > Maps & Modes). Se fizer isso, receberá o erro:

```
LogLoad: Error: Couldn't find file for level /Game/Levels/MainMenuLevel
```

Para conectar os botões do menu, crie um Blueprint que referencia seu GameInstance e defina os eventos de clique:

```cpp
// No Blueprint do menu principal:
OnPlayButtonClicked -> Cast to MyGameInstance -> StartGame
OnQuitButtonClicked -> Quit Game
```

Quando precisar passar dados entre cenas (como pontuação), use variáveis no GameInstance:

```cpp
// No arquivo MyGameInstance.h
public:
    UPROPERTY(BlueprintReadWrite, Category = "Game Data")
    int32 PlayerScore;

// No GameLevel quando o jogador coleta pontos:
UGameInstance* GI = GetGameInstance<UMyGameInstance>();
if(GI) GI->PlayerScore += 100;

// No GameOverLevel para exibir:
UTextBlock* ScoreText = //... obtém referência
UGameInstance* GI = GetGameInstance<UMyGameInstance>();
if(GI) ScoreText->SetText(FText::AsNumber(GI->PlayerScore));
```

Exercício: Crie um sistema de seleção de fase onde:
1. O menu principal mostra 3 botões de fase
2. Cada botão carrega um nível diferente
3. O nível carregado mostra qual fase foi selecionada

Solução comentada:

```cpp
// No GameInstance:
UFUNCTION(BlueprintCallable)
void LoadLevel(int32 LevelIndex)
{
    FString LevelName = FString::Printf(TEXT("Level_%d"), LevelIndex);
    UGameplayStatics::OpenLevel(GetWorld(), FName(*LevelName));
}

// No Blueprint do menu:
OnLevel1ButtonClicked -> LoadLevel(1)
OnLevel2ButtonClicked -> LoadLevel(2)
OnLevel3ButtonClicked -> LoadLevel(3)

// Em cada Level Blueprint (Event BeginPlay):
FString LevelNum = GetWorld()->GetName().RightChop(6); // Remove "Level_"
UTextBlock* Text = //... obtém referência
Text->SetText(FText::FromString("Fase " + LevelNum));
```