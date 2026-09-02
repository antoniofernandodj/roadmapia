## Distribuição e plataformas

Seu jogo está pronto: os sistemas funcionam, os assets estão otimizados e os testes finais foram aprovados. Agora surge o desafio prático: como levar esse jogo para os jogadores? A distribuição não é apenas "gerar um executável" - cada plataforma exige configurações específicas, formatos de empacotamento diferentes e, em alguns casos, adaptações no código.

Comecemos pelo PC, a plataforma mais direta. Na Unreal Engine, vá para `File > Package Project > Windows (64-bit)`. Antes de clicar, verifique as configurações críticas no `Project Settings > Packaging`:

```cpp
// Configurações básicas no DefaultGame.ini
[/Script/WindowsTargetPlatform.WindowsTargetSettings]
DefaultGraphicsRHI=DefaultGraphicsRHI_DX12
AudioQualityLevel=AAudioQualityLevel_High
```

Um erro comum aparece ao tentar empacotar sem configurar os ícones obrigatórios:

```
LogWindows: Error: Windows packaging failed: Missing application icon (128x128, 32-bit)
```

Corrija adicionando ícones nas dimensões corretas em `Project Settings > Description`. Para testar a build localmente:

```cpp
// Em seu GameInstance.cpp
void UMyGameInstance::OnStart()
{
    Super::OnStart();
    
    #if UE_BUILD_SHIPPING
    UE_LOG(LogTemp, Warning, TEXT("Running shipped version"));
    #else
    UE_LOG(LogTemp, Warning, TEXT("Running development version"));
    #endif
}
```

Para consoles como PlayStation e Xbox, o processo exige SDKs proprietários. Veja como preparar seu código para múltiplas plataformas:

```cpp
// PlatformUtils.h
class PLATFORMUTILS_API FPlatformUtils
{
public:
    static void SaveGame(const FString& SlotName, int32 UserIndex);
    
    #if PLATFORM_PS4
    static void ShowPS4Trophy(int32 TrophyID);
    #elif PLATFORM_XBOXONE
    static void UnlockXboxAchievement(const FString& AchievementID);
    #endif
};
```

Mobile (Android/iOS) traz desafios adicionais de controle de touch e desempenho. Um erro frequente é esquecer de configurar os requisitos mínimos:

```cpp
// DefaultDeviceProfiles.ini
[Android DeviceProfile]
+CVars=r.MobileContentScaleFactor=1.0
+CVars=r.MobileHDR=0

[iOS DeviceProfile]
+CVars=r.MetalShaders=1
```

Para distribuição em lojas digitais, prepare estes arquivos essenciais:
- `Metadata/StoreLogo.png` (300x300)
- `Metadata/Screenshots` (pelo menos 5 imagens 1920x1080)
- `Metadata/Description.txt` (sinopse, requisitos)

**Exercício:** Adapte um sistema de input existente para funcionar tanto com teclado quanto com toque na tela. O código deve detectar automaticamente a plataforma e usar o esquema de controle apropriado.

**Solução:**

```cpp
// InputManager.cpp
void UInputManager::SetupInput()
{
    #if PLATFORM_DESKTOP
    UInputComponent* InputComponent = GetOwner()->InputComponent;
    InputComponent->BindAxis("MoveForward", this, &UInputManager::MoveForward);
    InputComponent->BindAction("Jump", IE_Pressed, this, &UInputManager::Jump);
    #elif PLATFORM_ANDROID || PLATFORM_IOS
    SetupTouchControls();
    #endif
}

void UInputManager::SetupTouchControls()
{
    UInputComponent* TouchComponent = NewObject<UInputComponent>(this);
    TouchComponent->BindTouch(IE_Pressed, this, &UInputManager::TouchStarted);
    TouchComponent->BindTouch(IE_Released, this, &UInputManager::TouchStopped);
    GetOwner()->AddOwnedComponent(TouchComponent);
}
```