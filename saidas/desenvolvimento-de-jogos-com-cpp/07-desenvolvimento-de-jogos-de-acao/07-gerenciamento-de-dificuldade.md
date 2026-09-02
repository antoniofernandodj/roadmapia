## Gerenciamento de dificuldade

Um jogo de ação que mantém sempre a mesma dificuldade rapidamente se torna previsível - ou frustrantemente difícil para jogadores iniciantes. O segredo está em ajustar dinamicamente os desafios conforme a habilidade do jogador, sem que ele perceba a "mão" do sistema interferindo.

Vamos implementar um sistema escalonável para um shooter 2D, onde os parâmetros de inimigos e cenários se adaptam progressivamente. Começamos com uma classe base para configurar os parâmetros de dificuldade:

```cpp
// DifficultySettings.h
UCLASS(Blueprintable)
class UDifficultySettings : public UDataAsset
{
    GENERATED_BODY()
    
public:
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Enemy")
    float EnemyHealthMultiplier = 1.0f;
    
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Enemy")
    float EnemyDamageMultiplier = 1.0f;
    
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Spawn")
    float SpawnRateMultiplier = 1.0f;
    
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Player")
    float PlayerDamageReceivedMultiplier = 1.0f;
};
```

Agora, criamos o gerenciador principal que controlará a dificuldade atual:

```cpp
// DifficultyManager.h
UCLASS()
class MYGAME_API UDifficultyManager : public UObject
{
    GENERATED_BODY()
    
public:
    void Initialize(const TArray<UDifficultySettings*>& Settings);
    
    UFUNCTION(BlueprintCallable)
    void UpdateDifficulty(float PlayerPerformanceScore);
    
    UFUNCTION(BlueprintPure)
    UDifficultySettings* GetCurrentSettings() const;
    
private:
    UPROPERTY()
    TArray<UDifficultySettings*> DifficultyLevels;
    
    int32 CurrentDifficultyIndex = 0;
};
```

A implementação usa o desempenho do jogador (taxa de acertos, mortes, tempo) para ajustar os parâmetros:

```cpp
// DifficultyManager.cpp
void UDifficultyManager::Initialize(const TArray<UDifficultySettings*>& Settings)
{
    DifficultyLevels = Settings;
    CurrentDifficultyIndex = FMath::Clamp(CurrentDifficultyIndex, 0, DifficultyLevels.Num() - 1);
}

void UDifficultyManager::UpdateDifficulty(float PlayerPerformanceScore)
{
    // Score > 1: jogador indo bem, aumenta dificuldade
    // Score < 1: jogador com dificuldades, reduz desafio
    int32 NewIndex = FMath::RoundToInt(CurrentDifficultyIndex + (PlayerPerformanceScore - 1.0f));
    CurrentDifficultyIndex = FMath::Clamp(NewIndex, 0, DifficultyLevels.Num() - 1);
}

UDifficultySettings* UDifficultyManager::GetCurrentSettings() const
{
    if (DifficultyLevels.IsValidIndex(CurrentDifficultyIndex))
    {
        return DifficultyLevels[CurrentDifficultyIndex];
    }
    return nullptr;
}
```

Para aplicar isso aos inimigos, modificamos a classe base:

```cpp
// EnemyBase.cpp
void AEnemyBase::BeginPlay()
{
    Super::BeginPlay();
    
    UDifficultyManager* DifficultyManager = GetGameInstance()->GetSubsystem<UDifficultyManager>();
    if (DifficultyManager && DifficultyManager->GetCurrentSettings())
    {
        UDifficultySettings* Settings = DifficultyManager->GetCurrentSettings();
        MaxHealth *= Settings->EnemyHealthMultiplier;
        CurrentHealth = MaxHealth;
        AttackDamage *= Settings->EnemyDamageMultiplier;
    }
}
```

Um erro comum é esquecer de inicializar o gerenciador. Se tentarmos acessá-lo sem configuração prévia, receberemos:

```
LogDifficulty: Error: DifficultyManager not initialized! Call Initialize() first.
```

A solução é configurar no GameMode:

```cpp
// MyGameMode.cpp
void AMyGameMode::BeginPlay()
{
    Super::BeginPlay();
    
    UDifficultyManager* DifficultyManager = GetGameInstance()->GetSubsystem<UDifficultyManager>();
    DifficultyManager->Initialize(DifficultyPresets);
}
```

Para calcular o desempenho do jogador, usamos uma fórmula que combina vários fatores:

```cpp
float APlayerCharacter::CalculatePerformanceScore() const
{
    float Accuracy = (ShotsFired > 0) ? (ShotsHit / ShotsFired) : 1.0f;
    float HealthRatio = CurrentHealth / MaxHealth;
    float TimeFactor = FMath::Clamp(GetWorld()->GetTimeSeconds() / 300.0f, 0.5f, 2.0f);
    
    return (Accuracy * 0.6f) + (HealthRatio * 0.3f) + (TimeFactor * 0.1f);
}
```

**Exercício**: Implemente um sistema que reduza temporariamente a dificuldade quando o jogador morre 3 vezes seguidas, retornando gradualmente ao nível original após 5 mortes sem falhas.

```cpp
// Solução:
void UDifficultyManager::HandlePlayerDeath()
{
    DeathCount++;
    if (DeathCount >= 3)
    {
        EmergencyDifficultyReduction = FMath::Clamp(EmergencyDifficultyReduction - 0.2f, 0.5f, 1.0f);
        DeathCount = 0;
        GetWorld()->GetTimerManager().SetTimer(RecoveryTimer, this, 
            &UDifficultyManager::RecoverDifficulty, 5.0f, false);
    }
}

void UDifficultyManager::RecoverDifficulty()
{
    EmergencyDifficultyReduction = FMath::Min(EmergencyDifficultyReduction + 0.1f, 1.0f);
    if (EmergencyDifficultyReduction < 1.0f)
    {
        GetWorld()->GetTimerManager().SetTimer(RecoveryTimer, this, 
            &UDifficultyManager::RecoverDifficulty, 5.0f, false);
    }
}

UDifficultySettings* UDifficultyManager::GetEffectiveSettings() const
{
    UDifficultySettings* BaseSettings = GetCurrentSettings();
    UDifficultySettings* EffectiveSettings = DuplicateObject(BaseSettings, nullptr);
    
    EffectiveSettings->EnemyDamageMultiplier *= EmergencyDifficultyReduction;
    EffectiveSettings->SpawnRateMultiplier *= EmergencyDifficultyReduction;
    
    return EffectiveSettings;
}
```