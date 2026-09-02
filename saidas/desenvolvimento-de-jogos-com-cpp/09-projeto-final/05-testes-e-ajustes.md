## Testes e ajustes

Seu jogo está funcional - o personagem se move, inimigos atacam, itens são coletados. Mas quando você testa com atenção, descobre que o pulo às vezes trava em plataformas, o dano do inimigo é inconsistente e o jogo congela quando muitos efeitos ocorrem ao mesmo tempo. Esses são os problemas que testes e ajustes resolvem.

Vamos começar com o pulo travando. O código atual verifica colisões apenas uma vez por frame:

```cpp
void APlayerCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    
    if (IsJumping && !GetCharacterMovement()->IsMovingOnGround())
    {
        // Movimento do pulo
        AddMovementInput(FVector::UpVector, JumpForce);
    }
}
```

A saída do log mostra:
```
Warning: Character stuck in jumping state at position X=120, Y=340
```

O problema ocorre quando o personagem quase toca o chão mas não registra a colisão. A solução é verificar continuamente:

```cpp
void APlayerCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    
    if (IsJumping && GetCharacterMovement()->IsMovingOnGround())
    {
        IsJumping = false;
    }
}
```

Para o dano inconsistente, o inimigo está aplicando dano a cada frame enquanto colide:

```cpp
void AEnemy::OnOverlapBegin(UPrimitiveComponent* OverlappedComp, AActor* OtherActor)
{
    if (OtherActor->IsA(APlayerCharacter::StaticClass()))
    {
        Cast<APlayerCharacter>(OtherActor)->TakeDamage(DamageAmount);
    }
}
```

Isso causa dezenas de chamadas por segundo. O correto é adicionar um cooldown:

```cpp
void AEnemy::OnOverlapBegin(UPrimitiveComponent* OverlappedComp, AActor* OtherActor)
{
    if (CanAttack && OtherActor->IsA(APlayerCharacter::StaticClass()))
    {
        Cast<APlayerCharacter>(OtherActor)->TakeDamage(DamageAmount);
        CanAttack = false;
        GetWorld()->GetTimerManager().SetTimer(AttackTimer, this, &AEnemy::ResetAttack, AttackCooldown);
    }
}

void AEnemy::ResetAttack()
{
    CanAttack = true;
}
```

Quando o jogo congela com muitos efeitos, o problema está na alocação dinâmica de partículas:

```cpp
void ASpell::Cast()
{
    UParticleSystemComponent* Particle = UGameplayStatics::SpawnEmitterAtLocation(
        GetWorld(), 
        SpellEffect, 
        GetActorLocation()
    );
    // Partícula não é armazenada ou gerenciada
}
```

A solução é pré-carregar partículas e reutilizá-las:

```cpp
TArray<UParticleSystemComponent*> SpellParticles;

void ASpell::Cast()
{
    UParticleSystemComponent* Particle = nullptr;
    
    for (auto& P : SpellParticles)
    {
        if (!P->IsActive())
        {
            Particle = P;
            break;
        }
    }
    
    if (!Particle)
    {
        Particle = NewObject<UParticleSystemComponent>(this);
        SpellParticles.Add(Particle);
    }
    
    Particle->SetTemplate(SpellEffect);
    Particle->SetWorldLocation(GetActorLocation());
    Particle->ActivateSystem();
}
```

Para testar sistematicamente, crie um mapa de teste dedicado com:

1. Plataformas em várias alturas
2. Área com 100 inimigos spawnados
3. Zona para testar 50 efeitos de partículas simultâneos
4. Botões que forçam situações extremas

Um teste valioso é o "Teste de 5 minutos": jogue continuamente por 5 minutos tentando quebrar o jogo. Anote tudo que der errado:

```
1. 00:32 - Personagem ficou preso entre duas plataformas
2. 01:15 - Inimigo aplicou dano duplo
3. 03:47 - Efeito de fogo não desapareceu
4. 04:50 - FPS caiu para 15 durante explosão
```

Para cada problema, crie um ticket de bug claro:

```
Título: Dano duplo do inimigo arqueiro
Reprodução: 
1. Fique próximo ao inimigo
2. Mova-se rapidamente para frente e para trás
Resultado esperado: Dano aplicado a cada 1 segundo
Resultado atual: Dano aplicado a cada 0.2 segundos
Prioridade: Alta
```

Exercício: Implemente um sistema de debug que mostre na tela:
- FPS atual
- Número de inimigos ativos
- Estado do personagem (andando/pulando/atacando)
- Memória alocada para partículas

Solução:

```cpp
void APlayerHUD::DrawHUD()
{
    Super::DrawHUD();
    
    FString DebugText = FString::Printf(
        TEXT("FPS: %.1f\nEnemies: %d\nState: %s\nParticles: %d/%d KB"),
        GetWorld()->GetDeltaSeconds() > 0 ? 1/GetWorld()->GetDeltaSeconds() : 0,
        EnemyManager->GetActiveEnemies(),
        *Player->GetStateString(),
        ParticleManager->GetUsedMemory()/1024,
        ParticleManager->GetMaxMemory()/1024
    );
    
    DrawText(
        DebugText,
        FLinearColor::White,
        50, 50,
        GEngine->GetMediumFont()
    );
}
```