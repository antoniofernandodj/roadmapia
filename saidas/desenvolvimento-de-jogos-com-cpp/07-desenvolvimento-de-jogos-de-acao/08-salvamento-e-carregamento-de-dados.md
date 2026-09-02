## Salvamento e carregamento de dados

Seu jogo de ação está quase pronto - o jogador pode mover-se, atirar, coletar power-ups e enfrentar inimigos. Mas há um problema: quando o jogador fecha o jogo, todo o progresso é perdido. Em um jogo comercial, isso seria inaceitável. A solução está em salvar os dados críticos do jogo para carregá-los posteriormente.

Vamos implementar um sistema de salvamento que armazene:
- A posição do jogador
- A quantidade de vidas restantes
- A pontuação atual
- Os power-ups ativos

Na Unreal Engine, usaremos principalmente dois mecanismos para isso: `USaveGame` para dados estruturados e `FPlatformFileManager` para operações com arquivos. Veja como criar uma classe de salvamento básica:

```cpp
// Arquivo: SaveGameSystem.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/SaveGame.h"
#include "SaveGameSystem.generated.h"

UCLASS()
class ACTIONGAME_API USaveGameSystem : public USaveGame
{
    GENERATED_BODY()
    
public:
    UPROPERTY(VisibleAnywhere, Category = "Save Data")
    FVector PlayerLocation;

    UPROPERTY(VisibleAnywhere, Category = "Save Data")
    int32 PlayerLives;

    UPROPERTY(VisibleAnywhere, Category = "Save Data")
    int32 PlayerScore;

    UPROPERTY(VisibleAnywhere, Category = "Save Data")
    TArray<FString> ActivePowerUps;
};
```

Agora, vamos implementar as funções para salvar e carregar esses dados. Criaremos essas funções em uma classe de gerenciamento de jogos:

```cpp
// Arquivo: GameManager.cpp
#include "GameManager.h"
#include "Kismet/GameplayStatics.h"
#include "SaveGameSystem.h"

void UGameManager::SaveGame()
{
    USaveGameSystem* SaveGameInstance = Cast<USaveGameSystem>(
        UGameplayStatics::CreateSaveGameObject(USaveGameSystem::StaticClass()));

    // Preenche os dados do salvamento
    SaveGameInstance->PlayerLocation = PlayerCharacter->GetActorLocation();
    SaveGameInstance->PlayerLives = PlayerLives;
    SaveGameInstance->PlayerScore = PlayerScore;
    SaveGameInstance->ActivePowerUps = ActivePowerUps;

    // Salva no slot 0
    if (!UGameplayStatics::SaveGameToSlot(SaveGameInstance, TEXT("Slot0"), 0))
    {
        UE_LOG(LogTemp, Error, TEXT("Falha ao salvar o jogo!"));
    }
}

void UGameManager::LoadGame()
{
    if (UGameplayStatics::DoesSaveGameExist(TEXT("Slot0"), 0))
    {
        USaveGameSystem* LoadedGame = Cast<USaveGameSystem>(
            UGameplayStatics::LoadGameFromSlot(TEXT("Slot0"), 0));

        // Aplica os dados carregados
        PlayerCharacter->SetActorLocation(LoadedGame->PlayerLocation);
        PlayerLives = LoadedGame->PlayerLives;
        PlayerScore = LoadedGame->PlayerScore;
        ActivePowerUps = LoadedGame->ActivePowerUps;
    }
}
```

Um erro comum é tentar salvar referências diretas a objetos do jogo. Isso não funciona porque os objetos podem não existir na próxima sessão. Veja o que acontece:

```cpp
// ERRADO: Tentando salvar o ponteiro para o personagem
UPROPERTY(VisibleAnywhere, Category = "Save Data")
APlayerCharacter* PlayerCharacter;  // Isso não funcionará!

// CORRETO: Salvar apenas dados primitivos ou estruturas simples
UPROPERTY(VisibleAnywhere, Category = "Save Data")
FVector PlayerLocation;  // Isso sim funciona
```

