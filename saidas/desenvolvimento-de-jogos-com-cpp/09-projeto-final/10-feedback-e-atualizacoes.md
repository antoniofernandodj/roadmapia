## Feedback e atualizações

Seu jogo está funcional, mas agora vem o verdadeiro teste: como ele se comporta quando jogadores reais interagem com ele? Sistemas que pareciam perfeitos durante o desenvolvimento podem revelar falhas inesperadas quando enfrentam a criatividade (ou a agressividade) dos usuários. Vamos implementar um sistema de feedback robusto que coleta dados reais e permite atualizações contínuas.

**O problema clássico**: você lança seu jogo e recebe dezenas de mensagens como "o jogo trava quando eu pulo no inimigo enquanto atiro". Sem logs estruturados, reproduzir esse bug específico será como procurar uma agulha num palheiro.

Vamos criar uma classe `FeedbackSystem` que registra eventos críticos:

```cpp
// FeedbackSystem.h
#pragma once

#include "CoreMinimal.h"
#include "Engine/GameInstance.h"
#include "FeedbackSystem.generated.h"

UCLASS()
class MYGAME_API UFeedbackSystem : public UGameInstance
{
    GENERATED_BODY()
    
public:
    UFUNCTION(BlueprintCallable, Category = "Feedback")
    void LogGameEvent(FString EventType, FString EventData);
    
    UFUNCTION(BlueprintCallable, Category = "Feedback")
    void SendFeedbackToServer(FString PlayerFeedback);
    
private:
    TArray<FString> EventLogs;
    FString GetTimestamp();
};

// FeedbackSystem.cpp
#include "FeedbackSystem.h"
#include "Misc/DateTime.h"

void UFeedbackSystem::LogGameEvent(FString EventType, FString EventData)
{
    FString LogEntry = FString::Printf(TEXT("[%s] %s: %s"), 
        *GetTimestamp(), *EventType, *EventData);
    EventLogs.Add(LogEntry);
    
    // Debug output
    UE_LOG(LogTemp, Display, TEXT("%s"), *LogEntry);
}

FString UFeedbackSystem::GetTimestamp()
{
    return FDateTime::Now().ToString(TEXT("%Y-%m-%d %H:%M:%S"));
}

void UFeedbackSystem::SendFeedbackToServer(FString PlayerFeedback)
{
    // Implementar conexão com servidor de feedback
    UE_LOG(LogTemp, Display, TEXT("Feedback received: %s"), *PlayerFeedback);
}
```

**Implementando na prática**: vamos conectar esse sistema a eventos de jogo reais. Suponha que temos um sistema de combate:

```cpp
// CombatComponent.cpp
void UCombatComponent::HandlePlayerAttack()
{
    // Lógica de ataque normal...
    
    // Log do evento
    UFeedbackSystem* Feedback = GetGameInstance<UFeedbackSystem>();
    if(Feedback)
    {
        Feedback->LogGameEvent(
            TEXT("Combat"), 
            FString::Printf(TEXT("Player attacked at position: %s"), 
                *GetOwner()->GetActorLocation().ToString())
        );
    }
}
```

**Erro comum**: esquecer de inicializar o sistema de feedback. Se você tentar usar sem configurar, receberá:

```
LogTemp: Error: Attempted to access null GameInstance while logging feedback
```

Para corrigir, configure no GameInstance padrão do projeto:

1. Vá em Edit → Project Settings → Maps & Modes
2. Em "Game Instance Class", selecione sua classe `FeedbackSystem`
3. Salve e reinicie o editor

**Coletando feedback dos jogadores**: crie um widget simples para capturar input:

