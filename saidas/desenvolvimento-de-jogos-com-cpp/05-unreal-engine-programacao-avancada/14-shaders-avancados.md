## Shaders avançados

Um shader é um programa que roda na GPU para controlar como cada pixel é renderizado. Na Unreal Engine, shaders são essenciais para criar efeitos visuais impressionantes como água que reflete o ambiente, metais com brilho realista ou materiais que mudam de aparência dinamicamente.

Vamos criar um shader simples que modifica a cor de um objeto baseado na distância até a câmera. Comece criando um novo Material na pasta Content/Materials (botão direito > Material):

1. Clique com o botão direito na pasta
2. Selecione Material
3. Nomeie como "DistanceColor"

Dentro do editor de materiais, adicione um nó "CameraPositionWS" (World Space) e conecte-o a um nó "Distance". No outro lado do Distance, adicione um nó "ObjectPositionWS". Essa configuração calcula a distância entre o objeto e a câmera:

```
[CameraPositionWS] -----> [Distance] -----> [Lerp]
[ObjectPositionWS]--/             |
                                  v
                            [Color1] [Color2]
```

Conecte o resultado do Distance a um nó "Lerp" (Linear Interpolation). Defina duas cores constantes (por exemplo, vermelho e azul) como inputs do Lerp. Finalmente, conecte a saída do Lerp ao pin "Base Color" do nó principal do material. O shader agora interpola entre as duas cores baseado na distância.

O código HLSL equivalente gerado pela Unreal seria:

```hlsl
void Main(
    float3 WorldPosition : POSITION,
    out float4 OutColor : SV_Target0)
{
    float3 CameraPos = GetCameraPositionWS();
    float Distance = distance(WorldPosition, CameraPos);
    float4 Color1 = float4(1,0,0,1); // Vermelho
    float4 Color2 = float4(0,0,1,1); // Azul
    OutColor = lerp(Color1, Color2, saturate(Distance/1000.0f));
}
```

Erro comum: esquecer de normalizar a distância. Se você não dividir por um valor razoável (como 1000 no exemplo), a interpolação pode não funcionar como esperado. A função `saturate` garante que o valor fique entre 0 e 1.

Para um efeito mais avançado, podemos adicionar um Fresnel effect, que muda a aparência baseado no ângulo de visão:

1. Adicione um nó "Fresnel"
2. Conecte sua saída a um nó "Power" para controlar a intensidade
3. Use o resultado para controlar um segundo Lerp entre o resultado anterior e uma terceira cor

A combinação final na Unreal fica assim:

```
[DistanceColor] -----> [Lerp] -----> [BaseColor]
[FresnelEffect]--/     [EdgeColor]
```

Quando aplicado a uma esfera no nível, você verá:
1. Cor muda com a distância (vermelho perto, azul longe)
2. Bordas destacadas quando vistas de lado (Fresnel effect)

Para controlar shaders via C++, crie uma classe MaterialInstanceDynamic:

```cpp
// No header da sua classe Actor
UMaterialInstanceDynamic* DynamicMaterial;

// No cpp, no BeginPlay()
DynamicMaterial = UMaterialInstanceDynamic::Create(BaseMaterial, this);
MeshComponent->SetMaterial(0, DynamicMaterial);

// Para mudar parâmetros durante o jogo
DynamicMaterial->SetScalarParameterValue("GlowIntensity", 2.5f);
DynamicMaterial->SetVectorParameterValue("Color", FLinearColor::Green);
```

Exercício: Crie um material que:
1. Muda de cor baseado na altura do objeto (Y no mundo)
2. Pisca suavemente quando o jogador está próximo
3. Tem bordas brilhantes quando visto de certos ângulos

Solução comentada:

1. Use "ObjectPositionWS" e separe o componente Y com um "ComponentMask"
2. Compare com "CameraPositionWS" usando "Distance" e normalize
3. Use "Sine" com "Time" para criar o efeito de piscar
4. Combine com "Fresnel" para as bordas brilhantes
5. Misture tudo usando "Lerp" e "Multiply" nodes

```
[ObjectPositionWS] --> [ComponentMask(Y)] --> [HeightColor]
[CameraPositionWS] --> [Distance] --> [PulseEffect] 
[Time] --> [Sine] --> [Multiply(PulseEffect)]
[Fresnel] --> [EdgeEffect]
[Lerp(HeightColor, PulseColor, PulseEffect)] --> [FinalColor]
[Multiply(FinalColor, EdgeEffect)] --> [BaseColor]
```