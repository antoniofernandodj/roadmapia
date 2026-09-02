## Projeto prático: jogo básico

Vamos criar um jogo básico de plataforma 2D utilizando C++ e os conceitos que aprendemos até agora. O objetivo é guiar o jogador através de um nível simples, coletando moedas e evitando inimigos. Começaremos com a estrutura básica do jogo e, em seguida, adicionaremos funcionalidades como movimentação do personagem, colisões e pontuação.

### Estrutura básica do jogo

Primeiro, vamos criar a classe principal do nosso jogo, que chamaremos de `MyGame`. Esta classe será responsável por inicializar o jogo e gerenciar o loop principal.

```cpp
#include <iostream>
#include <string>

class MyGame {
public:
    MyGame() : isRunning(true) {}

    void Run() {
        Initialize();
        while (isRunning) {
            ProcessInput();
            Update();
            Render();
        }
        Shutdown();
    }

private:
    void Initialize() {
        std::cout << "Jogo inicializado!" << std::endl;
    }

    void ProcessInput() {
        // Aqui processaremos a entrada do usuário
    }

    void Update() {
        // Aqui atualizaremos o estado do jogo
    }

    void Render() {
        // Aqui renderizaremos o jogo
    }

    void Shutdown() {
        std::cout << "Jogo encerrado!" << std::endl;
    }

    bool isRunning;
};

int main() {
    MyGame game;
    game.Run();
    return 0;
}
```

### Movimentação do personagem

Agora, vamos adicionar um personagem que o jogador pode controlar. Para isso, criaremos uma classe `Player` com métodos para mover-se para a esquerda e para a direita.

```cpp
class Player {
public:
    Player() : x(0) {}

    void MoveLeft() {
        x--;
        std::cout << "Jogador moveu para a esquerda. Posição: " << x << std::endl;
    }

    void MoveRight() {
        x++;
        std::cout << "Jogador moveu para a direita. Posição: " << x << std::endl;
    }

private:
    int x;
};
```

Em seguida, integraremos o `Player` ao nosso jogo:

```cpp
class MyGame {
public:
    MyGame() : isRunning(true), player() {}

    void Run() {
        Initialize();
        while (isRunning) {
            ProcessInput();
            Update();
            Render();
        }
        Shutdown();
    }

private:
    void Initialize() {
        std::cout << "Jogo inicializado!" << std::endl;
    }

    void ProcessInput() {
        char input;
        std::cin >> input;
        if (input == 'a') {
            player.MoveLeft();
        } else if (input == 'd') {
            player.MoveRight();
        } else if (input == 'q') {
            isRunning = false;
        }
    }

    void Update() {
        // Atualizações do estado do jogo
    }

    void Render() {
        // Renderização do jogo
    }

    void Shutdown() {
        std::cout << "Jogo encerrado!" << std::endl;
    }

    bool isRunning;
    Player player;
};
```

### Colisões e pontuação

Vamos adicionar moedas que o jogador pode coletar. Primeiro, criaremos uma classe `Coin`:

```cpp
class Coin {
public:
    Coin(int pos) : position(pos), isCollected(false) {}

    void Collect() {
        isCollected = true;
        std::cout << "Moeda coletada!" << std::endl;
    }

    bool IsCollected() const {
        return isCollected;
    }

    int GetPosition() const {
        return position;
    }

private:
    int position;
    bool isCollected;
};
```

Agora, vamos integrar as moedas ao jogo e verificar colisões:

```cpp
class MyGame {
public:
    MyGame() : isRunning(true), player(), coin(5), score(0) {}

    void Run() {
        Initialize();
        while (isRunning) {
            ProcessInput();
            Update();
            Render();
        }
        Shutdown();
    }

private:
    void Initialize() {
        std::cout << "Jogo inicializado!" << std::endl;
    }

    void ProcessInput() {
        char input;
        std::cin >> input;
        if (input == 'a') {
            player.MoveLeft();
        } else if (input == 'd') {
            player.MoveRight();
        } else if (input == 'q') {
            isRunning = false;
        }
    }

    void Update() {
        if (player.GetPosition() == coin.GetPosition() && !coin.IsCollected()) {
            coin.Collect();
            score++;
        }
    }

    void Render() {
        std::cout << "Pontuação: " << score << std::endl;
    }

    void Shutdown() {
        std::cout << "Jogo encerrado!" << std::endl;
    }

    bool isRunning;
    Player player;
    Coin coin;
    int score;
};
```

### Exercício prático

Adicione um inimigo ao jogo que se move automaticamente para a esquerda e direita. Quando o jogador colidir com o inimigo, o jogo deve encerrar.

**Solução:**

```cpp
class Enemy {
public:
    Enemy() : x(10), direction(1) {}

    void Move() {
        x += direction;
        if (x <= 0 || x >= 20) {
            direction *= -1;
        }
        std::cout << "Inimigo moveu. Posição: " << x << std::endl;
    }

    int GetPosition() const {
        return x;
    }

private:
    int x;
    int direction;
};

class MyGame {
public:
    MyGame() : isRunning(true), player(), coin(5), enemy(), score(0) {}

    void Run() {
        Initialize();
        while (isRunning) {
            ProcessInput();
            Update();
            Render();
        }
        Shutdown();
    }

private:
    void Initialize() {
        std::cout << "Jogo inicializado!" << std::endl;
    }

    void ProcessInput() {
        char input;
        std::cin >> input;
        if (input == 'a') {
            player.MoveLeft();
        } else if (input == 'd') {
            player.MoveRight();
        } else if (input == 'q') {
            isRunning = false;
        }
    }

    void Update() {
        enemy.Move();
        if (player.GetPosition() == coin.GetPosition() && !coin.IsCollected()) {
            coin.Collect();
            score++;
        }
        if (player.GetPosition() == enemy.GetPosition()) {
            std::cout << "Colisão com inimigo! Game Over!" << std::endl;
            isRunning = false;
        }
    }

    void Render() {
        std::cout << "Pontuação: " << score << std::endl;
    }

    void Shutdown() {
        std::cout << "Jogo encerrado!" << std::endl;
    }

    bool isRunning;
    Player player;
    Coin coin;
    Enemy enemy;
    int score;
};
```