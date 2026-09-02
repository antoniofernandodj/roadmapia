## Sistema de pontuação e vidas

No meio de um combate intenso, o jogador precisa saber duas coisas cruciais: quantos inimigos já derrotou e quantos erros ainda pode cometer antes de falhar. Vamos implementar um sistema que mostra isso na tela e reage aos eventos do jogo.

Na classe do jogador (geralmente chamada de `AMyCharacter`), adicione estas variáveis privadas:

```cpp
private:
    int32 PlayerScore;
    int32 PlayerLives;
    UPROPERTY(EditAnywhere, Category = "Player Stats")
    int32 MaxLives = 3;
```

A macro `UPROPERTY` permite editar o valor diretamente no editor da Unreal. Quando o jogo inicia, precisamos inicializar essas variáveis no método `BeginPlay`:

```cpp
void AMyCharacter::BeginPlay()
{
    Super::BeginPlay();
    PlayerScore = 0;
    PlayerLives = MaxLives;
}
```

Para exibir esses valores na tela, crie um widget Blueprint com duas caixas de texto chamadas `ScoreText` e `LivesText`. Na classe do jogador, adicione:

```cpp
UPROPERTY(EditAnywhere, Category = "UI")
TSubclassOf<class UUserWidget> PlayerHUDClass;
UUserWidget* PlayerHUD;

// Dentro de BeginPlay, após inicializar as variáveis:
if (PlayerHUDClass)
{
    PlayerHUD = CreateWidget<UUserWidget>(GetWorld(), PlayerHUDClass);
    if (PlayerHUD)
    {
        PlayerHUD->AddToViewport();
        UpdateHUD();
    }
}

void AMyCharacter::UpdateHUD()
{
    if (!PlayerHUD) return;
    
    UTextBlock* ScoreText = Cast<UTextBlock>(PlayerHUD->GetWidgetFromName(FName("ScoreText")));
    UTextBlock* LivesText = Cast<UTextBlock>(PlayerHUD->GetWidgetFromName(FName("LivesText")));
    
    if (ScoreText) ScoreText->SetText(FText::AsNumber(PlayerScore));
    if (LivesText) LivesText->SetText(FText::AsNumber(PlayerLives));
}
```

Agora, quando o jogador derrota um inimigo, chame este método:

```cpp
void AMyCharacter::AddScore(int32 Points)
{
    PlayerScore += Points;
    UpdateHUD();
    
    // Exemplo de feedback adicional
    if (Points > 100)
    {
        GEngine->AddOnScreenDebugMessage(-1, 3.0f, FColor::Yellow, 
            FString::Printf(TEXT("Combo! +%d pontos"), Points));
    }
}
```

E quando o jogador sofre dano:

```cpp
void AMyCharacter::LoseLife()
{
    if (PlayerLives > 0)
    {
        PlayerLives--;
        UpdateHUD();
        
        if (PlayerLives <= 0)
        {
            // Game Over
            GetWorld()->GetTimerManager().SetTimer(
                RestartTimerHandle, this, &AMyCharacter::RestartLevel, 3.0f, false);
        }
    }
}
```

Um erro comum é tentar acessar elementos da UI sem verificar se eles existem. Se você esquecer a verificação `if (ScoreText)` e o widget não tiver o elemento nomeado corretamente, receberá este erro:

```
Access violation reading location 0x00000000
```

Para conectar esse sistema ao combate, modifique o método de receber dano no personagem:

```cpp
void AMyCharacter::TakeDamage(float DamageAmount, FDamageEvent const& DamageEvent, 
    AController* EventInstigator, AActor* DamageCauser)
{
    LoseLife();
    // Efeitos visuais e sonoros de dano...
}
```

E na classe do inimigo, quando for derrotado:

```cpp
void AEnemy::Destroyed()
{
    Super::Destroyed();
    
    AMyCharacter* Player = Cast<AMyCharacter>(GetWorld()->GetFirstPlayerController()->GetPawn());
    if (Player)
    {
        Player->AddScore(EnemyScoreValue);
    }
}
```

**Exercício:** Implemente um sistema de combo onde o jogador ganha pontos extras por derrotar múltiplos inimigos em um curto período. A pontuação adicional deve acumular (ex: 100 + 200 + 300 pontos para 3 inimigos em sequência) mas zerar se o jogador ficar 5 segundos sem derrotar inimigos.

**Solução:**

```cpp
// No .h
FTimerHandle ComboTimerHandle;
int32 ComboCount;

// No .cpp
void AMyCharacter::AddScore(int32 Points)
{
    if (ComboCount > 0)
    {
        Points *= (ComboCount + 1);
    }
    
    PlayerScore += Points;
    ComboCount++;
    UpdateHUD();
    
    GetWorld()->GetTimerManager().ClearTimer(ComboTimerHandle);
    GetWorld()->GetTimerManager().SetTimer(
        ComboTimerHandle, this, &AMyCharacter::ResetCombo, 5.0f, false);
}

void AMyCharacter::ResetCombo()
{
    ComboCount = 0;
}
```