## Estruturas de controle: switch

Imagine que você está programando o sistema de diálogos de um NPC (Personagem Não-Jogável) em seu jogo. O jogador pressiona teclas numéricas (1 a 4) para escolher diferentes respostas, e cada escolha deve disparar uma reação diferente do personagem. Usar uma sequência de `if-else` ficaria assim:

```cpp
#include <iostream>
using namespace std;

int main() {
    int escolha;
    cout << "Escolha sua resposta (1-4): ";
    cin >> escolha;

    if (escolha == 1) {
        cout << "NPC: Você é corajoso!" << endl;
    } 
    else if (escolha == 2) {
        cout << "NPC: Isso foi inesperado..." << endl;
    }
    else if (escolha == 3) {
        cout << "NPC: Hmm, interessante." << endl;
    }
    else if (escolha == 4) {
        cout << "NPC: Eu não faria isso." << endl;
    }
    else {
        cout << "NPC: Não entendi sua escolha." << endl;
    }
}
```

Isso funciona, mas quando temos muitas condições para testar a mesma variável, o `switch` oferece uma alternativa mais limpa e legível:

```cpp
#include <iostream>
using namespace std;

int main() {
    int escolha;
    cout << "Escolha sua resposta (1-4): ";
    cin >> escolha;

    switch (escolha) {
        case 1:
            cout << "NPC: Você é corajoso!" << endl;
            break;
        case 2:
            cout << "NPC: Isso foi inesperado..." << endl;
            break;
        case 3:
            cout << "NPC: Hmm, interessante." << endl;
            break;
        case 4:
            cout << "NPC: Eu não faria isso." << endl;
            break;
        default:
            cout << "NPC: Não entendi sua escolha." << endl;
    }
}
```

### Como o switch funciona

1. **Expressão avaliada**: O valor entre parênteses após `switch` é comparado com cada `case`.
2. **Casos**: Cada `case` é um valor possível. Quando há correspondência, o código desse bloco é executado.
3. **Break**: Fundamental para sair do `switch` após executar um caso. Sem ele, a execução "cai" para o próximo caso.
4. **Default**: Opcional, executa se nenhum caso corresponder.

Experimente remover os `break` e veja o que acontece:

```cpp
switch (escolha) {
    case 1:
        cout << "NPC: Você é corajoso!" << endl;
    case 2:
        cout << "NPC: Isso foi inesperado..." << endl;
    case 3:
        cout << "NPC: Hmm, interessante." << endl;
        break;
}
```

Se o jogador escolher 1, verá TODAS as mensagens até encontrar um `break`. Esse comportamento é útil em raras situações, como quando múltiplas escolhas devem disparar a mesma ação.

### Aplicação em jogos

No Unreal Engine, você pode usar `switch` para gerenciar estados do jogo. Por exemplo, um inimigo com diferentes comportamentos baseados em seu estado atual:

```cpp
enum class EstadoInimigo { Patrulhando, Perseguindo, Atacando, Fugindo };

EstadoInimigo estado = EstadoInimigo::Patrulhando;

switch (estado) {
    case EstadoInimigo::Patrulhando:
        // Lógica de patrulha
        break;
    case EstadoInimigo::Perseguindo:
        // Lógica de perseguição
        break;
    case EstadoInimigo::Atacando:
        // Lógica de ataque
        break;
    case EstadoInimigo::Fugindo:
        // Lógica de fuga
        break;
}
```

### Erro comum e como corrigir

O switch só funciona com tipos inteiros (incluindo `char` e `enum`). Tentar usar strings ou floats causará um erro de compilação:

```cpp
string dia = "segunda";
switch (dia) {  // ERRO: switch quantity not an integer
    case "segunda":
        // ...
}
```

Para esses casos, use `if-else`. Outro erro comum é esquecer o `default`, que captura entradas inesperadas - essencial para evitar bugs em jogos.

### Exercício prático

Crie um programa que simule um menu de pause em um jogo:
1. Mostre opções: "Continuar", "Salvar", "Configurações", "Sair"
2. Use `switch` para processar a escolha do jogador (1-4)
3. Inclua um `default` para opções inválidas

Solução comentada:

```cpp
#include <iostream>
using namespace std;

int main() {
    int opcao;
    cout << "Menu de Pause:\n";
    cout << "1. Continuar\n2. Salvar\n3. Configurações\n4. Sair\n";
    cout << "Escolha: ";
    cin >> opcao;

    switch (opcao) {
        case 1:
            cout << "Retornando ao jogo..." << endl;
            break;
        case 2:
            cout << "Jogo salvo com sucesso!" << endl;
            break;
        case 3:
            cout << "Abrindo menu de configurações..." << endl;
            break;
        case 4:
            cout << "Saindo para o menu principal." << endl;
            break;
        default:
            cout << "Opção inválida. Tente novamente." << endl;
    }
}
```