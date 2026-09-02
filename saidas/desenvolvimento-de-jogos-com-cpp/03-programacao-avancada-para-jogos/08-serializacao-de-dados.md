## Serialização de dados

Em desenvolvimento de jogos, frequentemente precisamos salvar o estado atual do jogo — como a posição do jogador, os itens coletados, ou o progresso em uma missão — para que o jogador possa continuar de onde parou. Esse processo de converter dados em um formato que pode ser armazenado ou transmitido é chamado de **serialização**. O inverso, reconstruir os dados a partir desse formato, é conhecido como **desserialização**.

### Por que serializar?

Imagine um jogo de plataforma onde o jogador coleta moedas e derrota inimigos. Sem serialização, toda vez que o jogador fecha o jogo, ele perderia todo o progresso. Para evitar isso, precisamos salvar essas informações em um arquivo ou banco de dados. A serialização permite que esses dados sejam armazenados de forma eficiente e recuperados posteriormente.

### Serialização básica em C++

Vamos começar com um exemplo simples. Suponha que temos uma estrutura `PlayerData` que armazena informações sobre o jogador:

```cpp
#include <iostream>
#include <fstream>

struct PlayerData {
    std::string name;
    int level;
    float health;
};
```

Para serializar essa estrutura, podemos escrever seus dados em um arquivo binário:

```cpp
void SerializePlayerData(const PlayerData& player, const std::string& filename) {
    std::ofstream outFile(filename, std::ios::binary);
    if (outFile.is_open()) {
        outFile.write(reinterpret_cast<const char*>(&player), sizeof(player));
        outFile.close();
    } else {
        std::cerr << "Erro ao abrir o arquivo para escrita." << std::endl;
    }
}
```

Aqui, `std::ofstream` é usado para criar um arquivo binário, e `reinterpret_cast` converte a estrutura `PlayerData` em um array de bytes que pode ser escrito no arquivo.

Para desserializar, lemos os dados de volta:

```cpp
PlayerData DeserializePlayerData(const std::string& filename) {
    PlayerData player;
    std::ifstream inFile(filename, std::ios::binary);
    if (inFile.is_open()) {
        inFile.read(reinterpret_cast<char*>(&player), sizeof(player));
        inFile.close();
    } else {
        std::cerr << "Erro ao abrir o arquivo para leitura." << std::endl;
    }
    return player;
}
```

### Problemas comuns e soluções

Um problema comum ao serializar estruturas complexas é que elas podem conter ponteiros ou objetos dinâmicos, que não podem ser serializados diretamente. Por exemplo, se `PlayerData` contivesse um `std::vector<std::string>`, o código acima não funcionaria corretamente.

Para resolver isso, precisamos serializar cada elemento individualmente:

```cpp
void SerializePlayerData(const PlayerData& player, const std::string& filename) {
    std::ofstream outFile(filename, std::ios::binary);
    if (outFile.is_open()) {
        size_t nameSize = player.name.size();
        outFile.write(reinterpret_cast<const char*>(&nameSize), sizeof(nameSize));
        outFile.write(player.name.c_str(), nameSize);
        outFile.write(reinterpret_cast<const char*>(&player.level), sizeof(player.level));
        outFile.write(reinterpret_cast<const char*>(&player.health), sizeof(player.health));
        outFile.close();
    } else {
        std::cerr << "Erro ao abrir o arquivo para escrita." << std::endl;
    }
}

PlayerData DeserializePlayerData(const std::string& filename) {
    PlayerData player;
    std::ifstream inFile(filename, std::ios::binary);
    if (inFile.is_open()) {
        size_t nameSize;
        inFile.read(reinterpret_cast<char*>(&nameSize), sizeof(nameSize));
        player.name.resize(nameSize);
        inFile.read(&player.name[0], nameSize);
        inFile.read(reinterpret_cast<char*>(&player.level), sizeof(player.level));
        inFile.read(reinterpret_cast<char*>(&player.health), sizeof(player.health));
        inFile.close();
    } else {
        std::cerr << "Erro ao abrir o arquivo para leitura." << std::endl;
    }
    return player;
}
```

### Exercício

Crie uma estrutura `GameState` que armazene o nome do jogador, a pontuação atual e o nível em que ele está. Implemente funções para serializar e desserializar essa estrutura. Teste seu código salvando e carregando os dados de um arquivo.

### Solução comentada

```cpp
#include <iostream>
#include <fstream>
#include <string>

struct GameState {
    std::string playerName;
    int score;
    int level;
};

void SerializeGameState(const GameState& state, const std::string& filename) {
    std::ofstream outFile(filename, std::ios::binary);
    if (outFile.is_open()) {
        size_t nameSize = state.playerName.size();
        outFile.write(reinterpret_cast<const char*>(&nameSize), sizeof(nameSize));
        outFile.write(state.playerName.c_str(), nameSize);
        outFile.write(reinterpret_cast<const char*>(&state.score), sizeof(state.score));
        outFile.write(reinterpret_cast<const char*>(&state.level), sizeof(state.level));
        outFile.close();
    } else {
        std::cerr << "Erro ao abrir o arquivo para escrita." << std::endl;
    }
}

GameState DeserializeGameState(const std::string& filename) {
    GameState state;
    std::ifstream inFile(filename, std::ios::binary);
    if (inFile.is_open()) {
        size_t nameSize;
        inFile.read(reinterpret_cast<char*>(&nameSize), sizeof(nameSize));
        state.playerName.resize(nameSize);
        inFile.read(&state.playerName[0], nameSize);
        inFile.read(reinterpret_cast<char*>(&state.score), sizeof(state.score));
        inFile.read(reinterpret_cast<char*>(&state.level), sizeof(state.level));
        inFile.close();
    } else {
        std::cerr << "Erro ao abrir o arquivo para leitura." << std::endl;
    }
    return state;
}

int main() {
    GameState state = {"Player1", 1000, 5};
    SerializeGameState(state, "gamestate.dat");

    GameState loadedState = DeserializeGameState("gamestate.dat");
    std::cout << "Nome: " << loadedState.playerName << ", Pontuação: " << loadedState.score << ", Nível: " << loadedState.level << std::endl;

    return 0;
}
```

Neste exemplo, serializamos e desserializamos uma estrutura `GameState` que contém o nome do jogador, a pontuação e o nível. O código funciona corretamente porque serializa cada campo individualmente, incluindo o tamanho da string `playerName`.