## Desenvolvimento do protótipo

Agora que você já planejou o jogo e definiu os sistemas principais, é hora de transformar essas ideias em um protótipo funcional. O protótipo é uma versão inicial do jogo que permite testar as mecânicas principais e validar se o conceito funciona na prática. Vamos começar criando o cenário básico e implementando o movimento do personagem principal.

### Criando o Cenário Básico

Primeiro, vamos criar um cenário simples para o nosso jogo de plataforma 2D. Abra a Unreal Engine e crie um novo projeto "Blank" com o template "Side Scroller". Isso já nos dá um ambiente básico para começar.

1. **Criação do Mapa**: No editor de níveis, adicione um `TileMap` para criar o chão e algumas plataformas. Você pode usar o `Paper2D` plugin para facilitar a criação de tilesets.

   ```cpp
   // Exemplo de código para adicionar um TileMap
   ATileMapActor* TileMap = GetWorld()->SpawnActor<ATileMapActor>();
   TileMap->SetTileSet(YourTileSet);
   TileMap->CreateMap(10, 10); // Cria um mapa de 10x10 tiles
   ```

2. **Configuração da Câmera**: Ajuste a câmera para seguir o personagem principal. Isso pode ser feito através do Blueprint ou diretamente no código C++.

   ```cpp
   // Exemplo de código para configurar a câmera
   APlayerController* PlayerController = GetWorld()->GetFirstPlayerController();
   if (PlayerController)
   {
       PlayerController->SetViewTargetWithBlend(YourCharacter, 0.5f);
   }
   ```

### Implementando o Movimento do Personagem

O próximo passo é implementar o movimento do personagem principal. Vamos criar uma classe `Character` personalizada para controlar o jogador.

1. **Criação da Classe Character**: No Unreal Editor, crie uma nova classe C++ chamada `MyCharacter` que herda de `ACharacter`.

   ```cpp
   // MyCharacter.h
   #pragma once
   #include "CoreMinimal.h"
   #include "GameFramework/Character.h"
   #include "MyCharacter.generated.h"

   UCLASS()
   class MYGAME_API AMyCharacter : public ACharacter
   {
       GENERATED_BODY()
   public:
       AMyCharacter();
       virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;
   private:
       void MoveForward(float AxisValue);
       void Jump();
   };

   // MyCharacter.cpp
   #include "MyCharacter.h"
   #include "GameFramework/CharacterMovementComponent.h"

   AMyCharacter::AMyCharacter()
   {
       PrimaryActorTick.bCanEverTick = true;
   }

   void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
   {
       Super::SetupPlayerInputComponent(PlayerInputComponent);
       PlayerInputComponent->BindAxis("MoveForward", this, &AMyCharacter::MoveForward);
       PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &AMyCharacter::Jump);
   }

   void AMyCharacter::MoveForward(float AxisValue)
   {
       AddMovementInput(FVector(1.0f, 0.0f, 0.0f), AxisValue);
   }

   void AMyCharacter::Jump()
   {
       ACharacter::Jump();
   }
   ```

2. **Configuração do Input**: No Unreal Editor, configure os inputs "MoveForward" e "Jump" no projeto para que o personagem possa se mover e pular.

   ```ini
   ; Config/DefaultInput.ini
   [/Script/Engine.InputSettings]
   +AxisMappings=(AxisName="MoveForward", Key=W, Scale=1.0)
   +AxisMappings=(AxisName="MoveForward", Key=S, Scale=-1.0)
   +ActionMappings=(ActionName="Jump", Key=SpaceBar)
   ```

### Testando o Protótipo

Agora que temos um cenário básico e o movimento do personagem implementado, é hora de testar o protótipo. Execute o jogo e verifique se o personagem pode se mover e pular corretamente.

```bash
Saída Esperada:
- O personagem deve se mover para a frente e para trás ao pressionar as teclas W e S.
- O personagem deve pular ao pressionar a barra de espaço.
```

### Tratamento de Erros Comuns

Um erro comum durante o desenvolvimento de protótipos é o esquecimento de adicionar componentes necessários ao personagem, como o `CharacterMovementComponent`. Se você esquecer de adicionar esse componente, o personagem não conseguirá se mover.

```cpp
// Certifique-se de que o CharacterMovementComponent está presente
if (!GetCharacterMovement())
{
    UE_LOG(LogTemp, Error, TEXT("CharacterMovementComponent não encontrado!"));
    return;
}
```

### Exercício Prático

**Exercício**: Adicione uma mecânica de ataque ao personagem. Quando o jogador pressionar a tecla "A", o personagem deve realizar um ataque básico.

**Solução**:

1. Adicione um novo input "Attack" no `DefaultInput.ini`.

   ```ini
   +ActionMappings=(ActionName="Attack", Key=A)
   ```

2. Implemente a função de ataque na classe `MyCharacter`.

   ```cpp
   // MyCharacter.h
   private:
       void Attack();

   // MyCharacter.cpp
   void AMyCharacter::Attack()
   {
       UE_LOG(LogTemp, Log, TEXT("Personagem atacou!"));
   }

   void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
   {
       Super::SetupPlayerInputComponent(PlayerInputComponent);
       PlayerInputComponent->BindAction("Attack", IE_Pressed, this, &AMyCharacter::Attack);
   }
   ```

3. Teste o jogo e verifique se o personagem realiza o ataque ao pressionar a tecla "A".

```bash
Saída Esperada:
- O personagem deve realizar um ataque ao pressionar a tecla A.
```

Com isso, você tem um protótipo funcional do seu jogo de plataforma 2D. Agora você pode seguir para a implementação de sistemas principais e criação de conteúdo para expandir o jogo.