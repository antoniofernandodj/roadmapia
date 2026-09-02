## Loops: for

Imagine que você precisa criar um sistema de contagem regressiva para a fase final do jogo. Mostrar "3... 2... 1... GO!" na tela exigiria repetir o mesmo código várias vezes, o que seria ineficiente e difícil de manter. É aqui que o loop `for` se torna essencial.

O loop `for` em C++ tem esta estrutura básica:

```cpp
for (inicialização; condição; incremento) {
    // Bloco de código que será repetido
}
```

Vamos criar um contador simples que mostra números de 1 a 5 no console:

```cpp
#include <iostream>

int main() {
    for (int i = 1; i <= 5; i++) {
        std::cout << "Contagem: " << i << std::endl;
    }
    return 0;
}
```

Saída:
```
Contagem: 1
Contagem: 2
Contagem: 3
Contagem: 4
Contagem: 5
```

Na prática de jogos, isso seria útil para:
- Atualizar todos os inimigos em um nível
- Processar efeitos visuais sequenciais
- Gerar obstáculos em padrões repetitivos

Um erro comum é esquecer que a variável do loop existe apenas dentro dele. Tentar usar `i` fora do `for` causará um erro:

```cpp
for (int i = 0; i < 3; i++) {
    std::cout << "Dentro: " << i << std::endl;
}
std::cout << "Fora: " << i << std::endl;  // Erro!
```

Mensagem de erro:
```
error: 'i' was not declared in this scope
```

Para contornar isso, declare a variável antes do loop se precisar usá-la depois:

```cpp
int j;
for (j = 0; j < 3; j++) {
    std::cout << "Dentro: " << j << std::endl;
}
std::cout << "Fora: " << j << std::endl;  // Funciona!
```

Em jogos, loops `for` frequentemente iteram sobre coleções. Mesmo sem conhecer arrays ainda (que serão vistos mais adiante), podemos simular isso:

```cpp
#include <iostream>

int main() {
    // Simulando vidas do jogador
    const int maxLives = 3;
    
    std::cout << "Jogador começa com " << maxLives << " vidas:" << std::endl;
    
    for (int life = 1; life <= maxLives; life++) {
        std::cout << "Vida " << life << " ativa" << std::endl;
    }
    
    return 0;
}
```

Saída:
```
Jogador começa com 3 vidas:
Vida 1 ativa
Vida 2 ativa
Vida 3 ativa
```

Você pode modificar o incremento para contar de forma diferente. Um exemplo útil para temporizadores de habilidades:

```cpp
#include <iostream>

int main() {
    // Contagem regressiva de cooldown de habilidade
    std::cout << "Habilidade em cooldown:" << std::endl;
    
    for (int seconds = 10; seconds >= 0; seconds -= 2) {
        std::cout << seconds << "s restantes" << std::endl;
    }
    
    std::cout << "Habilidade pronta novamente!" << std::endl;
    return 0;
}
```

Saída:
```
Habilidade em cooldown:
10s restantes
8s restantes
6s restantes
4s restantes
2s restantes
0s restantes
Habilidade pronta novamente!
```

Exercício: Crie um loop `for` que mostre os números pares entre 20 e 30 (inclusive). Depois, modifique-o para mostrar apenas os números ímpares no mesmo intervalo.

Solução comentada:

```cpp
#include <iostream>

int main() {
    // Números pares de 20 a 30
    std::cout << "Pares:" << std::endl;
    for (int num = 20; num <= 30; num += 2) {
        std::cout << num << " ";
    }
    std::cout << std::endl;
    
    // Números ímpares de 20 a 30
    std::cout << "Ímpares:" << std::endl;
    for (int num = 21; num <= 29; num += 2) {
        std::cout << num << " ";
    }
    std::cout << std::endl;
    
    return 0;
}
```

Saída:
```
Pares:
20 22 24 26 28 30 
Ímpares:
21 23 25 27 29 
```