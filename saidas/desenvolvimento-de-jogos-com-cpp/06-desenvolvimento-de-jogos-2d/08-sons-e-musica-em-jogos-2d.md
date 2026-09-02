## Sons e música em jogos 2D

Um jogo sem áudio é como um filme mudo - falta uma dimensão essencial da experiência. Na Unreal Engine, o sistema de áudio 2D é surpreendentemente simples de implementar, mas com alguns detalhes cruciais que fazem a diferença entre um som profissional e um efeito genérico.

Vamos começar com um problema concreto: seu personagem precisa emitir um som ao coletar um item. Primeiro, adicione um arquivo de som (.wav ou .ogg) ao seu projeto na pasta Content/Sounds. Crie uma classe para o item coletável:

```cpp
// Header
UPROPERTY(EditAnywhere, Category = "Audio")
class USoundBase* CollectSound;

// No construtor
static ConstructorHelpers::FObjectFinder<USoundBase> SoundAsset(TEXT("/Game/Sounds/CollectItemSound"));
if (SoundAsset.Succeeded()) {
    CollectSound = SoundAsset.Object;
}
```

Um erro comum é esquecer de marcar a variável do som com `UPROPERTY()`, resultando no erro:
```
unresolved external symbol "private: class USoundBase * Item::CollectSound"
```

Para tocar o som quando o item é coletado, adicione ao seu método de colisão:

```cpp
void ACollectibleItem::OnCollected() {
    if (CollectSound) {
        UGameplayStatics::PlaySound2D(GetWorld(), CollectSound);
    }
    Destroy();
}
```

A saída do sistema de áudio quando tudo funciona deve ser:
```
LogAudio: Display: Playing Sound 2D '/Game/Sounds/CollectItemSound'
```

Para música de fundo, o processo é similar mas com algumas diferenças importantes:

```cpp
// Header
UPROPERTY(EditAnywhere, Category = "Audio")
class USoundBase* BackgroundMusic;

// Ao iniciar o nível
if (BackgroundMusic) {
    UGameplayStatics::PlaySound2D(GetWorld(), BackgroundMusic, 0.5f, 1.0f, 0.0f, nullptr, true);
}
```

Os parâmetros controlam:
1. Volume (0.5f = 50%)
2. Pitch (1.0f = normal)
3. Start time (0.0f = início)
4. Concurrency settings (nullptr = padrão)
5. bPersistAcrossLevelTransition (true = continua entre cenas)

Um problema comum é o som parar abruptamente ao mudar de nível. A solução está no último parâmetro ou no uso de `UGameInstance` para gerenciar sons persistentes.

Para controlar sons programaticamente:

```cpp
// Parar todos os sons 2D
UGameplayStatics::StopAllSounds(GetWorld());

// Alterar volume global
UGameplayStatics::SetSoundMixClassOverride(GetWorld(), MySoundMix, MySoundClass, 0.7f);
```

Exercício: Crie um sistema onde:
1. O volume da música diminui quando o jogador entra em uma área específica
2. Efeitos sonoros de passos são tocados alternadamente a cada movimento

Solução comentada:

```cpp
// No header
UPROPERTY(EditAnywhere, Category = "Audio")
class USoundBase* FootstepSounds[2];

// Ao mover o personagem
void AMyCharacter::PlayFootstep() {
    static int NextFootstep = 0;
    if (FootstepSounds[NextFootstep]) {
        UGameplayStatics::PlaySound2D(GetWorld(), FootstepSounds[NextFootstep], 0.3f);
    }
    NextFootstep = (NextFootstep + 1) % 2;
}

// Na área especial
void ASpecialArea::OnBeginOverlap() {
    UGameplayStatics::SetSoundMixClassOverride(GetWorld(), nullptr, MusicSoundClass, 0.3f, 1.0f, 0.5f);
}
```