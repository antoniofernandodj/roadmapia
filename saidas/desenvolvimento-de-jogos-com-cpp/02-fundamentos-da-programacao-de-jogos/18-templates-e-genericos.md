## Templates e genéricos

Imagine que você está criando um sistema de inventário para seu jogo. Você precisa de uma classe para armazenar moedas, outra para poções, armas, chaves... Todas fazem basicamente a mesma coisa - guardam um item com quantidade - mas com tipos diferentes. Criar uma classe para cada tipo seria tedioso e difícil de manter. É aqui que templates salvam o dia.

Um template em C++ é como um molde que gera código para você. Veja como criar uma classe `Inventario` que funciona com qualquer tipo:

```cpp
template <typename T>
class Inventario {
private:
    T item;
    int quantidade;
    
public:
    Inventario(T novoItem, int qtd) : item(novoItem), quantidade(qtd) {}
    
    void Adicionar(int qtd) { quantidade += qtd; }
    void Remover(int qtd) { quantidade = FMath::Max(0, quantidade - qtd); }
    T GetItem() const { return item; }
    int GetQuantidade() const { return quantidade; }
};
```

Agora podemos usar com diferentes tipos:

```cpp
Inventario<FString> moedas("Moeda de Ouro", 10);
Inventario<int> poções(1, 5); // ID da poção
Inventario<AActor*> chave(ChaveMestra, 1); // Ponteiro para o ator chave
```

O compilador gera versões específicas da classe `Inventario` para cada tipo usado. Se você tentar usar um tipo incompatível, como passar um `FVector` onde espera operações aritméticas, verá:

```
error: no match for 'operator+=' (operand types are 'FVector' and 'int')
```

Templates não são limitados a classes. Funções também podem ser templates. Vamos criar uma função para trocar itens entre inventários:

```cpp
template <typename T>
void TrocarItens(Inventario<T>& a, Inventario<T>& b) {
    T tempItem = a.GetItem();
    int tempQtd = a.GetQuantidade();
    
    a = Inventario<T>(b.GetItem(), b.GetQuantidade());
    b = Inventario<T>(tempItem, tempQtd);
}
```

Na Unreal Engine, templates são usados intensivamente. O `TArray` que você já usa é um template:

```cpp
TArray<AInimigo*> InimigosAtivos;
TArray<FVector> PosicoesCheckpoint;
```

Um erro comum é esquecer de incluir a definição do template. Se você tentar usar `Inventario` em outro arquivo sem incluir sua definição, verá:

```
error: 'Inventario' was not declared in this scope
```

A solução é garantir que toda a definição do template esteja disponível - geralmente no arquivo de cabeçalho.

**Exercício**: Crie uma template function `CombinarInventarios` que recebe dois `Inventario<T>` e retorna um novo com a soma das quantidades. Os itens devem ser do mesmo tipo.

```cpp
// Solução:
template <typename T>
Inventario<T> CombinarInventarios(const Inventario<T>& a, const Inventario<T>& b) {
    // Verifica se são o mesmo item
    if (a.GetItem() == b.GetItem()) {
        return Inventario<T>(a.GetItem(), a.GetQuantidade() + b.GetQuantidade());
    }
    // Retorna vazio se tipos diferentes
    return Inventario<T>(T(), 0); 
}
```