Quando você executa esse código errado, a Unreal Engine mostra este erro:
```
LogSaveGame: Warning: Unable to save Actor /Game/Maps/Level1.Level1:PersistentLevel.PlayerCharacter_0 - Actor references are not supported by SaveGame system.
```

Para sistemas mais complexos, como salvar o estado de múltiplos inimigos ou objetos interativos, usamos um padrão chamado Memento. Aqui está como implementar:

```cpp
// Arquivo: EnemyMemento.h
USTRUCT()
struct FEnemyMemento
{
    GENERATED_BODY()

    UPROPERTY()
    FVector Location;

    UPROPERTY()
    float Health;

    UPROPERTY()
    FName CurrentState; // "Patrolling", "Chasing", "Attacking"
};

// E na classe de salvamento:
UPROPERTY(VisibleAnywhere, Category = "Save Data")
TMap<FString, FEnemyMemento> EnemyStates;
```

Para salvar os dados de todos os inimigos ativos:

```cpp
void UGameManager::SaveEnemyStates()
{
    for (AEnemy* Enemy : ActiveEnemies)
    {
        FEnemyMemento Memento;
        Memento.Location = Enemy->GetActorLocation();
        Memento.Health = Enemy->GetHealth();
        Memento.CurrentState = Enemy->GetCurrentStateName();

        SaveGameInstance->EnemyStates.Add(Enemy->GetUniqueID(), Memento);
    }
}
```

E para restaurar:

```cpp
void UGameManager::LoadEnemyStates()
{
    for (auto& Entry : SaveGameInstance->EnemyStates)
    {
        AEnemy* Enemy = FindEnemyByID(Entry.Key);
        if (Enemy)
        {
            Enemy->SetActorLocation(Entry.Value.Location);
            Enemy->SetHealth(Entry.Value.Health);
            Enemy->SetStateByName(Entry.Value.CurrentState);
        }
    }
}
```

**Exercício:** Implemente um sistema de múltiplos slots de salvamento que permita ao jogador escolher em qual slot salvar. A solução deve incluir:
1. Uma função para listar os slots disponíveis
2. Uma função para salvar em um slot específico
3. Uma função para carregar de um slot específico

**Solução:**

```cpp
// No GameManager.h
UFUNCTION(BlueprintCallable)
TArray<int32> GetAvailableSaveSlots();

UFUNCTION(BlueprintCallable)
bool SaveToSlot(int32 SlotIndex);

UFUNCTION(BlueprintCallable)
bool LoadFromSlot(int32 SlotIndex);

// No GameManager.cpp
TArray<int32> UGameManager::GetAvailableSaveSlots()
{
    TArray<int32> AvailableSlots;
    for (int32 i = 0; i < MaxSaveSlots; ++i)
    {
        if (UGameplayStatics::DoesSaveGameExist(
            FString::Printf(TEXT("Slot%d"), i), 0))
        {
            AvailableSlots.Add(i);
        }
    }
    return AvailableSlots;
}

bool UGameManager::SaveToSlot(int32 SlotIndex)
{
    FString SlotName = FString::Printf(TEXT("Slot%d"), SlotIndex);
    return UGameplayStatics::SaveGameToSlot(
        SaveGameInstance, SlotName, 0);
}

bool UGameManager::LoadFromSlot(int32 SlotIndex)
{
    FString SlotName = FString::Printf(TEXT("Slot%d"), SlotIndex);
    if (UGameplayStatics::DoesSaveGameExist(SlotName, 0))
    {
        USaveGameSystem* LoadedGame = Cast<USaveGameSystem>(
            UGameplayStatics::LoadGameFromSlot(SlotName, 0));
        ApplyLoadedData(LoadedGame);
        return true;
    }
    return false;
}
```