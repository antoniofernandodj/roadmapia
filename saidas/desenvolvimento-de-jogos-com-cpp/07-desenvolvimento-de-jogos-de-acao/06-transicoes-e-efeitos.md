## Transições e efeitos

Um jogo de ação sem transições é como um filme sem cortes - tudo acontece de forma abrupta e desconexa. Quando o jogador entra em uma nova área, morre ou ativa um power-up, a experiência precisa fluir. Veja o que acontece quando tentamos mudar cenas sem transição:

```cpp
// Na classe do jogador, quando colide com um portal
void APlayerCharacter::OnPortalCollision()
{
    UGameplayStatics::OpenLevel(GetWorld(), "NovaFase");
}
```

O resultado é um corte seco que quebra a imersão. Para corrigir isso, a Unreal Engine oferece o `UMatineeActor` para criar sequências de animação que controlam propriedades da cena. Vamos implementar um fade-out suave antes de carregar a nova fase:

```cpp
// Adicione no cabeçalho da classe
#include "Components/TimelineComponent.h"
#include "Curves/CurveFloat.h"

// Declarações na classe
FTimeline FadeTimeline;
UCurveFloat* FadeCurve;

UFUNCTION()
void FadeTimelineProgress(float Value);

// No arquivo .cpp, dentro de BeginPlay()
FadeCurve = Cast<UCurveFloat>(StaticLoadObject(UCurveFloat::StaticClass(), 
    nullptr, TEXT("/Game/Curves/FadeCurve.FadeCurve")));

if (FadeCurve)
{
    FOnTimelineFloat TimelineProgress;
    TimelineProgress.BindUFunction(this, FName("FadeTimelineProgress"));
    FadeTimeline.AddInterpFloat(FadeCurve, TimelineProgress);
    
    FOnTimelineEvent TimelineFinished;
    TimelineFinished.BindUFunction(this, FName("OnFadeComplete"));
    FadeTimeline.SetTimelineFinishedFunc(TimelineFinished);
}

void APlayerCharacter::OnPortalCollision()
{
    FadeTimeline.PlayFromStart();
}

void APlayerCharacter::FadeTimelineProgress(float Value)
{
    // Aplica o fade na tela
    if (APlayerController* PC = Cast<APlayerController>(GetController()))
    {
        PC->PlayerCameraManager->StartCameraFade(0.f, 1.f, 2.f, FLinearColor::Black, false, true);
    }
}

void APlayerCharacter::OnFadeComplete()
{
    UGameplayStatics::OpenLevel(GetWorld(), "NovaFase");
}
```

A curva `FadeCurve` controla a suavidade da transição. Se você esquecer de criá-la no editor, receberá este erro:

```
LogLoad: Warning: Failed to load '/Game/Curves/FadeCurve': Não foi possível encontrar o objeto
```

Para criar a curva, clique direito na pasta Content > Animation > Curve Float. Defina pontos em (0,0) e (1,1) para um fade linear, ou adicione pontos intermediários para efeitos mais elaborados.

Efeitos de pós-processamento são essenciais para momentos especiais, como quando o jogador ativa um power-up. Vamos adicionar um efeito de distorção temporal:

```cpp
// No cabeçalho
#include "Materials/MaterialInstanceDynamic.h"

// Na classe
UMaterialInstanceDynamic* SlowMoMaterial;

// Em BeginPlay()
SlowMoMaterial = UMaterialInstanceDynamic::Create(
    LoadObject<UMaterialInterface>(nullptr, TEXT("/Game/Materials/M_SlowMo.M_SlowMo")), 
    this);

// Quando o power-up é ativado
void APlayerCharacter::ActivateSlowMo()
{
    // Reduz a velocidade do jogo
    UGameplayStatics::SetGlobalTimeDilation(GetWorld(), 0.5f);
    
    // Aplica o material de pós-processamento
    if (APostProcessVolume* Volume = GetWorld()->SpawnActor<APostProcessVolume>())
    {
        Volume->bEnabled = true;
        Volume->Settings.WeightedBlendables.Array.Add(FWeightedBlendable(1.0f, SlowMoMaterial));
        Volume->SetBlendRadius(10000.f);
    }
    
    // Configura um timer para remover o efeito
    GetWorld()->GetTimerManager().SetTimer(SlowMoTimer, this, 
        &APlayerCharacter::DeactivateSlowMo, 5.0f, false);
}

void APlayerCharacter::DeactivateSlowMo()
{
    UGameplayStatics::SetGlobalTimeDilation(GetWorld(), 1.0f);
    
    // Limpa todos os volumes de pós-processamento
    TArray<AActor*> Volumes;
    UGameplayStatics::GetAllActorsOfClass(GetWorld(), APostProcessVolume::StaticClass(), Volumes);
    for (AActor* Volume : Volumes)
    {
        Volume->Destroy();
    }
}
```

Um erro comum é esquecer de restaurar o Time Dilation, deixando o jogo permanentemente lento. Sempre teste efeitos temporais com um timer visível.

Para partículas, como explosões ou rastros de projéteis, o sistema Niagara da Unreal oferece controle programático:

```cpp
// Adicione no cabeçalho
#include "NiagaraFunctionLibrary.h"
#include "NiagaraComponent.h"

// Criação de uma explosão
void AProjectile::Explode()
{
    // Sistema de partículas
    UNiagaraFunctionLibrary::SpawnSystemAtLocation(
        GetWorld(), 
        LoadObject<UNiagaraSystem>(nullptr, TEXT("/Game/Particles/NS_Explosion.NS_Explosion")),
        GetActorLocation(),
        FRotator::ZeroRotator,
        FVector(1.f), true, true, ENCPoolMethod::AutoRelease);
    
    // Destrói o projétil
    Destroy();
}
```

Se o sistema de partículas não for encontrado, você verá:

```
LogNiagara: Error: Failed to find Niagara System '/Game/Particles/NS_Explosion'
```

Exercício: Crie um efeito de "hit flash" que faz o personagem piscar em vermelho ao levar dano. Use um Material Instance Dynamic para modificar a cor do material do personagem temporariamente.

Solução:

```cpp
// Declaração na classe
UMaterialInstanceDynamic* CharacterMaterial;
FTimerHandle FlashTimer;

// Em BeginPlay()
CharacterMaterial = GetMesh()->CreateAndSetMaterialInstanceDynamic(0);

// Quando o personagem leva dano
void APlayerCharacter::TakeDamage(float DamageAmount)
{
    // Piscar vermelho
    CharacterMaterial->SetVectorParameterValue("Color", FLinearColor::Red);
    
    // Configurar timer para voltar à cor normal
    GetWorld()->GetTimerManager().ClearTimer(FlashTimer);
    GetWorld()->GetTimerManager().SetTimer(FlashTimer, [this]()
    {
        CharacterMaterial->SetVectorParameterValue("Color", FLinearColor::White);
    }, 0.1f, false);
}
```