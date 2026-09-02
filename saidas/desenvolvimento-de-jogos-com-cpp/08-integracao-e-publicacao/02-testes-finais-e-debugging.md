## Testes finais e debugging

Quando seu jogo está quase pronto, com todos os sistemas integrados, é hora de caçar os bugs que só aparecem quando tudo funciona junto. Vamos começar com um problema clássico: o jogador consegue pular infinitamente, mesmo no ar.

```cpp
void AMyCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    if (bIsJumping && CanJump())
    {
        Jump();
    }
}

bool AMyCharacter::CanJump() const
{
    return true; // SEMPRE permite pular
}
```

Ao testar, você percebe que o personagem voa sem parar. O problema está na função `CanJump()` que sempre retorna `true`. O correto seria verificar se o personagem está no chão:

```cpp
bool AMyCharacter::CanJump() const
{
    return GetCharacterMovement()->IsMovingOnGround();
}
```

A saída esperada agora é:
```
[Log] Character can only jump when on ground
```

Outro erro comum ocorre quando inimigos continuam atacando o jogador mesmo após a morte. O sistema de IA que implementamos anteriormente precisa de uma verificação adicional:

```cpp
void AEnemyAI::ChasePlayer()
{
    if (Player->GetHealth() <= 0)
    {
        StopChasing();
        return;
    }
    // Resto da lógica de perseguição
}
```

Ao testar, você pode encontrar este erro comum:
```
[Error] Attempted to access null Player reference
```

Isso acontece quando você esqueceu de atribuir a referência ao jogador no editor da Unreal. A correção é selecionar o inimigo no editor e, no painel de detalhes, arrastar o jogador para a propriedade `Player` do componente de IA.

Para testar a interface do usuário, crie um caso extremo onde a vida do jogador muda rapidamente:

```cpp
// No widget de vida
void UHealthWidget::UpdateHealth(float NewHealth)
{
    if (HealthBar == nullptr)
    {
        UE_LOG(LogTemp, Error, TEXT("HealthBar not initialized!"));
        return;
    }
    HealthBar->SetPercent(NewHealth / MaxHealth);
}
```

Se você esquecer de vincular o `HealthBar` no editor, verá:
```
[Error] HealthBar not initialized!
```

A solução é abrir o widget no editor de UI e vincular o progress bar à variável `HealthBar`.

Uma técnica eficaz é testar cada sistema isoladamente antes da integração final:
1. Movimento: tente sair dos limites do mapa
2. Combate: verifique dano negativo ou overflow de vida
3. IA: teste com múltiplos inimigos em cenas complexas

Para debugar problemas complexos, use a ferramenta de Output Log da Unreal com mensagens detalhadas:

```cpp
UE_LOG(LogGame, Warning, TEXT("Player position: X=%.2f Y=%.2f"), GetActorLocation().X, GetActorLocation().Y);
```

Isso mostrará no Output Log:
```
[Warning] Player position: X=1200.50 Y=450.30
```

**Exercício:** Implemente um sistema onde os inimigos param de perseguir o jogador quando estão a mais de 500 unidades de distância, com mensagem de log quando isso acontece.

**Solução:**
```cpp
void AEnemyAI::ChasePlayer()
{
    float Distance = FVector::Dist(GetActorLocation(), Player->GetActorLocation());
    if (Distance > 500.f)
    {
        UE_LOG(LogAI, Display, TEXT("Player too far, stopping chase"));
        StopChasing();
        return;
    }
    // Continua perseguindo
}
```
A saída esperada quando o jogador foge:
```
[Display] Player too far, stopping chase
```