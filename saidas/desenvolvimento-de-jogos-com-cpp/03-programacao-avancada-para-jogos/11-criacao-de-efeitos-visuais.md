## Criação de efeitos visuais

Efeitos visuais são essenciais para dar vida a um jogo, criando desde pequenas faíscas até explosões épicas. No contexto da Unreal Engine, esses efeitos são frequentemente criados usando shaders, que são programas executados na GPU para determinar como cada pixel é renderizado.

Para começar, vamos criar um efeito visual simples: um brilho pulsante em um objeto. Este efeito pode ser aplicado a qualquer objeto do jogo e será controlado por um shader personalizado.

### Criando um Material com Shader

Primeiro, abra o Material Editor na Unreal Engine. Crie um novo material chamado `BrilhoPulsante`. No painel de propriedades do material, adicione um nó `Time` para criar uma variável que muda continuamente ao longo do tempo. Conecte este nó a um nó `Sine`, que gerará uma onda senoidal.

```cpp
// Exemplo de conexão de nós no Material Editor
Time -> Sine -> Multiply -> BaseColor
```

Agora, multiplique a saída do nó `Sine` por um valor constante para controlar a intensidade do brilho. Conecte o resultado ao pin `BaseColor` do material. Isso fará com que a cor do objeto varie entre escuro e claro, criando o efeito de pulsação.

### Aplicando o Material ao Objeto

Com o material criado, aplique-o a um objeto no seu nível. Você pode fazer isso arrastando o material diretamente para o objeto na viewport ou selecionando o objeto e atribuindo o material na aba de detalhes.

### Personalizando o Efeito

Para tornar o efeito mais dinâmico, podemos adicionar um parâmetro de cor. No Material Editor, crie um novo parâmetro chamado `CorBrilho`. Conecte este parâmetro ao pin `BaseColor` após o nó `Multiply`. Isso permitirá que você altere a cor do brilho diretamente na instância do material, sem precisar editar o shader.

```cpp
// Exemplo de uso de parâmetro de cor
CorBrilho -> Multiply -> BaseColor
```

### Testando o Efeito

Execute o jogo e observe o objeto com o material aplicado. Você verá um brilho pulsante que muda de intensidade ao longo do tempo. Se o efeito estiver muito rápido ou lento, ajuste o valor multiplicador no Material Editor.

### Erro Comum e Solução

Um erro comum ao trabalhar com shaders é esquecer de salvar o material após as alterações. Se você não salvar, o objeto não refletirá as mudanças feitas no Material Editor. Certifique-se de sempre salvar o material clicando em `File -> Save` ou usando o atalho `Ctrl + S`.

```cpp
// Mensagem de erro comum
Error: Material 'BrilhoPulsante' has unsaved changes.
```

### Exercício Prático

Crie um novo material chamado `EfeitoFantasma` que combine transparência com um efeito de pulsação. Use um nó `Lerp` para interpolar entre duas cores e conecte o resultado ao pin `Opacity` do material. Aplique este material a um personagem no jogo para criar um efeito de invisibilidade temporária.

**Solução:**

```cpp
// Conexão de nós para o EfeitoFantasma
Time -> Sine -> Lerp (Cor1, Cor2) -> Opacity
```

Este exercício reforça o entendimento de como shaders podem ser usados para criar efeitos visuais dinâmicos e interativos em jogos.