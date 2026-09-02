## Monetização e economia

Um jogo pode ser incrível em mecânicas e gráficos, mas se não tiver um sistema econômico bem pensado, ele pode perder o interesse do jogador rapidamente ou até mesmo falhar financeiramente. Monetização e economia no jogo são essenciais para manter os jogadores engajados e garantir que o jogo seja sustentável. Vamos explorar como implementar sistemas básicos de monetização e economia usando C++ na Unreal Engine, sem complicações desnecessárias.

### Moeda virtual e recompensas

A primeira coisa que você precisa é de uma moeda virtual que os jogadores possam ganhar e gastar. Vamos criar uma classe `CurrencyManager` para lidar com isso:

```cpp
class CurrencyManager
{
public:
    CurrencyManager() : balance(0) {}

    void AddCurrency(int amount)
    {
        balance += amount;
        OnCurrencyChanged.Broadcast(balance);
    }

    bool SpendCurrency(int amount)
    {
        if (amount > balance)
        {
            return false;
        }
        balance -= amount;
        OnCurrencyChanged.Broadcast(balance);
        return true;
    }

    int GetBalance() const
    {
        return balance;
    }

    DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnCurrencyChanged, int, NewBalance);
    FOnCurrencyChanged OnCurrencyChanged;

private:
    int balance;
};
```

Este código define uma classe `CurrencyManager` que permite adicionar e gastar moedas. O evento `OnCurrencyChanged` é disparado sempre que o saldo muda, permitindo que outras partes do jogo reajam a essas mudanças.

**Saída esperada:**
Se você adicionar 100 moedas e depois gastar 50, o saldo final será 50, e o evento `OnCurrencyChanged` será chamado duas vezes.

### Loja virtual

Agora que temos uma moeda virtual, precisamos de uma loja onde os jogadores possam gastá-la. Vamos criar uma classe `ShopItem` e uma classe `Shop`:

```cpp
class ShopItem
{
public:
    ShopItem(const FString& Name, int Price) : ItemName(Name), ItemPrice(Price) {}

    FString GetName() const
    {
        return ItemName;
    }

    int GetPrice() const
    {
        return ItemPrice;
    }

private:
    FString ItemName;
    int ItemPrice;
};

class Shop
{
public:
    void AddItem(const ShopItem& Item)
    {
        Items.Add(Item);
    }

    bool PurchaseItem(int Index, CurrencyManager& Currency)
    {
        if (Index >= Items.Num())
        {
            return false;
        }

        const ShopItem& Item = Items[Index];
        if (Currency.SpendCurrency(Item.GetPrice()))
        {
            OnItemPurchased.Broadcast(Item);
            return true;
        }
        return false;
    }

    DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnItemPurchased, const ShopItem&, PurchasedItem);
    FOnItemPurchased OnItemPurchased;

private:
    TArray<ShopItem> Items;
};
```

Este código define uma loja que contém itens que podem ser comprados. O método `PurchaseItem` verifica se o jogador tem moedas suficientes para comprar o item e, se tiver, o item é comprado e o evento `OnItemPurchased` é disparado.

**Saída esperada:**
Se o jogador tentar comprar um item que custa 50 moedas e tiver apenas 40 moedas, a compra falhará. Se tiver 60 moedas, a compra será bem-sucedida e o evento `OnItemPurchased` será chamado.

### Recompensas diárias

Para manter os jogadores engajados, você pode implementar um sistema de recompensas diárias. Vamos criar uma classe `DailyRewards`:

```cpp
class DailyRewards
{
public:
    DailyRewards() : LastClaimedDay(-1) {}

    void ClaimReward(CurrencyManager& Currency)
    {
        int CurrentDay = GetCurrentDay();
        if (CurrentDay != LastClaimedDay)
        {
            Currency.AddCurrency(RewardAmount);
            LastClaimedDay = CurrentDay;
            OnRewardClaimed.Broadcast(RewardAmount);
        }
    }

    DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnRewardClaimed, int, Reward);
    FOnRewardClaimed OnRewardClaimed;

private:
    int GetCurrentDay() const
    {
        // Implemente uma função que retorna o dia atual (por exemplo, usando FDateTime)
        return FDateTime::Now().GetDayOfYear();
    }

    int LastClaimedDay;
    static const int RewardAmount = 100;
};
```

Este código permite que os jogadores reivindiquem uma recompensa diária, mas apenas uma vez por dia. O método `ClaimReward` verifica se a recompensa já foi reivindicada hoje e, se não foi, adiciona a recompensa ao saldo do jogador.

**Saída esperada:**
Se o jogador reivindicar a recompensa hoje, ele receberá 100 moedas. Se tentar reivindicar novamente no mesmo dia, nada acontecerá.

### Erro comum: Falha ao sincronizar dados

Um erro comum é não sincronizar corretamente os dados de moeda entre sessões de jogo. Se o saldo do jogador não for salvo e carregado corretamente, ele pode perder progresso. Para evitar isso, você deve salvar o saldo em um arquivo ou usar o sistema de salvamento da Unreal Engine.

**Solução:**
```cpp
void SaveCurrency(const CurrencyManager& Currency, const FString& SaveFilePath)
{
    TArray<uint8> Data;
    FMemoryWriter Writer(Data);
    Writer << Currency.GetBalance();

    FFileHelper::SaveArrayToFile(Data, *SaveFilePath);
}

void LoadCurrency(CurrencyManager& Currency, const FString& SaveFilePath)
{
    TArray<uint8> Data;
    if (FFileHelper::LoadFileToArray(Data, *SaveFilePath))
    {
        FMemoryReader Reader(Data);
        int Balance;
        Reader << Balance;
        Currency.AddCurrency(Balance);
    }
}
```

Este código salva o saldo do jogador em um arquivo e carrega-o quando o jogo é reiniciado.

**Saída esperada:**
Se o jogador tiver 100 moedas e salvar o jogo, ao reiniciar, ele ainda terá 100 moedas.

### Exercício prático

Implemente um sistema de missões que recompense o jogador com moedas ao completar objetivos específicos. Cada missão deve ter um título, uma descrição e uma recompensa em moedas. Crie uma classe `Mission` e uma classe `MissionManager` para gerenciar as missões.

**Solução:**
```cpp
class Mission
{
public:
    Mission(const FString& Title, const FString& Description, int Reward)
        : MissionTitle(Title), MissionDescription(Description), MissionReward(Reward) {}

    FString GetTitle() const { return MissionTitle; }
    FString GetDescription() const { return MissionDescription; }
    int GetReward() const { return MissionReward; }

private:
    FString MissionTitle;
    FString MissionDescription;
    int MissionReward;
};

class MissionManager
{
public:
    void AddMission(const Mission& NewMission)
    {
        Missions.Add(NewMission);
    }

    void CompleteMission(int Index, CurrencyManager& Currency)
    {
        if (Index >= Missions.Num())
        {
            return;
        }

        const Mission& CompletedMission = Missions[Index];
        Currency.AddCurrency(CompletedMission.GetReward());
        Missions.RemoveAt(Index);
        OnMissionCompleted.Broadcast(CompletedMission);
    }

    DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnMissionCompleted, const Mission&, CompletedMission);
    FOnMissionCompleted OnMissionCompleted;

private:
    TArray<Mission> Missions;
};
```

Este código permite adicionar missões e completá-las, recompensando o jogador com moedas.

**Saída esperada:**
Se o jogador completar uma missão que dá 50 moedas, ele receberá 50 moedas e a missão será removida da lista.