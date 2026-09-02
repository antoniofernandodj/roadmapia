## Materiais e texturas

Imagine que você criou um modelo 3D perfeito de uma espada para seu jogo, mas quando coloca na cena, ela aparece como um objeto cinza sem vida. Isso acontece porque falta o material - a "pele" que dá cor e textura ao objeto. Na Unreal Engine, materiais são como receitas que definem como a superfície dos objetos deve reagir à luz.

Vamos começar criando um material básico para nossa espada:

1. No Content Browser, clique com o botão direito → Materials & Textures → Material
2. Nomeie como "MetalBasic"
3. Dê duplo-clique para abrir o Material Editor

Você verá uma tela com um nó "Result" à direita. Este é o destino final do seu material. Tudo que você conectar aqui definirá a aparência final.

Começaremos com um material metálico simples. Arraste da área em branco para abrir o menu de nós e pesquise por "Constant3Vector". Este nó representa uma cor RGB. Conecte sua saída ao pin "Base Color" do Result:

```cpp
// Representação aproximada do que acontece no material
MaterialOutput {
    BaseColor = float3(0.5, 0.5, 0.5); // Cinza médio
    Metallic = 1.0; // Totalmente metálico
    Roughness = 0.3; // Pouco rugoso
}
```

Clique em "Apply" e depois "Save". Agora, selecione sua espada no Viewport, no Details Panel encontre a seção "Materials" e atribua seu novo material.

Mas nossa espada ainda parece muito artificial. Vamos adicionar uma textura para dar detalhes. Baixe uma textura de metal enferrujado (por exemplo, do Quixel Bridge) e importe para seu projeto. No Material Editor:

1. Arraste a textura para a área de trabalho - isso criará um TextureSample
2. Conecte o pin RGB ao pin "Base Color" (substituindo o Constant3Vector)
3. Conecte o pin Alpha ao pin "Roughness"

Agora o material usa pixels reais da textura em vez de cores sólidas. Se você aplicar e voltar ao Viewport, verá que a espada ganhou detalhes de superfície.

Um erro comum é esquecer de configurar o "Texture Group". Se sua textura aparecer borrada, clique nela no Content Browser e no Details Panel, em Texture → LOD Group, mude para "World". Isso otimiza o mipmapping para objetos no mundo 3D.

Para um efeito mais avançado, vamos criar um material que reage à luz dinamicamente:

1. Adicione um nó "Fresnel" e conecte ao pin "Emissive Color"
2. Ajuste o Exponent para 3.0
3. Multiplique por um Constant3Vector azul usando um nó "Multiply"
4. Conecte o resultado ao pin "Emissive Color"

Isso criará um brilho azul nas bordas do objeto quando visto de ângulos oblíquos, perfeito para itens mágicos. O gráfico de nós deve parecer com:

```
TextureSample ──┬─ Base Color
                └─ Roughness
Fresnel ─ Multiply(azul) ─ Emissive
```

Quando você compila e aplica este material, notará que a espada emite um brilho sutil nas bordas. Se o efeito for muito forte, volte ao nó Multiply e reduza o valor do azul (por exemplo, para 0.3, 0.3, 1.0).

Para organizar materiais complexos, use "Material Functions". Crie uma nova via Content Browser → Materials & Textures → Material Function. Por exemplo, uma função que calcula dano:

1. Crie inputs "Health" (Scalar) e "BaseColor" (Vector3)
2. Use um nó "LinearGradient" para interpolar entre vermelho (0) e BaseColor (1) baseado em Health
3. Exponha o resultado como output

Depois, em qualquer material, você pode chamar esta função via nó "Function Call".

Exercício: Crie um material que:
1. Use uma textura de pedra para Base Color
2. Tenha Roughness variável baseado na posição vertical (use PixelDepth)
3. Emita um brilho vermelho quando visto de baixo

Solução:
1. Arraste a textura de pedra e conecte ao Base Color
2. Adicione um nó "PixelDepth", normalize dividindo por 1000
3. Conecte ao Roughness (inverta com 1-x se necessário)
4. Crie um Fresnel com Exponent baixo (1.5)
5. Multiplique por um Vector3 vermelho e conecte ao Emissive
6. Use um nó "Height" para reforçar o efeito quando visto de baixo