## Estruturas e uniões

Em jogos, frequentemente precisamos agrupar dados relacionados. Por exemplo, para representar um inimigo, podemos precisar armazenar sua saúde, posição e estado atual. Em C++, usamos **estruturas** (structs) para isso.

Uma estrutura define um novo tipo personalizado que pode conter múltiplos membros de diferentes tipos. Veja como criar e usar uma estrutura para representar um inimigo:

```cpp
#include <iostream>
#include <string>

struct Inimigo {
    std::string nome;
    int saude;
    float posicaoX;
    float posicaoY;
    bool estaVivo;
};

int main() {
    Inimigo inimigo1;
    inimigo1.nome = "Orc";
    inimigo1.saude = 100;
    inimigo1.posicaoX = 10.5f;
    inimigo1.posicaoY = 5.0f;
    inimigo1.estaVivo = true;

    std::cout << "Inimigo: " << inimigo1.nome << "\n"
              << "Saúde: " << inimigo1.saude << "\n"
              << "Posição: (" << inimigo1.posicaoX << ", " << inimigo1.posicaoY << ")\n"
              << "Estado: " << (inimigo1.estaVivo ? "Vivo" : "Morto") << "\n";

    return 0;
}
```

Saída:
```
Inimigo: Orc
Saúde: 100
Posição: (10.5, 5)
Estado: Vivo
```

Estruturas são semelhantes a classes, mas por padrão todos seus membros são públicos (acessíveis de qualquer lugar). Isso as torna ideais para simples agrupamentos de dados onde não precisamos de encapsulamento.

Podemos inicializar estruturas diretamente usando listas de inicialização:

```cpp
Inimigo inimigo2 = {"Goblin", 50, 3.2f, 7.8f, true};
```

**Uniões** são outro tipo especial que permite armazenar diferentes tipos de dados no mesmo local de memória. A cada momento, apenas um membro pode estar ativo. Isso economiza memória quando sabemos que precisamos apenas de um tipo por vez.

Aqui está um exemplo de união para armazenar diferentes tipos de dados de evento:

```cpp
#include <iostream>

union Evento {
    int tipo;
    float valorFlutuante;
    char caractere;
};

int main() {
    Evento evento;
    evento.tipo = 1;

    std::cout << "Tipo do evento: " << evento.tipo << "\n";

    evento.valorFlutuante = 3.14f;
    std::cout << "Valor flutuante: " << evento.valorFlutuante << "\n";
    // Acesso a 'tipo' agora retornará valor indefinido

    return 0;
}
```

Saída:
```
Tipo do evento: 1
Valor flutuante: 3.14
```

Observe que ao atribuir a `valorFlutuante`, o valor anterior de `tipo` é sobrescrito. Uniões são úteis quando precisamos de economia de memória extrema ou quando lidamos com dados que podem ser interpretados de múltiplas maneiras.

Um erro comum é tentar acessar o membro errado de uma união:

```cpp
Evento evento;
evento.valorFlutuante = 2.71f;
std::cout << evento.tipo; // Comportamento indefinido!
```

Para evitar isso, muitas vezes usamos uniões dentro de estruturas com um campo adicional que indica qual membro está ativo:

```cpp
struct EventoComTipo {
    int tipoAtivo;
    union {
        int inteiro;
        float flutuante;
        char caractere;
    } dados;
};

EventoComTipo evento;
evento.tipoAtivo = 2;
evento.dados.flutuante = 1.618f;

if (evento.tipoAtivo == 2) {
    std::cout << "Valor flutuante: " << evento.dados.flutuante << "\n";
}
```

Saída:
```
Valor flutuante: 1.618
```

Exercício: Crie uma estrutura `Personagem` que contenha nome, nível, experiência e pontos de vida. Crie uma função que receba um personagem e aumente seu nível, resetando a experiência para 0 e aumentando os pontos de vida em 10%. Mostre o resultado.

Solução:

```cpp
#include <iostream>
#include <string>

struct Personagem {
    std::string nome;
    int nivel;
    float experiencia;
    int pontosVida;
};

void subirNivel(Personagem& p) {
    p.nivel++;
    p.experiencia = 0;
    p.pontosVida = static_cast<int>(p.pontosVida * 1.1);
}

int main() {
    Personagem heroi = {"Herói", 1, 100.0f, 100};
    subirNivel(heroi);

    std::cout << "Nome: " << heroi.nome << "\n"
              << "Nível: " << heroi.nivel << "\n"
              << "Experiência: " << heroi.experiencia << "\n"
              << "Pontos de Vida: " << heroi.pontosVida << "\n";

    return 0;
}
```

Saída:
```
Nome: Herói
Nível: 2
Experiência: 0
Pontos de Vida: 110
```