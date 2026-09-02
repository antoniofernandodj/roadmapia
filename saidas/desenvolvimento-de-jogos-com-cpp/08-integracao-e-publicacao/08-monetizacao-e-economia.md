## Monetização e economia

Monetização em jogos não se resume a "colocar anúncios" ou "vender itens". É sobre criar um sistema econômico que motive os jogadores a investirem tempo e dinheiro sem prejudicar a experiência. Vamos começar com o básico: moedas virtuais.

Na Unreal Engine, criamos uma moeda virtual usando uma estrutura simples:

```cpp
USTRUCT(BlueprintType)
struct FCurrency
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Currency")
    int32 Amount;

    FCurrency() : Amount(0) {}

    void Add(int32 Value)
    {
        Amount += Value;
    }

    bool Spend(int32 Value)
    {
        if (Amount >= Value)
        {
            Amount -= Value;
            return true;
        }
        return false;
    }
};
```

Essa estrutura permite criar diferentes tipos de moedas (ouro, gemas, pontos) e gerenciar operações básicas. Para usá-la em um personagem:

```cpp
UCLASS()
class APlayerCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Economy")
    FCurrency Gold;

    void CollectGold(int32 Amount)
    {
        Gold.Add(Amount);
        UE_LOG(LogTemp, Display, TEXT("Gold collected! Total: %d"), Gold.Amount);
    }

    bool BuyItem(int32 Cost)
    {
        if (Gold.Spend(Cost))
        {
            UE_LOG(LogTemp, Display, TEXT("Item purchased! Remaining gold: %d"), Gold.Amount);
            return true;
        }
        UE_LOG(LogTemp, Warning, TEXT("Not enough gold to buy item!"));
        return false;
    }
};
```

Ao executar este código e chamar `CollectGold(100)` seguido de `BuyItem(75)`, você verá na saída:

```
Gold collected! Total: 100
Item purchased! Remaining gold: 25
```

Mas e se o jogador tentar comprar algo sem dinheiro suficiente? O método `BuyItem` retorna `false` e exibe:

```
Not enough gold to buy item!
```

Um erro comum é esquecer de inicializar a quantidade de moedas. Sem o valor inicial `Amount(0)` no construtor, o valor inicial seria indefinido, podendo causar bugs difíceis de rastrear.

Para monetização, introduzimos moedas premium que podem ser compradas com dinheiro real. Criamos uma nova estrutura:

```cpp
USTRUCT(BlueprintType)
struct FPremiumCurrency : public FCurrency
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Currency")
    FString CurrencyCode; // Ex: "USD", "EUR"

    FPremiumCurrency() : FCurrency(), CurrencyCode("USD") {}
};
```

E adicionamos métodos para compra:

```cpp
bool PurchasePremiumCurrency(int32 Amount, const FString& CurrencyCode)
{
    // Aqui você integraria com um sistema de pagamento real
    UE_LOG(LogTemp, Display, TEXT("Purchased %d premium currency with %s"), Amount, *CurrencyCode);
    return true;
}
```

Um sistema econômico completo precisa balancear ganho e gasto. Por exemplo, aqui está uma função que ajusta preços baseado na inflação:

```cpp
float CalculateAdjustedPrice(float BasePrice, float InflationRate, int32 DaysPassed)
{
    return BasePrice * FMath::Pow(1.0f + InflationRate, DaysPassed);
}
```

Se `BasePrice` é 100 e `InflationRate` é 0.01 (1%), após 10 dias o preço seria:

```
Adjusted price: 110.46
```

Exercício: Modifique o sistema para permitir conversão entre moedas com uma taxa de câmbio. Solução:

```cpp
bool ConvertCurrency(FCurrency& From, FCurrency& To, float ExchangeRate)
{
    if (From.Spend(1))
    {
        To.Add(ExchangeRate);
        return true;
    }
    return false;
}
```