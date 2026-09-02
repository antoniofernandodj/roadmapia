## Movimentação do personagem

A movimentação do personagem é o coração de qualquer jogo de plataforma. Para implementar isso na Unreal Engine, precisamos compreender dois componentes principais: a entrada do jogador e o controle físico do personagem. Vamos criar um personagem que pode se mover para a esquerda e direita e pular.

Primeiro, precisamos configurar o componente de movimento do personagem. Na Unreal Engine, isso é feito através da classe `UCharacterMovementComponent`. Esse componente já vem com funcionalidades básicas como gravidade, pulo e movimentação horizontal, o que facilita nossa tarefa.

Vamos começar criando uma nova classe `APlatformerCharacter` que herda de `ACharacter`. No construtor dessa classe, vamos configurar alguns parâmetros básicos:

```cpp
APlatformerCharacter::APlatformerCharacter()
{
    // Configuração básica do movimento
    GetCharacterMovement()->JumpZVelocity = 700.f;
    GetCharacterMovement()->GravityScale = 2.f;
    GetCharacterMovement()->AirControl = 0.2f;
    GetCharacterMovement()->MaxWalkSpeed = 500.f;
}
```

Essas configurações definem a velocidade do pulo, a escala da gravidade, o controle aéreo e a velocidade máxima de caminhada. Esses valores podem ser ajustados conforme necessário para o seu jogo.

Agora, vamos implementar a movimentação horizontal. Para isso, precisamos capturar a entrada do jogador e aplicar a movimentação ao personagem. A Unreal Engine fornece um sistema de entrada que pode ser configurado no editor, mas vamos fazer isso diretamente no código.

Primeiro, adicione as seguintes funções na classe `APlatformerCharacter`:

```cpp
void APlatformerCharacter::MoveRight(float Value)
{
    if (Value != 0.0f)
    {
        const FRotator Rotation = Controller->GetControlRotation();
        const FRotator YawRotation(0, Rotation.Yaw, 0);
        const FVector Direction = FRotationMatrix(YawRotation).GetUnitAxis(EAxis::Y);
        AddMovementInput(Direction, Value);
    }
}

void APlatformerCharacter::Jump()
{
    ACharacter::Jump();
}
```

A função `MoveRight` calcula a direção de movimento com base na rotação do controlador e aplica o movimento ao personagem. A função `Jump` simplesmente chama a implementação de pulo da classe base `ACharacter`.

Para vincular essas funções às entradas do jogador, precisamos configurar o mapeamento de entrada no arquivo `SetupPlayerInputComponent`:

```cpp
void APlatformerCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAxis("MoveRight", this, &APlatformerCharacter::MoveRight);
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &APlatformerCharacter::Jump);
}
```

Aqui, estamos vinculando o eixo "MoveRight" à função `MoveRight` e a ação "Jump" à função `Jump`. Esses nomes ("MoveRight" e "Jump") devem corresponder aos nomes configurados nas configurações de entrada do projeto.

### Testando a movimentação

Ao compilar e executar o projeto, você deve ser capaz de mover o personagem para a esquerda e direita usando as teclas de seta ou o joystick, e pular com a barra de espaço ou botão correspondente. Se o personagem não se mover, verifique se os nomes das entradas estão corretos e se o componente de entrada está configurado corretamente.

### Erro comum: esquecer de configurar o RootComponent

Um erro comum ao implementar a movimentação é esquecer de configurar o `RootComponent` para o personagem. Isso pode causar problemas de física e colisão. Certifique-se de que o `RootComponent` está configurado corretamente, geralmente como um `UCapsuleComponent`:

```cpp
APlatformerCharacter::APlatformerCharacter()
{
    // Configuração do componente de colisão
    UCapsuleComponent* Capsule = GetCapsuleComponent();
    Capsule->InitCapsuleSize(42.f, 96.0f);
    Capsule->SetCollisionProfileName(UCollisionProfile::Pawn_ProfileName);

    // Configuração do RootComponent
    RootComponent = Capsule;
}
```

### Exercício prático

Modifique o código para adicionar uma funcionalidade de "corrida" que aumenta a velocidade de movimento quando o jogador segura a tecla Shift. Implemente isso na função `MoveRight` e ajuste a velocidade máxima de caminhada conforme necessário.

```cpp
void APlatformerCharacter::MoveRight(float Value)
{
    if (Value != 0.0f)
    {
        const FRotator Rotation = Controller->GetControlRotation();
        const FRotator YawRotation(0, Rotation.Yaw, 0);
        const FVector Direction = FRotationMatrix(YawRotation).GetUnitAxis(EAxis::Y);

        // Verifica se a tecla Shift está pressionada
        if (GetCharacterMovement()->IsFalling() == false && IsInputKeyDown(EKeys::LeftShift))
        {
            GetCharacterMovement()->MaxWalkSpeed = 800.f;
        }
        else
        {
            GetCharacterMovement()->MaxWalkSpeed = 500.f;
        }

        AddMovementInput(Direction, Value);
    }
}
```

Este código verifica se a tecla Shift está pressionada e ajusta a velocidade de movimento. Quando a tecla Shift é liberada, a velocidade volta ao normal.