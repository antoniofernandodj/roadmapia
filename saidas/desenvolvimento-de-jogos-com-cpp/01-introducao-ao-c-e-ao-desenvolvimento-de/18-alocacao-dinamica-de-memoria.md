## Alocação dinâmica de memória

Em um jogo, frequentemente não sabemos quantos inimigos existirão em uma fase ou quantos itens o jogador coletará. Arrays com tamanho fixo, como `int inimigos[50]`, não resolvem - e se precisarmos de 51? É aqui que entra a alocação dinâmica.

Considere um sistema de spawn de inimigos onde cada novo inimigo precisa de memória:

```cpp
#include <iostream>

int main() {
    int quantidadeInimigos;
    std::cout << "Quantos inimigos devem spawnar? ";
    std::cin >> quantidadeInimigos;

    // Alocação dinâmica
    int* inimigos = new int[quantidadeInimigos];
    
    // Preenche os valores de vida dos inimigos
    for (int i = 0; i < quantidadeInimigos; ++i) {
        inimigos[i] = 100; // Vida inicial
    }
    
    // Simula dano no terceiro inimigo
    inimigos[2] -= 30;
    std::cout << "Vida do 3º inimigo: " << inimigos[2] << std::endl;

    // Libera a memória
    delete[] inimigos;
    return 0;
}
```

Saída possível:
```
Quantos inimigos devem spawnar? 5
Vida do 3º inimigo: 70
```

O operador `new` aloca memória no heap (área de memória disponível para alocação) e retorna um ponteiro para o início do bloco. A sintaxe `new tipo[tamanho]` cria um array dinâmico. É crucial liberar essa memória com `delete[]` quando não for mais necessária, caso contrário ocorre vazamento de memória.

Um erro comum é esquecer de liberar a memória ou usar o operador errado:

```cpp
int* item = new int;  // Aloca um único inteiro
delete[] item;        // ERRADO: usa delete[] em new simples
```

Isso gera um erro em tempo de execução:
```
free(): invalid pointer
Aborted (core dumped)
```

A forma correta seria:
```cpp
delete item;  // Correto para new simples
```

Para arrays dinâmicos, a diferença entre `new`/`delete` e `new[]`/`delete[]` é essencial. O sistema operacional mantém metadados sobre o tamanho dos arrays alocados, e usar o operador errado corrompe esses dados.

Na Unreal Engine, embora existam alternativas mais seguras (como `TArray`), entender alocação dinâmica é fundamental para:

1. Criar sistemas que lidam com quantidades variáveis de elementos
2. Entender como contêineres da engine funcionam internamente
3. Escrever código performático quando necessário

**Exercício:** Modifique o exemplo dos inimigos para armazenar structs `Inimigo` (com vida e tipo) em vez de inteiros. Aloque dinamicamente o array, preencha os valores e libere a memória corretamente.

Solução comentada:
```cpp
#include <iostream>

struct Inimigo {
    int vida;
    std::string tipo;
};

int main() {
    int quantidade = 3;
    
    // Aloca array de Inimigos
    Inimigo* inimigos = new Inimigo[quantidade];
    
    // Preenche os dados
    inimigos[0] = {100, "Orc"};
    inimigos[1] = {150, "Troll"};
    inimigos[2] = {80, "Goblin"};
    
    // Exibe informações
    for (int i = 0; i < quantidade; ++i) {
        std::cout << inimigos[i].tipo << ": " << inimigos[i].vida << " HP\n";
    }
    
    // Libera memória
    delete[] inimigos;
    return 0;
}
```

Saída:
```
Orc: 100 HP
Troll: 150 HP
Goblin: 80 HP
```