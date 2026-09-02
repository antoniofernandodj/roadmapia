## Integração com APIs gráficas avançadas

Quando você precisa criar efeitos visuais que vão além do padrão oferecido pelos materiais da Unreal Engine, a integração direta com APIs gráficas como DirectX ou Vulkan se torna essencial. Vamos implementar um shader personalizado que altera a cor de um objeto baseado na distância até a câmera, demonstrando como conectar C++ com a pipeline gráfica.

Primeiro, criamos uma classe que herda de `FGlobalShader`:

```cpp
// ShaderExample.h
#pragma once
#include "GlobalShader.h"
#include "ShaderParameterStruct.h"

class FDistanceColorShader : public FGlobalShader
{
    DECLARE_SHADER_TYPE(FDistanceColorShader, Global);
    
public:
    FDistanceColorShader() {}
    FDistanceColorShader(const ShaderMetaType::CompiledShaderInitializerType& Initializer)
        : FGlobalShader(Initializer)
    {
        CameraPosition.Bind(Initializer.ParameterMap, TEXT("CameraPosition"));
    }
    
    static bool ShouldCache(EShaderPlatform Platform)
    {
        return true;
    }
    
    static bool ShouldCompilePermutation(const FGlobalShaderPermutationParameters& Parameters)
    {
        return true;
    }
    
    void SetParameters(FRHICommandList& RHICmdList, const FVector& InCameraPosition)
    {
        SetShaderValue(RHICmdList, RHICmdList.GetBoundPixelShader(), CameraPosition, InCameraPosition);
    }
    
private:
    FShaderParameter CameraPosition;
};
```

O erro mais comum aqui é esquecer de vincular o parâmetro no construtor. Se você tentar usar `CameraPosition` sem a chamada a `Bind()`, o motor lançará um erro:

```
Error: Shader parameter CameraPosition not bound
```

Agora implementamos o shader em HLSL:

```cpp
// DistanceColorShader.usf
#include "/Engine/Public/Platform.ush"

float3 CameraPosition;

float4 MainPS(
    float4 Position : SV_POSITION,
    float3 WorldPos : TEXCOORD0
) : SV_Target0
{
    float Distance = distance(WorldPos, CameraPosition);
    float3 Color = float3(saturate(Distance / 1000.0f), 0.0f, 1.0f - saturate(Distance / 1000.0f));
    return float4(Color, 1.0f);
}
```

Para usar este shader, criamos uma classe de renderização:

```cpp
// ShaderUsage.cpp
void RenderDistanceShader(FRHICommandList& RHICmdList, ERHIFeatureLevel::Type FeatureLevel, const FVector& CameraPosition)
{
    auto ShaderMap = GetGlobalShaderMap(FeatureLevel);
    TShaderMapRef<FDistanceColorShader> VertexShader(ShaderMap);
    TShaderMapRef<FDistanceColorShader> PixelShader(ShaderMap);
    
    FGraphicsPipelineStateInitializer GraphicsPSOInit;
    RHICmdList.ApplyCachedRenderTargets(GraphicsPSOInit);
    GraphicsPSOInit.BlendState = TStaticBlendState<>::GetRHI();
    GraphicsPSOInit.RasterizerState = TStaticRasterizerState<>::GetRHI();
    GraphicsPSOInit.DepthStencilState = TStaticDepthStencilState<true, CF_DepthNearOrEqual>::GetRHI();
    GraphicsPSOInit.BoundShaderState.VertexDeclarationRHI = GFilterVertexDeclaration.VertexDeclarationRHI;
    GraphicsPSOInit.BoundShaderState.VertexShaderRHI = VertexShader.GetVertexShader();
    GraphicsPSOInit.BoundShaderState.PixelShaderRHI = PixelShader.GetPixelShader();
    GraphicsPSOInit.PrimitiveType = PT_TriangleList;
    
    SetGraphicsPipelineState(RHICmdList, GraphicsPSOInit);
    
    PixelShader->SetParameters(RHICmdList, CameraPosition);
    
    RHICmdList.SetViewport(0, 0, 0.0f, 1920, 1080, 1.0f);
    RHICmdList.DrawPrimitive(0, 1, 1);
}
```

Quando integrado a um componente de cena, o resultado mostra objetos ficando mais vermelhos conforme se afastam da câmera (de perto são roxos, de longe vermelhos). A saída do shader será:

```
// Objeto próximo: RGB(0.2, 0.0, 0.8)
// Objeto médio: RGB(0.5, 0.0, 0.5)
// Objeto distante: RGB(0.9, 0.0, 0.1)
```

**Exercício**: Modifique o shader para incluir um efeito de pulsação baseado no tempo. A intensidade do azul deve variar entre 0.2 e 0.8 com uma frequência de 1Hz. Use a variável `Time` já disponível nos shaders da Unreal.

Solução:

```cpp
// DistanceColorShader.usf (modificado)
#include "/Engine/Public/Platform.ush"

float3 CameraPosition;
float Time;

float4 MainPS(
    float4 Position : SV_POSITION,
    float3 WorldPos : TEXCOORD0
) : SV_Target0
{
    float Distance = distance(WorldPos, CameraPosition);
    float Pulse = 0.5f + 0.3f * sin(Time * PI * 2.0f);
    float3 Color = float3(
        saturate(Distance / 1000.0f),
        0.0f,
        (1.0f - saturate(Distance / 1000.0f)) * Pulse
    );
    return float4(Color, 1.0f);
}
```