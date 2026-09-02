## Iluminação básica

Uma cena sem iluminação na Unreal Engine parece um modelo 3D plano e sem vida. Vamos criar um ambiente simples com um cubo no centro e iluminá-lo corretamente. Comece criando um novo projeto "Blank" e adicione um Static Mesh (Cube) no Viewport.

Para a iluminação mais básica, usaremos dois tipos de luzes:

1. **Directional Light** (simula o sol)
2. **Point Light** (fonte de luz pontual)

Adicione uma Directional Light (Modos > Luzes > Directional Light) e ajuste sua direção para que ilumine o cubo em um ângulo de 45 graus. No Details Panel, experimente mudar:

```cpp
Intensity: 10.0
Light Color: Branco (255,255,255)
```

Agora adicione uma Point Light próxima ao cubo para criar um efeito secundário. Configure:

```cpp
Intensity: 5000.0
Attenuation Radius: 1000.0
```

O erro mais comum é esquecer de ajustar o Attenuation Radius, resultando em luz que não alcança os objetos ou ilumina demais a cena toda. Se você ver a mensagem "Light needs to be rebuilt", pressione o botão "Build" na Toolbar.

Para entender como a luz interage com superfícies, crie um Material básico:
1. Clique direito no Content Browser > Materials > Material
2. Dê duplo clique para abrir o editor
3. Conecte um nó Constant3Vector (cor) ao emissivo
4. Conecte um nó Constant (valor 0.3) ao Roughness

Aplique este material ao cubo e observe como a luz reage diferentemente com valores de Roughness alterados (0.0 = muito brilhante, 1.0 = fosco).

Para ver todos os efeitos de iluminação ativos, no Viewport clique em "Lit" (em vez de "Unlit") na barra de visualização.

**Exercício:** Crie uma cena com:
- 3 esferas em linha
- Cada esfera com um material de Roughness diferente (0.0, 0.5, 1.0)
- Duas Point Lights com cores complementares (ex: vermelho e ciano)
- Ajuste as intensidades para criar áreas de sombra suave entre as esferas

**Solução comentada:**
1. Adicione 3 Static Meshes (Sphere) alinhados
2. Crie 3 materiais com Roughness variando
3. Adicione duas Point Lights com cores RGB (255,0,0) e (0,255,255)
4. Posicione as luzes em lados opostos das esferas
5. Ajuste Intensity para ~3000 e Attenuation Radius para ~500
6. Construa a iluminação (Build) e observe as diferenças nos materiais