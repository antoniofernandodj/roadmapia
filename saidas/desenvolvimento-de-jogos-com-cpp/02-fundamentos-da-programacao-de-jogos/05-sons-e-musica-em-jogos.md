## Sons e música em jogos

Imagine um jogo onde o personagem pula, mas não há som de salto. Ou um cenário sem música ambiente. Parece incompleto, não? Sons são tão essenciais quanto os gráficos para a imersão. Vamos implementar um sistema simples de áudio no Unreal Engine usando C++.

Primeiro, precisamos preparar nosso projeto. No Unreal Editor:

1. Crie uma pasta `Sounds` no Content Browser
2. Importe seus arquivos de áudio (formatos .wav ou .ogg)
3. Clique com o botão direito em cada som e selecione "Create Sound"

Vamos começar com um efeito sonoro básico para quando o personagem pula. Suponha que já temos um character chamado `MyCharacter` com movimento básico implementado.

```cpp
// MyCharacter.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "Components/AudioComponent.h"
#include "Sound/SoundBase.h"
#include "MyCharacter.generated.h"

UCLASS()
class MYGAME_API AMyCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    // Construtor
    AMyCharacter();

    // Componente de áudio
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Audio")
    UAudioComponent* AudioComponent;

    // Som do pulo
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Audio")
    USoundBase* JumpSound;

    // Função para pular
    void Jump() override;
};
```

No arquivo .cpp correspondente:

```cpp
// MyCharacter.cpp
#include "MyCharacter.h"

AMyCharacter::AMyCharacter()
{
    // Cria o componente de áudio
    AudioComponent = CreateDefaultSubobject<UAudioComponent>(TEXT("AudioComponent"));
    AudioComponent->SetupAttachment(RootComponent);
}

void AMyCharacter::Jump()
{
    Super::Jump();

    // Toca o som do pulo se existir
    if (JumpSound && AudioComponent)
    {
        AudioComponent->SetSound(JumpSound);
        AudioComponent->Play();
    }
}
```

Um erro comum é esquecer de inicializar o `AudioComponent` no construtor ou tentar tocar um som sem verificar se ele foi carregado corretamente. Se você esquecer essas verificações, pode receber erros como:

```
LogAudio: Warning: Failed to play sound. Sound is null.
LogAudio: Error: AudioComponent is not valid.
```

Para configurar a música de fundo, vamos criar um `GameMode` que gerencia a trilha sonora principal:

```cpp
// MyGameMode.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "MyGameMode.generated.h"

UCLASS()
class MYGAME_API AMyGameMode : public AGameModeBase
{
    GENERATED_BODY()

public:
    AMyGameMode();

    // Trilha sonora principal
    UPROPERTY(EditAnywhere, Category = "Audio")
    class USoundBase* BackgroundMusic;

    // Componente de áudio para a música
    UPROPERTY()
    class UAudioComponent* MusicComponent;

protected:
    virtual void BeginPlay() override;
};
```

E sua implementação:

```cpp
// MyGameMode.cpp
#include "MyGameMode.h"
#include "Components/AudioComponent.h"
#include "Sound/SoundBase.h"

AMyGameMode::AMyGameMode()
{
    MusicComponent = CreateDefaultSubobject<UAudioComponent>(TEXT("MusicComponent"));
}

void AMyGameMode::BeginPlay()
{
    Super::BeginPlay();

    if (BackgroundMusic && MusicComponent)
    {
        MusicComponent->SetSound(BackgroundMusic);
        MusicComponent->SetVolumeMultiplier(0.5f); // Volume mais baixo que efeitos
        MusicComponent->bLoop = true; // Repete continuamente
        MusicComponent->Play();
    }
}
```

Se você tentar tocar a música sem configurar `bLoop` como verdadeiro, ela tocará apenas uma vez. Outro erro comum é definir um volume muito alto (acima de 1.0), o que pode causar distorção.

Para controlar volumes e pausar sons durante o jogo, podemos adicionar estas funções ao `GameMode`:

```cpp
// MyGameMode.h - adicione essas funções
public:
    UFUNCTION(BlueprintCallable, Category = "Audio")
    void SetMusicVolume(float Volume);

    UFUNCTION(BlueprintCallable, Category = "Audio")
    void PauseAllSounds(bool bPause);
```

```cpp
// MyGameMode.cpp
void AMyGameMode::SetMusicVolume(float Volume)
{
    if (MusicComponent)
    {
        // Limita o volume entre 0 e 1
        float ClampedVolume = FMath::Clamp(Volume, 0.0f, 1.0f);
        MusicComponent->SetVolumeMultiplier(ClampedVolume);
    }
}

void AMyGameMode::PauseAllSounds(bool bPause)
{
    if (bPause)
    {
        UGameplayStatics::SetSoundMixClassOverride(this, nullptr, 0.0f, 1.0f, 0.0f);
    }
    else
    {
        UGameplayStatics::ClearSoundMixClassOverrides(this);
    }
}
```

**Exercício**: Implemente um sistema onde um som especial toca sempre que o jogador coleta um item. Crie uma classe `CollectibleItem` com um som de coleta e faça-o tocar quando o jogador colidir com o item.

**Solução**:

```cpp
// CollectibleItem.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Sound/SoundBase.h"
#include "CollectibleItem.generated.h"

UCLASS()
class MYGAME_API ACollectibleItem : public AActor
{
    GENERATED_BODY()
    
public:    
    ACollectibleItem();

    // Som ao coletar
    UPROPERTY(EditAnywhere, Category = "Audio")
    USoundBase* CollectSound;

    UFUNCTION()
    void OnCollected(AActor* OtherActor);

protected:
    virtual void BeginPlay() override;
};
```

```cpp
// CollectibleItem.cpp
#include "CollectibleItem.h"
#include "Components/SphereComponent.h"
#include "Kismet/GameplayStatics.h"

ACollectibleItem::ACollectibleItem()
{
    // Cria um colisor simples
    USphereComponent* SphereCollider = CreateDefaultSubobject<USphereComponent>(TEXT("Collider"));
    RootComponent = SphereCollider;
    SphereCollider->SetSphereRadius(50.0f);
    SphereCollider->SetCollisionProfileName(FName("OverlapAllDynamic"));
}

void ACollectibleItem::BeginPlay()
{
    Super::BeginPlay();
    
    // Configura o evento de colisão
    GetRootComponent()->OnComponentBeginOverlap.AddDynamic(this, &ACollectibleItem::OnCollected);
}

void ACollectibleItem::OnCollected(AActor* OtherActor)
{
    // Verifica se é o jogador
    if (OtherActor->IsA(APawn::StaticClass()))
    {
        if (CollectSound)
        {
            UGameplayStatics::PlaySoundAtLocation(this, CollectSound, GetActorLocation());
        }
        Destroy();
    }
}
```