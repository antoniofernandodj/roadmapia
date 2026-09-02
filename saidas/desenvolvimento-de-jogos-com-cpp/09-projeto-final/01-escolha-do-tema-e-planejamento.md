## Escolha do tema e planejamento

Um jogo começa antes da primeira linha de código. Se você pular diretamente para a implementação sem planejar, enfrentará dois problemas clássicos:

1. **Escopo inflado**: seu "jogo simples" vira um projeto impossível quando você percebe que quer mecânicas complexas sem ter a base pronta
2. **Paralisia por decisão**: gastará horas ajustando detalhes irrelevantes porque não definiu o que realmente importa

Vamos criar um planejamento real para um jogo 2D de plataforma chamado "Ghost Runner" onde você controla um fantasma que precisa recuperar suas memórias pulando entre plataformas e evitando armadilhas.

### Definindo os pilares do jogo

1. **Gênero**: Plataforma 2D com elementos de puzzle
2. **Mecânica principal**: Pulo preciso + habilidade de "fasear" através de paredes por tempo limitado
3. **Progressão**: 5 níveis com dificuldade crescente, cada um recuperando uma memória do personagem
4. **Controles**: Teclado (setas + espaço para pular, Shift para fasear)

Exemplo de documento inicial no Unreal (arquivo `GameDesignDoc.cpp`):

```cpp
// GhostRunnerDesign.h
#pragma once

struct GameDesign {
    static constexpr int TOTAL_LEVELS = 5;
    static constexpr float PHASE_DURATION = 3.0f; // segundos
    static constexpr float JUMP_FORCE = 1500.0f;
    
    enum class MemoryType {
        CHILDHOOD,
        FAMILY,
        ADVENTURE,
        LOSS,
        FINAL_REVELATION
    };
};
```

### Quebrando em sistemas

Cada sistema vira uma classe C++ separada. Para nosso jogo:

1. **Personagem**: `GhostCharacter` (herda de `Character`)
2. **Gerenciador de fases**: `PhaseSystem` (controla tempo e efeitos visuais)
3. **Sistema de progressão**: `MemoryTracker` (guarda memórias coletadas)
4. **Gerenciador de níveis**: `LevelManager` (carrega cenas e verifica conclusão)

Código mínimo inicial para o personagem (`GhostCharacter.h`):

```cpp
// GhostCharacter.h
#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "GhostCharacter.generated.h"

UCLASS()
class GHOSTRUNNER_API AGhostCharacter : public ACharacter {
    GENERATED_BODY()

public:
    AGhostCharacter();
    
    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;

    void Jump() override;
    void StartPhasing();
    void StopPhasing();

private:
    bool bCanPhase = true;
    FTimerHandle PhaseTimerHandle;
};
```

Implementação básica (`GhostCharacter.cpp`):

```cpp
// GhostCharacter.cpp
#include "GhostCharacter.h"
#include "GameDesignDoc.h"

AGhostCharacter::AGhostCharacter() {
    // Configurações iniciais
}

void AGhostCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    Super::SetupPlayerInputComponent(PlayerInputComponent);
    
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &AGhostCharacter::Jump);
    PlayerInputComponent->BindAction("Phase", IE_Pressed, this, &AGhostCharacter::StartPhasing);
    PlayerInputComponent->BindAction("Phase", IE_Released, this, &AGhostCharacter::StopPhasing);
}

void AGhostCharacter::StartPhasing() {
    if (bCanPhase) {
        // Ativa efeitos e lógica de faseamento
        GetWorldTimerManager().SetTimer(PhaseTimerHandle, [this]() {
            bCanPhase = false;
        }, GameDesign::PHASE_DURATION, false);
    }
}
```

### Erro comum e correção

Se você tentar implementar tudo de uma vez:

```
Fatal error: GameDesignDoc.h: No such file or directory
```

Solução: Crie o arquivo de design primeiro e adicione ao projeto Unreal antes das classes que o referenciam. No Unreal Editor:

1. Clique direito na pasta `Source` > `New C++ Class`
2. Escolha "None" (classe comum)
3. Nomeie como `GameDesignDoc`
4. Adicione as constantes e enumerações mostradas anteriormente

### Cronograma realista

Para um projeto solo, divida em semanas:

| Semana | Tarefa |
|--------|--------|
| 1 | Personagem básico (movimento e pulo) |
| 2 | Mecânica de faseamento e 1º nível |
| 3 | Sistema de coleta de memórias |
| 4 | 3 níveis adicionais |
| 5 | Menu principal e finalização |

### Exercício

Crie o arquivo `LevelManager.h` com:

1. Um método para carregar níveis (`LoadLevel(int levelNum)`)
2. Uma propriedade para armazenar o nível atual
3. Uma enumeração com os nomes dos níveis (Level1 a Level5)

Solução comentada:

```cpp
// LevelManager.h
#pragma once

#include "CoreMinimal.h"
#include "GameDesignDoc.h"

class LevelManager {
public:
    enum class LevelName {
        LEVEL_1,
        LEVEL_2,
        LEVEL_3,
        LEVEL_4,
        LEVEL_5
    };

    void LoadLevel(int levelNum) {
        CurrentLevel = static_cast<LevelName>(levelNum - 1);
        // Lógica para carregar a cena correspondente
    }

    LevelName GetCurrentLevel() const { return CurrentLevel; }

private:
    LevelName CurrentLevel = LevelName::LEVEL_1;
};
```