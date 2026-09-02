## Estruturas de controle: if e else

Imagine que você está programando um jogo de plataforma onde o personagem pode coletar moedas. Quando o jogador toca em uma moeda, você precisa:
1. Aumentar o contador de moedas
2. Fazer a moeda desaparecer
3. Tocar um efeito sonoro

Mas só deve fazer isso SE o jogador realmente tocou na moeda. É aí que entra o `if` (se, em português). Veja como isso funciona na prática:

```cpp
#include <iostream>

int main() {
    int moedasColetadas = 0;
    bool tocouMoeda = true;  // Simulando que o jogador tocou na moeda

    if (tocouMoeda) {
        moedasColetadas = moedasColetadas + 1;
        std::cout << "Moeda coletada! Total: " << moedasColetadas << std::endl;
    }

    return 0;
}
```

Saída do programa:
```
Moeda coletada! Total: 1
```

A estrutura básica do `if` é:
```cpp
if (condição) {
    // Código que executa apenas se a condição for verdadeira
}
```

O que acontece se `tocouMoeda` for `false`? Vamos testar:

```cpp
#include <iostream>

int main() {
    int moedasColetadas = 0;
    bool tocouMoeda = false;  // Agora o jogador NÃO tocou na moeda

    if (tocouMoeda) {
        moedasColetadas = moedasColetadas + 1;
        std::cout << "Moeda coletada! Total: " << moedasColetadas << std::endl;
    }

    std::cout << "Fim da verificação" << std::endl;
    return 0;
}
```

Saída:
```
Fim da verificação
```

Observe que quando `tocouMoeda` é `false`, todo o bloco dentro do `if` é ignorado. O programa pula direto para o código depois das chaves.

### Trabalhando com else

Agora vamos expandir nosso exemplo de jogo. Quando o jogador não coletar a moeda, queremos mostrar uma mensagem diferente. É aí que usamos o `else` (senão):

```cpp
#include <iostream>

int main() {
    int moedasColetadas = 0;
    bool tocouMoeda = false;

    if (tocouMoeda) {
        moedasColetadas = moedasColetadas + 1;
        std::cout << "Moeda coletada! Total: " << moedasColetadas << std::endl;
    } else {
        std::cout << "Você perdeu a moeda!" << std::endl;
    }

    return 0;
}
```

Saída:
```
Você perdeu a moeda!
```

A estrutura completa fica:
```cpp
if (condição) {
    // Executa se verdadeiro
} else {
    // Executa se falso
}
```

### Condições mais complexas

No desenvolvimento de jogos, raramente usamos condições simples como no exemplo anterior. Vamos criar um sistema de vida onde:
- Se o jogador tem mais de 70% de vida: status "Saudável"
- Entre 30% e 70%: "Machucado"
- Menos de 30%: "Perigo"

```cpp
#include <iostream>

int main() {
    float vidaAtual = 25.0f;  // 25% de vida
    float vidaMaxima = 100.0f;

    float porcentagemVida = (vidaAtual / vidaMaxima) * 100;

    if (porcentagemVida > 70.0f) {
        std::cout << "Status: Saudável" << std::endl;
    } else if (porcentagemVida > 30.0f) {
        std::cout << "Status: Machucado" << std::endl;
    } else {
        std::cout << "Status: Perigo!" << std::endl;
    }

    return 0;
}
```

Saída:
```
Status: Perigo!
```

### Erro comum: esquecer as chaves

Um erro frequente é omitir as chaves quando há apenas uma linha no bloco:

```cpp
if (tocouMoeda)
    std::cout << "Moeda coletada!" << std::endl;  // Funciona
    moedasColetadas++;  // SEMPRE executa, mesmo sem tocar na moeda!
```

Mesmo que pareça funcionar, isso é perigoso. Sem as chaves, apenas a primeira linha depois do `if` é condicional. As demais executam sempre. O correto é:

```cpp
if (tocouMoeda) {
    std::cout << "Moeda coletada!" << std::endl;
    moedasColetadas++;
}
```

### Exercício prático

Crie um sistema simples de verificação de idade para um jogo:
- Se a idade for menor que 12: mostrar "Modo infantil ativado"
- Entre 12 e 18: mostrar "Modo adolescente"
- Maior ou igual a 18: mostrar "Modo adulto"

Solução comentada:

```cpp
#include <iostream>

int main() {
    int idade = 15;  // Teste com diferentes valores

    if (idade < 12) {
        std::cout << "Modo infantil ativado" << std::endl;
    } else if (idade < 18) {
        std::cout << "Modo adolescente" << std::endl;
    } else {
        std::cout << "Modo adulto" << std::endl;
    }

    return 0;
}
```