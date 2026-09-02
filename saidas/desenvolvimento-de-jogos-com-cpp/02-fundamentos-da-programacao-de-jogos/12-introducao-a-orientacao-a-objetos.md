## Introdução à orientação a objetos

Imagine que você está desenvolvendo um jogo de plataforma onde precisa controlar um personagem que pode pular, correr e coletar moedas. Se você pensar em tudo que o personagem precisa fazer — mover-se, detectar colisões, atualizar a pontuação — rapidamente perceberá que o código pode ficar confuso e difícil de manter. É aqui que a **orientação a objetos** entra em cena.

A orientação a objetos é uma forma de organizar seu código em torno de "objetos", que são representações de coisas do mundo real ou conceitos do jogo. Esses objetos encapsulam dados (propriedades) e comportamentos (métodos) relacionados, tornando o código mais modular e fácil de entender.

Vamos criar um exemplo simples: um personagem que pode se mover para a esquerda e direita. Em vez de escrever tudo em um único bloco de código, podemos criar uma classe chamada `Personagem`:

```cpp
class Personagem {
public:
    void MoverEsquerda() {
        PosicaoX -= Velocidade;
        UE_LOG(LogTemp, Log, TEXT("Movendo para a esquerda. Posição X: %f"), PosicaoX);
    }

    void MoverDireita() {
        PosicaoX += Velocidade;
        UE_LOG(LogTemp, Log, TEXT("Movendo para a direita. Posição X: %f"), PosicaoX);
    }

private:
    float PosicaoX = 0.0f;
    float Velocidade = 10.0f;
};
```

Aqui, `Personagem` é uma classe que define um objeto. Dentro dela, temos dois métodos públicos (`MoverEsquerda` e `MoverDireita`) que alteram a posição do personagem, e duas variáveis privadas (`PosicaoX` e `Velocidade`) que armazenam o estado do personagem.

Agora, vamos usar essa classe no loop principal do jogo:

```cpp
Personagem MeuPersonagem;

void JogoLoop() {
    // Simulando entrada do usuário: tecla esquerda pressionada
    MeuPersonagem.MoverEsquerda();

    // Simulando entrada do usuário: tecla direita pressionada
    MeuPersonagem.MoverDireita();
}
```

Quando você executa esse código, o personagem se move para a esquerda e depois para a direita, e a posição atual é exibida no log. A vantagem aqui é que toda a lógica relacionada ao personagem está encapsulada na classe `Personagem`. Se você precisar adicionar mais funcionalidades, como saltar ou coletar moedas, basta adicionar métodos à classe sem mexer no resto do código.

### Erro comum: Acessar propriedades privadas diretamente

Um erro comum ao começar com orientação a objetos é tentar acessar diretamente propriedades privadas de uma classe. Por exemplo:

```cpp
Personagem MeuPersonagem;
MeuPersonagem.PosicaoX = 100.0f; // Erro! PosicaoX é privada.
```

Isso resulta em um erro de compilação porque `PosicaoX` é uma propriedade privada e só pode ser acessada dentro da própria classe. Para corrigir isso, você precisa criar um método público que permita alterar a posição de forma controlada:

```cpp
class Personagem {
public:
    void DefinirPosicaoX(float NovaPosicaoX) {
        PosicaoX = NovaPosicaoX;
    }

private:
    float PosicaoX = 0.0f;
};
```

Agora você pode definir a posição do personagem sem violar o encapsulamento:

```cpp
Personagem MeuPersonagem;
MeuPersonagem.DefinirPosicaoX(100.0f); // Funciona!
```

### Exercício: Criando um inimigo

Agora que você entende o básico de orientação a objetos, tente criar uma classe `Inimigo` que tenha uma propriedade `Vida` e um método `ReceberDano` que reduz a vida do inimigo. Use o seguinte código como ponto de partida:

```cpp
class Inimigo {
public:
    void ReceberDano(int Quantidade) {
        // Implemente aqui
    }

private:
    int Vida = 100;
};
```

**Solução:**

```cpp
class Inimigo {
public:
    void ReceberDano(int Quantidade) {
        Vida -= Quantidade;
        UE_LOG(LogTemp, Log, TEXT("Inimigo recebeu dano! Vida restante: %d"), Vida);
    }

private:
    int Vida = 100;
};
```

Para testar, crie um objeto `Inimigo` e chame o método `ReceberDano`:

```cpp
Inimigo MeuInimigo;
MeuInimigo.ReceberDano(20); // Vida restante: 80
```

Com isso, você já está começando a estruturar seu jogo de forma mais organizada e eficiente usando orientação a objetos.