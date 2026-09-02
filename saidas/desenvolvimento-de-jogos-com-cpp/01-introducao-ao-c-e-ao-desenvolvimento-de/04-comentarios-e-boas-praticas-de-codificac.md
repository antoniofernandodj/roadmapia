## Comentários e boas práticas de codificação

Quando você escreve código em C++, sua prioridade não é apenas fazer o programa funcionar, mas garantir que ele seja fácil de entender e manter. Isso é especialmente importante em projetos de jogos, onde o código pode crescer rapidamente e ser modificado por várias pessoas ao longo do tempo. Para ajudar nisso, existem **comentários** e **boas práticas de codificação**.

### Comentários em C++

Comentários são trechos de texto que o compilador ignora, mas que servem para explicar o código para quem está lendo. Em C++, existem dois tipos principais de comentários:

1. **Comentários de linha única**: Começam com `//` e continuam até o final da linha.
2. **Comentários de múltiplas linhas**: Começam com `/*` e terminam com `*/`.

Veja um exemplo prático:

```cpp
#include <iostream>

int main() {
    // Exibe uma mensagem de boas-vindas no console
    std::cout << "Bem-vindo ao meu jogo!" << std::endl;

    /* 
       Aqui começamos a definir as regras do jogo.
       Este bloco de comentário pode abranger várias linhas.
    */
    int vidaDoJogador = 100;  // Vida inicial do jogador

    return 0;
}
```

**Saída:**
```
Bem-vindo ao meu jogo!
```

Comentários são úteis para explicar o propósito de uma função, o significado de uma variável ou o funcionamento de um algoritmo complexo. No entanto, evite comentários óbvios ou redundantes. Por exemplo:

```cpp
int vida = 100;  // Define a vida como 100
```

Esse comentário não acrescenta nada, pois o código já é autoexplicativo.

### Boas práticas de codificação

Além dos comentários, existem várias práticas que tornam o código mais legível e organizado. Aqui estão algumas das mais importantes:

1. **Nomes descritivos para variáveis e funções**: Escolha nomes que indiquem claramente o propósito da variável ou função. Por exemplo, `pontuacaoDoJogador` é melhor que `p`.

```cpp
int pontuacaoDoJogador = 0;  // Bom
int p = 0;                   // Ruim
```

2. **Indentação consistente**: Use espaços ou tabulações para organizar o código em blocos lógicos. Isso facilita a leitura e a identificação de erros.

```cpp
if (vidaDoJogador > 0) {
    std::cout << "Jogador ainda está vivo!" << std::endl;
} else {
    std::cout << "Jogador morreu!" << std::endl;
}
```

3. **Evitar linhas muito longas**: Se uma linha de código ficar muito extensa, divida-a em várias linhas para facilitar a leitura.

```cpp
std::cout << "O jogador coletou " << quantidadeDeMoedas 
          << " moedas e agora tem " << pontuacaoDoJogador 
          << " pontos!" << std::endl;
```

4. **Comentar apenas o necessário**: Comentários são úteis, mas em excesso podem poluir o código. Priorize comentários que explicam decisões complexas ou não óbvias.

5. **Organização do código**: Agrupe trechos de código relacionados e mantenha uma estrutura lógica. Por exemplo, todas as variáveis de inicialização podem estar no início da função `main`.

```cpp
int main() {
    int vidaDoJogador = 100;
    int pontuacaoDoJogador = 0;
    bool estaVivo = true;

    // Lógica do jogo aqui
    return 0;
}
```

### Erros comuns e como evitá-los

Um erro comum é esquecer de atualizar os comentários quando o código muda. Isso pode levar a confusões. Por exemplo:

```cpp
int vidaDoJogador = 50;  // Vida inicial do jogador é 100
```

Se você alterar o valor da variável, mas esquecer de atualizar o comentário, ele estará incorreto. Para evitar isso, mantenha os comentários sempre atualizados ou use nomes de variáveis tão descritivos que dispensem comentários.

### Exercício prático

Escreva um programa em C++ que calcula a pontuação final de um jogador com base na quantidade de moedas coletadas e no tempo restante. Use comentários para explicar cada parte do código e siga as boas práticas de codificação.

**Solução comentada:**

```cpp
#include <iostream>

int main() {
    // Variáveis iniciais
    int moedasColetadas = 30;  // Quantidade de moedas coletadas pelo jogador
    int tempoRestante = 120;   // Tempo restante em segundos

    // Cálculo da pontuação
    int pontuacaoFinal = moedasColetadas * 10 + tempoRestante;

    // Exibição do resultado
    std::cout << "Pontuação final do jogador: " << pontuacaoFinal << std::endl;

    return 0;
}
```

**Saída:**
```
Pontuação final do jogador: 420
```

Neste exemplo, os comentários explicam o propósito de cada variável e o cálculo da pontuação, enquanto o código segue boas práticas como nomes descritivos e organização lógica.