```cpp
// FeedbackWidget.h
UCLASS()
class MYGAME_API UFeedbackWidget : public UUserWidget
{
    GENERATED_BODY()
    
public:
    UFUNCTION(BlueprintCallable)
    void SubmitFeedback(const FString& FeedbackText);
    
    UPROPERTY(meta = (BindWidget))
    class UMultiLineEditableTextBox* FeedbackTextBox;
};

// FeedbackWidget.cpp
void UFeedbackWidget::SubmitFeedback(const FString& FeedbackText)
{
    if(FeedbackText.IsEmpty()) return;
    
    UFeedbackSystem* Feedback = GetGameInstance<UFeedbackSystem>();
    if(Feedback)
    {
        Feedback->SendFeedbackToServer(FeedbackText);
        FeedbackTextBox->SetText(FText::GetEmpty());
    }
}
```

**Implementando atualizações**: quando você recebe feedback suficiente para identificar um problema, precisa distribuir a correção. Vamos implementar um verificador de versão:

```cpp
// VersionChecker.h
UCLASS()
class MYGAME_API UVersionChecker : public UObject
{
    GENERATED_BODY()
    
public:
    void CheckForUpdates();
    
    UFUNCTION()
    void OnUpdateCheckComplete(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful);
    
    UPROPERTY(BlueprintAssignable)
    FOnUpdateAvailable OnUpdateAvailable;
};

// VersionChecker.cpp
void UVersionChecker::CheckForUpdates()
{
    FHttpModule& Http = FHttpModule::Get();
    TSharedRef<IHttpRequest> Request = Http.CreateRequest();
    
    Request->SetURL(TEXT("http://your-server.com/api/version-check"));
    Request->SetVerb(TEXT("GET"));
    Request->OnProcessRequestComplete().BindUObject(this, &UVersionChecker::OnUpdateCheckComplete);
    Request->ProcessRequest();
}

void UVersionChecker::OnUpdateCheckComplete(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful)
{
    if(bWasSuccessful && Response.IsValid())
    {
        // Parse JSON response
        TSharedPtr<FJsonObject> JsonObject;
        TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(Response->GetContentAsString());
        
        if(FJsonSerializer::Deserialize(Reader, JsonObject))
        {
            FString LatestVersion = JsonObject->GetStringField("version");
            FString CurrentVersion = FString::Printf(TEXT("%d.%d"), 
                FEngineVersion::Current().GetMajor(), 
                FEngineVersion::Current().GetMinor());
                
            if(LatestVersion != CurrentVersion)
            {
                OnUpdateAvailable.Broadcast(LatestVersion);
            }
        }
    }
}
```

**Exercício prático**: Implemente um sistema que:
1. Registre quando o jogador morre (incluindo posição e causa)
2. Mostre um popup após 3 mortes pedindo feedback
3. Grave os dados localmente em um arquivo .log

**Solução comentada**:

```cpp
// DeathTrackerComponent.h
UCLASS()
class MYGAME_API UDeathTrackerComponent : public UActorComponent
{
    GENERATED_BODY()
    
public:
    void RegisterDeath(FString Cause);
    
private:
    int32 DeathCount = 0;
    FTimerHandle FeedbackTimerHandle;
};

// DeathTrackerComponent.cpp
void UDeathTrackerComponent::RegisterDeath(FString Cause)
{
    DeathCount++;
    
    UFeedbackSystem* Feedback = GetGameInstance<UFeedbackSystem>();
    if(Feedback)
    {
        Feedback->LogGameEvent(
            TEXT("Death"), 
            FString::Printf(TEXT("Cause: %s, Location: %s"), 
                *Cause, *GetOwner()->GetActorLocation().ToString())
        );
    }
    
    if(DeathCount >= 3)
    {
        GetWorld()->GetTimerManager().SetTimer(
            FeedbackTimerHandle,
            FTimerDelegate::CreateLambda([this](){
                ShowFeedbackPopup();
            }),
            5.0f, // Após 5 segundos
            false
        );
    }
}

void UDeathTrackerComponent::ShowFeedbackPopup()
{
    // Implementar lógica para mostrar widget de feedback
}
```

Este sistema gera logs como:
```
[2023-11-15 14:22:10] Death: Cause: FallDamage, Location: X=1250.0,Y=340.0,Z=-120.0
```