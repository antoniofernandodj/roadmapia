## Loops: while e do-while

Imagine um inimigo em seu jogo que precisa perseguir o jogador enquanto estiver vivo. Ou um sistema de respawn que continua tentando posicionar o personagem até encontrar um local seguro. Essas situações exigem repetição de código - exatamente o que loops resolvem.

O `while` é o loop mais básico em C++. Ele repete um bloco de código enquanto uma condição for verdadeira. Veja como implementar um contador simples:

```cpp
#include <iostream>

int main() {
    int vidas = 3;
    
    while (vidas > 0) {
        std::cout << "Jogador ainda tem " << vidas << " vidas.\n";
        vidas--;  // Equivalente a vidas = vidas - 1
    }
    
    std::cout << "Game Over!\n";
    return 0;
}
```

Saída:
```
Jogador ainda tem 3 vidas.
Jogador ainda tem 2 vidas.
Jogador ainda tem 1 vidas.
Game Over!
```

O erro mais comum com `while` é criar um loop infinito acidentalmente. Se esquecermos de decrementar `vidas`, o programa nunca termina:

```cpp
// CUIDADO: loop infinito!
while (vidas > 0) {
    std::cout << "Jogador ainda tem " << vidas << " vidas.\n";
    // Esquecemos de decrementar vidas!
}
```

A Unreal Engine detectaria esse problema com uma mensagem como:
```
Fatal error: Potential infinite loop detected (vidas not modified in loop body)
```

O `do-while` é uma variação que garante pelo menos uma execução, testando a condição no final. É útil para menus ou validação de entrada:

```cpp
#include <iostream>
#include <string>

int main() {
    std::string resposta;
    
    do {
        std::cout << "Deseja jogar novamente? (sim/nao): ";
        std::cin >> resposta;
    } while (resposta != "sim" && resposta != "nao");
    
    std::cout << "Resposta válida: " << resposta << "\n";
    return 0;
}
```

Diferença chave:
- `while` verifica primeiro, depois executa (0 ou mais vezes)
- `do-while` executa primeiro, depois verifica (1 ou mais vezes)

Aplicação em jogos:
1. Processar entrada até ser válida
2. Atualizar estado de inimigos enquanto existirem
3. Repetir animações enquanto durar um efeito

Exercício: Crie um sistema de dificuldade que reduz o tempo de reação do inimigo a cada 5 segundos, começando em 3.0s até chegar a 0.5s. Exiba cada atualização.

Solução comentada:
```cpp
#include <iostream>
#include <unistd.h>  // Para sleep()

int main() {
    float tempoReacao = 3.0f;
    
    while (tempoReacao > 0.5f) {
        std::cout << "Tempo de reacao do inimigo: " << tempoReacao << "s\n";
        sleep(5);  // Espera 5 segundos
        tempoReacao -= 0.5f;  // Aumenta a dificuldade
    }
    
    std::cout << "Dificuldade maxima alcancada!\n";
    return 0;
}
```