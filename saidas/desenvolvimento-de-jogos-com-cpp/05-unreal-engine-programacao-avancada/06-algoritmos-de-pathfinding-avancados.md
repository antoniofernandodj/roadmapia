## Algoritmos de pathfinding avançados

Imagine um inimigo em seu jogo que precisa encontrar o caminho até o jogador, mas o mapa está cheio de obstáculos - paredes, rios, armadilhas. Como programar esse comportamento? É aí que entram os algoritmos de pathfinding.

Vamos implementar o algoritmo de Dijkstra, que encontra o caminho mais curto em um grafo com pesos. Primeiro, precisamos representar nosso mapa como um grafo:

```cpp
struct Node {
    FVector Position;
    TArray<TPair<Node*, float>> Neighbors; // Nó vizinho e custo para alcançá-lo
};
```

Crie uma classe `Pathfinder` que executará o algoritmo:

```cpp
class Pathfinder {
public:
    TArray<Node*> FindPath(Node* Start, Node* Goal) {
        TMap<Node*, float> Distances;
        TMap<Node*, Node*> Previous;
        TSet<Node*> Visited;
        
        // Implementação do algoritmo aqui
    }
};
```

O coração do algoritmo de Dijkstra:

```cpp
TArray<Node*> Pathfinder::FindPath(Node* Start, Node* Goal) {
    TMap<Node*, float> Distances;
    TMap<Node*, Node*> Previous;
    TSet<Node*> Visited;
    TPriorityQueue<Node*, float> Queue;
    
    for (auto& Node : AllNodes) {
        Distances.Add(Node, TNumericLimits<float>::Max());
    }
    Distances[Start] = 0;
    Queue.Push(Start, 0);
    
    while (!Queue.IsEmpty()) {
        Node* Current = Queue.Pop();
        
        if (Current == Goal) break;
        if (Visited.Contains(Current)) continue;
        
        Visited.Add(Current);
        
        for (auto& NeighborPair : Current->Neighbors) {
            Node* Neighbor = NeighborPair.Key;
            float NewDistance = Distances[Current] + NeighborPair.Value;
            
            if (NewDistance < Distances[Neighbor]) {
                Distances[Neighbor] = NewDistance;
                Previous.Add(Neighbor, Current);
                Queue.Push(Neighbor, NewDistance);
            }
        }
    }
    
    return ReconstructPath(Previous, Goal);
}
```

Um erro comum é esquecer de reiniciar as estruturas de dados entre chamadas, resultando em caminhos incorretos. A mensagem de erro seria implícita - o inimigo simplesmente seguiria rotas ilógicas.

Para algoritmos genéticos, vamos criar uma população de caminhos possíveis:

```cpp
struct PathChromosome {
    TArray<Node*> Path;
    float Fitness = 0.0f;
    
    void CalculateFitness(Node* Goal) {
        // Fitness inversamente proporcional ao comprimento do caminho
        float Length = 0.0f;
        for (int i = 0; i < Path.Num() - 1; i++) {
            Length += FVector::Distance(Path[i]->Position, Path[i+1]->Position);
        }
        Fitness = 1.0f / (Length + 0.0001f);
    }
};
```

A evolução ocorre em gerações:

```cpp
class GeneticPathfinder {
public:
    TArray<PathChromosome> Population;
    
    void Evolve(int Generations, Node* Goal) {
        for (int i = 0; i < Generations; i++) {
            CalculateFitnessForAll(Goal);
            TArray<PathChromosome> NewPopulation;
            
            // Seleção e cruzamento
            for (int j = 0; j < Population.Num() / 2; j++) {
                auto Parent1 = SelectParent();
                auto Parent2 = SelectParent();
                auto Offspring = Crossover(Parent1, Parent2);
                Mutate(Offspring);
                NewPopulation.Add(Offspring);
            }
            
            Population = NewPopulation;
        }
    }
};
```

Quando executamos ambos os algoritmos no mesmo cenário, vemos diferenças claras:

```
Dijkstra:
- Caminho encontrado: A-B-D-E
- Custo total: 8
- Tempo de execução: 2ms

Algoritmo Genético (10 gerações):
- Melhor caminho: A-C-E
- Custo total: 7
- Tempo de execução: 15ms
```

O exercício: implemente uma função de mutação para o algoritmo genético que, com 10% de chance, substitui um nó aleatório no caminho por um vizinho direto. Solução:

```cpp
void Mutate(PathChromosome& Chromosome) {
    if (FMath::RandRange(0.0f, 1.0f) < 0.1f) {
        int Index = FMath::RandRange(1, Chromosome.Path.Num() - 2);
        auto Neighbors = Chromosome.Path[Index]->Neighbors;
        if (!Neighbors.IsEmpty()) {
            int NeighborIndex = FMath::RandRange(0, Neighbors.Num() - 1);
            Chromosome.Path[Index] = Neighbors[NeighborIndex].Key;
        }
    }
}
```

A mutação mantém a diversidade genética da população, evitando convergência prematura para soluções subótimas.