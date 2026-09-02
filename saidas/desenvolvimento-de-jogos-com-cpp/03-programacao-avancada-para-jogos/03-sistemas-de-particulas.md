## Sistemas de partículas

Quando seu personagem pisa em uma poça d'água, você quer que os respingos pareçam reais. Quando uma explosão acontece, cada faísca deve seguir uma trajetória física convincente. Sistemas de partículas são a solução para esses efeitos, simulando milhares de pequenos elementos que juntos criam fenômenos complexos como fogo, fumaça ou líquidos.

Na Unreal Engine, criamos um sistema de partículas com o módulo Niagara. Vamos começar com um efeito simples: faíscas de uma fogueira. Primeiro, crie um novo sistema Niagara:

1. Clique com o botão direito no Content Browser
2. Selecione FX > Niagara System
3. Escolha "Empty System" e nomeie como "NS_FireSparks"

Dentro do sistema, adicione um emitter (o gerador de partículas) clicando no botão "+" e selecione "Sprite Renderer" para partículas 2D. Agora configure as propriedades básicas:

```cpp
// No módulo Initialize Particle:
Velocity = FVector(0, 0, 100) + FMath::VRand() * 50;
Color = FLinearColor(1.0f, 0.5f, 0.0f);
Size = FVector2D(5.0f, 5.0f);
Lifetime = 1.0f;

// No módulo Update Particle:
Velocity.Z -= 980.0f * DeltaTime;
Color.A = 1.0f - (Age / Lifetime);
```

Este código faz cada partícula:
- Nascer subindo rápido (100 unidades/segundo no eixo Z)
- Ter um movimento aleatório inicial (VRand() * 50)
- Ser laranja (RGB 1.0, 0.5, 0.0)
- Medir 5x5 pixels
- "Viver" por 1 segundo
- Perder velocidade devido à gravidade (980 unidades/segundo²)
- Desaparecer gradualmente (alfa diminui com a idade)

Um erro comum é esquecer de multiplicar a gravidade por DeltaTime, o que faz as partículas acelerarem muito rápido. A mensagem de erro não será clara - o efeito simplesmente parecerá "estranho". Sempre lembre: forças contínuas devem ser multiplicadas pelo tempo do frame.

Para disparar esse efeito no jogo, adicione no código do seu ator (por exemplo, onde ocorre a explosão):

```cpp
// No cabeçalho:
#include "NiagaraFunctionLibrary.h"

// No corpo da função:
UNiagaraFunctionLibrary::SpawnSystemAtLocation(
    GetWorld(), 
    FireSparksSystem, 
    GetActorLocation(), 
    FRotator::ZeroRotator, 
    FVector(1.0f), 
    true, 
    true, 
    ENCPoolMethod::AutoRelease
);
```

Parâmetros importantes:
- FireSparksSystem: referência ao asset NS_FireSparks que criamos
- GetActorLocation(): onde as partículas surgirão
- FVector(1.0f): escala normal (aumente para partículas maiores)

Um exercício prático: modifique o sistema para criar um rastro de partículas atrás de um projétil. Dica: você precisará:

1. Criar um novo sistema com emissão contínua
2. Anexá-lo ao projétil usando AttachToComponent
3. Configurar Velocity para seguir a direção do projétil (GetVelocity())

Solução comentada:

```cpp
// 1. Crie um sistema Niagara chamado "NS_BulletTrail" com:
// - Velocidade inicial: Particle.Velocity = Emitter.Direction * 1000
// - Vida útil curta: Particle.Lifetime = 0.2f
// - Tamanho que encolhe: Particle.Size = 10.0f * (1 - Age/Lifetime)

// 2. No projétil:
UNiagaraComponent* Trail = UNiagaraFunctionLibrary::SpawnSystemAttached(
    BulletTrailSystem,
    GetRootComponent(),
    NAME_None,
    FVector::ZeroVector,
    FRotator::ZeroRotator,
    EAttachLocation::KeepRelativeOffset,
    true
);

// 3. Atualize a direção a cada frame:
Trail->SetVectorParameter("Emitter.Direction", GetVelocity());
```

Isso criará partículas que sempre acompanham a trajetória atual do projétil, dando a impressão de movimento rápido.