## Serialização de dados avançada

Serialização de dados é o processo de converter objetos ou estruturas de dados em um formato que pode ser armazenado ou transmitido. Na Unreal Engine, isso é essencial para salvar o estado do jogo, armazenar configurações ou enviar dados entre diferentes sistemas. Vamos explorar técnicas avançadas para serializar dados complexos, incluindo objetos customizados e hierarquias de classes.

### Serialização de Objetos Customizados

Para salvar objetos customizados, é necessário implementar a interface `FArchive`. Essa interface permite que você defina como os dados do objeto serão lidos e escritos. Vamos criar uma classe simples `FPlayerData` que será serializada:

```cpp
USTRUCT()
struct FPlayerData
{
    GENERATED_BODY()

    UPROPERTY()
    FString PlayerName;

    UPROPERTY()
    int32 PlayerLevel;

    UPROPERTY()
    float Health;

    void Serialize(FArchive& Ar)
    {
        Ar << PlayerName;
        Ar << PlayerLevel;
        Ar << Health;
    }
};
```

Aqui, `Serialize` é o método que define como os dados serão escritos ou lidos. O operador `<<` é usado para serializar cada propriedade.

Para salvar esses dados em um arquivo, você pode usar `FFileHelper`:

```cpp
FPlayerData PlayerData;
PlayerData.PlayerName = TEXT("Hero");
PlayerData.PlayerLevel = 10;
PlayerData.Health = 100.0f;

TArray<uint8> Data;
FMemoryWriter Writer(Data);
PlayerData.Serialize(Writer);

FFileHelper::SaveArrayToFile(Data, *(FPaths::ProjectSavedDir() / TEXT("PlayerData.sav")));
```

Para carregar os dados de volta:

```cpp
TArray<uint8> LoadedData;
FFileHelper::LoadFileToArray(LoadedData, *(FPaths::ProjectSavedDir() / TEXT("PlayerData.sav")));

FMemoryReader Reader(LoadedData);
FPlayerData LoadedPlayerData;
LoadedPlayerData.Serialize(Reader);
```

### Serialização de Hierarquias de Classes

Quando você tem uma hierarquia de classes, a serialização pode se tornar mais complexa devido ao polimorfismo. Suponha que você tenha uma classe base `UCharacter` e uma classe derivada `UHero`. Para serializar corretamente, você precisa registrar as classes que podem ser serializadas:

```cpp
UCLASS()
class UCharacter : public UObject
{
    GENERATED_BODY()

    UPROPERTY()
    FString CharacterName;

    virtual void Serialize(FArchive& Ar)
    {
        Ar << CharacterName;
    }
};

UCLASS()
class UHero : public UCharacter
{
    GENERATED_BODY()

    UPROPERTY()
    FString HeroClass;

    virtual void Serialize(FArchive& Ar) override
    {
        Super::Serialize(Ar);
        Ar << HeroClass;
    }
};
```

Para salvar e carregar objetos polimórficos, você precisa usar `FObjectAndNameAsStringProxyArchive`:

```cpp
UHero* Hero = NewObject<UHero>();
Hero->CharacterName = TEXT("Aragorn");
Hero->HeroClass = TEXT("Ranger");

TArray<uint8> Data;
FMemoryWriter Writer(Data);
FObjectAndNameAsStringProxyArchive Ar(Writer, false);
Hero->Serialize(Ar);

FFileHelper::SaveArrayToFile(Data, *(FPaths::ProjectSavedDir() / TEXT("HeroData.sav")));
```

Para carregar:

```cpp
TArray<uint8> LoadedData;
FFileHelper::LoadFileToArray(LoadedData, *(FPaths::ProjectSavedDir() / TEXT("HeroData.sav")));

FMemoryReader Reader(LoadedData);
FObjectAndNameAsStringProxyArchive Ar(Reader, true);
UHero* LoadedHero = NewObject<UHero>();
LoadedHero->Serialize(Ar);
```

### Exercício

Crie uma classe `FInventoryItem` com propriedades `ItemName` e `ItemQuantity`. Serialize uma lista de `FInventoryItem` para um arquivo e depois carregue-a de volta. Modifique a quantidade de um dos itens e salve novamente.

**Solução:**

```cpp
USTRUCT()
struct FInventoryItem
{
    GENERATED_BODY()

    UPROPERTY()
    FString ItemName;

    UPROPERTY()
    int32 ItemQuantity;

    void Serialize(FArchive& Ar)
    {
        Ar << ItemName;
        Ar << ItemQuantity;
    }
};

TArray<FInventoryItem> Inventory;
Inventory.Add({ TEXT("Sword"), 1 });
Inventory.Add({ TEXT("Potion"), 5 });

TArray<uint8> Data;
FMemoryWriter Writer(Data);
for (FInventoryItem& Item : Inventory)
{
    Item.Serialize(Writer);
}

FFileHelper::SaveArrayToFile(Data, *(FPaths::ProjectSavedDir() / TEXT("Inventory.sav")));

TArray<uint8> LoadedData;
FFileHelper::LoadFileToArray(LoadedData, *(FPaths::ProjectSavedDir() / TEXT("Inventory.sav")));

FMemoryReader Reader(LoadedData);
TArray<FInventoryItem> LoadedInventory;
while (Reader.Tell() < Reader.TotalSize())
{
    FInventoryItem Item;
    Item.Serialize(Reader);
    LoadedInventory.Add(Item);
}

// Modificar a quantidade de um item
LoadedInventory[0].ItemQuantity = 2;

// Salvar novamente
Data.Empty();
FMemoryWriter WriterModified(Data);
for (FInventoryItem& Item : LoadedInventory)
{
    Item.Serialize(WriterModified);
}

FFileHelper::SaveArrayToFile(Data, *(FPaths::ProjectSavedDir() / TEXT("ModifiedInventory.sav")));
```

### Conclusão

A serialização avançada na Unreal Engine permite salvar e carregar dados complexos, incluindo objetos customizados e hierarquias de classes. Implementar a interface `FArchive` e usar `FObjectAndNameAsStringProxyArchive` são técnicas essenciais para lidar com polimorfismo e garantir que os dados sejam serializados corretamente.