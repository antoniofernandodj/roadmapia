## Sobrecarga de operadores

Imagine que você está programando um sistema de física para seu jogo e precisa somar duas velocidades. Em C++ puro, você teria que escrever algo como:

```cpp
FVector velocidadeResultante;
velocidadeResultante.X = velocidade1.X + velocidade2.X;
velocidadeResultante.Y = velocidade1.Y + velocidade2.Y;
velocidadeResultante.Z = velocidade1.Z + velocidade2.Z;
```

Isso funciona, mas é verboso e pouco intuitivo. Seria muito mais claro se pudéssemos simplesmente escrever `velocidade1 + velocidade2`. É exatamente para isso que serve a sobrecarga de operadores.

A sobrecarga de operadores permite definir como os operadores padrão do C++ (como +, -, *, /, etc.) funcionam com seus tipos personalizados. Vamos implementar isso para uma classe `Velocidade` simples:

```cpp
class Velocidade {
public:
    float X;
    float Y;
    
    Velocidade(float x, float y) : X(x), Y(y) {}
    
    // Sobrecarga do operador +
    Velocidade operator+(const Velocidade& outra) const {
        return Velocidade(X + outra.X, Y + outra.Y);
    }
};
```

Agora podemos usar nossa classe de forma mais natural:

```cpp
Velocidade v1(10.0f, 5.0f);
Velocidade v2(3.0f, 7.0f);
Velocidade resultado = v1 + v2;  // Chama operator+
```

O compilador transforma `v1 + v2` em `v1.operator+(v2)`. O operador é na verdade uma função especial com um nome específico (`operator+` neste caso).

### Erro comum: esquecer o const

Um erro frequente é esquecer a palavra-chave `const` na declaração do operador. Se tentarmos:

```cpp
Velocidade operator+(Velocidade& outra) {  // Sem const
    return Velocidade(X + outra.X, Y + outra.Y);
}
```

E depois usarmos:

```cpp
Velocidade resultado = Velocidade(1,2) + Velocidade(3,4);
```

Obtemos o erro:
```
error: no match for 'operator+' (operand types are 'Velocidade' and 'Velocidade')
```

Isso acontece porque `Velocidade(1,2)` cria um objeto temporário, e referências não-const não podem se ligar a temporários. A solução é adicionar `const` como mostrado no exemplo correto.

### Operadores de comparação

Para permitir comparações entre objetos, podemos sobrecarregar operadores como `==` e `!=`. Vamos expandir nossa classe `Velocidade`:

```cpp
bool operator==(const Velocidade& outra) const {
    return X == outra.X && Y == outra.Y;
}

bool operator!=(const Velocidade& outra) const {
    return !(*this == outra);  // Reutiliza o operador ==
}
```

Agora podemos fazer:

```cpp
if (v1 == v2) {
    // As velocidades são iguais
}
```

### Operadores de fluxo para debug

Sobrecarregar os operadores `<<` é útil para imprimir objetos com `std::cout`. Vamos adicionar suporte a isso:

```cpp
#include <iostream>

std::ostream& operator<<(std::ostream& os, const Velocidade& v) {
    os << "Velocidade(" << v.X << ", " << v.Y << ")";
    return os;
}
```

Agora podemos fazer:

```cpp
Velocidade v(5, 10);
std::cout << "Velocidade atual: " << v << std::endl;
```

Saída:
```
Velocidade atual: Velocidade(5, 10)
```

### Operadores compostos

Operadores como `+=` também podem ser sobrecarregados. Eles geralmente retornam uma referência para permitir encadeamento:

```cpp
Velocidade& operator+=(const Velocidade& outra) {
    X += outra.X;
    Y += outra.Y;
    return *this;
}
```

Uso:

```cpp
Velocidade v1(1,2);
Velocidade v2(3,4);
v1 += v2;  // Agora v1 é (4,6)
```

### Exercício: Implementando operadores para uma classe de Jogador

Vamos criar uma classe `Jogador` simples com posição (X,Y) e implementar alguns operadores:

1. Implemente os operadores `+` e `-` para somar/subtrair posições
2. Sobrecarregue o operador `==` para comparar jogadores
3. Implemente o operador `<<` para imprimir a posição do jogador

Solução:

```cpp
#include <iostream>

class Jogador {
public:
    float X;
    float Y;
    
    Jogador(float x, float y) : X(x), Y(y) {}
    
    Jogador operator+(const Jogador& outro) const {
        return Jogador(X + outro.X, Y + outro.Y);
    }
    
    Jogador operator-(const Jogador& outro) const {
        return Jogador(X - outro.X, Y - outro.Y);
    }
    
    bool operator==(const Jogador& outro) const {
        return X == outro.X && Y == outro.Y;
    }
    
    friend std::ostream& operator<<(std::ostream& os, const Jogador& j);
};

std::ostream& operator<<(std::ostream& os, const Jogador& j) {
    os << "Jogador(" << j.X << ", " << j.Y << ")";
    return os;
}

int main() {
    Jogador p1(10, 20);
    Jogador p2(5, 30);
    
    Jogador soma = p1 + p2;
    Jogador diferenca = p1 - p2;
    
    std::cout << "Soma: " << soma << std::endl;
    std::cout << "Diferença: " << diferenca << std::endl;
    
    if (p1 == p2) {
        std::cout << "Posições iguais" << std::endl;
    } else {
        std::cout << "Posições diferentes" << std::endl;
    }
}
```

Saída:
```
Soma: Jogador(15, 50)
Diferença: Jogador(5, -10)
Posições diferentes
```