## Colisões e física 2D

Quando um personagem pula sobre uma plataforma ou um projétil atinge um inimigo, o jogo precisa detectar esses contatos para reagir adequadamente. Vamos implementar um sistema de colisão simples para um jogo de plataforma 2D na Unreal Engine.

Comece criando uma nova classe `APlatformerCharacter` que herda de `ACharacter`. Adicione um componente de colisão do tipo `UCapsuleComponent` como raiz:

```cpp
APlatformerCharacter::APlatformerCharacter()
{
    // Configuração do componente de colisão
    GetCapsuleComponent()->InitCapsuleSize(42.f, 96.0f);
    GetCapsuleComponent()->SetCollisionProfileName(TEXT("Pawn"));
    
    // Sprite do personagem
    Sprite = CreateDefaultSubobject<UPaperSpriteComponent>(TEXT("Sprite"));
    Sprite->SetupAttachment(RootComponent);
    Sprite->SetCollisionEnabled(ECollisionEnabled::NoCollision);
}
```

Um erro comum é esquecer de definir o perfil de colisão (`CollisionProfile`). Se você tentar mover o personagem sem isso, receberá o erro:

```
LogCollision: Warning: No CollisionProfile was specified for 'Pawn'
```

Para plataformas estáticas, crie uma classe `APlatform` com um `BoxComponent`:

```cpp
APlatform::APlatform()
{
    // Componente de colisão para a plataforma
    CollisionBox = CreateDefaultSubobject<UBoxComponent>(TEXT("CollisionBox"));
    RootComponent = CollisionBox;
    CollisionBox->SetCollisionProfileName(TEXT("BlockAll"));
    CollisionBox->SetBoxExtent(FVector(100.f, 10.f, 100.f));

    // Sprite visual da plataforma
    PlatformSprite = CreateDefaultSubobject<UPaperSpriteComponent>(TEXT("PlatformSprite"));
    PlatformSprite->SetupAttachment(RootComponent);
}
```

Para detectar quando o personagem pousa numa plataforma, usamos eventos de colisão. Modifique o `APlatformerCharacter`:

```cpp
void APlatformerCharacter::BeginPlay()
{
    Super::BeginPlay();
    
    // Registrar evento de colisão
    GetCapsuleComponent()->OnComponentBeginOverlap.AddDynamic(this, &APlatformerCharacter::OnOverlapBegin);
}

void APlatformerCharacter::OnOverlapBegin(UPrimitiveComponent* OverlappedComp, AActor* OtherActor, 
    UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult& SweepResult)
{
    if (OtherActor->IsA(APlatform::StaticClass()))
    {
        UE_LOG(LogTemp, Log, TEXT("Pousou na plataforma!"));
        // Lógica adicional para o pouso
    }
}
```

A física básica é controlada pelo componente `CharacterMovement` que já vem com a classe `ACharacter`. Para ajustar os parâmetros:

```cpp
// No construtor do APlatformerCharacter:
GetCharacterMovement()->GravityScale = 2.0f;
GetCharacterMovement()->JumpZVelocity = 1000.f;
GetCharacterMovement()->AirControl = 0.3f;
```

Se você configurar valores muito altos para `JumpZVelocity`, pode enfrentar problemas onde o personagem atravessa plataformas. Isso acontece porque o movimento é tão rápido que a detecção de colisão entre frames falha. A solução é aumentar a precisão da detecção:

```cpp
GetCharacterMovement()->SetUpdateNavAgentWithOwnersCollisions(true);
GetCharacterMovement()->bUseFlatBaseForFloorChecks = true;
```

Para objetos que devem responder a física (como caixas que podem ser empurradas), crie uma classe `APhysicsObject`:

```cpp
APhysicsObject::APhysicsObject()
{
    // Componente de física
    PhysicsBody = CreateDefaultSubobject<UBoxComponent>(TEXT("PhysicsBody"));
    RootComponent = PhysicsBody;
    PhysicsBody->SetSimulatePhysics(true);
    PhysicsBody->SetCollisionProfileName(TEXT("PhysicsActor"));
    
    // Ajuste para evitar rotação indesejada
    PhysicsBody->BodyInstance.bLockRotation = true;
}
```

**Exercício:** Crie um obstáculo que empurre o personagem para trás quando colidido. A solução deve:
1. Criar uma nova classe `APushObstacle`
2. Implementar o evento `OnHit` para aplicar força
3. Configurar os parâmetros físicos adequados

**Solução comentada:**

```cpp
// No construtor de APushObstacle:
PushCollision = CreateDefaultSubobject<UBoxComponent>(TEXT("PushCollision"));
RootComponent = PushCollision;
PushCollision->SetCollisionProfileName(TEXT("BlockAllDynamic"));
PushCollision->OnComponentHit.AddDynamic(this, &APushObstacle::OnHit);

void APushObstacle::OnHit(UPrimitiveComponent* HitComp, AActor* OtherActor, 
    UPrimitiveComponent* OtherComp, FVector NormalImpulse, const FHitResult& Hit)
{
    if (OtherActor->IsA(APlatformerCharacter::StaticClass()))
    {
        FVector PushDirection = -Hit.ImpactNormal;
        PushDirection.Z = 0; // Manter no plano 2D
        PushDirection.Normalize();
        
        OtherActor->GetComponentByClass<UPrimitiveComponent>()->AddImpulse(PushDirection * 500.f);
    }
}
```