## O loop principal do jogo

Um jogo é, em sua essência, um programa que executa uma série de tarefas repetidamente enquanto o jogador está interagindo com ele. Essa repetição é conhecida como **loop principal do jogo** (ou *game loop*). O loop principal é responsável por garantir que o jogo continue funcionando, atualizando o estado do mundo, processando entradas do jogador e renderizando a tela.

Imagine um jogo de plataforma. Enquanto o jogador está correndo, pulando e lutando, o jogo precisa:
1. Verificar se o jogador pressionou alguma tecla ou moveu o mouse.
2. Atualizar a posição do personagem e dos inimigos com base nessas entradas.
3. Desenhar tudo na tela para que o jogador veja o que está acontecendo.

Esse ciclo de verificar, atualizar e desenhar acontece várias vezes por segundo, criando a ilusão de movimento e interatividade. Se esse ciclo parar, o jogo também para.

### Como o loop principal funciona?

O loop principal é um `while` ou `for` infinito que continua executando até que o jogador feche o jogo. Veja um exemplo básico em C++:

```cpp
#include <iostream>
#include <chrono>
#include <thread>

bool isRunning = true;

void processInput() {
    // Simula a leitura de entrada do jogador
    std::cout << "Processando entrada..." << std::endl;
}

void updateGame() {
    // Atualiza o estado do jogo (movimento, colisões, etc.)
    std::cout << "Atualizando jogo..." << std::endl;
}

void renderScreen() {
    // Desenha a tela do jogo
    std::cout << "Renderizando tela..." << std::endl;
}

int main() {
    while (isRunning) {
        processInput();
        updateGame();
        renderScreen();

        // Controla a taxa de atualização (60 FPS)
        std::this_thread::sleep_for(std::chrono::milliseconds(16));
    }

    return 0;
}
```

Saída esperada (repetida indefinidamente até que o jogo seja fechado):

```
Processando entrada...
Atualizando jogo...
Renderizando tela...
Processando entrada...
Atualizando jogo...
Renderizando tela...
...
```

### O ciclo de atualização e renderização

O loop principal divide o tempo em duas etapas principais:
1. **Atualização**: O estado do jogo é modificado com base nas entradas do jogador e nas regras do jogo. Isso inclui mover personagens, verificar colisões e atualizar pontuações.
2. **Renderização**: O estado atual do jogo é desenhado na tela para o jogador ver.

Essas etapas devem ser executadas em uma ordem específica. Se você renderizar antes de atualizar, o jogador verá um estado desatualizado do jogo. Por exemplo, se o personagem se moveu para a direita, mas a renderização acontecer antes da atualização, o jogador verá o personagem ainda na posição antiga.

### Controlando a taxa de atualização

Um jogo precisa ser fluido e responsivo. Para isso, o loop principal deve ser executado em uma taxa constante, geralmente 60 vezes por segundo (60 FPS). Isso significa que cada ciclo do loop deve levar aproximadamente 16 milissegundos (1000 ms / 60).

Se o loop for executado muito rápido, o jogo pode consumir recursos desnecessários. Se for muito lento, o jogo parecerá travado. No exemplo anterior, usamos `std::this_thread::sleep_for` para garantir que cada ciclo leve pelo menos 16 ms.

### Erros comuns no loop principal

Um erro comum é esquecer de controlar a taxa de atualização, resultando em um jogo que roda muito rápido ou muito lento. Por exemplo:

```cpp
while (isRunning) {
    processInput();
    updateGame();
    renderScreen();
}
```

Nesse caso, o loop será executado o mais rápido possível, o que pode fazer o jogo ficar incontrolável ou consumir toda a CPU do computador.

Outro erro é não limpar a tela antes de renderizar o próximo quadro, causando sobreposição de imagens. Isso não é mostrado no exemplo básico, mas é algo que você precisará considerar ao trabalhar com gráficos.

### Exercício

Crie um loop principal que simula um jogo simples onde um número (representando a posição de um personagem) aumenta de 1 em 1 a cada ciclo. O jogo deve parar quando o número atingir 100. Certifique-se de controlar a taxa de atualização para 30 FPS.

```cpp
#include <iostream>
#include <chrono>
#include <thread>

int main() {
    int position = 0;
    bool isRunning = true;

    while (isRunning) {
        // Atualiza a posição do personagem
        position++;
        std::cout << "Posição: " << position << std::endl;

        // Verifica se o jogo deve parar
        if (position >= 100) {
            isRunning = false;
        }

        // Controla a taxa de atualização (30 FPS)
        std::this_thread::sleep_for(std::chrono::milliseconds(33));
    }

    std::cout << "Fim do jogo!" << std::endl;
    return 0;
}
```

Saída esperada:

```
Posição: 1
Posição: 2
...
Posição: 100
Fim do jogo!
```

### Solução comentada

1. **Variável `position`**: Representa a posição do personagem no jogo.
2. **Loop `while`**: Continua executando enquanto `isRunning` for verdadeiro.
3. **Atualização**: Incrementa `position` em 1 a cada ciclo.
4. **Condição de parada**: Quando `position` atinge 100, `isRunning` é definido como `false`, encerrando o loop.
5. **Controle de FPS**: `std::this_thread::sleep_for` garante que cada ciclo leve aproximadamente 33 ms, resultando em 30 FPS.