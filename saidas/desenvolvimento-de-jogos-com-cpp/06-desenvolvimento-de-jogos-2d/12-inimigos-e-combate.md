## Inimigos e combate

Neste momento, seu jogo tem um personagem principal que se move e pula, mas ainda falta o elemento que traz desafio: os inimigos. Vamos implementar um sistema básico de combate onde o jogador pode eliminar inimigos pulando sobre eles - um clássico dos jogos de plataforma.

Primeiro, crie uma nova classe C++ chamada `AEnemy` que herda de `ACharacter`. Vamos configurar os componentes básicos no construtor:

```cpp
AEnemy::AEnemy()
{
    // Configuração do sprite
    GetSprite()->SetSprite(ConstructorHelpers::FObjectFinder<UPaperSprite>(TEXT("PaperSprite'/Game/Sprites/Enemy_Sprite.Enemy_Sprite'")).Object);
    
    // Configuração da cápsula de colisão
    GetCapsuleComponent()->InitCapsuleSize(34.0f, 50.0f);
    GetCapsuleComponent()->SetCollisionProfileName(TEXT("Enemy"));
    
    // Configuração de movimento
    GetCharacterMovement()->GravityScale = 2.0f;
    GetCharacterMovement()->MaxWalkSpeed = 150.0f;
}
```

Um erro comum é esquecer de configurar o `GravityScale` corretamente, resultando em inimigos que não caem ou caem muito devagar. Se isso acontecer, você verá o inimigo flutuando no ar sem interagir com as plataformas.

Para implementar o sistema de dano, adicione à classe `AEnemy`:

```cpp
void AEnemy::ReceiveDamage()
{
    // Animação de morte
    GetSprite()->SetFlipbook(DeathAnimation);
    
    // Desativa colisões
    GetCapsuleComponent()->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    
    // Aplica força para cima
    GetCharacterMovement()->AddImpulse(FVector(0, 0, 500.0f), true);
    
    // Destrói o inimigo após 1 segundo
    SetLifeSpan(1.0f);
}
```

Agora, modifique a classe do personagem principal para detectar quando pisa em um inimigo. No arquivo do personagem, adicione:

```cpp
void AMyCharacter::OnHitEnemy(UPrimitiveComponent* HitComponent, AActor* OtherActor, 
    UPrimitiveComponent* OtherComp, FVector NormalImpulse, const FHitResult& Hit)
{
    if (OtherActor->IsA<AEnemy>())
    {
        // Verifica se o personagem está vindo de cima
        if (Hit.Normal.Z > 0.7f)
        {
            Cast<AEnemy>(OtherActor)->ReceiveDamage();
            // Adiciona pequeno impulso para cima
            GetCharacterMovement()->AddImpulse(FVector(0, 0, 300.0f), true);
        }
        else
        {
            // O inimigo causa dano ao jogador
            ReceiveDamage();
        }
    }
}
```

Para que essa função seja chamada, você precisa configurar a colisão no construtor do personagem:

```cpp
GetCapsuleComponent()->OnComponentHit.AddDynamic(this, &AMyCharacter::OnHitEnemy);
```

Um erro que você pode encontrar é:
```
LogScript: Error: OnComponentHit: Function 'AMyCharacter::OnHitEnemy' not found on 'AMyCharacter' or invalid.
```

Isso ocorre quando a assinatura da função não corresponde exatamente ao que o delegado espera. Verifique se todos os parâmetros estão corretos e se a função está declarada no arquivo de cabeçalho.

Para tornar o inimigo mais interessante, vamos implementar um movimento patrulhamento simples. Adicione à classe `AEnemy`:

```cpp
void AEnemy::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    // Movimento de patrulha simples
    AddMovementInput(FVector(IsMovingRight ? 1.0f : -1.0f, 0, 0));
    
    // Verifica se precisa inverter direção
    FHitResult HitResult;
    if (!GetWorld()->LineTraceSingleByChannel(HitResult, 
        GetActorLocation(), 
        GetActorLocation() + FVector(IsMovingRight ? 50.0f : -50.0f, 0, -100.0f),
        ECC_Visibility))
    {
        IsMovingRight = !IsMovingRight;
    }
}
```

E no construtor, inicialize a variável:
```cpp
IsMovingRight = true;
```

Para testar, crie um Blueprint baseado na classe `AEnemy` e coloque alguns inimigos em seu nível. Quando você pula sobre um inimigo, ele deve ser "derrotado" com uma animação, enquanto se você tocá-lo pelos lados, seu personagem receberá dano.

**Exercício prático:** 
Modifique o sistema para que os inimigos causem diferentes quantidades de dano baseado em seu tipo. Crie duas classes derivadas de `AEnemy` - `AWeakEnemy` que causa 1 ponto de dano e `AStrongEnemy` que causa 2 pontos. Implemente uma variável `DamageAmount` na classe base e sobrescreva-a nas classes derivadas.

**Solução comentada:**

1. Na classe `AEnemy`, adicione:
```cpp
UPROPERTY(EditDefaultsOnly)
int32 DamageAmount = 1;
```

2. Crie a classe `AWeakEnemy`:
```cpp
AWeakEnemy::AWeakEnemy()
{
    DamageAmount = 1;
}
```

3. Crie a classe `AStrongEnemy`:
```cpp
AStrongEnemy::AStrongEnemy()
{
    DamageAmount = 2;
}
```

4. Modifique a função `OnHitEnemy` no personagem para usar essa variável:
```cpp
// Substitua ReceiveDamage() por:
ReceiveDamage(Cast<AEnemy>(OtherActor)->DamageAmount);
```