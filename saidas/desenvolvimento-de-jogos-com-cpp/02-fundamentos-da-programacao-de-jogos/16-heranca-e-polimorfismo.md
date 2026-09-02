## Herança e polimorfismo

Imagine que você está criando um jogo de plataforma com vários tipos de inimigos - alguns que andam, outros que voam, e alguns que atiram. Sem herança, você teria que duplicar código para cada tipo de inimigo, mesmo quando compartilham características comuns. Veja o problema na prática:

```cpp
// SEM HERANÇA - CÓDIGO DUPLICADO
class InimigoAndante {
public:
    float Vida;
    void Mover() { /* implementação complexa */ }
    void ReceberDano(float Dano) { Vida -= Dano; }
};

class InimigoVoador {
public:
    float Vida;
    void Voar() { /* implementação diferente */ }
    void ReceberDano(float Dano) { Vida -= Dano; } // Código repetido!
};
```

A herança resolve isso permitindo que classes compartilhem código comum. Vamos criar uma hierarquia de inimigos:

```cpp
// CLASSE BASE
class AInimigo {
public:
    float Vida;
    FVector Posicao;

    AInimigo() : Vida(100.0f) {} // Construtor inicializa vida
    
    virtual void Mover() = 0; // Método abstrato - deve ser implementado
    
    virtual void ReceberDano(float Dano) {
        Vida -= Dano;
        UE_LOG(LogTemp, Warning, TEXT("Inimigo recebeu %f de dano!"), Dano);
    }
};

// CLASSE DERIVADA
class AInimigoAndante : public AInimigo {
public:
    virtual void Mover() override {
        Posicao.X += 10.0f;
        UE_LOG(LogTemp, Log, TEXT("Inimigo andando para %s"), *Posicao.ToString());
    }
};

// OUTRA CLASSE DERIVADA
class AInimigoVoador : public AInimigo {
public:
    virtual void Mover() override {
        Posicao.Z += 5.0f;
        UE_LOG(LogTemp, Log, TEXT("Inimigo voando para %s"), *Posicao.ToString());
    }
    
    virtual void ReceberDano(float Dano) override {
        Vida -= Dano * 2; // Inimigos voadores recebem dano dobrado
        UE_LOG(LogTemp, Warning, TEXT("Inimigo voador recebeu dano crítico!"));
    }
};
```

O polimorfismo entra quando tratamos todos esses inimigos de forma uniforme, mesmo que cada um tenha comportamentos específicos:

```cpp
TArray<AInimigo*> Inimigos;
Inimigos.Add(new AInimigoAndante());
Inimigos.Add(new AInimigoVoador());

// Atualização do jogo - loop principal
for (AInimigo* Inimigo : Inimigos) {
    Inimigo->Mover(); // Chama a implementação correta para cada tipo
    
    if (FMath::RandBool()) { // 50% de chance de receber dano
        Inimigo->ReceberDano(10.0f);
    }
}
```

Saída do log (exemplo real):

```
LogTemp: Inimigo andando para (10.0, 0.0, 0.0)
Warning: Inimigo recebeu 10.0 de dano!
LogTemp: Inimigo voando para (0.0, 0.0, 5.0)
Warning: Inimigo voador recebeu dano crítico!
```

Um erro comum é esquecer o `override` ao sobrescrever métodos, o que pode levar a comportamentos inesperados. O compilador emite este aviso:

```
error: 'function' marked 'override' does not override any member functions
```

Para corrigir, sempre use `override` quando estiver sobrescrevendo um método virtual da classe base, e verifique se o método na classe base está marcado como `virtual`.

Exercício: Crie uma classe `AInimigoAtirador` que herda de `AInimigo` e implementa:
1. Um método `Mover()` que faz o inimigo se mover mais devagar (metade da velocidade)
2. Um método `Atirar()` específico para esta classe
3. Sobrescreva `ReceberDano()` para reduzir a velocidade após levar dano

Solução comentada:

```cpp
class AInimigoAtirador : public AInimigo {
public:
    float Velocidade = 5.0f; // Mais lento que os outros
    
    virtual void Mover() override {
        Posicao.X += Velocidade;
        UE_LOG(LogTemp, Log, TEXT("Inimigo atirador se arrastando..."));
    }
    
    void Atirar() {
        UE_LOG(LogTemp, Warning, TEXT("Pew! Pew!"));
    }
    
    virtual void ReceberDano(float Dano) override {
        AInimigo::ReceberDano(Dano); // Chama a implementação base
        Velocidade = FMath::Max(1.0f, Velocidade * 0.5f); // Reduz a velocidade, mínimo de 1.0
    }
};
```