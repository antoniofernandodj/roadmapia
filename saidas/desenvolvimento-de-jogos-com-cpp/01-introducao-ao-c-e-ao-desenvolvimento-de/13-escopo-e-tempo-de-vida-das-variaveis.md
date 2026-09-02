## Escopo e tempo de vida das variáveis

Imagine um chefão de jogo que só existe dentro de uma sala específica. Quando você entra na sala, ele aparece; quando sai, ele some. Variáveis em C++ funcionam assim - elas têm um "espaço" onde existem e um tempo de vida limitado. Veja o que acontece quando tentamos acessar uma variável fora de seu território:

```cpp
#include <iostream>

void criarInimigo() {
    int pontosVidaInimigo = 100;
    std::cout << "Inimigo criado com " << pontosVidaInimigo << " pontos de vida!\n";
}

int main() {
    criarInimigo();
    std::cout << "Tentando acessar vida do inimigo fora da função: " << pontosVidaInimigo << "\n";
    return 0;
}
```

Ao compilar, você receberá um erro como:
```
error: 'pontosVidaInimigo' was not declared in this scope
```

Isso acontece porque `pontosVidaInimigo` só existe dentro da função `criarInimigo()`. Quando a função termina, a variável deixa de existir. Este é o conceito de **escopo** - a região do código onde uma variável é válida.

### Blocos e hierarquia de escopos

Em C++, cada par de chaves `{}` cria um novo escopo. Variáveis declaradas dentro de um bloco só são visíveis dentro dele e em blocos internos:

```cpp
#include <iostream>

int main() {
    int vidaJogador = 200; // Escopo da função main
    
    if (vidaJogador > 0) {
        std::string mensagem = "Jogador vivo!"; // Escopo do if
        std::cout << mensagem << "\n";
        
        for (int i = 0; i < 3; i++) { // 'i' só existe no for
            std::cout << "Contagem: " << i << "\n";
            std::cout << mensagem << "\n"; // Acesso permitido
        }
        
        // std::cout << i << "\n"; // Erro! 'i' não existe aqui
    }
    
    // std::cout << mensagem << "\n"; // Erro! 'mensagem' não existe aqui
    
    return 0;
}
```

Saída:
```
Jogador vivo!
Contagem: 0
Jogador vivo!
Contagem: 1
Jogador vivo!
Contagem: 2
Jogador vivo!
```

### Variáveis com mesmo nome em escopos diferentes

Em jogos, é comum termos múltiplas instâncias de inimigos ou objetos com propriedades similares. Podemos declarar variáveis com o mesmo nome em escopos diferentes:

```cpp
#include <iostream>

void atacar() {
    int dano = 30; // Dano local para a função atacar
    std::cout << "Causando " << dano << " de dano!\n";
}

int main() {
    int dano = 10; // Dano principal
    
    if (true) {
        int dano = 50; // Dano especial dentro deste bloco
        std::cout << "Dano especial: " << dano << "\n";
    }
    
    std::cout << "Dano base: " << dano << "\n";
    atacar();
    
    return 0;
}
```

Saída:
```
Dano especial: 50
Dano base: 10
Causando 30 de dano!
```

A regra é clara: quando há conflito de nomes, a variável no escopo mais interno "esconde" as do escopo externo. Mas isso pode causar confusão, então é melhor usar nomes únicos quando possível.

### Tempo de vida das variáveis

O tempo de vida de uma variável é o período durante a execução em que ela ocupa memória:

1. **Variáveis locais automáticas**: Existem desde sua declaração até o final do bloco onde foram declaradas.
2. **Variáveis de parâmetros de função**: Existem durante a execução da função.

Veja um exemplo com um sistema de cooldown de habilidade:

```cpp
#include <iostream>
#include <thread>
#include <chrono>

void usarHabilidade() {
    int cooldown = 5; // Variável criada cada vez que a função é chamada
    
    while (cooldown > 0) {
        std::cout << "Habilidade em cooldown: " << cooldown << "s\n";
        std::this_thread::sleep_for(std::chrono::seconds(1));
        cooldown--;
    }
    
    // 'cooldown' é destruída aqui
}

int main() {
    usarHabilidade();
    std::cout << "Habilidade pronta novamente!\n";
    
    usarHabilidade(); // Nova variável 'cooldown' é criada
    return 0;
}
```

### Exercício: Sistema de Vida por Estágios

Crie um programa que simule um inimigo com três fases de batalha. Cada fase deve ter:
1. Um escopo separado com a vida específica da fase
2. Um loop while que reduz a vida até zerar
3. Uma mensagem ao final de cada fase

Solução comentada:

```cpp
#include <iostream>
#include <thread>
#include <chrono>

int main() {
    // Fase 1
    {
        int vidaFase1 = 50;
        while (vidaFase1 > 0) {
            std::cout << "Fase 1 - Vida: " << vidaFase1 << "\n";
            std::this_thread::sleep_for(std::chrono::milliseconds(300));
            vidaFase1 -= 5;
        }
        std::cout << "Fase 1 concluída!\n";
    }
    
    // Fase 2
    {
        int vidaFase2 = 75;
        while (vidaFase2 > 0) {
            std::cout << "Fase 2 - Vida: " << vidaFase2 << "\n";
            std::this_thread::sleep_for(std::chrono::milliseconds(200));
            vidaFase2 -= 8;
        }
        std::cout << "Fase 2 concluída!\n";
    }
    
    // Fase 3
    {
        int vidaFase3 = 100;
        while (vidaFase3 > 0) {
            std::cout << "Fase 3 - Vida: " << vidaFase3 << "\n";
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
            vidaFase3 -= 10;
        }
        std::cout << "Chefe derrotado!\n";
    }
    
    return 0;
}
```

Cada variável `vidaFaseX` existe apenas dentro de seu bloco, demonstrando claramente o tempo de vida limitado das variáveis locais.