## Feedback e atualizações

Seu jogo está pronto, os testes foram concluídos e você o publicou. Mas eis que chegam os primeiros relatos: "O personagem fica preso no canto da fase 3" ou "O jogo fecha sozinho depois de 20 minutos". Esses são problemas reais que só aparecem quando centenas de jogadores interagem com seu sistema de maneiras imprevistas. É aqui que um fluxo eficiente de feedback e atualizações se torna crucial.

Vamos implementar um sistema que coleta relatos automaticamente e permite enviar correções diretamente para os jogadores. Na Unreal Engine, começamos criando um objeto de jogo dedicado:

```cpp
// Arquivo: FeedbackManager.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "FeedbackManager.generated.h"

UCLASS()
class MEUJOGO_API AFeedbackManager : public AActor
{
    GENERATED_BODY()
    
public:    
    AFeedbackManager();

    UFUNCTION(BlueprintCallable, Category = "Feedback")
    void SubmitFeedback(const FString& PlayerID, const FString& Message);

    UFUNCTION(BlueprintCallable, Category = "Updates")
    bool CheckForUpdates();

    UFUNCTION(BlueprintCallable, Category = "Updates")
    void ApplyUpdate(const FString& UpdateURL);

private:
    TMap<FString, FString> PendingUpdates;
};
```

```cpp
// Arquivo: FeedbackManager.cpp
#include "FeedbackManager.h"
#include "HttpModule.h"
#include "Interfaces/IHttpRequest.h"
#include "Interfaces/IHttpResponse.h"

AFeedbackManager::AFeedbackManager()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AFeedbackManager::SubmitFeedback(const FString& PlayerID, const FString& Message)
{
    FString Report = FString::Printf(TEXT("Player: %s\nIssue: %s"), *PlayerID, *Message);
    UE_LOG(LogTemp, Warning, TEXT("%s"), *Report);
    
    // Envia para servidor remoto
    TSharedRef<IHttpRequest> Request = FHttpModule::Get().CreateRequest();
    Request->SetURL("http://seuservidor.com/feedback");
    Request->SetVerb("POST");
    Request->SetContentAsString(Report);
    Request->ProcessRequest();
}

bool AFeedbackManager::CheckForUpdates()
{
    TSharedRef<IHttpRequest> Request = FHttpModule::Get().CreateRequest();
    Request->OnProcessRequestComplete().BindUObject(this, &AFeedbackManager::OnUpdateCheckComplete);
    Request->SetURL("http://seuservidor.com/updates/latest");
    Request->SetVerb("GET");
    Request->ProcessRequest();
    return true;
}

void AFeedbackManager::OnUpdateCheckComplete(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful)
{
    if (bWasSuccessful && Response.IsValid())
    {
        FString UpdateData = Response->GetContentAsString();
        // Processa resposta JSON aqui
    }
}

void AFeedbackManager::ApplyUpdate(const FString& UpdateURL)
{
    // Lógica para baixar e aplicar atualização
}
```

Um erro comum é esquecer de configurar as permissões de HTTP no arquivo `DefaultEngine.ini`:

```
[HTTP]
bEnableHttp=true
[/HTTP]
```

Sem isso, você verá o erro:
```
LogHttp: Warning: HTTP requests disabled! Enable with bEnableHttp=true in config
```

Para testar o sistema, adicione um widget de feedback no seu HUD:

```cpp
// No seu arquivo HUD
void AMeuHUD::ShowFeedbackWidget()
{
    if (FeedbackWidgetClass)
    {
        FeedbackWidget = CreateWidget<UFeedbackWidget>(GetWorld(), FeedbackWidgetClass);
        if (FeedbackWidget)
        {
            FeedbackWidget->AddToViewport();
        }
    }
    else
    {
        UE_LOG(LogTemp, Error, TEXT("FeedbackWidgetClass não definido!"));
    }
}
```

Quando jogadores reportam problemas, você pode enviar atualizações sem exigir que baixem o jogo novamente. Veja como carregar novos assets em tempo real:

```cpp
// Carregamento dinâmico de textura
void UMyGameInstance::LoadNewTexture(const FString& TexturePath)
{
    FStreamableManager Streamable;
    TSoftObjectPtr<UTexture2D> TexturePtr(TexturePath);
    
    Streamable.RequestAsyncLoad(TexturePtr.ToSoftObjectPath(), 
        [this, TexturePtr]() 
        {
            UTexture2D* NewTexture = TexturePtr.Get();
            if (NewTexture)
            {
                ApplyNewTextureToMaterials(NewTexture);
            }
        });
}
```

Um exercício prático: modifique o sistema para incluir screenshots automáticas quando um erro é reportado. A solução envolve:

```cpp
// Solução:
void AFeedbackManager::CaptureAndSubmitScreenshot(const FString& PlayerID)
{
    FScreenshotRequest::RequestScreenshot(
        FPaths::ProjectSavedDir() + "FeedbackScreens/" + PlayerID + ".png",
        false, 
        [this, PlayerID](bool bSuccess)
        {
            if (bSuccess)
            {
                SubmitFeedback(PlayerID, "Screenshot anexada automaticamente");
            }
        }
    );
}
```