## Debugging e testes básicos

Quando seu personagem de jogo plataforma começa a atravessar paredes ou os inimigos param de atacar sem motivo aparente, você está diante de problemas típicos que exigem debugging. Na Unreal Engine, temos ferramentas poderosas integradas diretamente no editor para identificar e corrigir esses problemas.

### O básico do Output Log

Todo desenvolvedor de jogos precisa dominar o Output Log da Unreal. É aqui que mensagens de erro, warnings e seus próprios logs aparecem. Vamos criar uma situação comum: seu personagem não está pulando quando você pressiona a tecla espaço.

```cpp
void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);
    
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &AMyCharacter::Jump);
}
```

Se o pulo não funciona, adicione uma mensagem de debug para verificar se a função está sendo chamada:

```cpp
void AMyCharacter::Jump()
{
    UE_LOG(LogTemp, Warning, TEXT("Jump function called!"));
    // Restante da implementação do pulo
}
```

No Output Log, você verá:

```
LogTemp: Warning: Jump function called!
```

Se essa mensagem aparecer, o problema está na implementação do pulo. Se não aparecer, o problema está no mapeamento de entrada.

### Breakpoints e Step Debugging

Para problemas mais complexos, como um cálculo de física errado, breakpoints são essenciais. Imagine que sua plataforma móvel está se movendo muito rápido:

```cpp
void AMovingPlatform::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    
    FVector NewLocation = GetActorLocation();
    float DeltaHeight = (FMath::Sin(RunningTime + DeltaTime) - FMath::Sin(RunningTime));
    NewLocation.Z += DeltaHeight * 500.0f; // Valor arbitrário
    RunningTime += DeltaTime;
    SetActorLocation(NewLocation);
}
```

Adicione um breakpoint na linha `SetActorLocation(NewLocation)` e execute o jogo em modo debug (F5 no Visual Studio). Quando o breakpoint for atingido, você pode:

1. Inspecionar o valor de `NewLocation`
2. Ver como `DeltaHeight` é calculado
3. Step over (F10) para seguir linha por linha

### Visualização de Colisões

Problemas de colisão são comuns em jogos 2D. Para visualizar as caixas de colisão durante o jogo, pressione **' no editor (apóstrofo) para mostrar os debug shapes. Ou adicione no código:

```cpp
// No construtor do seu ator
GetCapsuleComponent()->SetHiddenInGame(false);
```

Isso mostrará a cápsula de colisão do personagem em vermelho durante o jogo.

### Testes Básicos com Checagens

Implemente checagens simples para validar comportamentos do jogo:

```cpp
void AEnemy::DealDamage(float DamageAmount)
{
    if (DamageAmount <= 0)
    {
        UE_LOG(LogTemp, Error, TEXT("DamageAmount must be positive!"));
        return;
    }
    
    Health -= DamageAmount;
    if (Health <= 0)
    {
        Destroy();
    }
}
```

Se você chamar `DealDamage(-10)`, verá no Output Log:

```
LogTemp: Error: DamageAmount must be positive!
```

### Erro Comum: Esquecer de Chamar Super

Um erro comum é esquecer de chamar a função da classe pai:

```cpp
void AMyCharacter::BeginPlay()
{
    // Esqueceu de chamar Super::BeginPlay()
    UE_LOG(LogTemp, Warning, TEXT("MyCharacter BeginPlay"));
}
```

Isso pode causar comportamentos inesperados. A mensagem de erro será:

```
Warning: Super::BeginPlay not called in MyCharacter. Please ensure proper initialization.
```

### Exercício Prático

Crie uma plataforma que muda de cor quando o personagem pousa nela. Adicione mensagens de debug para:
1. Quando o personagem entra na plataforma
2. Quando a cor muda
3. Se o temporizador de reset não funcionar

**Solução:**

```cpp
void AColorChangingPlatform::OnOverlapBegin(UPrimitiveComponent* OverlappedComp, AActor* OtherActor, 
    UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult& SweepResult)
{
    UE_LOG(LogTemp, Warning, TEXT("Player landed on platform"));
    
    UStaticMeshComponent* Mesh = GetStaticMeshComponent();
    if (Mesh)
    {
        Mesh->SetMaterial(0, ActiveMaterial);
        UE_LOG(LogTemp, Warning, TEXT("Platform color changed"));
        
        GetWorld()->GetTimerManager().SetTimer(TimerHandle, this, 
            &AColorChangingPlatform::ResetColor, 3.0f, false);
    }
}

void AColorChangingPlatform::ResetColor()
{
    if (GetStaticMeshComponent())
    {
        GetStaticMeshComponent()->SetMaterial(0, DefaultMaterial);
        UE_LOG(LogTemp, Warning, TEXT("Platform color reset"));
    }
    else
    {
        UE_LOG(LogTemp, Error, TEXT("Mesh component not found!"));
    }
}
```