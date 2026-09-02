## Gerenciamento de cenas

Em um jogo, as cenas são como capítulos de um livro. Cada cena pode representar um nível, um menu, ou até mesmo uma tela de créditos. O gerenciamento eficiente dessas cenas é crucial para garantir que o jogador tenha uma experiência fluída e imersiva. Na Unreal Engine, isso é feito principalmente através da classe `ULevel` e do uso de Blueprints ou C++ para controlar a transição entre elas.

### Criando uma nova cena

Vamos começar criando uma nova cena. No Content Browser, clique com o botão direito e selecione `New Level`. Você terá a opção de criar uma cena vazia ou usar um template pré-configurado. Para este exemplo, vamos escolher `Empty Level`.

```cpp
// Exemplo de código C++ para criar uma nova cena
UWorld* World = GetWorld();
if (World)
{
    World->ServerTravel("/Game/NewLevel");
}
```

Este código é usado para carregar uma nova cena chamada `NewLevel` no servidor. O `ServerTravel` é frequentemente usado em jogos multiplayer para garantir que todos os jogadores estejam na mesma cena.

### Carregando uma cena existente

Para carregar uma cena existente, você pode usar o método `OpenLevel` da classe `UGameplayStatics`. Este método é bastante simples e eficaz para transições básicas entre cenas.

```cpp
#include "Kismet/GameplayStatics.h"

void ALoadLevelActor::LoadNewLevel()
{
    UGameplayStatics::OpenLevel(this, TEXT("NewLevel"));
}
```

Neste exemplo, `LoadNewLevel` é uma função que carrega a cena chamada `NewLevel`. O `this` refere-se ao objeto atual que está chamando a função.

### Erro comum: Cena não encontrada

Um erro comum ao tentar carregar uma cena é o `Failed to travel to level: NewLevel`. Isso geralmente acontece porque o nome da cena está incorreto ou a cena não foi salva corretamente. Certifique-se de que o nome da cena corresponde exatamente ao nome do arquivo `.umap` no Content Browser.

### Transição entre cenas

Para uma transição suave entre cenas, você pode usar um `Loading Screen`. Isso pode ser feito criando um Widget Blueprint que será exibido enquanto a nova cena é carregada. Aqui está um exemplo básico de como fazer isso:

```cpp
#include "Kismet/GameplayStatics.h"
#include "Blueprint/UserWidget.h"

void ALevelTransitionActor::TransitionToNewLevel()
{
    // Exibe a tela de carregamento
    if (LoadingScreenClass)
    {
        UUserWidget* LoadingScreen = CreateWidget<UUserWidget>(GetWorld(), LoadingScreenClass);
        LoadingScreen->AddToViewport();
    }

    // Carrega a nova cena
    UGameplayStatics::OpenLevel(this, TEXT("NewLevel"));
}
```

Neste exemplo, `LoadingScreenClass` é uma variável que armazena a classe do Widget Blueprint da tela de carregamento. Quando `TransitionToNewLevel` é chamada, a tela de carregamento é exibida antes de carregar a nova cena.

### Exercício prático

Crie um jogo simples com três cenas: um menu principal, um nível de jogo e uma tela de game over. Use Blueprints ou C++ para controlar as transições entre essas cenas. Certifique-se de que cada cena tenha um botão que permita ao jogador navegar para a próxima cena.

```cpp
// Exemplo de código para transição entre cenas em um menu
void AMainMenuActor::GoToGameLevel()
{
    UGameplayStatics::OpenLevel(this, TEXT("GameLevel"));
}

void AGameLevelActor::GoToGameOver()
{
    UGameplayStatics::OpenLevel(this, TEXT("GameOver"));
}
```

Neste exemplo, `GoToGameLevel` e `GoToGameOver` são funções que carregam as cenas `GameLevel` e `GameOver`, respectivamente.

### Conclusão

O gerenciamento de cenas é uma parte fundamental do desenvolvimento de jogos na Unreal Engine. Compreender como criar, carregar e transitar entre cenas permitirá que você crie experiências de jogo mais complexas e envolventes. Pratique esses conceitos criando projetos simples e expandindo-os gradualmente para incluir mais funcionalidades.