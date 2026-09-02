## Construtores e destrutores

Imagine que seu jogo precisa criar um inimigo quando o jogador entra em uma nova área. Como garantir que esse inimigo comece com os valores corretos de vida, posição e textura? E quando o jogador sai da área, como limpar esses recursos? É aí que entram os construtores e destrutores.

### O problema da inicialização manual

Suponha que você crie uma classe `Inimigo` sem construtor:

```cpp
class AInimigo : public AActor
{
public:
    int32 Vida;
    FVector PosicaoInicial;
    UPaperSpriteComponent* Sprite;
};
```

Para usá-la, você precisaria inicializar cada propriedade manualmente:

```cpp
AInimigo* MeuInimigo = NewObject<AInimigo>();
MeuInimigo->Vida = 100;
MeuInimigo->PosicaoInicial = FVector(300, 0, 0);
MeuInimigo->Sprite = CreateDefaultSubobject<UPaperSpriteComponent>(TEXT("Sprite"));
// E assim por diante...
```

Isso é propenso a erros. Se você esquecer de inicializar alguma propriedade, o jogo pode crashar com mensagens como:

```
Access violation reading location 0x00000000
```

### Construtor: inicialização garantida

O construtor é um método especial que roda automaticamente quando o objeto é criado. Na Unreal Engine, ele tem uma assinatura específica:

```cpp
class AInimigo : public AActor
{
public:
    AInimigo()
    {
        Vida = 100;
        PosicaoInicial = FVector(300, 0, 0);
        Sprite = CreateDefaultSubobject<UPaperSpriteComponent>(TEXT("Sprite"));
        RootComponent = Sprite;
    }
    
    int32 Vida;
    FVector PosicaoInicial;
    UPaperSpriteComponent* Sprite;
};
```

Agora, ao criar o inimigo, tudo já estará configurado:

```cpp
AInimigo* MeuInimigo = NewObject<AInimigo>();
// Tudo já está inicializado corretamente!
```

### Destruidor: limpeza automática

Quando o inimigo é derrotado ou o jogador sai da área, precisamos liberar recursos. O destruidor (com `~`) faz isso:

```cpp
class AInimigo : public AActor
{
public:
    ~AInimigo()
    {
        if(Sprite)
        {
            Sprite->DestroyComponent();
        }
        UE_LOG(LogTemp, Warning, TEXT("Inimigo destruído!"));
    }
    // ... resto do código ...
};
```

Se você tentar destruir um inimigo sem limpar o sprite, pode ver vazamentos de memória no Output Log da Unreal:

```
LogMemory: Memória alocada para sprites não liberada: 512KB
```

### Construtor com parâmetros

Para criar inimigos com valores diferentes, adicione parâmetros:

```cpp
AInimigo(int32 VidaInicial, FVector Posicao)
{
    Vida = VidaInicial;
    PosicaoInicial = Posicao;
    Sprite = CreateDefaultSubobject<UPaperSpriteComponent>(TEXT("Sprite"));
}
```

Uso:
```cpp
AInimigo* InimigoFraco = NewObject<AInimigo>(50, FVector(200,0,0));
AInimigo* InimigoForte = NewObject<AInimigo>(200, FVector(500,0,0));
```

### Erro comum: esquecer o GENERATED_BODY

Se você criar um construtor em uma classe da Unreal e esquecer a macro `GENERATED_BODY()`, verá este erro:

```
error C2440: 'default argument': cannot convert from 'const char [6]' to 'FName'
```

Solução: sempre inclua:

```cpp
UCLASS()
class AInimigo : public AActor
{
    GENERATED_BODY()
public:
    AInimigo() { ... }
    // ...
};
```

### Exercício prático

Crie uma classe `APowerUp` que:
1. No construtor, inicialize um sprite e defina uma pontuação base (100 pontos)
2. No destruidor, limpe o sprite e logue "PowerUp coletado"
3. Adicione um construtor alternativo que aceite um valor personalizado de pontos

Solução comentada:

```cpp
UCLASS()
class APowerUp : public AActor
{
    GENERATED_BODY()
public:
    // Construtor padrão
    APowerUp()
    {
        Pontos = 100;
        Sprite = CreateDefaultSubobject<UPaperSpriteComponent>(TEXT("Sprite"));
    }
    
    // Construtor com parâmetro
    APowerUp(int32 ValorPontos) : Pontos(ValorPontos)
    {
        Sprite = CreateDefaultSubobject<UPaperSpriteComponent>(TEXT("Sprite"));
    }
    
    ~APowerUp()
    {
        if(Sprite)
        {
            Sprite->DestroyComponent();
        }
        UE_LOG(LogTemp, Log, TEXT("PowerUp coletado!"));
    }
    
private:
    int32 Pontos;
    UPaperSpriteComponent* Sprite;
};
```