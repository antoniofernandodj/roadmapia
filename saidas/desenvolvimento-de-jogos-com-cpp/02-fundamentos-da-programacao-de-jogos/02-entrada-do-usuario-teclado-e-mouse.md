## Entrada do usuário: teclado e mouse

Capturar a entrada do usuário é essencial para qualquer jogo. Sem ela, não há interação. Em C++ com Unreal Engine, isso é feito através de eventos que monitoram o teclado e o mouse. Vamos começar com o teclado, que é a forma mais comum de entrada em jogos.

### Capturando entrada do teclado

Para capturar a entrada do teclado, você precisa definir ações que serão associadas a teclas específicas. No Unreal Engine, isso é feito através do sistema de Input Mapping. Primeiro, você precisa configurar essas ações no editor. Depois, você pode acessá-las no código.

Vamos criar uma ação chamada "MoveForward" e associá-la à tecla "W". No código, você pode verificar se a tecla foi pressionada e mover o personagem para frente.

```cpp
void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAction("MoveForward", IE_Pressed, this, &AMyCharacter::MoveForward);
}

void AMyCharacter::MoveForward()
{
    FVector Direction = GetActorForwardVector();
    AddMovementInput(Direction, 1.0f);
}
```

Neste exemplo, `MoveForward` é chamado quando a tecla "W" é pressionada, e o personagem se move para frente.

### Capturando entrada do mouse

A entrada do mouse é tão importante quanto a do teclado, especialmente em jogos que requerem mira ou movimento da câmera. No Unreal Engine, você pode capturar o movimento do mouse e os cliques.

Vamos configurar um evento para capturar o movimento do mouse e rotacionar a câmera.

```cpp
void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAxis("Turn", this, &AMyCharacter::Turn);
}

void AMyCharacter::Turn(float Rate)
{
    AddControllerYawInput(Rate);
}
```

Aqui, `Turn` é chamado sempre que o mouse é movido horizontalmente, e o personagem gira para esquerda ou direita.

### Erros comuns

Um erro comum é esquecer de configurar as ações no editor. Se você tentar acessar uma ação que não foi configurada, o código não funcionará e você verá um erro como:

```
LogTemp: Error: Attempted to bind to non-existent action 'MoveForward'
```

Outro erro comum é não normalizar o movimento. Se você não normalizar o vetor de direção, o personagem pode se mover mais rápido diagonalmente do que em linha reta. Para corrigir isso, normalize o vetor:

```cpp
void AMyCharacter::MoveForward()
{
    FVector Direction = GetActorForwardVector();
    Direction.Normalize();
    AddMovementInput(Direction, 1.0f);
}
```

### Exercício

Crie um personagem que se move para frente e para trás com as teclas "W" e "S", e gira com o movimento do mouse. Adicione também a capacidade de pular com a tecla "Espaço".

```cpp
void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAction("MoveForward", IE_Pressed, this, &AMyCharacter::MoveForward);
    PlayerInputComponent->BindAction("MoveBackward", IE_Pressed, this, &AMyCharacter::MoveBackward);
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &AMyCharacter::Jump);
    PlayerInputComponent->BindAxis("Turn", this, &AMyCharacter::Turn);
}

void AMyCharacter::MoveForward()
{
    FVector Direction = GetActorForwardVector();
    Direction.Normalize();
    AddMovementInput(Direction, 1.0f);
}

void AMyCharacter::MoveBackward()
{
    FVector Direction = GetActorForwardVector();
    Direction.Normalize();
    AddMovementInput(Direction, -1.0f);
}

void AMyCharacter::Turn(float Rate)
{
    AddControllerYawInput(Rate);
}

void AMyCharacter::Jump()
{
    ACharacter::Jump();
}
```

Este código permite que o personagem se mova para frente e para trás, gire com o mouse e pule. Certifique-se de configurar as ações "MoveForward", "MoveBackward" e "Jump" no editor.