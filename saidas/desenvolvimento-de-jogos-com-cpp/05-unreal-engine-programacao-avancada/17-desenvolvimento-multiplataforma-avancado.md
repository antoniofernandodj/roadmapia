## Desenvolvimento multiplataforma avançado

Quando seu jogo precisa rodar em PC, consoles e dispositivos móveis, cada plataforma exige adaptações específicas. A Unreal Engine abstrai muitas dessas diferenças, mas você ainda precisa estruturar seu código para lidar com variações de hardware, controles e sistemas operacionais.

### O problema das plataformas diferentes

Considere um sistema de salvamento de progresso. No PC você pode gravar em qualquer pasta, enquanto consoles têm sistemas de armazenamento restritos. Um código ingênuo como este falharia:

```cpp
void UGameSaveSystem::SaveGame(FString SaveData)
{
    FString Path = FPaths::ProjectDir() + TEXT("/Saves/GameSave.sav");
    FFileHelper::SaveStringToFile(SaveData, *Path);
}
```

No PlayStation, isso geraria o erro:
```
Failed to save file: /Saves/GameSave.sav (Error: Access Denied)
```

### Solução: usando os utilitários de plataforma

A Unreal fornece `FPlatformMisc` e `FPaths` para lidar com essas diferenças. O código correto seria:

```cpp
void UGameSaveSystem::SaveGame(FString SaveData)
{
    FString Path = FPaths::ProjectSavedDir() + TEXT("SaveGames/");
    
    if (!FPlatformFileManager::Get().GetPlatformFile().DirectoryExists(*Path))
    {
        FPlatformFileManager::Get().GetPlatformFile().CreateDirectory(*Path);
    }
    
    Path += TEXT("GameSave.sav");
    FFileHelper::SaveStringToFile(SaveData, *Path);
}
```

Isso funciona em todas as plataformas porque:
1. `ProjectSavedDir()` aponta para a pasta correta em cada SO
2. Verificamos e criamos o diretório se necessário
3. Usamos o gerenciador de arquivos da plataforma

### Controles multiplataforma

Outro desafio é a entrada do jogador. Considere este trecho problemático:

```cpp
void APlayerCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &APlayerCharacter::Jump);
}
```

Isso assume que todas as plataformas têm um botão "Jump" mapeado. Na prática, você precisa:

```cpp
void APlayerCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    if (FPlatformMisc::GetPlatformType() == FPlatformType::Windows)
    {
        PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &APlayerCharacter::Jump);
    }
    else if (FPlatformMisc::GetPlatformType() == FPlatformType::Android)
    {
        PlayerInputComponent->BindTouch(IE_Pressed, this, &APlayerCharacter::HandleTouchJump);
    }
    // ... outros casos
}
```

### Resolução de assets

Dispositivos móveis precisam de texturas menores. A Unreal permite configurar isso via `UPackageSettings`:

```cpp
void UGameAssetManager::InitializeRuntimeSettings()
{
    if (FPlatformMisc::GetPlatformType() == FPlatformType::Android ||
        FPlatformMisc::GetPlatformType() == FPlatformType::IOS)
    {
        TextureQuality = 0.5f; // Reduz qualidade para móveis
    }
    else
    {
        TextureQuality = 1.0f; // Qualidade máxima para PC/console
    }
}
```

### Builds condicionais

Para código específico de plataforma, use macros de compilação:

```cpp
void UGamePerformance::OptimizeForPlatform()
{
    #if PLATFORM_DESKTOP
        // Configurações para PC/console
        MaxParticles = 10000;
    #elif PLATFORM_ANDROID
        // Configurações para Android
        MaxParticles = 2000;
    #endif
}
```

### Exercício: Sistema de Notificações Multiplataforma

Crie uma classe `UNotificationSystem` que:
1. Mostra notificações nativas no mobile
2. Usa widgets na tela no PC/console
3. Loga mensagens no editor

Solução comentada:

```cpp
UCLASS()
class MYGAME_API UNotificationSystem : public UObject
{
    GENERATED_BODY()
    
public:
    void ShowNotification(const FString& Message)
    {
        #if PLATFORM_ANDROID || PLATFORM_IOS
            FPlatformMisc::PlatformNotification(Message);
        #elif PLATFORM_DESKTOP
            if (GEngine)
            {
                GEngine->AddOnScreenDebugMessage(-1, 5.0f, FColor::Green, Message);
            }
        #endif
        
        UE_LOG(LogTemp, Log, TEXT("Notification: %s"), *Message);
    }
};
```