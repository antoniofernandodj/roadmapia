## Introdução aos Blueprints

Imagine que você quer fazer uma porta se abrir quando o jogador se aproxima. Em linguagens tradicionais, isso exigiria escrever código, compilar e testar repetidamente. Com Blueprints, você pode criar esse comportamento arrastando e conectando blocos visuais, vendo o resultado imediatamente.

**O que são Blueprints?**  
São scripts visuais da Unreal Engine que permitem criar lógica de jogo sem escrever código tradicional. Funcionam como diagramas de fluxo onde você conecta nós (caixas) com fios (conexões). Cada nó representa uma ação, cálculo ou valor.

Vamos criar um exemplo prático. Na Viewport, adicione um Cube (Actor básico) e um Player Start:

1. No Content Browser, clique com o botão direito → Basic Assets → Cube
2. Arraste o Cube para a cena
3. Repita para adicionar um Player Start

Agora, clique com o botão direito no Cube no World Outliner e selecione "Create Blueprint Class". Nomeie como "BP_Door". Isso criará um novo arquivo .uasset no Content Browser.

Duplo-clique no BP_Door para abrir o Editor de Blueprints. Você verá:

- **Event Graph**: Onde programamos a lógica
- **Components**: Lista de partes do objeto
- **My Blueprint**: Variáveis e funções

Vamos fazer o Cube girar quando o jogador pressionar a tecla E:

1. No Event Graph, clique direito → pesquise "Event Tick" (executa todo frame)
2. Arraste da saída "Delta Seconds" e pesquise "Print String"
3. Digite "Olá, mundo!" no campo "In String"

Clique em "Compile" e depois "Play". Você verá a mensagem aparecer repetidamente no canto da tela.

Agora, vamos melhorar:

1. Delete o nó Print String
2. Clique direito → pesquise "E Key Event" (em Input)
3. Arraste da saída "Pressed" e pesquise "AddActorLocalRotation"
4. Conecte "Target" ao "self" (pino automático)
5. Em Delta Rotation, defina Y=10 (graus)

Erro comum: Esquecer de compilar antes de testar. Se você clicar em Play sem Compile, verá:
```
LogBlueprint: Error: [Compiler] BP_Door: The blueprint has been modified but not compiled
```

A solução é simples - clique no botão Compile antes de Play.

**Variáveis em Blueprints:**  
Para armazenar informações, criamos variáveis. Vamos adicionar uma para controlar a velocidade de rotação:

1. Em My Blueprint, clique "+" em Variables
2. Nomeie como "RotationSpeed"
3. Defina Type como Float
4. Clique em "Editable" (para aparecer no Details Panel)
5. Compile e defaut Value como 5.0

Modifique o AddActorLocalRotation:
- Desconecte Delta Rotation
- Arraste a variável RotationSpeed para o gráfico
- Pesquise "Make Rotator" e conecte Y ao RotationSpeed
- Conecte o resultado ao Delta Rotation

Agora você pode ajustar a velocidade diretamente na cena selecionando o BP_Door e mudando o valor no Details Panel.

**Comunicação entre Blueprints:**  
Para mostrar como Blueprints podem interagir, vamos criar um contador:

1. Crie uma nova variável inteira chamada "PressCount"
2. No E Key Event, adicione um nó "Increment Int" conectado a PressCount
3. Adicione um "Print String" mostrando "Tecla E pressionada [X] vezes"
4. Use um "Format Text" para incluir o valor de PressCount

Quando você testar, verá:
```
Tecla E pressionada 1 vezes  
Tecla E pressionada 2 vezes
...
```

**Exercício:**  
Crie um Blueprint que:
1. Muda a cor do Cube para vermelho quando o jogador pressiona R
2. Volta ao branco quando pressiona W
3. Exibe a cor atual na tela

Solução:
1. Adicione um "R Key Event" e "W Key Event"
2. Pesquise "Set Material" (em Render)
3. Para o vermelho:  
   - Crie um Dynamic Material Instance (pesquise "Create Dynamic Material Instance")  
   - Conecte ao Set Material  
   - Adicione um "Set Vector Parameter Value" com Parameter Name="Color" e Value=(1,0,0,1)  
4. Repita para branco com Value=(1,1,1,1)  
5. Use Print String para mostrar "Cor: Vermelho" ou "Cor: Branco"