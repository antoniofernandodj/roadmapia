## Salvamento e carregamento de dados

Um jogo de plataforma sem sistema de salvamento é como uma corrida sem linha de chegada - o jogador precisa poder continuar de onde parou. Vamos implementar um sistema simples para salvar a posição do personagem, pontuação e o nível atual.

O Unreal Engine oferece duas abordagens principais para persistência de dados:

1. **GameInstance**: Persiste entre níveis e sessões
2. **SaveGame**: Sistema especializado para salvar estados de jogo

Vamos focar no `SaveGame`, que é mais adequado para progresso do jogador. Primeiro, crie uma nova classe herdando de `USaveGame`:

```cpp
// MeuSaveGame.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/SaveGame.h"
#include "MeuSaveGame.generated.h"

UCLASS()
class MEUJOGO_API UMeuSaveGame : public USaveGame
{
    GENERATED_BODY()
    
public:
    UPROPERTY(VisibleAnywhere, Category="SaveData")
    FString PlayerName;
    
    UPROPERTY(VisibleAnywhere, Category="SaveData")
    FVector PlayerLocation;
    
    UPROPERTY(VisibleAnywhere, Category="SaveData")
    int32 CurrentScore;
    
    UPROPERTY(VisibleAnywhere, Category="SaveData")
    FString LevelName;
};
```

Para salvar o estado atual do jogo, adicione este código ao seu personagem ou GameMode:

```cpp
// Salvar o jogo
void AMeuPersonagem::SalvarJogo()
{
    UMeuSaveGame* SaveGameInstance = Cast<UMeuSaveGame>(UGameplayStatics::CreateSaveGameObject(UMeuSaveGame::StaticClass()));
    
    if(SaveGameInstance)
    {
        SaveGameInstance->PlayerName = "Jogador1";
        SaveGameInstance->PlayerLocation = GetActorLocation();
        SaveGameInstance->CurrentScore = MinhaPontuacao;
        SaveGameInstance->LevelName = GetWorld()->GetMapName();
        
        if(UGameplayStatics::SaveGameToSlot(SaveGameInstance, TEXT("Slot1"), 0))
        {
            UE_LOG(LogTemp, Warning, TEXT("Jogo salvo com sucesso!"));
        }
        else
        {
            UE_LOG(LogTemp, Error, TEXT("Falha ao salvar o jogo!"));
        }
    }
}
```

Um erro comum é esquecer de marcar as variáveis com `UPROPERTY()`. Se fizer isso, a mensagem de erro será:

```
LogSavePackage: Warning: SaveGame /Game/SaveGames/SaveSlot1: Property 'PlayerLocation' wasn't saved because it isn't marked with UPROPERTY()
```

Para carregar o jogo salvo:

```cpp
// Carregar o jogo
void AMeuPersonagem::CarregarJogo()
{
    UMeuSaveGame* LoadedGame = Cast<UMeuSaveGame>(UGameplayStatics::LoadGameFromSlot(TEXT("Slot1"), 0));
    
    if(LoadedGame)
    {
        SetActorLocation(LoadedGame->PlayerLocation);
        MinhaPontuacao = LoadedGame->CurrentScore;
        
        // Se o nível atual for diferente do salvo, carregamos o nível certo
        if(GetWorld()->GetMapName() != LoadedGame->LevelName)
        {
            UGameplayStatics::OpenLevel(GetWorld(), FName(*LoadedGame->LevelName));
        }
        
        UE_LOG(LogTemp, Warning, TEXT("Jogo carregado com sucesso!"));
    }
    else
    {
        UE_LOG(LogTemp, Warning, TEXT("Nenhum save encontrado."));
    }
}
```

Na prática, você pode chamar esses métodos em eventos como:

```cpp
// No construtor do personagem ou em SetupPlayerInputComponent
InputComponent->BindAction("Salvar", IE_Pressed, this, &AMeuPersonagem::SalvarJogo);
InputComponent->BindAction("Carregar", IE_Pressed, this, &AMeuPersonagem::CarregarJogo);
```

**Exercício prático**: Implemente um sistema que salve não apenas a posição do personagem, mas também o estado dos inimigos (vivos/mortos) em um array dentro do SaveGame. Mostre na tela a data/hora do último save.

**Solução comentada**:
```cpp
// Adicione ao MeuSaveGame.h
UPROPERTY(VisibleAnywhere, Category="SaveData")
TArray<bool> InimigosVivos;

UPROPERTY(VisibleAnywhere, Category="SaveData")
FDateTime SaveDateTime;

// Modifique SalvarJogo()
SaveGameInstance->SaveDateTime = FDateTime::Now();

// Para inimigos (em um loop antes de salvar)
SaveGameInstance->InimigosVivos.Add(Inimigo->EstaVivo());

// Na UI
FString SaveTimeText = FString::Printf(TEXT("Último save: %s"), 
    *SaveGameInstance->SaveDateTime.ToString());
```