## Herança e polimorfismo em C++

Em jogos, personagens, inimigos e objetos muitas vezes compartilham características comuns, mas também têm comportamentos específicos. Imagine um jogo de plataforma onde você tem diferentes tipos de inimigos: alguns voam, outros andam, e alguns atiram projéteis. Em vez de criar classes completamente separadas para cada tipo de inimigo, podemos usar **herança** para compartilhar código comum e **polimorfismo** para permitir comportamentos específicos.

### Herança: Compartilhando Características Comuns

A herança permite que uma classe (chamada de classe derivada ou filha) herde atributos e métodos de outra classe (chamada de classe base ou pai). Vamos criar uma classe base `Inimigo` que contém atributos e métodos comuns a todos os inimigos:

```cpp
class Inimigo {
public:
    Inimigo(int vida) : vida(vida) {}
    virtual void Atacar() {
        std::cout << "Inimigo ataca!" << std::endl;
    }
protected:
    int vida;
};
```

Aqui, `Inimigo` tem um construtor que inicializa a vida do inimigo e um método `Atacar()` que define um comportamento padrão. A palavra-chave `virtual` permite que esse método seja sobrescrito por classes derivadas.

Agora, vamos criar duas classes derivadas: `InimigoVoador` e `InimigoTerrestre`.

```cpp
class InimigoVoador : public Inimigo {
public:
    InimigoVoador(int vida) : Inimigo(vida) {}
    void Atacar() override {
        std::cout << "Inimigo voador ataca do céu!" << std::endl;
    }
};

class InimigoTerrestre : public Inimigo {
public:
    InimigoTerrestre(int vida) : Inimigo(vida) {}
    void Atacar() override {
        std::cout << "Inimigo terrestre ataca no chão!" << std::endl;
    }
};
```

Ambas as classes derivadas herdam o atributo `vida` e o método `Atacar()` da classe base `Inimigo`. No entanto, elas sobrescrevem o método `Atacar()` para fornecer comportamentos específicos.

### Polimorfismo: Comportamentos Específicos

O polimorfismo permite que objetos de classes derivadas sejam tratados como objetos da classe base, mas ainda assim executem suas próprias implementações de métodos sobrescritos. Isso é especialmente útil em jogos, onde você pode ter uma lista de inimigos e chamar o método `Atacar()` sem se preocupar com o tipo específico de cada inimigo.

```cpp
int main() {
    Inimigo* inimigo1 = new InimigoVoador(100);
    Inimigo* inimigo2 = new InimigoTerrestre(150);

    inimigo1->Atacar(); // Saída: Inimigo voador ataca do céu!
    inimigo2->Atacar(); // Saída: Inimigo terrestre ataca no chão!

    delete inimigo1;
    delete inimigo2;

    return 0;
}
```

Aqui, `inimigo1` e `inimigo2` são ponteiros para a classe base `Inimigo`, mas apontam para objetos das classes derivadas `InimigoVoador` e `InimigoTerrestre`, respectivamente. Quando chamamos `Atacar()`, o método correto é executado com base no tipo real do objeto, graças ao polimorfismo.

### Erro Comum: Esquecer `virtual` e `override`

Se você esquecer de usar `virtual` na classe base ou `override` na classe derivada, o polimorfismo não funcionará como esperado. Veja o que acontece:

```cpp
class Inimigo {
public:
    Inimigo(int vida) : vida(vida) {}
    void Atacar() { // Sem virtual
        std::cout << "Inimigo ataca!" << std::endl;
    }
protected:
    int vida;
};

class InimigoVoador : public Inimigo {
public:
    InimigoVoador(int vida) : Inimigo(vida) {}
    void Atacar() { // Sem override
        std::cout << "Inimigo voador ataca do céu!" << std::endl;
    }
};

int main() {
    Inimigo* inimigo = new InimigoVoador(100);
    inimigo->Atacar(); // Saída: Inimigo ataca!
    delete inimigo;
    return 0;
}
```

Neste caso, o método `Atacar()` da classe base é chamado, porque o compilador não sabe que você queria sobrescrever o método. Para evitar isso, sempre use `virtual` na classe base e `override` na classe derivada.

### Exercício Prático

Crie uma nova classe derivada chamada `InimigoAquatico` que herda de `Inimigo`. Sobrescreva o método `Atacar()` para exibir a mensagem "Inimigo aquático ataca na água!". Em seguida, crie um objeto dessa classe e chame o método `Atacar()` para verificar se o polimorfismo está funcionando corretamente.

**Solução:**

```cpp
class InimigoAquatico : public Inimigo {
public:
    InimigoAquatico(int vida) : Inimigo(vida) {}
    void Atacar() override {
        std::cout << "Inimigo aquático ataca na água!" << std::endl;
    }
};

int main() {
    Inimigo* inimigo = new InimigoAquatico(200);
    inimigo->Atacar(); // Saída: Inimigo aquático ataca na água!
    delete inimigo;
    return 0;
}
```