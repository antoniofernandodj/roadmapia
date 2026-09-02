## Algoritmos de pathfinding

Imagine um inimigo em seu jogo que precisa encontrar o caminho até o jogador, mas está separado por paredes e obstáculos. Movê-lo em linha reta não funciona, e fazer ele andar aleatoriamente parece pouco inteligente. É aqui que os algoritmos de pathfinding entram em cena - eles calculam rotas eficientes em ambientes complexos.

Vamos implementar o algoritmo A* (A-estrela), o mais usado em jogos por equilibrar desempenho e resultados. Ele funciona como um GPS que:

1. Conhece o ponto de partida (nó inicial) e destino (nó final)
2. Calcula o custo do caminho até agora (g)
3. Estima o custo restante até o destino (h)
4. Prioriza os nós com menor custo total (f = g + h)

Primeiro, precisamos representar nosso cenário como uma grade navegável. No Unreal Engine, podemos usar um `NavMeshBoundsVolume` para definir áreas caminháveis, mas para nosso exemplo em C++ puro:

```cpp
#include <vector>
#include <algorithm>
#include <cmath>

struct Node {
    int x, y; // Posição na grade
    bool walkable; // Se o nó é atravessável
    float gCost, hCost; // Custos g e h
    Node* parent; // Nó anterior no caminho

    float fCost() { return gCost + hCost; }
};

class AStar {
private:
    std::vector<std::vector<Node>> grid;
    std::vector<Node*> openSet;
    std::vector<Node*> closedSet;
    Node* startNode;
    Node* targetNode;

    // Calcula distância entre dois nós (heurística)
    float calculateDistance(Node* a, Node* b) {
        return sqrt(pow(a->x - b->x, 2) + pow(a->y - b->y, 2));
    }
```

Ao executar esse código sem definir os nós inicial e final, receberemos um erro comum:

```
error: 'startNode' is used uninitialized in this function
```

Corrigimos inicializando os nós antes de usar:

```cpp
public:
    void FindPath(Node start, Node target) {
        startNode = &start;
        targetNode = &target;
        openSet.push_back(startNode);

        while (!openSet.empty()) {
            // Encontra o nó com menor fCost na openSet
            Node* currentNode = openSet[0];
            for (Node* node : openSet) {
                if (node->fCost() < currentNode->fCost() || 
                   (node->fCost() == currentNode->fCost() && node->hCost < currentNode->hCost)) {
                    currentNode = node;
                }
            }

            // Remove o nó atual da openSet e adiciona à closedSet
            openSet.erase(std::remove(openSet.begin(), openSet.end(), currentNode), openSet.end());
            closedSet.push_back(currentNode);

            // Chegou ao destino
            if (currentNode == targetNode) {
                RetracePath(startNode, targetNode);
                return;
            }

            // Analisa vizinhos
            for (Node* neighbor : GetNeighbors(currentNode)) {
                if (!neighbor->walkable || std::find(closedSet.begin(), closedSet.end(), neighbor) != closedSet.end())
                    continue;

                float newCostToNeighbor = currentNode->gCost + calculateDistance(currentNode, neighbor);
                if (newCostToNeighbor < neighbor->gCost || 
                    std::find(openSet.begin(), openSet.end(), neighbor) == openSet.end()) {
                    neighbor->gCost = newCostToNeighbor;
                    neighbor->hCost = calculateDistance(neighbor, targetNode);
                    neighbor->parent = currentNode;

                    if (std::find(openSet.begin(), openSet.end(), neighbor) == openSet.end())
                        openSet.push_back(neighbor);
                }
            }
        }
    }
```

O método `RetracePath` reconstrói o caminho do final ao início:

```cpp
    std::vector<Node*> RetracePath(Node* startNode, Node* endNode) {
        std::vector<Node*> path;
        Node* currentNode = endNode;

        while (currentNode != startNode) {
            path.push_back(currentNode);
            currentNode = currentNode->parent;
        }
        std::reverse(path.begin(), path.end());
        return path;
    }
```

Para testar, criamos uma grade 5x5 com alguns obstáculos:

```cpp
int main() {
    std::vector<std::vector<Node>> grid(5, std::vector<Node>(5));
    
    // Inicializa grid
    for (int x = 0; x < 5; x++) {
        for (int y = 0; y < 5; y++) {
            grid[x][y] = Node{x, y, true, 0, 0, nullptr};
        }
    }

    // Adiciona obstáculos
    grid[2][1].walkable = false;
    grid[2][2].walkable = false;
    grid[2][3].walkable = false;

    AStar pathfinder;
    pathfinder.SetGrid(grid);
    pathfinder.FindPath(grid[0][0], grid[4][4]);

    return 0;
}
```

O caminho calculado contornará os obstáculos centrais. Se você esquecer de marcar os nós como não caminháveis, o inimigo atravessará paredes - um erro comum que quebra a imersão do jogo.

**Exercício**: Modifique o código para lidar com terrenos de custo variável (ex: grama = custo 1, areia = custo 2, água = custo 3). A solução requer ajustar o cálculo de `gCost` para considerar esses valores.

**Solução**:

```cpp
struct Node {
    // ... outros campos
    float movementCost = 1.0f; // Custo padrão

    float fCost() { return gCost + hCost * movementCost; }
};

// No cálculo do custo:
float newCostToNeighbor = currentNode->gCost + 
                         calculateDistance(currentNode, neighbor) * 
                         neighbor->movementCost;
```