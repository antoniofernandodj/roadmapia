## Arrays e vetores

Imagine que você está criando um sistema de inventário para seu jogo. Precisamos armazenar os 10 itens que o jogador está carregando. Criar 10 variáveis separadas (`item1`, `item2`, ..., `item10`) seria trabalhoso e difícil de gerenciar. É aqui que os arrays entram:

```cpp
#include <iostream>

int main() {
    // Array de inteiros com 10 posições
    int inventario[10] = {1, 5, 3, 0, 8, 0, 0, 2, 4, 0};
    
    // Acessando o terceiro item (índice 2)
    std::cout << "Item 3: " << inventario[2] << std::endl;
    
    // Modificando o sexto item
    inventario[5] = 7;
    
    return 0;
}
```

Saída esperada:
```
Item 3: 3
```

O array `inventario` armazena 10 valores inteiros em posições consecutivas de memória, acessíveis pelo índice entre colchetes. Importante: em C++, os índices começam em 0, então `inventario[0]` é o primeiro item.

Um erro comum é acessar índices fora dos limites do array:
```cpp
int inventario[10];
std::cout << inventario[10];  // Erro! Índice máximo é 9
```

Isso causa comportamento indefinido - pode crashar, retornar lixo ou parecer funcionar até falhar inesperadamente em produção.

Para arrays de tamanho fixo como esse, podemos descobrir o tamanho em tempo de compilação com:
```cpp
int tamanho = sizeof(inventario) / sizeof(inventario[0]);
std::cout << "Tamanho do inventário: " << tamanho << std::endl;
```

Saída:
```
Tamanho do inventário: 10
```

Mas e se precisarmos de um container que cresça dinamicamente conforme o jogador adquire mais itens? Para isso usamos `std::vector` da biblioteca padrão:

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> inventario = {1, 5, 3};
    
    // Adicionando itens dinamicamente
    inventario.push_back(8);
    inventario.push_back(2);
    
    // Acessando como array normal
    std::cout << "Quantidade de itens: " << inventario.size() << std::endl;
    std::cout << "Primeiro item: " << inventario[0] << std::endl;
    
    // Iterando com for-range (C++11)
    for (int item : inventario) {
        std::cout << item << " ";
    }
    std::cout << std::endl;
    
    return 0;
}
```

Saída:
```
Quantidade de itens: 5
Primeiro item: 1
1 5 3 8 2 
```

Principais vantagens do `vector`:
- Cresce automaticamente quando necessário
- Sabe seu próprio tamanho (`size()`)
- Oferece métodos úteis como `push_back()`, `pop_back()`, `clear()`
- Mais seguro que arrays brutos

Um erro comum com vectors é assumir que índices são válidos sem verificar:
```cpp
std::vector<int> itens;
std::cout << itens[0];  // Comportamento indefinido - vector vazio!
```

A forma segura é usar `at()` que lança exceção se o índice for inválido:
```cpp
try {
    std::cout << itens.at(0);
} catch (const std::out_of_range& e) {
    std::cout << "Erro: " << e.what() << std::endl;
}
```

Para um jogo, poderíamos usar vectors para:
- Inventários de tamanho variável
- Lista de inimigos na tela
- Pontuações das fases
- Efeitos sonoros a serem reproduzidos

**Exercício**: Crie um sistema simples de experiência por nível onde cada nível requer o dobro de XP do anterior. Armazene os requisitos de XP até o nível 10 em um array e depois em um vector, mostrando como acessar o valor para o nível 5.

**Solução**:
```cpp
#include <iostream>
#include <vector>

int main() {
    // Com array fixo
    int xpArray[10];
    xpArray[0] = 100;  // Nível 1
    
    for (int i = 1; i < 10; ++i) {
        xpArray[i] = xpArray[i-1] * 2;
    }
    std::cout << "XP para nível 5 (array): " << xpArray[4] << std::endl;

    // Com vector
    std::vector<int> xpVector;
    xpVector.push_back(100);  // Nível 1
    
    for (int i = 1; i < 10; ++i) {
        xpVector.push_back(xpVector[i-1] * 2);
    }
    std::cout << "XP para nível 5 (vector): " << xpVector[4] << std::endl;

    return 0;
}
```

Saída:
```
XP para nível 5 (array): 1600
XP para nível 5 (vector): 1600
```