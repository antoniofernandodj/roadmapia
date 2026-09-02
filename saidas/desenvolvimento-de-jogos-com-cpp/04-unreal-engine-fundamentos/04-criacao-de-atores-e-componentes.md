## Criação de atores e componentes

Na Unreal Engine, tudo no seu jogo existe como **Atores** (Actors) - paredes, personagens, itens coletáveis e até luzes ambientais. Um Actor é como uma caixa vazia que você enche com **Componentes** para dar funcionalidade específica. Vamos criar um objeto simples que se move quando o jogador pressiona uma tecla.

Primeiro, crie um novo Blueprint Class baseado em Actor. No Content Browser:

1. Clique direito → Blueprint Class
2. Selecione "Actor" como classe pai
3. Nomeie como "BP_MovingPlatform"

Dentro do editor de Blueprints, adicione um componente Static Mesh para dar forma visual à plataforma:

1. No painel Components, clique em "Add Component"
2. Procure por "Static Mesh"
3. No Details Panel, em Static Mesh, escolha "Shape_Cube"

Agora vamos fazer a plataforma se mover. Adicione um novo componente chamado "Timeline" (linha do tempo de animação):

```plaintext
Components Panel → Add Component → Timeline
```

Na aba Event Graph, clique direito e adicione um evento "Event BeginPlay". Conecte-o a uma nova Timeline:

1. Arraste da saída "Play" da Timeline para criar um novo nó "Play Timeline"
2. Clique duas vezes na Timeline para editar suas curvas
3. Adicione um vetor (Vector Track) chamado "MovementTrack"

Configure a curva para mover a plataforma:

1. Na Timeline, clique em "Add Key" (tempo 0.0, valor (0,0,0))
2. Adicione outro key (tempo 1.0, valor (0,200,0))
3. Conecte a saída "MovementTrack" ao "Set Relative Location" do Static Mesh

Se você testar agora (Play), a plataforma se moverá automaticamente. Mas queremos controle pelo jogador. Modifique o Blueprint:

1. Adicione um novo evento "InputAction Jump" (você precisará configurar as entradas no Project Settings primeiro)
2. Conecte "Pressed" a um nó "FlipFlop"
3. Conecte "A" ao "Play" da Timeline e "B" ao "Reverse"

**Erro comum:** Esquecer de configurar as entradas no Project Settings. Se tentar usar "InputAction Jump" sem isso, você verá:

```plaintext
LogBlueprintUserMessages: Error: Input action 'Jump' is not defined in the Input Settings
```

Para corrigir:
1. Edit → Project Settings → Input → Action Mappings
2. Adicione nova ação chamada "Jump"
3. Atribua a tecla Space Bar

Componentes podem comunicar-se entre si. Vamos adicionar um som quando a plataforma se move:

1. Adicione um componente "Audio" → "Audio Component"
2. Arraste do pin de saída "Play" da Timeline para "Play" no Audio Component
3. No Details Panel do Audio Component, selecione um som de sua escolha

**Exercício:** Crie um ator "BP_RotatingDoor" que gira 90 graus quando o jogador pressiona a tecla "E". Use:
- Um Static Mesh (Shape_Cube) como base visual
- Uma Timeline com rotação (Rotation Track) em vez de movimento
- Input Action "Interact" mapeado para a tecla E

**Solução comentada:**
1. Crie novo Blueprint baseado em Actor
2. Adicione Static Mesh (Shape_Cube) e posicione como uma porta
3. Crie Input Action "Interact" no Project Settings
4. Na Event Graph:
   - Event BeginPlay → Timeline
   - InputAction Interact → FlipFlop → Play/Reverse Timeline
5. Na Timeline:
   - Rotation Track: 0.0 (0,0,0) → 1.0 (0,90,0)
   - Conecte à saída "Set Relative Rotation" do Static Mesh