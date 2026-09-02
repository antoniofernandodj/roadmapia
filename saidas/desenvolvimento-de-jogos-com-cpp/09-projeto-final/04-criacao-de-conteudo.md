## Criação de conteúdo

Um jogo sem arte, animações e sons é como um livro sem palavras - apenas uma estrutura vazia. Na Unreal Engine, mesmo projetos 2D exigem atenção à pipeline de conteúdo. Vamos começar com sprites, a base visual de qualquer jogo 2D.

### Importando e configurando sprites

Na pasta `Content`, crie uma subpasta `Sprites`. Arraste seu arquivo PNG (digamos, `Hero.png`) para esta pasta. A Unreal mostrará esta janela de importação:

```cpp
// Configurações recomendadas para sprites 2D:
Texture Group: 2D Pixels (unfiltered)
Compression Settings: UserInterface2D (RGBA)
sRGB: Enabled (para cores vibrantes)
```

Se você receber o erro `Texture has non-power-of-two dimensions`, significa que sua imagem tem tamanho como 127x63 pixels. Corrija exportando-a com dimensões como 128x64 (potências de 2). Após a importação, clique duplo no sprite e configure:

```cpp
Sprite Size: 128x128 (ajuste conforme sua arte)
Pixels Per Unit: 64 (padrão para jogos 2D)
```

### Criando flipbooks (animações)

Na pasta `Animations`, clique direito → Animation → Flipbook. Nomeie como `Hero_Run`. Adicione seus frames na ordem correta. Um erro comum é esquecer de configurar:

```cpp
Frames Per Second: 12 (para animações estilo pixel art)
Looping: True (para animações contínuas)
```

Se a animação parecer desalinhada, corrija com `Sprite Setup Offset` no flipbook.

### Sons e efeitos sonoros

Importe arquivos WAV ou MP3 para a pasta `Sounds`. Para um som de pulo:

```cpp
// Blueprint de som:
1. Crie um Sound Cue (direita → Sounds → Sound Cue)
2. Arraste seu arquivo WAV para o gráfico
3. Conecte ao Output
4. Ajuste Volume Multiplier (0.8 para efeitos)
```

Se o som não tocar, verifique:
1. O Audio Mixer está ativo no Editor Preferences
2. O Volume no Sound Cue não está zerado
3. O som está sendo chamado via código:

```cpp
// Em seu Character.cpp:
#include "Components/AudioComponent.h"

void AMyCharacter::Jump()
{
    if (JumpSound)
    {
        UGameplayStatics::PlaySound2D(this, JumpSound);
    }
    Super::Jump();
}
```

### Particionando assets para performance

Evite o erro de importar um tileset inteiro como uma única textura. Use a ferramenta de sprite slicing:

1. Clique duplo no tileset importado
2. Selecione "Sprite Editor"
3. Clique em "Slice" → "Automatic"
4. Defina o método como "Grid" e insira o tamanho dos tiles (ex: 32x32)

### Exercício prático

Crie um sprite sheet com 3 frames de animação (pode ser um quadrado mudando de cor). Importe-o seguindo os passos acima, crie um flipbook e implemente em um ator simples que mostra a animação em loop.

Solução:

1. Exporte um PNG 96x32 (3 frames de 32x32)
2. Importe com as configurações de sprite
3. No sprite editor, divida em 3 frames (Slice → Grid, 32x32)
4. Crie flipbook com os 3 frames em sequência
5. Em um Blueprint:
   - Adicione componente "PaperFlipbook"
   - Selecione seu flipbook criado
   - Na aba Event Graph:
     ```cpp
     Event BeginPlay → Set Flipbook (seu flipbook)
     ```