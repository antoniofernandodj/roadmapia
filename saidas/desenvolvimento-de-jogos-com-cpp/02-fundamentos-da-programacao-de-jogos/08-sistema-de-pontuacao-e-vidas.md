## Sistema de pontuação e vidas

Em jogos de plataforma, cada moeda coletada aumenta sua pontuação e cada inimigo que te atinge reduz suas vidas. Vamos implementar esse sistema em C++ com Unreal Engine, conectando a lógica às colisões que você já conhece.

Comece criando duas variáveis no cabeçalho da classe do jogador (`AJogador.h`):

```cpp
UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Pontuacao")
int32 Pontuacao;

UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Vidas")
int32 Vidas;
```

O `UPROPERTY` expõe essas variáveis para o editor da Unreal, enquanto `int32` é o tipo inteiro padrão do engine. Inicialize-as no construtor do jogador (`AJogador.cpp`):

```cpp
AJogador::AJogador()
{
    Pontuacao = 0;
    Vidas = 3;
}
```

Para detectar colisões com moedas, adicione esta função ao arquivo `.cpp`:

```cpp
void AJogador::OnOverlapBegin(UPrimitiveComponent* OverlappedComp, AActor* OtherActor, 
                             UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, 
                             bool bFromSweep, const FHitResult& SweepResult)
{
    if (OtherActor->ActorHasTag("Moeda"))
    {
        Pontuacao += 100;
        OtherActor->Destroy();
        UE_LOG(LogTemp, Warning, TEXT("Pontuação: %d"), Pontuacao);
    }
    else if (OtherActor->ActorHasTag("Inimigo"))
    {
        Vidas--;
        UE_LOG(LogTemp, Error, TEXT("Vidas restantes: %d"), Vidas);
        if (Vidas <= 0) 
        {
            // Chamar função de game over
        }
    }
}
```

Erro comum é esquecer de configurar as tags nos atores. Se você tentar executar sem marcar uma moeda com a tag "Moeda", verá este erro no Output Log:

```
LogScript: Warning: Attempted to call ActorHasTag on None
```

Corrija no editor selecionando o ator moeda e adicionando a tag na seção "Tags" dos detalhes.

Para testar, crie uma cena simples com:
1. Um ator `BP_Moeda` (com tag "Moeda" e um colisor)
2. Um ator `BP_Inimigo` (com tag "Inimigo" e colisor)
3. Seu personagem com a função de overlap configurada

Ao executar e colidir com a moeda, a saída será:
```
LogTemp: Warning: Pontuação: 100
```

E ao tocar no inimigo:
```
LogTemp: Error: Vidas restantes: 2
```

**Exercício**: Modifique o sistema para:
1. Adicionar um multiplicador que dobra a pontuação após coletar 5 moedas consecutivas
2. Resetar o multiplicador ao levar dano

Solução comentada:

```cpp
// No AJogador.h
int32 MoedasConsecutivas;
float Multiplicador;

// No construtor
MoedasConsecutivas = 0;
Multiplicador = 1.0f;

// Modifique OnOverlapBegin
if (OtherActor->ActorHasTag("Moeda"))
{
    MoedasConsecutivas++;
    if (MoedasConsecutivas >= 5)
    {
        Multiplicador = 2.0f;
    }
    Pontuacao += 100 * Multiplicador;
    // Restante do código...
}
else if (OtherActor->ActorHasTag("Inimigo"))
{
    MoedasConsecutivas = 0;
    Multiplicador = 1.0f;
    // Restante do código...
}
```