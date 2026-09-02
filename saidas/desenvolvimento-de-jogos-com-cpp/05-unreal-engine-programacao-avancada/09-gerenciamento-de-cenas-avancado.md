## Gerenciamento de cenas avançado

Quando seu jogo tem múltiplas fases ou áreas complexas, simplesmente carregar tudo na memória não é viável. A Unreal Engine oferece um sistema robusto para gerenciar cenas através do `UGameInstance`, que persiste durante toda a sessão do jogo, e do `UWorld`, que representa o mundo do jogo atual.

Vamos implementar um sistema onde cada fase é uma subclasse de `ULevelScriptActor`. Primeiro, crie uma classe base para todas as cenas:

```cpp
// SceneBase.h
UCLASS()
class MYGAME_API ASceneBase : public ALevelScriptActor
{
    GENERATED_BODY()
    
public:
    UFUNCTION(BlueprintCallable, Category = "Scene Management")
    virtual void LoadScene() 
    {
        UE_LOG(LogTemp, Warning, TEXT("Base scene loaded"));
    }

    UFUNCTION(BlueprintCallable, Category = "Scene Management")
    virtual void UnloadScene() 
    {
        UE_LOG(LogTemp, Warning, TEXT("Base scene unloaded"));
    }
};
```

Agora, implemente uma cena específica:

```cpp
// ForestScene.h
UCLASS()
class MYGAME_API AForestScene : public ASceneBase
{
    GENERATED_BODY()
    
public:
    virtual void LoadScene() override
    {
        Super::LoadScene();
        // Carrega assets específicos da floresta
        UE_LOG(LogTemp, Warning, TEXT("Forest scene loaded"));
        
        // Exemplo de carregamento de assets
        static ConstructorHelpers::FObjectFinder<UStaticMesh> TreeMesh(TEXT("/Game/Environment/Meshes/SM_Tree"));
        if (TreeMesh.Succeeded())
        {
            TreeAsset = TreeMesh.Object;
        }
    }

    virtual void UnloadScene() override
    {
        // Libera recursos específicos
        TreeAsset = nullptr;
        Super::UnloadScene();
    }

private:
    UStaticMesh* TreeAsset;
};
```

Para gerenciar as transições entre cenas, crie um `SceneManager`:

```cpp
// SceneManager.h
UCLASS()
class MYGAME_API USceneManager : public UObject
{
    GENERATED_BODY()
    
public:
    void Initialize(TSubclassOf<ASceneBase> InitialScene)
    {
        CurrentSceneClass = InitialScene;
        LoadScene(InitialScene);
    }

    void TransitionToScene(TSubclassOf<ASceneBase> NewScene)
    {
        if (CurrentScene)
        {
            CurrentScene->UnloadScene();
        }
        LoadScene(NewScene);
    }

private:
    void LoadScene(TSubclassOf<ASceneBase> SceneClass)
    {
        UWorld* World = GetWorld();
        if (!World) return;

        FActorSpawnParameters SpawnParams;
        SpawnParams.Owner = nullptr;
        SpawnParams.Instigator = nullptr;
        
        CurrentScene = World->SpawnActor<ASceneBase>(SceneClass, FVector::ZeroVector, FRotator::ZeroRotator, SpawnParams);
        if (CurrentScene)
        {
            CurrentScene->LoadScene();
            CurrentSceneClass = SceneClass;
        }
    }

    TSubclassOf<ASceneBase> CurrentSceneClass;
    ASceneBase* CurrentScene;
};
```

Um erro comum é esquecer de limpar os recursos na transição entre cenas. Se você apenas criar uma nova cena sem descarregar a anterior, verá este erro no Output Log:

```
LogTemp: Warning: Previous scene resources still loaded (MemoryLeak)
```

Para usar o gerenciador de cenas, registre-o no `GameInstance`:

```cpp
// MyGameInstance.h
UCLASS()
class MYGAME_API UMyGameInstance : public UGameInstance
{
    GENERATED_BODY()
    
public:
    virtual void Init() override
    {
        Super::Init();
        SceneManager = NewObject<USceneManager>(this);
        SceneManager->Initialize(DefaultSceneClass);
    }

    USceneManager* GetSceneManager() const { return SceneManager; }

private:
    UPROPERTY()
    USceneManager* SceneManager;
    
    UPROPERTY(EditDefaultsOnly, Category = "Scenes")
    TSubclassOf<ASceneBase> DefaultSceneClass;
};
```

Para transicionar entre cenas em qualquer lugar do código:

```cpp
UMyGameInstance* GameInstance = Cast<UMyGameInstance>(GetGameInstance());
if (GameInstance)
{
    GameInstance->GetSceneManager()->TransitionToScene(AForestScene::StaticClass());
}
```

**Exercício**: Crie uma cena de dungeon que carrega um mesh de parede de pedra e um som ambiente ao ser carregada, e os libera ao ser descarregada. Implemente um método adicional `ReloadScene()` no `SceneManager` que recarrega a cena atual.

**Solução**:

```cpp
// DungeonScene.h
UCLASS()
class MYGAME_API ADungeonScene : public ASceneBase
{
    GENERATED_BODY()
    
public:
    virtual void LoadScene() override
    {
        Super::LoadScene();
        
        // Carrega assets da dungeon
        static ConstructorHelpers::FObjectFinder<UStaticMesh> WallMesh(TEXT("/Game/Dungeon/Meshes/SM_StoneWall"));
        static ConstructorHelpers::FObjectFinder<USoundWave> AmbientSound(TEXT("/Game/Dungeon/Sounds/Ambient_Dungeon"));
        
        if (WallMesh.Succeeded()) WallAsset = WallMesh.Object;
        if (AmbientSound.Succeeded()) 
        {
            AmbientSoundAsset = AmbientSound.Object;
            UGameplayStatics::PlaySound2D(this, AmbientSoundAsset);
        }
    }

    virtual void UnloadScene() override
    {
        UGameplayStatics::StopSound2D(this, AmbientSoundAsset);
        WallAsset = nullptr;
        AmbientSoundAsset = nullptr;
        Super::UnloadScene();
    }

private:
    UStaticMesh* WallAsset;
    USoundWave* AmbientSoundAsset;
};

// Adicione em SceneManager.h
void ReloadScene()
{
    if (CurrentSceneClass && CurrentScene)
    {
        CurrentScene->UnloadScene();
        LoadScene(CurrentSceneClass);
    }
}
```