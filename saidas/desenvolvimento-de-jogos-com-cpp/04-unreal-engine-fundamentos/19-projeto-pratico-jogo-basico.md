## Projeto prático: jogo básico

Vamos criar um jogo simples onde um personagem pode se mover e pular para coletar moedas. Comece criando um novo projeto "Blank" na Unreal Engine, selecionando a opção C++ (não apenas Blueprint).

Primeiro, adicione um personagem ao cenário. No Content Browser, clique com o botão direito e selecione "Blueprint Class", escolhendo "Character" como classe pai. Nomeie-o como "BP_Player". Abra este Blueprint e adicione um componente "Static Mesh" (uma esfera simples servirá como placeholder).

Para o movimento, precisamos configurar os inputs. Vá em Edit > Project Settings > Input e adicione as seguintes ações:

```text
MoveForward (Axis) - W: 1.0, S: -1.0
MoveRight (Axis) - D: 1.0, A: -1.0
Jump (Action) - Barra de Espaço
```

Agora, abra o Blueprint do jogador e conecte esses inputs no Event Graph:

```blueprint
Event Axis MoveForward → Add Movement Input (Forward)
Event Axis MoveRight → Add Movement Input (Right)
Event Pressed Jump → Jump
```

Para as moedas colecionáveis, crie uma nova classe C++ chamada "ACoin" que herda de AActor. O código essencial é:

```cpp
// Coin.h
UCLASS()
class MYGAME_API ACoin : public AActor
{
    GENERATED_BODY()
public:
    ACoin();
    UPROPERTY(VisibleAnywhere) UStaticMeshComponent* Mesh;
    UPROPERTY(EditAnywhere) int32 Value = 10;
};

// Coin.cpp
ACoin::ACoin()
{
    Mesh = CreateDefaultSubobject<UStaticMeshComponent>("Mesh");
    RootComponent = Mesh;
    Mesh->SetCollisionProfileName("OverlapAllDynamic");
}
```

Compile e crie um Blueprint baseado nesta classe. No editor, defina a malha como uma moeda (ou esfera) e ajuste o valor se desejar.

Para detectar a coleta, adicione em "BP_Player" um evento de colisão:

```blueprint
Event ActorBeginOverlap (Collision Preset: OverlapAllDynamic)
→ Cast to Coin
→ Se sucesso: Destroy Actor (Other Actor)
            → Add to Score (usando uma variável de instância)
            → Play Sound 2D (efeito de coleta)
```

Um erro comum é esquecer de configurar o "Collision Preset". Se o jogador passar pelas moedas sem coletar, verifique se ambos têm:

- Jogador: Collision Preset = "Pawn"
- Moeda: Collision Preset = "OverlapAllDynamic"

Para finalizar, crie um Widget Blueprint chamado "WB_HUD" mostrando a pontuação. Adicione um Text Block e conecte-o à variável de pontuação do jogador usando "Bind" no Designer Graph.

No Level Blueprint, adicione alguns coins à cena manualmente e teste o jogo:

1. O jogador deve se mover com WASD
2. Espaço faz pular
3. Ao tocar nas moedas, elas desaparecem e a pontuação aumenta
4. Um som simples toca a cada coleta

**Exercício:** Modifique o jogo para que as moedas desapareçam gradualmente (usando Timeline) quando coletadas, em vez de sumirem instantaneamente.

**Solução:** No Blueprint da moeda, ao invés de destruir imediatamente, adicione uma Timeline que controla a escala (de 1 a 0 em 0.5s) e só destrói no final da animação. Conecte a saída da Timeline ao "Set World Scale" do componente de malha.