## Manipulação de arquivos

Em jogos, frequentemente precisamos salvar e carregar dados: configurações do jogador, progresso da campanha ou até mapas gerados proceduralmente. Vamos implementar um sistema simples de save/load usando arquivos de texto na Unreal Engine.

### Leitura básica de arquivos

O Unreal Engine fornece a classe `FPlatformFileManager` para manipulação de arquivos. Veja como ler um arquivo de configuração simples:

```cpp
#include "HAL/PlatformFilemanager.h"
#include "GenericPlatform/GenericPlatformFile.h"

void UMyGameInstance::LoadGameSettings()
{
    IPlatformFile& PlatformFile = FPlatformFileManager::Get().GetPlatformFile();
    FString FilePath = FPaths::ProjectConfigDir() + TEXT("GameSettings.ini");
    
    if (PlatformFile.FileExists(*FilePath))
    {
        FString FileContent;
        if (FFileHelper::LoadFileToString(FileContent, *FilePath))
        {
            UE_LOG(LogTemp, Display, TEXT("Config loaded: %s"), *FileContent);
        }
        else
        {
            UE_LOG(LogTemp, Error, TEXT("Failed to read file: %s"), *FilePath);
        }
    }
    else
    {
        UE_LOG(LogTemp, Warning, TEXT("Config file not found: %s"), *FilePath);
    }
}
```

Saída esperada no Output Log:
```
LogTemp: Display: Config loaded: [Game]
PlayerSpeed=500
EnemyCount=20
```

### Escrita de arquivos

Para salvar dados do jogador, usamos `FFileHelper`:

```cpp
void UMyGameInstance::SavePlayerProgress(FString PlayerName, int32 Level, int32 Score)
{
    FString SaveData = FString::Printf(TEXT("%s|%d|%d"), *PlayerName, Level, Score);
    FString SavePath = FPaths::ProjectSavedDir() + TEXT("Saves/PlayerProgress.sav");
    
    if (!FFileHelper::SaveStringToFile(SaveData, *SavePath))
    {
        UE_LOG(LogTemp, Error, TEXT("Failed to save player progress!"));
    }
}
```

Erro comum: esquecer de criar o diretório antes de salvar. Se a pasta "Saves" não existir, o código falhará. Corrigimos assim:

```cpp
void UMyGameInstance::EnsureSaveDirectoryExists()
{
    FString SaveDir = FPaths::ProjectSavedDir() + TEXT("Saves/");
    IPlatformFile& PlatformFile = FPlatformFileManager::Get().GetPlatformFile();
    
    if (!PlatformFile.DirectoryExists(*SaveDir))
    {
        PlatformFile.CreateDirectory(*SaveDir);
    }
}
```

### Formatos estruturados

Para dados complexos, o Unreal oferece JSON e XML. Veja como salvar uma lista de itens em JSON:

```cpp
#include "Serialization/JsonSerializer.h"

void UMyGameInstance::SaveInventory(TArray<FItem> InventoryItems)
{
    TSharedPtr<FJsonObject> RootObject = MakeShareable(new FJsonObject);
    TArray<TSharedPtr<FJsonValue>> ItemsArray;
    
    for (const FItem& Item : InventoryItems)
    {
        TSharedPtr<FJsonObject> ItemObject = MakeShareable(new FJsonObject);
        ItemObject->SetStringField("Name", Item.Name);
        ItemObject->SetNumberField("Quantity", Item.Quantity);
        ItemsArray.Add(MakeShareable(new FJsonValueObject(ItemObject)));
    }
    
    RootObject->SetArrayField("Inventory", ItemsArray);
    
    FString OutputString;
    TSharedRef<TJsonWriter<>> Writer = TJsonWriterFactory<>::Create(&OutputString);
    FJsonSerializer::Serialize(RootObject.ToSharedRef(), Writer);
    
    FString SavePath = FPaths::ProjectSavedDir() + TEXT("Saves/Inventory.json");
    FFileHelper::SaveStringToFile(OutputString, *SavePath);
}
```

### Exercício prático

Implemente uma função que carregue os dados do jogador (nome, vida e posição) de um arquivo chamado "PlayerState.sav" no formato:
```
PlayerName:Jogador1
Health:85
Location:1250,340
```

Solução comentada:

```cpp
FPlayerData UMyGameInstance::LoadPlayerState()
{
    FPlayerData PlayerData;
    FString FilePath = FPaths::ProjectSavedDir() + TEXT("Saves/PlayerState.sav");
    
    if (FFileHelper::LoadFileToString(PlayerData.RawData, *FilePath))
    {
        TArray<FString> Lines;
        PlayerData.RawData.ParseIntoArrayLines(Lines);
        
        for (FString& Line : Lines)
        {
            FString Key, Value;
            if (Line.Split(TEXT(":"), &Key, &Value))
            {
                if (Key.Equals(TEXT("PlayerName")))
                {
                    PlayerData.Name = Value;
                }
                else if (Key.Equals(TEXT("Health")))
                {
                    PlayerData.Health = FCString::Atoi(*Value);
                }
                else if (Key.Equals(TEXT("Location")))
                {
                    TArray<FString> Coords;
                    Value.ParseIntoArray(Coords, TEXT(","));
                    if (Coords.Num() == 2)
                    {
                        PlayerData.X = FCString::Atof(*Coords[0]);
                        PlayerData.Y = FCString::Atof(*Coords[1]);
                    }
                }
            }
        }
    }
    
    return PlayerData;
}
```