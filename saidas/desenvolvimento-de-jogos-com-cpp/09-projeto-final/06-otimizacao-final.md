## Otimização final

Seu jogo está funcional, com todos os sistemas implementados, mas algo não está certo. Durante o teste, você nota que os FPS caem quando muitos inimigos aparecem na tela, ou que há microlag ao carregar novas áreas. Esses são sintomas clássicos de problemas de performance que precisam ser resolvidos antes da versão final.

### Identificando gargalos

A Unreal Engine fornece ferramentas poderosas para análise de performance. Vamos começar usando o Stat Unit:

```cpp
// No arquivo GameMode.cpp
void AMyGameMode::BeginPlay()
{
    Super::BeginPlay();
    
    // Ativa as estatísticas de performance
    UKismetSystemLibrary::ExecuteConsoleCommand(GetWorld(), TEXT("stat unit"));
}
```

Ao executar o jogo, você verá no canto superior esquerdo uma saída como:

```
Frame: 16.6ms (60.1 fps)
Game: 5.2ms
Draw: 8.7ms
GPU: 10.4ms
```

Isso mostra onde está o gargalo:
- Se `Game` é alto: lógica do jogo está pesada (IA, física, etc.)
- Se `Draw` é alto: muitos objetos sendo renderizados
- Se `GPU` é alto: shaders ou efeitos visuais complexos

### Otimizando a renderização

Para problemas de renderização, o primeiro passo é reduzir chamadas desnecessárias. Vamos criar um sistema de culling que só renderiza o que está visível:

```cpp
// No arquivo MyActor.cpp
void AMyActor::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    // Calcula distância até o jogador
    float DistanceToPlayer = FVector::Dist(GetActorLocation(), 
        GetWorld()->GetFirstPlayerController()->GetPawn()->GetActorLocation());

    // Desativa renderização se muito longe
    bool bShouldRender = DistanceToPlayer < RenderDistance;
    
    GetMesh()->SetVisibility(bShouldRender);
    GetMesh()->SetCollisionEnabled(bShouldRender ? ECollisionEnabled::QueryAndPhysics 
                                              : ECollisionEnabled::NoCollision);
}
```

Isso reduz drasticamente o trabalho da GPU, especialmente em cenas com muitos objetos. Teste diferentes valores para `RenderDistance` (1000 a 5000 unidades costumam funcionar bem).

### Pool de objetos

Instanciar e destruir objetos constantemente causa gargalos. A solução é criar pools de objetos:

```cpp
// No arquivo ObjectPool.h
class UObjectPool : public UObject
{
    GENERATED_BODY()
    
public:
    void Initialize(TSubclassOf<AActor> ActorClass, int32 Size);
    AActor* GetPooledObject();
    void ReturnPooledObject(AActor* Actor);
    
private:
    TArray<AActor*> Pool;
    TSubclassOf<AActor> PooledActorClass;
};

// No arquivo ObjectPool.cpp
void UObjectPool::Initialize(TSubclassOf<AActor> ActorClass, int32 Size)
{
    PooledActorClass = ActorClass;
    for(int32 i = 0; i < Size; i++)
    {
        AActor* NewActor = GetWorld()->SpawnActor<AActor>(PooledActorClass);
        NewActor->SetActorHiddenInGame(true);
        NewActor->SetActorEnableCollision(false);
        Pool.Add(NewActor);
    }
}

AActor* UObjectPool::GetPooledObject()
{
    for(AActor* Actor : Pool)
    {
        if(Actor->IsHidden())
        {
            Actor->SetActorHiddenInGame(false);
            Actor->SetActorEnableCollision(true);
            return Actor;
        }
    }
    return nullptr;
}
```

Use assim para inimigos:

```cpp
// Inicialização (no GameMode)
EnemyPool->Initialize(EnemyClass, 20);

// Quando precisar de um inimigo
AActor* NewEnemy = EnemyPool->GetPooledObject();
if(NewEnemy)
{
    NewEnemy->SetActorLocation(SpawnLocation);
}
```

### Otimizando a física

Física mal configurada é um dos maiores vilões da performance. Para objetos que não precisam de física precisa:

```cpp
// No construtor do seu ator
GetStaticMeshComponent()->SetCollisionProfileName(TEXT("OverlapAll"));
GetStaticMeshComponent()->SetSimulatePhysics(false);
```

Use colisões simples quando possível:

```cpp
// Substitua caixas de colisão complexas por versões simplificadas
UBoxComponent* CollisionBox = CreateDefaultSubobject<UBoxComponent>(TEXT("CollisionBox"));
CollisionBox->InitBoxExtent(FVector(50, 50, 50));
CollisionBox->SetCollisionProfileName(TEXT("BlockAll"));
CollisionBox->SetupAttachment(RootComponent);
```

### Otimizando updates

Nem tudo precisa atualizar a cada frame. Para sistemas que podem rodar menos frequentemente:

```cpp
// No header
FTimerHandle TimerHandle;

// Na implementação
GetWorld()->GetTimerManager().SetTimer(TimerHandle, this, 
    &AMyActor::UpdateLessCriticalSystem, 0.2f, true);
```

### Exercício prático

Implemente um sistema que mostra o número de objetos ativos na cena e seu impacto na performance:

```cpp
// No HUD ou GameMode
void AMyHUD::DrawHUD()
{
    Super::DrawHUD();
    
    int32 ActorCount = 0;
    int32 RenderCount = 0;
    for(TActorIterator<AActor> It(GetWorld()); It; ++It)
    {
        ActorCount++;
        if(It->IsHidden() == false) RenderCount++;
    }
    
    FString PerfText = FString::Printf(TEXT("Objetos: %d (Render: %d) - FPS: %.1f"), 
        ActorCount, RenderCount, 1.f / GetWorld()->GetDeltaSeconds());
    
    DrawText(PerfText, FLinearColor::White, 50, 50);
}
```

Solução comentada:
1. `TActorIterator` percorre todos os atores na cena
2. Contamos o total e quantos estão sendo renderizados
3. Calculamos o FPS atual invertendo o delta time
4. Exibimos tudo na tela com `DrawText`