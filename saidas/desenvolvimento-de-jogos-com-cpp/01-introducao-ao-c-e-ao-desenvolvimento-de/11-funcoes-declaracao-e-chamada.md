## Funções: declaração e chamada

Imagine que você está programando um jogo de plataforma 2D e precisa checar constantemente se o personagem está no chão para permitir ou não um pulo. Sem funções, você teria que repetir o mesmo código em vários lugares:

```cpp
// Sem função - código repetido
if (posicaoY == alturaChao && velocidadeY == 0) {
    podePular = true;
}
```

Repetir código é problemático. Se precisar mudar a lógica (adicionando um novo tipo de plataforma, por exemplo), terá que alterar em vários lugares. É aí que funções entram.

**Função é um bloco de código nomeado que executa uma tarefa específica e pode ser chamado de qualquer parte do programa.** Veja como transformar nosso exemplo em uma função:

```cpp
void VerificarPulo() {
    if (posicaoY == alturaChao && velocidadeY == 0) {
        podePular = true;
    }
}
```

Agora, sempre que precisar verificar se o personagem pode pular, basta chamar:

```cpp
VerificarPulo();
```

### Anatomia de uma função básica

Vamos dissecar a função `VerificarPulo()`:

```cpp
void VerificarPulo() {
    // Corpo da função
}
```

1. **Tipo de retorno (`void`)**: Indica que a função não retorna nenhum valor. Usaremos outros tipos posteriormente.
2. **Nome (`VerificarPulo`)**: Segue camelCase e descreve claramente o que a função faz.
3. **Parênteses `()`**: Por enquanto vazios, mas logo usaremos para parâmetros.
4. **Chaves `{}`**: Delimitam o corpo da função.

### Declarando vs. Chamando

**Declaração** é criar a função (mostramos acima). **Chamada** é usar a função em outro lugar do código:

```cpp
// Declaração
void MostrarVida() {
    std::cout << "Vida: " << vidaAtual << "/" << vidaMaxima << std::endl;
}

int main() {
    // Chamada
    MostrarVida();
    
    // Código do jogo...
    
    // Chamada novamente
    MostrarVida();
    
    return 0;
}
```

Saída:
```
Vida: 100/100
Vida: 100/100
```

### Erro comum: chamar antes de declarar

C++ exige que funções sejam declaradas antes de serem chamadas. Este código gera erro:

```cpp
int main() {
    Saudacao();  // Erro! Saudacao não foi declarada ainda
    return 0;
}

void Saudacao() {
    std::cout << "Bem-vindo ao jogo!" << std::endl;
}
```

Mensagem de erro típica:
```
error: 'Saudacao' was not declared in this scope
```

**Solução 1:** Reordenar as funções:
```cpp
void Saudacao() {
    std::cout << "Bem-vindo ao jogo!" << std::endl;
}

int main() {
    Saudacao();  // Agora funciona
    return 0;
}
```

**Solução 2:** Usar protótipo (declaração antecipada):
```cpp
// Protótipo
void Saudacao();

int main() {
    Saudacao();  // Funciona com o protótipo
    return 0;
}

// Implementação
void Saudacao() {
    std::cout << "Bem-vindo ao jogo!" << std::endl;
}
```

### Aplicação em jogos: organizando sistemas

Funções ajudam a estruturar sistemas complexos de jogos. Veja um exemplo simplificado de loop principal:

```cpp
void ProcessarEntradas();
void AtualizarLogica();
void RenderizarCena();

int main() {
    while (jogoAtivo) {
        ProcessarEntradas();
        AtualizarLogica();
        RenderizarCena();
    }
    return 0;
}

void ProcessarEntradas() { /* Lê teclado/controle */ }
void AtualizarLogica()  { /* Atualiza posições, estados */ }
void RenderizarCena()   { /* Desenha gráficos */ }
```

### Exercício

Transforme este trecho de jogo em funções adequadas:

```cpp
// Código original
int main() {
    while (jogoRodando) {
        // Controle de FPS
        tempoAtual = std::chrono::high_resolution_clock::now();
        deltaTime = std::chrono::duration<float>(tempoAtual - tempoAnterior).count();
        tempoAnterior = tempoAtual;
        
        // Input
        if (teclaPressionada(KEY_SPACE)) {
            personagem.pular();
        }
        
        // Atualização
        personagem.atualizar(deltaTime);
        inimigos.atualizar(deltaTime);
        
        // Render
        renderizarCenario();
        personagem.desenhar();
        inimigos.desenhar();
    }
    return 0;
}
```

**Solução comentada:**

```cpp
void ControleFPS(float& deltaTime, std::chrono::time_point<std::chrono::high_resolution_clock>& tempoAnterior) {
    auto tempoAtual = std::chrono::high_resolution_clock::now();
    deltaTime = std::chrono::duration<float>(tempoAtual - tempoAnterior).count();
    tempoAnterior = tempoAtual;
}

void ProcessarInput() {
    if (teclaPressionada(KEY_SPACE)) {
        personagem.pular();
    }
}

void AtualizarJogo(float deltaTime) {
    personagem.atualizar(deltaTime);
    inimigos.atualizar(deltaTime);
}

void RenderizarJogo() {
    renderizarCenario();
    personagem.desenhar();
    inimigos.desenhar();
}

int main() {
    // Variáveis de tempo
    auto tempoAnterior = std::chrono::high_resolution_clock::now();
    float deltaTime;
    
    while (jogoRodando) {
        ControleFPS(deltaTime, tempoAnterior);
        ProcessarInput();
        AtualizarJogo(deltaTime);
        RenderizarJogo();
    }
    return 0;
}
```