## Gerenciamento de assets

Quando você precisa adicionar um personagem ao seu jogo, não começa modelando do zero toda vez. Na Unreal Engine, assets são esses recursos prontos - modelos 3D, sons, texturas - que você organiza e reutiliza. Vamos criar um sistema prático para gerenciá-los.

Abra o Content Browser (Ctrl+Space) e crie uma estrutura básica de pastas:

```
Content/
├── Characters/
├── Maps/
├── Materials/
├── Meshes/
└── Sounds/
```

Para importar um asset, arraste um arquivo .fbx (modelo 3D) para a pasta Meshes. A Unreal mostrará este diálogo:

![Import Options dialog showing mesh import settings](https://docs.unrealengine.com/Images/Engine/Content/Importing/FBX/ImportOptionsReference.webp)

Marque "Import Materials" e clique em Import. Agora você verá duas novas entradas: o mesh em Meshes/ e seu material em Materials/. 

Um erro comum é esquecer de configurar as colisões. Se você tentar usar o mesh sem colisão:

```
LogStaticMesh: Error: Mesh 'SM_Table' has no collision data
```

Corrija clicando no mesh, indo em Details > Collision e selecionando "Use Complex Collision As Simple" ou gerando colisão automática com "Auto Convex Collision".

Para organizar melhor, use prefixes nos nomes:

- S_ para sons (S_Explosion)
- T_ para texturas (T_BrickWall)
- M_ para materiais (M_MetalRusty)
- BP_ para Blueprints (BP_EnemyDrone)

Quando seu projeto crescer, encontre assets rapidamente com o filtro do Content Browser. Digite "T_ wall" para encontrar todas as texturas de parede.

Para mover assets entre pastas, use o menu de contexto (botão direito) ou arraste com Alt pressionado (evita referências quebradas). Se mover sem Alt, aparecerá:

```
Warning: 42 references to '/Game/Assets/Enemies/BP_Orc' need to be updated
```

Conserte com "Fix Up Redirectors" no menu File.

Crie um material master que servirá de base para variações. Clique direito em Materials/ > Material. Nomeie como M_Master, então:

1. No Material Editor, clique em Base Color > Texture Sample
2. Conecte à entrada Base Color do nó principal
3. Salve (Ctrl+S)

Agora crie instâncias desse material para variações: botão direito em M_Master > Create Material Instance. Nomeie como MI_Metal_Damaged e ajuste parâmetros sem alterar o original.

Exercício: Importe um modelo 3D gratuito (como do Quixel Bridge), organize nas pastas corretas com prefixo, crie um material master e duas instâncias com cores diferentes. Solução comentada:

1. Baixe um asset do Quixel (Megascans > Props)
2. Arraste para Meshes/ como SM_QuixelRock
3. Crie M_RockMaster com TextureSample da textura da rocha
4. Gere MI_Rock_Mossy (verde) e MI_Rock_Sandy (bege)
5. Aplique as instâncias ao mesh no Viewport