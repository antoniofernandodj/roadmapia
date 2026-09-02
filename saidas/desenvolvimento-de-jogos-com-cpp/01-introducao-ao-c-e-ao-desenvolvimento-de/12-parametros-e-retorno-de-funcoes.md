## Parâmetros e retorno de funções

Imagine que você está programando um sistema de dano para seu jogo. Sem funções com parâmetros, cada cálculo de ataque teria que ser reescrito manualmente:

```cpp
int danoJogador = 10;
int defesaInimigo1 = 5;
int vidaInimigo1 = 30;
vidaInimigo1 = vidaInimigo1 - (danoJogador - defesaInimigo1);

int defesaInimigo2 = 8;
int vidaInimigo2 = 45;
vidaInimigo2 = vidaInimigo2 - (danoJogador - defesaInimigo2);
```

Repetir esse código para cada inimigo é ineficiente. Uma função com parâmetros resolve isso:

```cpp
int calcularDano(int danoAtaque, int defesaAlvo, int vidaAlvo) {
    return vidaAlvo - (danoAtaque - defesaAlvo);
}

int main() {
    int danoJogador = 10;
    
    int vidaInimigo1 = calcularDano(danoJogador, 5, 30);
    int vidaInimigo2 = calcularDano(danoJogador, 8, 45);
    
    std::cout << "Vida Inimigo 1: " << vidaInimigo1 << std::endl;
    std::cout << "Vida Inimigo 2: " << vidaInimigo2 << std::endl;
    
    return 0;
}
```

Saída:
```
Vida Inimigo 1: 25
Vida Inimigo 2: 37
```

A função `calcularDano` recebe três parâmetros (valores de entrada) e retorna um resultado (valor de saída). Os parâmetros são como variáveis temporárias que existem apenas dentro da função.

### Passagem por valor vs. referência

Por padrão, C++ passa parâmetros por valor - cria cópias dos valores originais. Modificar o parâmetro dentro da função não afeta a variável original:

```cpp
void tentarAumentarDano(int dano) {
    dano = dano + 5;
    std::cout << "Dano dentro da função: " << dano << std::endl;
}

int main() {
    int danoBase = 10;
    tentarAumentarDano(danoBase);
    std::cout << "Dano após função: " << danoBase << std::endl;
    return 0;
}
```

Saída:
```
Dano dentro da função: 15
Dano após função: 10
```

Para modificar a variável original, usamos referências (veremos em detalhes posteriormente):

```cpp
void aumentarDano(int& dano) {
    dano = dano + 5;
}
```

### Retorno de valores

O tipo de retorno da função é declarado antes do nome. `void` significa "não retorna nada":

```cpp
// Retorna um float
float calcularVelocidade(float distancia, float tempo) {
    return distancia / tempo;
}

// Não retorna nada (void)
void exibirMensagem(string texto) {
    std::cout << texto << std::endl;
}
```

Erro comum: esquecer o `return` em funções não-void:

```cpp
int soma(int a, int b) {
    int resultado = a + b;
    // Esqueceu o return!
}

// Erro de compilação: "warning: control reaches end of non-void function"
```

### Parâmetros com valores padrão

Na Unreal Engine, é comum ver funções com parâmetros opcionais:

```cpp
void configurarPersonagem(string nome, int vida = 100, float velocidade = 1.0f) {
    // ...
}

int main() {
    configurarPersonagem("Herói"); // Usa vida=100 e velocidade=1.0
    configurarPersonagem("Vilão", 150); // vida=150, velocidade=1.0
    configurarPersonagem("NPC", 50, 0.5f); // Todos parâmetros especificados
    return 0;
}
```

### Exercício

Crie uma função `aplicarEfeitoElemental` que:
1. Recebe a vida atual do alvo (int)
2. Recebe o tipo de efeito (string: "fogo", "gelo" ou "raio")
3. Retorna a nova vida após aplicar o efeito:
   - Fogo: reduz vida em 25%
   - Gelo: reduz vida em 15%
   - Raio: reduz vida em 30%

Solução:

```cpp
int aplicarEfeitoElemental(int vida, string elemento) {
    if (elemento == "fogo") {
        return vida * 0.75;
    } else if (elemento == "gelo") {
        return vida * 0.85;
    } else if (elemento == "raio") {
        return vida * 0.7;
    }
    return vida; // Se elemento desconhecido, não altera
}

int main() {
    int vidaInimigo = 100;
    std::cout << "Fogo: " << aplicarEfeitoElemental(vidaInimigo, "fogo") << std::endl;
    std::cout << "Gelo: " << aplicarEfeitoElemental(vidaInimigo, "gelo") << std::endl;
    std::cout << "Raio: " << aplicarEfeitoElemental(vidaInimigo, "raio") << std::endl;
    return 0;
}
```