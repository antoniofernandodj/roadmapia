## Multithreading e concorrência avançados

Num jogo de ação, quando 100 inimigos precisam calcular seus caminhos simultaneamente enquanto o sistema de partículas processa efeitos e a física resolve colisões, tudo precisa acontecer sem travar o frame principal. A Unreal Engine oferece ferramentas poderosas para distribuir esse trabalho entre threads.

### Task Graph System: O coração do paralelismo na UE

O sistema de Task Graph da Unreal divide automaticamente o trabalho em tarefas paralelizáveis. Veja como criar uma tarefa simples para processamento fora da thread principal:

```cpp
// Em MyGameInstance.h
class AMyGameInstance : public UGameInstance
{
    //...
    FGraphEventRef MyTask;
    
    void StartBackgroundTask();
    void OnTaskCompleted();
};

// Em MyGameInstance.cpp
void AMyGameInstance::StartBackgroundTask()
{
    MyTask = FFunctionGraphTask::CreateAndDispatchWhenReady([this]()
    {
        // Código executado em thread background
        int32 Result = 0;
        for(int32 i = 0; i < 1000000; i++) {
            Result += FMath::Rand() % 100;
        }
        
        // Retornar para a thread do jogo
        AsyncTask(ENamedThreads::GameThread, [this]() {
            OnTaskCompleted();
        });
    }, TStatId(), nullptr, ENamedThreads::AnyBackgroundThreadNormalTask);
}

void AMyGameInstance::OnTaskCompleted()
{
    UE_LOG(LogTemp, Warning, TEXT("Tarefa concluída!"));
}
```

Ao executar, você verá no Output Log:
```
LogTemp: Warning: Tarefa concluída!
```

### AsyncTask vs. FRunnable: Quando usar cada um

Para operações simples que precisam voltar à thread principal, `AsyncTask` é ideal. Para processamento pesado contínuo, `FRunnable` oferece mais controle:

```cpp
class FMyRunnable : public FRunnable
{
public:
    virtual uint32 Run() override
    {
        while(!bStopThread)
        {
            // Processamento contínuo
            FPlatformProcess::Sleep(0.1f);
        }
        return 0;
    }
    
    void Stop() { bStopThread = true; }
    
private:
    bool bStopThread = false;
};

// Uso:
FMyRunnable* Runnable = new FMyRunnable();
FRunnableThread* Thread = FRunnableThread::Create(Runnable, TEXT("MyThread"));
// Para parar:
Thread->Kill();
```

Erro comum ao usar FRunnable:
```
Assertion failed: IsInGameThread()
```
Significa que você está tentando acessar objetos da UE de uma thread que não é a principal. A solução é usar `AsyncTask` para retornar à thread do jogo antes de manipular objetos do engine.

### ParallelFor: Processamento em lote eficiente

Para operações em arrays que podem ser paralelizadas, `ParallelFor` é uma ferramenta poderosa:

```cpp
TArray<int32> MyArray;
MyArray.SetNum(1000000);

// Preenchimento sequencial (normal)
for(int32& Value : MyArray) {
    Value = FMath::Rand();
}

// Processamento paralelo
ParallelFor(MyArray.Num(), [&MyArray](int32 Index)
{
    MyArray[Index] = FMath::Sqrt(MyArray[Index]);
});
```

Diferença de desempenho em um teste com 1.000.000 de elementos:
```
Sequencial: 32ms
Paralelo (4 cores): 9ms
```

### Futures e Promises: Sincronização avançada

Para operações assíncronas que retornam valores, a UE oferece `TFuture` e `TPromise`:

```cpp
TFuture<int32> FutureValue = Async(EAsyncExecution::ThreadPool, []()
{
    FPlatformProcess::Sleep(1.0f); // Simula trabalho pesado
    return 42;
});

// Enquanto espera, a thread principal continua executando
if(FutureValue.IsReady())
{
    int32 Result = FutureValue.Get();
    UE_LOG(LogTemp, Warning, TEXT("Resultado: %d"), Result);
}
```

### Exercício prático: Processamento paralelo de inimigos

Implemente um sistema onde cada inimigo calcula seu caminho em paralelo:

1. Crie uma classe `AParallelEnemy` que herda de `ACharacter`
2. No método `Tick`, agende o cálculo do caminho usando `AsyncTask`
3. Armazene o resultado em uma variável segura para threads (`TAtomic`)
4. Atualize a posição do inimigo na thread principal

Solução comentada:

```cpp
// AParallelEnemy.h
class AParallelEnemy : public ACharacter
{
    //...
    TAtomic<bool> bPathReady;
    FVector TargetLocation;
    
    void CalculatePathAsync();
    void OnPathCalculated(FVector Result);
};

// AParallelEnemy.cpp
void AParallelEnemy::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    
    if(!bPathReady)
    {
        CalculatePathAsync();
    }
}

void AParallelEnemy::CalculatePathAsync()
{
    AsyncTask(ENamedThreads::AnyBackgroundThreadNormalTask, [this]()
    {
        FVector Result = FVector::ZeroVector;
        // Cálculo complexo do caminho aqui
        Result = TargetLocation + FVector(FMath::RandRange(-100,100), 0, 0);
        
        AsyncTask(ENamedThreads::GameThread, [this, Result]()
        {
            OnPathCalculated(Result);
        });
    });
}

void AParallelEnemy::OnPathCalculated(FVector Result)
{
    bPathReady = true;
    SetActorLocation(Result);
}
```