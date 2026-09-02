## Multithreading e concorrência

Imagine seu jogo precisando calcular a inteligência artificial de 50 inimigos enquanto renderiza gráficos complexos e processa a física dos objetos. Se tudo rodar em uma única thread, o jogo vai travar sempre que houver muito processamento. A solução? Distribuir essas tarefas em threads paralelas.

Na Unreal Engine, criamos threads usando a classe `FRunnable`. Veja um exemplo prático para calcular dano em área sem travar o jogo principal:

```cpp
// DamageCalculator.h
#pragma once
#include "CoreMinimal.h"
#include "HAL/Runnable.h"

class DAMAGECALCULATOR_API FDamageCalculator : public FRunnable
{
public:
    FDamageCalculator(const TArray<AActor*>& Targets, float BaseDamage);
    
    virtual bool Init() override;
    virtual uint32 Run() override;
    virtual void Exit() override;
    
    bool IsFinished() const { return bIsFinished; }
    TArray<float> GetResults() const { return DamageResults; }

private:
    TArray<AActor*> TargetsToDamage;
    float DamageAmount;
    TArray<float> DamageResults;
    bool bIsFinished = false;
};
```

```cpp
// DamageCalculator.cpp
#include "DamageCalculator.h"

FDamageCalculator::FDamageCalculator(const TArray<AActor*>& Targets, float BaseDamage)
    : TargetsToDamage(Targets), DamageAmount(BaseDamage) {}

bool FDamageCalculator::Init()
{
    DamageResults.Empty();
    bIsFinished = false;
    return true;
}

uint32 FDamageCalculator::Run()
{
    for (AActor* Target : TargetsToDamage)
    {
        // Cálculo complexo de dano (exemplo simplificado)
        float FinalDamage = DamageAmount * FMath::FRandRange(0.8f, 1.2f);
        DamageResults.Add(FinalDamage);
        
        // Simula processamento demorado
        FPlatformProcess::Sleep(0.1f);
    }
    
    bIsFinished = true;
    return 0;
}

void FDamageCalculator::Exit()
{
    // Limpeza se necessário
}
```

Para usar esta thread no seu game thread principal:

```cpp
// No seu GameMode ou classe similar
void AMyGameMode::CalculateAreaDamage()
{
    TArray<AActor*> Targets = GetEnemiesInRadius(PlayerCharacter, 500.0f);
    
    // Cria e inicia a thread
    DamageCalcThread = new FDamageCalculator(Targets, 50.0f);
    DamageCalcThreadHandle = FRunnableThread::Create(DamageCalcThread, TEXT("DamageCalculatorThread"));
    
    // Verifica conclusão periodicamente
    GetWorldTimerManager().SetTimer(TimerHandle_CheckDamageCalc, this, 
        &AMyGameMode::OnDamageCalcComplete, 0.1f, true);
}

void AMyGameMode::OnDamageCalcComplete()
{
    if (DamageCalcThread && DamageCalcThread->IsFinished())
    {
        TArray<float> Results = DamageCalcThread->GetResults();
        ApplyDamageToEnemies(Results);
        
        // Limpeza
        DamageCalcThreadHandle->Kill();
        delete DamageCalcThread;
        DamageCalcThread = nullptr;
        
        GetWorldTimerManager().ClearTimer(TimerHandle_CheckDamageCalc);
    }
}
```

Erro comum: tentar acessar dados da thread principal diretamente da worker thread. A Unreal vai detectar isso e lançar um erro:

```
Assertion failed: IsInGameThread() 
[File:Runtime/Core/Public/Containers/Array.h] [Line: 558]
Array access in unsafe thread context!
```

A solução é usar `AsyncTask` para comunicação segura entre threads:

```cpp
// Na worker thread:
AsyncTask(ENamedThreads::GameThread, [this]()
{
    // Este código roda na thread principal
    OnDamageCalculationComplete.Broadcast(DamageResults);
});
```

Para tarefas mais simples, a Unreal oferece `Async`:

```cpp
// Carregamento assíncrono de textura
Async(EAsyncExecution::ThreadPool, [this]()
{
    UTexture2D* LoadedTexture = LoadTextureFromDisk(TexturePath);
    AsyncTask(ENamedThreads::GameThread, [this, LoadedTexture]()
    {
        ApplyLoadedTexture(LoadedTexture);
    });
});
```

Exercício: Modifique o sistema de pathfinding existente para calcular rotas em uma thread separada. Mantenha o inimigo se movendo pela rota atual enquanto a nova rota é calculada. Quando a nova rota estiver pronta, transicione suavemente.

Solução comentada:

```cpp
// 1. Adicione uma variável para armazenar a thread no seu inimigo
FRunnableThread* PathfindingThread = nullptr;
FPathCalculator* PathCalcRunnable = nullptr;

// 2. Crie uma função para solicitar novo caminho
void AEnemy::RequestNewPath(FVector Destination)
{
    if (PathCalcRunnable == nullptr)
    {
        PathCalcRunnable = new FPathCalculator(CurrentGrid, GetActorLocation(), Destination);
        PathfindingThread = FRunnableThread::Create(PathCalcRunnable, TEXT("PathfindingThread"));
        
        GetWorldTimerManager().SetTimer(PathCheckTimer, this, 
            &AEnemy::OnNewPathReady, 0.1f, true);
    }
}

// 3. Verifique quando o cálculo terminar
void AEnemy::OnNewPathReady()
{
    if (PathCalcRunnable && PathCalcRunnable->IsFinished())
    {
        TArray<FVector> NewPath = PathCalcRunnable->GetResult();
        SmoothTransitionToNewPath(NewPath);
        
        // Limpeza
        PathfindingThread->Kill();
        delete PathCalcRunnable;
        PathCalcRunnable = nullptr;
    }
}
```