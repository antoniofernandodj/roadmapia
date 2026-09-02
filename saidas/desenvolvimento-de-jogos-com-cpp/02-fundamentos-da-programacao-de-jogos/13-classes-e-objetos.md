## Classes e objetos

No desenvolvimento de jogos, quase tudo que você interage é um objeto: o personagem, os inimigos, os itens coletáveis. Em C++, esses objetos são criados a partir de classes, que funcionam como moldes para definir suas propriedades e comportamentos.

Vamos criar nossa primeira classe para representar um personagem de jogo. No Unreal Engine, toda classe herda de `AActor` ou `UObject`. Para um personagem que se move, usaremos `ACharacter`:

```cpp
// Arquivo Heroi.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "Heroi.generated.h"

UCLASS()
class MEUJOGO_API AHeroi : public ACharacter
{
    GENERATED_BODY()

public:
    AHeroi(); // Construtor
    
    // Propriedades
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Heroi")
    float VelocidadeMovimento;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Heroi")
    int32 PontosVida;

    // Métodos
    void Mover(FVector Direcao);
    void ReceberDano(int32 Quantidade);
};
```

```cpp
// Arquivo Heroi.cpp
#include "Heroi.h"

AHeroi::AHeroi()
{
    VelocidadeMovimento = 600.0f;
    PontosVida = 100;
}

void AHeroi::Mover(FVector Direcao)
{
    AddMovementInput(Direcao, VelocidadeMovimento * GetWorld()->GetDeltaSeconds());
}

void AHeroi::ReceberDano(int32 Quantidade)
{
    PontosVida -= Quantidade;
    if(PontosVida <= 0)
    {
        UE_LOG(LogTemp, Warning, TEXT("Heroi derrotado!"));
    }
}
```

Agora vamos instanciar (criar um objeto a partir da classe) e usar nosso herói:

```cpp
// Em algum lugar do seu código de jogo
AHeroi* MeuHeroi = GetWorld()->SpawnActor<AHeroi>();
MeuHeroi->Mover(FVector(1.0f, 0.0f, 0.0f)); // Move para direita
MeuHeroi->ReceberDano(20); // Perde 20 pontos de vida
```

Se tentarmos acessar uma propriedade diretamente sem marcá-la com `UPROPERTY`, o Unreal Engine nos avisará:

```
Error: Accessing Nonexistent UProperty or RProperty in non-shipping build
```

Para corrigir, sempre declare propriedades que serão usadas no editor ou Blueprints com `UPROPERTY()`.

A principal diferença entre classes e objetos é que a classe é a definição (como o arquivo Heroi.h), enquanto o objeto é a instância concreta (como MeuHeroi na memória). Você pode criar vários objetos a partir de uma única classe:

```cpp
AHeroi* Heroi1 = GetWorld()->SpawnActor<AHeroi>();
AHeroi* Heroi2 = GetWorld()->SpawnActor<AHeroi>();

Heroi1->VelocidadeMovimento = 500.0f; // Mais lento
Heroi2->VelocidadeMovimento = 800.0f; // Mais rápido
```

Agora pratique: Crie uma classe `AInimigo` com propriedades `DanoAtaque` e `VelocidadePerseguicao`, e um método `Atacar()` que diminui a vida do herói quando chamado. Implemente também um método `Perseguir()` que move o inimigo na direção do jogador.

**Solução:**

```cpp
// Inimigo.h
UCLASS()
class MEUJOGO_API AInimigo : public ACharacter
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere)
    float DanoAtaque;

    UPROPERTY(EditAnywhere)
    float VelocidadePerseguicao;

    void Atacar(AHeroi* Alvo);
    void Perseguir(AHeroi* Alvo);
};
```

```cpp
// Inimigo.cpp
void AInimigo::Atacar(AHeroi* Alvo)
{
    if(Alvo)
    {
        Alvo->ReceberDano(DanoAtaque);
    }
}

void AInimigo::Perseguir(AHeroi* Alvo)
{
    if(Alvo)
    {
        FVector Direcao = Alvo->GetActorLocation() - GetActorLocation();
        Direcao.Normalize();
        AddMovementInput(Direcao, VelocidadePerseguicao * GetWorld()->GetDeltaSeconds());
    }
}
```