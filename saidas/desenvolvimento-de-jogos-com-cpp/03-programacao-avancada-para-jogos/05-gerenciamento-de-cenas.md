## Gerenciamento de cenas

Em um jogo, as cenas são como diferentes telas ou ambientes que o jogador pode experienciar. Por exemplo, você pode ter uma cena para o menu principal, outra para o nível 1 e mais uma para a tela de game over. Gerenciar essas cenas de forma eficiente é crucial para manter o fluxo do jogo organizado e garantir que o jogador tenha uma experiência contínua e sem interrupções.

Na Unreal Engine, as cenas são chamadas de "Levels" (níveis). Cada nível pode ser pensado como uma cena independente, com seu próprio conjunto de objetos, configurações e comportamentos. Para alternar entre essas cenas, a Unreal Engine fornece uma API simples e poderosa que permite carregar e descarregar níveis dinamicamente.

### Criando e Alternando Entre Cenas

Primeiro, vamos criar dois níveis simples: um para o menu principal e outro para o primeiro nível do jogo. Na Unreal Editor, você pode criar novos níveis indo em `File > New Level`. Vamos chamar esses níveis de `MainMenu` e `Level1`.

Para alternar entre esses níveis usando C++, você pode usar a função `UGameplayStatics::OpenLevel`. Essa função recebe o nome do nível que você deseja carregar e pode ser chamada a partir de qualquer lugar no código do jogo.

Aqui está um exemplo de como carregar o `Level1` a partir do `MainMenu`:

```cpp
#include "Kismet/GameplayStatics.h"

void AMainMenuGameMode::StartGame()
{
    UGameplayStatics::OpenLevel(this, FName("Level1"));
}
```

Neste exemplo, `AMainMenuGameMode` é a classe de GameMode para o menu principal. Quando o jogador pressiona um botão para iniciar o jogo, a função `StartGame` é chamada, e o nível `Level1` é carregado.

### Gerenciando Dados Entre Cenas

Um desafio comum ao alternar entre cenas é manter dados persistentes, como a pontuação do jogador ou configurações de jogo. Para isso, você pode usar o `GameInstance`, que é uma classe que persiste durante toda a execução do jogo, independentemente de qual nível está carregado.

Primeiro, crie uma classe personalizada que herda de `UGameInstance`. Vamos chamá-la de `MyGameInstance`:

```cpp
#include "CoreMinimal.h"
#include "Engine/GameInstance.h"
#include "MyGameInstance.generated.h"

UCLASS()
class MYGAME_API UMyGameInstance : public UGameInstance
{
    GENERATED_BODY()

public:
    int32 PlayerScore;

    void AddScore(int32 ScoreToAdd)
    {
        PlayerScore += ScoreToAdd;
    }
};
```

Agora, configure o `GameInstance` na Unreal Editor para usar `MyGameInstance`. Para isso, vá em `Edit > Project Settings > Maps & Modes` e selecione `MyGameInstance` na opção `Game Instance Class`.

Agora você pode acessar e modificar a pontuação do jogador em qualquer nível:

```cpp
void ALevel1GameMode::AddPlayerScore(int32 Score)
{
    UMyGameInstance* GameInstance = Cast<UMyGameInstance>(GetGameInstance());
    if (GameInstance)
    {
        GameInstance->AddScore(Score);
    }
}
```

### Lidando com Erros Comuns

Um erro comum ao alternar entre cenas é tentar carregar um nível que não existe ou foi nomeado incorretamente. Se você tentar carregar um nível que não existe, a Unreal Engine lançará um erro como este:

```
LogWorld: Warning: Failed to load map 'Level2'. Assertion failed: MapPackage.IsValid() [File:D:\Build\++UE4\Sync\Engine\Source\Runtime\Engine\Private\World.cpp]
```

Para evitar esse problema, sempre verifique se o nome do nível está correto e se o nível foi salvo corretamente no projeto.

### Exercício Prático

Crie um jogo simples com três níveis: `MainMenu`, `Level1` e `Level2`. No `MainMenu`, adicione dois botões: um para iniciar o jogo e carregar `Level1`, e outro para carregar `Level2`. Em `Level1` e `Level2`, adicione um objeto que, quando coletado pelo jogador, aumenta a pontuação. Use o `GameInstance` para manter a pontuação entre os níveis.

Solução:

1. Crie os níveis `MainMenu`, `Level1` e `Level2`.
2. No `MainMenu`, adicione dois botões que chamam `UGameplayStatics::OpenLevel` para carregar `Level1` e `Level2`.
3. Em `Level1` e `Level2`, crie um objeto coletável que chama `AddPlayerScore` quando coletado.
4. Implemente `MyGameInstance` para manter a pontuação do jogador.

Este exercício ensina como gerenciar cenas e manter dados persistentes entre elas, habilidades essenciais para o desenvolvimento de jogos.