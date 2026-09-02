## Operadores aritméticos e lógicos

Em um jogo, quase toda ação envolve cálculos: o dano causado por uma espada, a trajetória de um projétil, a velocidade do personagem ao pular. Em C++, esses cálculos são feitos com operadores aritméticos, enquanto as decisões lógicas (como verificar se o jogador coletou todos os itens necessários) usam operadores lógicos.

### Operadores aritméticos básicos

Vamos simular o cálculo de dano em um combate. Quando um ataque acerta, o dano real pode variar devido a fatores como armadura ou bônus:

```cpp
#include <iostream>

int main() {
    int danoBase = 25;
    int bonusDano = 8;
    int reducaoArmadura = 5;
    
    int danoTotal = danoBase + bonusDano - reducaoArmadura;
    
    std::cout << "Dano causado: " << danoTotal << std::endl;
    
    // Cálculo de dano crítico (aumenta 150%)
    float multiplicadorCritico = 1.5f;
    float danoCritico = danoTotal * multiplicadorCritico;
    
    std::cout << "Dano crítico: " << danoCritico << std::endl;
    
    return 0;
}
```

Saída:
```
Dano causado: 28
Dano crítico: 42
```

Os operadores básicos são:
- `+` (adição)
- `-` (subtração)
- `*` (multiplicação)
- `/` (divisão)
- `%` (módulo - resto da divisão)

Um erro comum é esquecer que a divisão entre inteiros resulta em um inteiro truncado:

```cpp
int vidaTotal = 100;
int pocaoCura = 30;
int numeroPocoes = vidaTotal / pocaoCura;

std::cout << "Poções necessárias: " << numeroPocoes << std::endl;
```

Saída:
```
Poções necessárias: 3
```

Apesar de 100/30 ser aproximadamente 3.333, o resultado é truncado para 3. Para obter o valor preciso, precisaríamos usar `float`:

```cpp
float pocaoCuraF = 30.0f;
float numeroPocoesF = vidaTotal / pocaoCuraF;
std::cout << "Poções precisas: " << numeroPocoesF << std::endl;
```

Saída:
```
Poções precisas: 3.33333
```

### Operadores de atribuição combinados

Em jogos, frequentemente atualizamos valores incrementando ou decrementando:

```cpp
int pontuacao = 0;
pontuacao += 100;  // Equivalente a: pontuacao = pontuacao + 100
pontuacao -= 10;   // Perde pontos por tempo
pontuacao *= 2;    // Bônus de dobro de pontos
```

Os operadores combinados são:
- `+=` (adição)
- `-=` (subtração)
- `*=` (multiplicação)
- `/=` (divisão)
- `%=` (módulo)

### Operadores de incremento e decremento

Contadores são essenciais em jogos para vidas, munição, tempo, etc. C++ oferece operadores específicos:

```cpp
int vidas = 3;
vidas++;  // Incrementa após usar o valor
++vidas;  // Incrementa antes de usar o valor

int municao = 10;
municao--;  // Decrementa após usar
--municao;  // Decrementa antes de usar
```

A diferença entre pré e pós-incremento aparece quando usado em expressões:

```cpp
int contador1 = 5;
int resultado1 = contador1++ * 2;  // resultado1 = 10, contador1 = 6

int contador2 = 5;
int resultado2 = ++contador2 * 2;  // resultado2 = 12, contador2 = 6
```

### Operadores lógicos

Para tomar decisões em jogos (verificar se o jogador tem itens necessários, se um inimigo está no alcance, etc.), usamos operadores lógicos:

```cpp
bool temChave = true;
bool portaDestrancada = false;
bool podeAbrir = temChave && !portaDestrancada;

std::cout << "Pode abrir a porta? " << podeAbrir << std::endl;
```

Saída:
```
Pode abrir a porta? 1  // 1 representa true
```

Os operadores lógicos são:
- `&&` (E lógico) - verdadeiro se ambos operandos forem verdadeiros
- `||` (OU lógico) - verdadeiro se pelo menos um operando for verdadeiro
- `!` (NÃO lógico) - inverte o valor booleano

Um erro comum é confundir os operadores lógicos com os operadores bit a bit (`&` e `|`). Compare:

```cpp
bool resultadoLogico = true && false;  // false
int resultadoBit = 5 & 3;             // 1 (0101 & 0011 = 0001)
```

### Operadores de comparação

Para verificar condições como colisões ou limites de tela:

```cpp
float posicaoX = 120.5f;
float limiteTela = 800.0f;

bool colidiuDireita = posicaoX >= limiteTela;
bool dentroDaTela = posicaoX > 0 && posicaoX < limiteTela;
```

Operadores de comparação:
- `==` (igual a)
- `!=` (diferente de)
- `>` (maior que)
- `<` (menor que)
- `>=` (maior ou igual)
- `<=` (menor ou igual)

Cuidado com comparações de ponto flutuante devido a imprecisões:

```cpp
float a = 0.1f + 0.2f;
float b = 0.3f;
std::cout << (a == b) << std::endl;  // Pode ser 0 (false)
```

Em vez disso, compare com uma margem de erro:

```cpp
float epsilon = 0.0001f;
bool saoIguais = fabs(a - b) < epsilon;
```

### Um exemplo completo: sistema de experiência

Vamos implementar um sistema de level up baseado em experiência:

```cpp
#include <iostream>
#include <cmath>  // Para fabs

int main() {
    int nivel = 1;
    float experiencia = 0.0f;
    float expProximoNivel = 100.0f;
    float expGanha = 35.5f;
    
    experiencia += expGanha;
    
    std::cout << "Experiência atual: " << experiencia << "/" << expProximoNivel << std::endl;
    
    bool subiuNivel = experiencia >= expProximoNivel;
    std::cout << "Subiu de nível? " << subiuNivel << std::endl;
    
    // Se faltou pouco para subir de nível
    float faltaExp = expProximoNivel - experiencia;
    bool estaPerto = faltaExp < 15.0f;
    std::cout << "Está perto de subir? " << estaPerto << std::endl;
    
    return 0;
}
```

Saída:
```
Experiência atual: 35.5/100
Subiu de nível? 0
Está perto de subir? 0
```

### Exercício

Implemente um sistema simples de coleta de moedas onde:
1. Cada moeda vale 10 pontos
2. Quando o jogador coleta 5 moedas, ganha uma vida extra
3. O jogador começa com 3 vidas
4. Mostre o número de moedas coletadas, pontos totais e vidas atuais

Solução comentada:

```cpp
#include <iostream>

int main() {
    int moedas = 0;
    int pontos = 0;
    int vidas = 3;
    
    // Simula coletar 7 moedas
    moedas += 7;
    pontos = moedas * 10;
    
    // Verifica se ganhou vida extra
    if (moedas >= 5) {
        vidas += moedas / 5;  // Divisão inteira
        moedas = moedas % 5;  // Mantém o resto
    }
    
    std::cout << "Moedas: " << moedas 
              << "\nPontos: " << pontos 
              << "\nVidas: " << vidas << std::endl;
    
    return 0;
}
```

Saída:
```
Moedas: 2
Pontos: 70
Vidas: 4
```

Explicação:
- Foram coletadas 7 moedas (70 pontos)
- 7 / 5 = 1 vida extra (restam 2 moedas)
- Total de vidas: 3 iniciais + 1 extra = 4