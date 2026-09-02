## Criando o primeiro projeto na Unreal Engine

Quando você abre a Unreal Engine pela primeira vez, o projeto em branco parece uma tela vazia cheia de possibilidades. Vamos começar criando um projeto básico que servirá como base para todos os seus jogos futuros.

Na tela inicial da Unreal Engine, clique em "Games" na categoria de projetos. Você verá três opções principais:

1. **Blank** - Um projeto totalmente vazio
2. **First Person** - Template com jogador em primeira pessoa
3. **Third Person** - Template com jogador em terceira pessoa

Selecione "Third Person" para nosso primeiro projeto. Esse template já vem com:
- Um personagem controlável
- Física básica
- Um ambiente simples
- Sistema de câmera pré-configurado

Na próxima tela, vamos configurar:
- **Project Name**: "MeuPrimeiroJogo"
- **Location**: Escolha uma pasta fácil de encontrar
- **Template**: Third Person (já selecionado)
- **Quality Preset**: Maximum (podemos ajustar depois)
- **Starter Content**: Clique em "Include Starter Content"

Antes de clicar em "Create Project", vamos entender os erros comuns nesta etapa:

1. **Nome inválido**: Se você usar caracteres especiais ou espaços, verá o erro:
   ```
   Project names may only contain alphanumeric characters, underscores and dashes
   ```
   Solução: Use apenas letras, números, underscores (_) ou hífens (-).

2. **Caminho muito longo**: Unreal Engine tem problemas com caminhos de pasta muito longos. Se vir o erro:
   ```
   The selected path is too long
   ```
   Solução: Crie o projeto em uma pasta mais próxima da raiz do disco (como C:\Projetos).

3. **Disco cheio**: Projetos Unreal Engine consomem bastante espaço. O erro será:
   ```
   Not enough disk space to create project
   ```
   Solução: Libere espaço ou escolha outro disco.

Depois de criar o projeto, você verá a interface principal dividida em várias áreas:

1. **Viewport** (centro): Onde você vê e interage com o jogo
2. **Content Browser** (inferior): Todos os arquivos do projeto
3. **World Outliner** (direita): Lista de objetos na cena
4. **Details** (direita): Propriedades do objeto selecionado

Para testar seu projeto, pressione o botão "Play" na barra superior (ou pressione Alt+P). O jogo deve iniciar com um personagem que você pode controlar com WASD. A câmera segue o personagem em terceira pessoa.

Se o jogo não iniciar corretamente, os erros mais comuns são:

1. **Personagem não responde aos controles**:
   ```
   LogTemp: Warning: No player controller spawned for player 0
   ```
   Solução: No World Outliner, selecione "ThirdPersonCharacter" e verifique no Details que "Auto Possess Player" está como "Player 0".

2. **Tela preta ao executar**:
   ```
   LogTemp: Error: Failed to spawn player controller
   ```
   Solução: Verifique se há um "Player Start" na cena (procure no World Outliner).

Vamos agora organizar nosso projeto. No Content Browser:

1. Crie uma pasta chamada "Maps" e mova o mapa atual ("ThirdPersonExampleMap") para ela
2. Crie uma pasta "Blueprints" para organizar os elementos do jogo
3. Crie uma pasta "Materials" para texturas e shaders

A estrutura final deve parecer com:
```
Content/
  ├── Maps/
  │   └── ThirdPersonExampleMap.umap
  ├── Blueprints/
  ├── Materials/
  └── StarterContent/
```

Para salvar seu progresso, use Ctrl+S ou vá em File > Save All. O Unreal Engine salva automaticamente:
- O mapa atual (.umap)
- Configurações do projeto (.uproject)
- Blueprints modificados

**Exercício Prático**:
1. Renomeie o mapa principal para "Level1"
2. Adicione 10 caixas do Starter Content ao mapa (encontre em StarterContent > Props)
3. Posicione as caixas para criar um pequeno obstáculo
4. Teste o jogo e tente pular sobre as caixas

Solução passo a passo:
1. No Content Browser, clique com o botão direito em "ThirdPersonExampleMap" > Rename > "Level1"
2. No Content Browser, navegue até StarterContent > Props
3. Arraste o objeto "SM_Crate" para o Viewport 10 vezes
4. Selecione cada caixa e no Details Panel, ajuste a posição (Location) para criar uma escada ou obstáculo
5. Pressione Play e use a barra de espaço para pular sobre as caixas