## Projeto prático: jogo avançado

Vamos criar um jogo de plataforma 2D com elementos de RPG usando C++ na Unreal Engine. O jogador controlará um personagem que pode atacar inimigos, coletar itens e evoluir habilidades. Começaremos pelo sistema de combate, que ilustra vários conceitos avançados de forma integrada.

**Sistema de Dano com Herança e Polimorfismo**

Primeiro, definimos a classe base para todos os atores que podem receber dano:

```cpp
// DamageableActor.h
UCLASS()
class MYGAME_API ADamageableActor : public AActor
{
    GENERATED_BODY()
    
public:
    virtual void TakeDamage(float DamageAmount, FVector HitLocation);
    virtual float CalculateDamageReduction() { return 0.0f; }
    
    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    float CurrentHealth = 100.0f;
};
```

Na implementação:

```cpp
// DamageableActor.cpp
void ADamageableActor::TakeDamage(float DamageAmount, FVector HitLocation)
{
    float ActualDamage = DamageAmount - CalculateDamageReduction();
    CurrentHealth -= ActualDamage;
    
    if(CurrentHealth <= 0.0f)
    {
        OnDeath();
    }
}

void ADamageableActor::OnDeath()
{
    Destroy();
}
```

Agora criamos um inimigo com redução de dano baseada em armadura:

```cpp
// ArmoredEnemy.h
UCLASS()
class MYGAME_API AArmoredEnemy : public ADamageableActor
{
    GENERATED_BODY()
    
public:
    virtual float CalculateDamageReduction() override;
    
private:
    UPROPERTY(EditDefaultsOnly)
    float ArmorValue = 20.0f;
};
```

```cpp
// ArmoredEnemy.cpp
float AArmoredEnemy::CalculateDamageReduction()
{
    return ArmorValue * 0.5f; // Reduz 50% do valor da armadura
}
```

**Erro comum**: esquecer o `override` pode fazer com que o método da classe base seja chamado. O compilador emitirá:

```
warning: 'CalculateDamageReduction' overrides a member function but is not marked 'override'
```

**Sistema de Itens com Templates**

Criamos uma classe template para o inventário:

```cpp
// Inventory.h
template<typename T>
class MYGAME_API UInventory
{
public:
    void AddItem(T Item);
    int32 CountItems() const;
    T GetItem(int32 Index) const;
    
private:
    TArray<T> Items;
};
```

Implementação:

```cpp
template<typename T>
void UInventory<T>::AddItem(T Item)
{
    Items.Add(Item);
}

template<typename T>
int32 UInventory<T>::CountItems() const
{
    return Items.Num();
}

template<typename T>
T UInventory<T>::GetItem(int32 Index) const
{
    return Items.IsValidIndex(Index) ? Items[Index] : T();
}
```

Podemos usar com diferentes tipos:

```cpp
UInventory<FWeaponData> WeaponInventory;
UInventory<FPotionData> PotionInventory;
```

**Salvamento do Jogo**

Implementamos serialização para salvar o estado do jogador:

```cpp
// PlayerSaveGame.h
UCLASS()
class MYGAME_API UPlayerSaveGame : public USaveGame
{
    GENERATED_BODY()
    
public:
    UPROPERTY()
    FString PlayerName;
    
    UPROPERTY()
    float Health;
    
    UPROPERTY()
    TArray<FName> CollectedItems;
};
```

Para salvar:

```cpp
bool UGameManager::SavePlayerData()
{
    UPlayerSaveGame* SaveData = Cast<UPlayerSaveGame>(UGameplayStatics::CreateSaveGameObject(UPlayerSaveGame::StaticClass()));
    
    SaveData->PlayerName = PlayerCharacter->GetName();
    SaveData->Health = PlayerCharacter->GetHealth();
    SaveData->CollectedItems = PlayerCharacter->GetInventoryItemNames();
    
    return UGameplayStatics::SaveGameToSlot(SaveData, "PlayerSave", 0);
}
```

**Exercício**: Crie uma classe `MagicalEnemy` que herda de `ADamageableActor` e implementa um método `CalculateDamageReduction` que reduz mais dano quando a saúde está baixa (abaixo de 30%).

**Solução**:

```cpp
// MagicalEnemy.h
UCLASS()
class MYGAME_API AMagicalEnemy : public ADamageableActor
{
    GENERATED_BODY()
    
public:
    virtual float CalculateDamageReduction() override;
};

// MagicalEnemy.cpp
float AMagicalEnemy::CalculateDamageReduction()
{
    return (CurrentHealth < 30.0f) ? 40.0f : 15.0f;
}
```