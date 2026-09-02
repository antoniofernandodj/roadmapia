## Ponteiros e referências

Imagine que você está criando um sistema de inventário para seu jogo. Cada item precisa ser acessado e modificado em diferentes partes do código - na interface, no combate, ao ser coletado. Como compartilhar eficientemente esses dados sem fazer cópias desnecessárias? É aqui que ponteiros e referências entram.

Um ponteiro é uma variável que armazena o endereço de memória de outra variável. Vamos ver na prática:

```cpp
#include <iostream>

int main() {
    int vidaJogador = 100;
    int* ponteiroVida = &vidaJogador; // & obtém o endereço
    
    std::cout << "Valor da vida: " << vidaJogador << std::endl;
    std::cout << "Endereço da vida: " << ponteiroVida << std::endl;
    std::cout << "Valor via ponteiro: " << *ponteiroVida << std::endl;
    
    *ponteiroVida = 50; // Modifica o valor original
    std::cout << "Vida após modificação: " << vidaJogador << std::endl;
    
    return 0;
}
```

Saída:
```
Valor da vida: 100
Endereço da vida: 0x7ffee3a5c7fc
Valor via ponteiro: 100
Vida após modificação: 50
```

Um erro comum é esquecer de inicializar o ponteiro, o que pode causar crashes:

```cpp
int* ponteiroPerigoso; // Não inicializado
*ponteiroPerigoso = 10; // Comportamento indefinido!
```

O compilador emite o aviso: `warning: 'ponteiroPerigoso' is used uninitialized in this function`. A solução é sempre inicializar com `nullptr` ou um endereço válido.

Referências são como apelidos para variáveis existentes. Elas não ocupam espaço adicional na memória e devem ser inicializadas na declaração:

```cpp
int manaJogador = 200;
int& refMana = manaJogador; // Deve ser inicializada

refMana = 150; // Modifica manaJogador
std::cout << "Mana via referência: " << refMana 
          << ", mana original: " << manaJogador << std::endl;
```

Saída:
```
Mana via referência: 150, mana original: 150
```

A principal diferença prática entre ponteiros e referências é que:
- Ponteiros podem ser reatribuídos (apontar para outro endereço)
- Referências são fixas após inicialização
- Ponteiros podem ser nulos (`nullptr`), referências não
- Sintaxe de acesso: ponteiros usam `*`, referências usam nome direto

Em jogos, referências são frequentemente usadas em parâmetros de função para evitar cópia:

```cpp
void aplicarDano(int& vidaAlvo, int quantidade) {
    vidaAlvo -= quantidade;
}

int main() {
    int vidaInimigo = 75;
    aplicarDano(vidaInimigo, 20);
    std::cout << "Vida restante: " << vidaInimigo << std::endl;
    return 0;
}
```

Saída:
```
Vida restante: 55
```

Um padrão comum na Unreal Engine é usar ponteiros para objetos do jogo. Por exemplo, ao acessar um componente:

```cpp
// Exemplo Unreal Engine (conceitual)
UStaticMeshComponent* Mesh = GetOwner()->FindComponentByClass<UStaticMeshComponent>();
if (Mesh != nullptr) {
    Mesh->SetVisibility(false); // Esconde o componente
}
```

**Exercício**: Crie uma função `trocarItens` que recebe dois ponteiros para inteiros (representando itens no inventário) e troca seus valores. Teste com itens 10 e 20.

Solução:

```cpp
void trocarItens(int* item1, int* item2) {
    int temp = *item1;
    *item1 = *item2;
    *item2 = temp;
}

int main() {
    int espada = 10;
    int escudo = 20;
    
    trocarItens(&espada, &escudo);
    
    std::cout << "Espada: " << espada << ", Escudo: " << escudo << std::endl;
    return 0;
}
```

Saída:
```
Espada: 20, Escudo: 10
```