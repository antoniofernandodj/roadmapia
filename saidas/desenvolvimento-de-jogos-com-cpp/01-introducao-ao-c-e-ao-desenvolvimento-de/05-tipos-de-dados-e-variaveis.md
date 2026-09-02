## Tipos de dados e variáveis

Todo jogo precisa guardar informações - a vida do jogador, a pontuação, se uma porta está aberta ou fechada. Em C++, usamos variáveis para armazenar esses valores durante a execução do programa. Vamos começar com um problema real: queremos mostrar na tela a vida atual do personagem e atualizá-la quando ele sofrer dano.

```cpp
#include <iostream>

int main() {
    int vidaJogador = 100;  // Vida inicial do jogador
    std::cout << "Vida do jogador: " << vidaJogador << std::endl;
    
    // Jogador sofre 25 de dano
    vidaJogador = vidaJogador - 25;
    std::cout << "Vida após dano: " << vidaJogador << std::endl;

    return 0;
}
```

Saída:
```
Vida do jogador: 100
Vida após dano: 75
```

Aqui, `int vidaJogador = 100;` declara uma variável do tipo `int` (inteiro) chamada `vidaJogador` e atribui o valor 100. O `=` é o operador de atribuição, não de igualdade matemática.

### Tipos numéricos básicos

C++ oferece vários tipos para números, cada um com seu uso específico em jogos:

1. `int` - números inteiros (positivos ou negativos)
   ```cpp
   int inimigosDestruidos = 0;
   int nivelAtual = 3;
   ```

2. `float` - números decimais (precisão simples)
   ```cpp
   float posicaoX = 3.14f;
   float tempoDecorrido = 45.67f;
   ```

3. `double` - números decimais (precisão dupla)
   ```cpp
   double distanciaEntreObjetos = 12345.6789;
   ```

4. `bool` - valores booleanos (verdadeiro/falso)
   ```cpp
   bool jogadorVivo = true;
   bool nivelCompleto = false;
   ```

Experimente remover o `f` do final de um float - o compilador mostrará um aviso:
```
warning C4305: 'initializing': truncation from 'double' to 'float'
```

Isso acontece porque sem o `f`, o valor é considerado um `double` por padrão, e estamos tentando armazená-lo em uma variável `float`, que tem menos precisão.

### Caracteres e texto básico

Para armazenar caracteres individuais (como teclas pressionadas), usamos `char`:

```cpp
char teclaPressionada = 'W';  // Note as aspas simples
```

Para textos mais longos (como mensagens de diálogo), usamos `std::string`, mas precisamos incluir a biblioteca `<string>`:

```cpp
#include <string>

std::string nomeJogador = "Aragorn";
std::string mensagem = "Bem-vindo, " + nomeJogador + "!";
```

### Declaração vs. Inicialização

É importante distinguir entre declarar e inicializar variáveis:

```cpp
int pontos;         // Declaração (valor indeterminado)
pontos = 500;       // Atribuição posterior

int moedas = 10;    // Declaração com inicialização
```

Tentar usar uma variável não inicializada pode causar comportamentos imprevisíveis no jogo:

```cpp
int vidaExtra;
std::cout << vidaExtra;  // ERRO: variável não inicializada
```

O compilador pode avisar:
```
warning C4700: uninitialized local variable 'vidaExtra' used
```

### Constantes

Para valores que não devem mudar durante o jogo (como gravidade ou velocidade máxima), usamos `const`:

```cpp
const float GRAVIDADE = 9.8f;
const int VIDAS_INICIAIS = 3;
```

Tentar modificar uma constante resultará em erro:
```
error C3892: 'GRAVIDADE': you cannot assign to a variable that is const
```

### Convenções de nomenclatura

Para código limpo na Unreal Engine, siga estas convenções:
- Variáveis: camelCase (`vidaJogador`)
- Constantes: UPPER_CASE (`GRAVIDADE`)
- Booleans: prefixo `b` (`bEstaAtivo`)

### Exercício

Crie um programa que:
1. Declare variáveis para armazenar:
   - Nome do jogador (string)
   - Nível atual (int)
   - XP acumulado (float)
   - Se o jogador tem poder especial (bool)
2. Exiba esses valores formatados
3. Atualize o XP após ganhar 125.5 pontos
4. Mostre os novos valores

Solução comentada:

```cpp
#include <iostream>
#include <string>

int main() {
    // 1. Declaração das variáveis
    std::string nomeJogador = "Link";
    int nivelAtual = 5;
    float xp = 1250.0f;
    bool temPoder = true;

    // 2. Exibição inicial
    std::cout << "Jogador: " << nomeJogador << std::endl;
    std::cout << "Nivel: " << nivelAtual << std::endl;
    std::cout << "XP: " << xp << std::endl;
    std::cout << "Poder especial: " << (temPoder ? "Sim" : "Nao") << std::endl;

    // 3. Atualização do XP
    xp += 125.5f;  // Equivalente a xp = xp + 125.5f

    // 4. Exibição atualizada
    std::cout << "\nXP atualizado: " << xp << std::endl;

    return 0;
}
```

Saída esperada:
```
Jogador: Link
Nivel: 5
XP: 1250
Poder especial: Sim

XP atualizado: 1375.5
```