## Sistema de pontuação e vidas

Um jogo de plataforma sem pontuação é como um livro sem páginas - falta o elemento que motiva o jogador a continuar. Vamos implementar um sistema onde coletar moedas aumenta a pontuação e tocar em inimigos reduz as vidas.

Primeiro, crie um novo C++ class chamado `APlatformerCharacter` derivado de `Character`. Adicione estas variáveis no header:

```cpp
UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Score")
int32 CurrentScore;

UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category="Lives")
int32 MaxLives = 3;

UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Lives")
int32 CurrentLives;
```

Inicialize-as no construtor:

```cpp
APlatformerCharacter::APlatformerCharacter()
{
    CurrentScore = 0;
    CurrentLives = MaxLives;
}
```

Para coletar moedas, adicione uma função que será chamada quando o personagem colidir com elas:

```cpp
void APlatformerCharacter::AddScore(int32 PointsToAdd)
{
    CurrentScore += PointsToAdd;
    
    // Erro comum: esquecer de arredondar valores
    CurrentScore = FMath::Max(0, CurrentScore); // Garante não ter pontuação negativa
    
    UE_LOG(LogTemp, Display, TEXT("Pontuação atual: %d"), CurrentScore);
}
```

Quando você testar sem o `FMath::Max`, pode ocorrer um comportamento indesejado onde a pontuação fica negativa. A mensagem de log ajuda a depurar durante o desenvolvimento.

Para o sistema de vidas, implemente:

```cpp
void APlatformerCharacter::LoseLife()
{
    CurrentLives--;
    
    if(CurrentLives <= 0)
    {
        UE_LOG(LogTemp, Warning, TEXT("Game Over!"));
        // Implementar lógica de game over aqui
    }
    else
    {
        UE_LOG(LogTemp, Display, TEXT("Vidas restantes: %d/%d"), 
               CurrentLives, MaxLives);
    }
}
```

Agora integre com as colisões. No método `SetupPlayerInputComponent`, adicione:

```cpp
void APlatformerCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);
    
    // Configura colisão com moedas
    GetCapsuleComponent()->OnComponentBeginOverlap.AddDynamic(
        this, &APlatformerCharacter::OnOverlapBegin);
}

void APlatformerCharacter::OnOverlapBegin(
    UPrimitiveComponent* OverlappedComponent,
    AActor* OtherActor,
    UPrimitiveComponent* OtherComp,
    int32 OtherBodyIndex,
    bool bFromSweep,
    const FHitResult& SweepResult)
{
    if(OtherActor->ActorHasTag("Coin"))
    {
        AddScore(10);
        OtherActor->Destroy();
    }
    else if(OtherActor->ActorHasTag("Enemy"))
    {
        LoseLife();
    }
}
```

Um erro comum é esquecer de marcar os atores com as tags "Coin" ou "Enemy" no editor. Se fizer isso, a mensagem de erro será:

```
LogScript: Warning: Accessed None trying to read property ActorHasTag
```

Para consertar, selecione o ator no editor e na aba Details, em Tags, adicione a tag correspondente.

Finalmente, mostre as informações na tela. Crie um User Widget chamado `W_ScoreDisplay` com dois TextBlocks. No header do personagem:

```cpp
UPROPERTY(EditAnywhere, Category="UI")
TSubclassOf<class UUserWidget> ScoreWidgetClass;

UPROPERTY()
UUserWidget* ScoreWidget;
```

Inicialize no BeginPlay:

```cpp
void APlatformerCharacter::BeginPlay()
{
    Super::BeginPlay();
    
    if(ScoreWidgetClass)
    {
        ScoreWidget = CreateWidget<UUserWidget>(GetWorld(), ScoreWidgetClass);
        ScoreWidget->AddToViewport();
    }
}
```

No Blueprint do widget, vincule os TextBlocks às variáveis (usando a sintaxe `{Score}` e `{Lives}`) e atualize-os sempre que os valores mudarem:

```cpp
void APlatformerCharacter::UpdateUI()
{
    if(ScoreWidget)
    {
        UTextBlock* ScoreText = Cast<UTextBlock>(
            ScoreWidget->GetWidgetFromName("ScoreText"));
        UTextBlock* LivesText = Cast<UTextBlock>(
            ScoreWidget->GetWidgetFromName("LivesText"));
            
        if(ScoreText && LivesText)
        {
            ScoreText->SetText(FText::FromString(
                FString::Printf(TEXT("Score: %d"), CurrentScore)));
            LivesText->SetText(FText::FromString(
                FString::Printf(TEXT("Lives: %d/%d"), 
                CurrentLives, MaxLives)));
        }
    }
}
```

Chame `UpdateUI()` no final de `AddScore()` e `LoseLife()`.

**Exercício**: Implemente um sistema de "combo" onde coletar moedas em sequência rapidamente dá bônus. Se mais de 3 segundos passarem entre coletas, o combo é resetado.

Solução:

```cpp
// No header
UPROPERTY(VisibleAnywhere)
float LastCoinTime;

UPROPERTY(VisibleAnywhere)
int32 ComboCounter;

// No construtor
LastCoinTime = 0.f;
ComboCounter = 0;

// Modifique AddScore
void APlatformerCharacter::AddScore(int32 PointsToAdd)
{
    float CurrentTime = GetWorld()->GetTimeSeconds();
    
    if(CurrentTime - LastCoinTime < 3.f)
    {
        ComboCounter++;
        PointsToAdd *= ComboCounter; // Bônus de combo
    }
    else
    {
        ComboCounter = 1;
    }
    
    LastCoinTime = CurrentTime;
    CurrentScore += PointsToAdd;
    
    // Restante da função...
}
```