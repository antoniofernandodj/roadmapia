## Marketing e divulgação

Seu jogo está pronto, mas como fazer com que jogadores o descubram? Um trailer mal otimizado pode ser o motivo pelo qual seu jogo passa despercebido nas lojas digitais. Vamos criar um sistema básico de compartilhamento em C++ que gera automaticamente capturas de tela para promoção.

Primeiro, implemente uma função que captura a tela do jogo:

```cpp
// No arquivo MyGameInstance.h
public:
    UFUNCTION(BlueprintCallable, Category = "Marketing")
    void CaptureForPromotion(const FString& ScreenshotName);

// No arquivo MyGameInstance.cpp
void UMyGameInstance::CaptureForPromotion(const FString& ScreenshotName)
{
    if (GEngine && GEngine->GameViewport)
    {
        FString Path = FPaths::ProjectSavedDir() + "Promo/";
        IFileManager::Get().MakeDirectory(*Path, true);
        
        FString FinalPath = Path + ScreenshotName + ".png";
        FScreenshotRequest::RequestScreenshot(FinalPath, false, false);
        
        UE_LOG(LogTemp, Display, TEXT("Screenshot saved to: %s"), *FinalPath);
    }
}
```

Chame esta função durante momentos-chave do jogo, como após derrotar um chefe:

```cpp
// Quando o jogador derrota um chefe
if (PlayerDefeatedBoss())
{
    FString Timestamp = FDateTime::Now().ToString();
    GetGameInstance()->CaptureForPromotion(FString::Printf(TEXT("BossDefeat_%s"), *Timestamp));
}
```

A saída no log será:
```
LogTemp: Display: Screenshot saved to: C:/MyGame/Saved/Promo/BossDefeat_2023.11.15-14.30.22.png
```

Erro comum: esquecer de criar o diretório antes de salvar. Sem `MakeDirectory`, você verá:
```
LogTemp: Error: Failed to save screenshot - path does not exist
```

Agora, vamos automatizar o compartilhamento. Implemente uma função para enviar para redes sociais:

```cpp
// Adicione no MyGameInstance.h
UFUNCTION(BlueprintCallable, Category = "Marketing")
void ShareOnTwitter(const FString& ImagePath, const FString& Message);

// Implementação
void UMyGameInstance::ShareOnTwitter(const FString& ImagePath, const FString& Message)
{
    FString AbsolutePath = IFileManager::Get().ConvertToAbsolutePathForExternalAppForRead(*ImagePath);
    FString Url = FString::Printf(TEXT("https://twitter.com/intent/tweet?text=%s&url=%s"), 
        *FGenericPlatformHttp::UrlEncode(Message),
        *FGenericPlatformHttp::UrlEncode(AbsolutePath));
    
    FPlatformProcess::LaunchURL(*Url, nullptr, nullptr);
}
```

Chamada de exemplo:
```cpp
ShareOnTwitter(
    "C:/MyGame/Saved/Promo/BossDefeat_2023.11.15-14.30.22.png",
    "Acabei de derrotar o chefe final no MyGame! #IndieGame"
);
```

Para métricas básicas, implemente um sistema de tracking:

```cpp
// Estrutura para armazenar dados
struct FPlayerEngagementData
{
    int32 SessionCount;
    float AveragePlayTime;
    TArray<FString> SharedMoments;
};

// Função para salvar métricas
void UMyGameInstance::SaveEngagementData(const FPlayerEngagementData& Data)
{
    FString JsonString;
    FJsonObjectConverter::UStructToJsonObjectString(Data, JsonString);
    
    FString Path = FPaths::ProjectSavedDir() + "Analytics/Engagement.json";
    FFileHelper::SaveStringToFile(JsonString, *Path);
}
```

Exercício: Modifique o sistema de captura para incluir a pontuação do jogador na imagem. Solução:

```cpp
void UMyGameInstance::CaptureWithScore(const FString& ScreenshotName, int32 PlayerScore)
{
    // Captura normal
    CaptureForPromotion(ScreenshotName);
    
    // Processa a imagem para adicionar texto
    FString ImagePath = FPaths::ProjectSavedDir() + "Promo/" + ScreenshotName + ".png";
    FImageUtils::AddTextToImage(
        ImagePath, 
        FString::Printf(TEXT("Score: %d"), PlayerScore),
        FVector2D(50, 50), // Posição
        FLinearColor::White,
        24 // Tamanho da fonte
    );
}
```