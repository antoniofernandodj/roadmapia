## Templates e genéricos em C++

Imagine que você está desenvolvendo um jogo e precisa criar um sistema de inventário que pode armazenar diferentes tipos de itens, como armas, poções e armaduras. Cada tipo de item tem características específicas, mas você quer que o código para adicionar, remover e listar itens seja o mesmo, independentemente do tipo. Aqui é onde os templates em C++ entram em jogo.

### O que são templates?

Templates são uma ferramenta poderosa em C++ que permite escrever código genérico. Eles permitem que você crie funções ou classes que funcionam com qualquer tipo de dado, sem precisar reescrever o código para cada tipo específico. Isso aumenta a reutilização de código e reduz a redundância.

### Exemplo prático: Criando uma função genérica

Vamos começar com um exemplo simples. Suponha que você quer criar uma função que retorna o maior valor entre dois números. Em vez de escrever uma função para `int`, outra para `float`, e assim por diante, você pode usar um template.

```cpp
template <typename T>
T Max(T a, T b) {
    return (a > b) ? a : b;
}
```

Aqui, `typename T` é um placeholder para qualquer tipo de dado. Quando você chama a função `Max`, o compilador substitui `T` pelo tipo real dos argumentos que você passa.

```cpp
int main() {
    int intMax = Max(3, 7);
    float floatMax = Max(6.7f, 8.9f);
    UE_LOG(LogTemp, Warning, TEXT("Maior inteiro: %d"), intMax);
    UE_LOG(LogTemp, Warning, TEXT("Maior float: %f"), floatMax);
    return 0;
}
```

Saída:
```
Maior inteiro: 7
Maior float: 8.900000
```

### Criando uma classe genérica

Agora, vamos criar uma classe genérica para nosso sistema de inventário. Queremos que essa classe possa armazenar qualquer tipo de item.

```cpp
template <typename ItemType>
class Inventory {
private:
    TArray<ItemType> Items;

public:
    void AddItem(ItemType item) {
        Items.Add(item);
    }

    void RemoveItem(ItemType item) {
        Items.Remove(item);
    }

    void ListItems() {
        for (auto& Item : Items) {
            UE_LOG(LogTemp, Warning, TEXT("Item: %s"), *Item.GetName());
        }
    }
};
```

Aqui, `ItemType` pode ser qualquer tipo de item que você definir. Por exemplo, você pode criar uma classe `Weapon` e uma classe `Potion`, e ambas podem ser armazenadas em instâncias diferentes de `Inventory`.

```cpp
class Weapon {
public:
    FString GetName() const {
        return TEXT("Espada Flamejante");
    }
};

class Potion {
public:
    FString GetName() const {
        return TEXT("Poção de Cura");
    }
};

int main() {
    Inventory<Weapon> WeaponInventory;
    WeaponInventory.AddItem(Weapon());
    WeaponInventory.ListItems();

    Inventory<Potion> PotionInventory;
    PotionInventory.AddItem(Potion());
    PotionInventory.ListItems();

    return 0;
}
```

Saída:
```
Item: Espada Flamejante
Item: Poção de Cura
```

### Erro comum: Tipos incompatíveis

Um erro comum ao usar templates é tentar usar tipos incompatíveis. Por exemplo, se você tentar passar um `int` para uma função que espera um `FString`, o compilador vai gerar um erro.

```cpp
int main() {
    Inventory<FString> StringInventory;
    StringInventory.AddItem(42);  // Erro: não pode converter 'int' para 'FString'
    return 0;
}
```

Para evitar esse tipo de erro, sempre certifique-se de que os tipos que você está usando são compatíveis com o template.

### Exercício

Crie uma função template chamada `Swap` que troca os valores de duas variáveis de qualquer tipo. Teste a função com `int`, `float` e `FString`.

```cpp
template <typename T>
void Swap(T& a, T& b) {
    T temp = a;
    a = b;
    b = temp;
}

int main() {
    int a = 5, b = 10;
    Swap(a, b);
    UE_LOG(LogTemp, Warning, TEXT("a: %d, b: %d"), a, b);

    float c = 3.14f, d = 2.71f;
    Swap(c, d);
    UE_LOG(LogTemp, Warning, TEXT("c: %f, d: %f"), c, d);

    FString e = TEXT("Hello"), f = TEXT("World");
    Swap(e, f);
    UE_LOG(LogTemp, Warning, TEXT("e: %s, f: %s"), *e, *f);

    return 0;
}
```

Saída:
```
a: 10, b: 5
c: 2.710000, d: 3.140000
e: World, f: Hello
```

Templates são uma ferramenta essencial para escrever código genérico e reutilizável em C++, especialmente em projetos complexos como jogos. Eles permitem que você crie funções e classes que podem trabalhar com qualquer tipo de dado, aumentando a flexibilidade e a eficiência do seu código.