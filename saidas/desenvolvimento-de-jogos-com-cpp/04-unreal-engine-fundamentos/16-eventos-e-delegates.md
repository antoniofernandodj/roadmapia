## Eventos e delegates

Imagine um personagem que precisa reagir quando o jogador pressiona uma tecla ou quando um inimigo entra em alcance. Você poderia verificar essas condições a cada quadro no `Tick()`, mas isso seria ineficiente. A Unreal Engine oferece um sistema elegante para esses casos: os **delegates** e **eventos**.

Um delegate é como um rádio walkie-talkie: você configura quem pode falar (broadcast) e quem deve escutar (bind). Quando algo importante acontece, emite-se um sinal sem precisar saber quem está ouvindo.

Vamos criar um sistema simples onde um botão na tela (UMG Widget) emite um evento quando clicado, e um Actor na cena reage a esse evento:

```cpp
// No arquivo MyButton.h
DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnButtonClicked);

UCLASS()
class MYGAME_API UMyButton : public UUserWidget
{
    GENERATED_BODY()

public:
    UPROPERTY(BlueprintAssignable)
    FOnButtonClicked OnButtonClicked;

    UFUNCTION(BlueprintCallable)
    void SimulateClick()
    {
        OnButtonClicked.Broadcast();
    }
};
```

```cpp
// No arquivo MyActor.h
UCLASS()
class MYGAME_API AMyActor : public AActor
{
    GENERATED_BODY()

public:
    UFUNCTION()
    void ReactToClick()
    {
        UE_LOG(LogTemp, Warning, TEXT("Button was clicked!"));
    }
};
```

No Blueprint do seu Widget:

1. Adicione um `UMyButton` como membro
2. No Graph do Widget, chame `MyButton->OnButtonClicked.AddDynamic()` 
3. Selecione seu `AMyActor` na cena e a função `ReactToClick`

Quando você chamar `SimulateClick()` (ou clicar num botão real conectado a essa função), verá a mensagem no Output Log. A magia aqui é que o botão não conhece o Actor - eles estão completamente desacoplados.

**Erro comum**: esquecer de usar `DYNAMIC` no delegate quando se pretende expô-lo a Blueprints. Se você usar apenas `DECLARE_MULTICAST_DELEGATE` e tentar conectá-lo no Editor, receberá o erro:

```
LogBlueprint: Error: [Compiler] Incompatible delegate type (FOnButtonClicked is not a dynamic delegate)
```

Para delegates que transportam dados, declare os parâmetros:

```cpp
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnHealthChanged, float, NewHealth);

// Uso:
OnHealthChanged.Broadcast(75.0f);
```

**Comparação com Blueprints**: Em C++, você declara o tipo do delegate manualmente, enquanto em Blueprints eles são criados automaticamente quando você arrasta um pino de evento. O conceito é o mesmo - são pontos de conexão entre partes do código.

Exercício: Crie um `AMyEnemy` que emite um evento `OnEnemyDied` quando sua vida chega a zero, e faça um `AMyPlayer` que escuta esse evento para atualizar o placar de pontos.

Solução comentada:

```cpp
// MyEnemy.h
DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnEnemyDied);

UCLASS()
class MYGAME_API AMyEnemy : public AActor
{
    GENERATED_BODY()
    
public:
    UPROPERTY(BlueprintAssignable)
    FOnEnemyDied OnEnemyDied;
    
    void TakeDamage(float Amount)
    {
        Health -= Amount;
        if(Health <= 0)
        {
            OnEnemyDied.Broadcast();
            Destroy();
        }
    }
    
private:
    float Health = 100.f;
};
```

```cpp
// MyPlayer.h
UCLASS()
class MYGAME_API AMyPlayer : public ACharacter
{
    GENERATED_BODY()
    
    void BeginPlay() override
    {
        Super::BeginPlay();
        
        // Supondo que já temos uma referência ao inimigo
        Enemy->OnEnemyDied.AddDynamic(this, &AMyPlayer::HandleEnemyDeath);
    }
    
    void HandleEnemyDeath()
    {
        Score += 10;
        UE_LOG(LogTemp, Warning, TEXT("New score: %d"), Score);
    }
    
private:
    int32 Score = 0;
};
```