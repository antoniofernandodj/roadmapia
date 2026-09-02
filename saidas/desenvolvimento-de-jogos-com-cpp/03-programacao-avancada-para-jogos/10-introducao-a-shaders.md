## Introdução a shaders

Imagine que você está criando um jogo onde o personagem precisa atravessar um rio. A água parece sólida e estática, como se fosse uma imagem plana colada no cenário. Para dar vida a essa água, você precisa de algo que possa simular o movimento das ondas, a reflexão da luz e a transparência da superfície. É aqui que os shaders entram.

Shaders são pequenos programas que rodam na GPU (Unidade de Processamento Gráfico) e são responsáveis por determinar como cada pixel na tela deve ser renderizado. Eles permitem que você crie efeitos visuais complexos, como reflexos, sombras, transparências e muito mais, sem precisar calcular tudo isso manualmente em C++.

### Como funcionam os shaders?

Quando você renderiza um objeto em um jogo, ele passa por várias etapas antes de aparecer na tela. Uma dessas etapas é o processo de shading, onde os shaders são aplicados. Existem três tipos principais de shaders:

1. **Vertex Shader**: Transforma as coordenadas dos vértices (os pontos que compõem a forma do objeto) em coordenadas de tela. Ele pode ser usado para deformar objetos ou criar efeitos como ondulações.

2. **Fragment Shader (Pixel Shader)**: Calcula a cor e outras propriedades de cada pixel na tela. É aqui que você pode aplicar texturas, iluminação e efeitos especiais.

3. **Geometry Shader**: Gera novos vértices a partir dos existentes, permitindo criar geometria adicional ou modificar a forma de objetos em tempo real.

### Criando um Shader Básico na Unreal Engine

Vamos criar um shader simples que muda a cor de um objeto com base na sua altura. Para isso, usaremos a Unreal Engine e o sistema de Material Editor.

1. Abra a Unreal Engine e crie um novo projeto.
2. No Content Browser, clique com o botão direito e selecione `Material` para criar um novo material.
3. Nomeie o material como `HeightColorShader`.
4. Dê duplo clique no material para abrir o Material Editor.

No Material Editor, você verá uma série de nós que podem ser conectados para criar efeitos visuais. Vamos adicionar um nó `VertexColor` e conectá-lo ao `Emissive Color` do material.

```plaintext
[VertexColor] -> [Emissive Color]
```

Isso fará com que o objeto mude de cor com base nas coordenadas dos vértices. Para testar, aplique o material a um objeto na cena e veja como ele muda de cor.

### Erro Comum e Solução

Um erro comum ao trabalhar com shaders é esquecer de aplicar o material ao objeto. Se você criar um shader mas não aplicá-lo, nada aparecerá na tela. Para corrigir isso, certifique-se de arrastar o material para o objeto na cena.

Outro erro é esquecer de salvar o material antes de aplicá-lo. Se você fizer alterações no Material Editor e não salvar, as mudanças não serão refletidas no jogo. Sempre salve o material após fazer alterações.

### Exercício Prático

Crie um shader que simule um efeito de água simples. Use o Material Editor para adicionar um nó `Texture Sample` com uma textura de onda e conecte-o ao `Base Color` do material. Aplique o shader a um plano na cena para simular a superfície da água.

```plaintext
[Texture Sample (WaveTexture)] -> [Base Color]
```

### Conclusão

Shaders são ferramentas poderosas que permitem criar efeitos visuais impressionantes em jogos. Com eles, você pode transformar objetos simples em elementos complexos e realistas, como água, fogo, vidro e muito mais. Dominar os shaders é um passo importante para criar jogos visualmente atraentes e imersivos.