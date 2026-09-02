## Criação de projetos

Ao iniciar um projeto na Unreal Engine, o primeiro passo é definir o tipo de jogo que você deseja criar. A Unreal Engine oferece vários templates pré-configurados que facilitam o início de um projeto, seja ele um jogo 3D, 2D, um simulador ou até mesmo um projeto de realidade virtual. Para começar, abra a Unreal Engine e clique em "New Project" na aba de projetos.

Na tela de criação de projetos, você verá duas abas principais: "Games" e "Other". Para desenvolvimento de jogos, selecione a aba "Games". Aqui, você encontrará templates como "First Person", "Third Person", "Top Down", e "Side Scroller". Cada template vem com uma configuração inicial que inclui um personagem básico, controles e uma cena de exemplo.

### Escolhendo o Template

Vamos criar um projeto de jogo 2D de plataforma. Selecione o template "Side Scroller". Este template é ideal para jogos onde o personagem se move lateralmente, como em clássicos de plataforma. Após selecionar o template, você precisará configurar algumas opções básicas:

1. **Nome do Projeto**: Escolha um nome descritivo para o seu projeto. Por exemplo, "MeuJogo2D".
2. **Localização**: Defina onde o projeto será salvo no seu computador.
3. **Configurações Adicionais**: Aqui, você pode escolher entre "Blueprint" e "C++". Para este exemplo, selecione "Blueprint" para criar um projeto baseado em Blueprints, que são scripts visuais da Unreal Engine.

### Configurações de Projeto

Após definir essas opções, clique em "Create". A Unreal Engine começará a criar o projeto com base no template selecionado. Isso pode levar alguns minutos, dependendo da sua máquina.

Uma vez que o projeto esteja criado, você será direcionado para a interface principal da Unreal Engine. Aqui, você verá várias janelas e painéis como o Viewport, Content Browser, Details Panel, Toolbar, Modes e World Outliner. Esses componentes são essenciais para a criação e manipulação do seu jogo.

### Explorando o Projeto Criado

No Viewport, você verá uma cena inicial que inclui um personagem e um ambiente básico. Este ambiente é gerado automaticamente pelo template "Side Scroller". Você pode navegar pela cena usando o mouse e o teclado:

- **Movimentação**: Use o botão direito do mouse para girar a câmera e o scroll do mouse para zoom.
- **Seleção**: Clique em objetos no Viewport para selecioná-los. As propriedades do objeto selecionado aparecerão no Details Panel.

No Content Browser, você encontrará assets como modelos 3D, texturas e sons que foram incluídos automaticamente no projeto. Esses assets podem ser usados para construir sua cena ou substituídos por outros conforme necessário.

### Modificando a Cena

Vamos fazer uma pequena modificação na cena para entender como funciona a edição na Unreal Engine. Selecione o personagem no Viewport e observe as propriedades no Details Panel. Aqui, você pode alterar aspectos como a escala, rotação e localização do personagem.

Experimente mover o personagem para uma nova posição na cena. Clique e arraste o personagem no Viewport ou ajuste as coordenadas de localização diretamente no Details Panel. Após mover o personagem, clique em "Play" na Toolbar para testar o jogo. Você verá que o personagem agora começa na nova posição que você definiu.

### Salvando o Projeto

É importante salvar seu projeto regularmente para evitar perda de trabalho. Para salvar, clique em "File" no menu superior e selecione "Save All". Você também pode usar o atalho `Ctrl + S` para salvar rapidamente.

### Erros Comuns e Soluções

Um erro comum ao criar projetos é selecionar o template errado para o tipo de jogo que você deseja desenvolver. Por exemplo, se você escolher o template "First Person" para um jogo 2D, terá que fazer ajustes significativos para adaptar o projeto. Se isso acontecer, a melhor solução é criar um novo projeto com o template correto e migrar os assets necessários.

Outro erro comum é esquecer de configurar o projeto para a versão correta da Unreal Engine. Certifique-se de que você está usando a versão mais recente ou a versão específica que seu projeto requer.

### Exercício Prático

Para praticar, crie um novo projeto usando o template "Top Down". Explore a cena inicial, mova alguns objetos e teste o jogo. Depois, tente criar um projeto "Blank" (sem template) e adicione manualmente um personagem e um ambiente básico.

### Solução Comentada

No projeto "Top Down", você encontrará uma cena onde o personagem é controlado de uma perspectiva superior. Para mover o personagem, selecione-o no Viewport e ajuste as coordenadas no Details Panel. Teste o jogo clicando em "Play" e observe como o personagem se comporta.

No projeto "Blank", você começará com uma cena vazia. Para adicionar um personagem, vá ao Content Browser, navegue até a pasta "Mannequin" (ou qualquer outra pasta de assets) e arraste um modelo de personagem para o Viewport. Ajuste as propriedades conforme necessário e teste o jogo.