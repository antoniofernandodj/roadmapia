## Integração com APIs gráficas

Quando você quer criar efeitos visuais personalizados ou otimizar a renderização além do que o Unreal Engine oferece por padrão, precisa acessar diretamente a GPU através de APIs gráficas. Vamos começar com um problema concreto: sua cena precisa renderizar 10.000 partículas com um efeito especial que o Niagara não suporta nativamente.

O código abaixo mostra como inicializar o OpenGL dentro de um projeto Unreal:

```cpp
// No arquivo YourGameModule.cpp
#include "OpenGLDrv.h"

void FYourGameModule::StartupModule() {
    // Inicializa o contexto OpenGL
    FOpenGLDynamicRHI* OpenGLRHI = static_cast<FOpenGLDynamicRHI*>(GDynamicRHI);
    if (OpenGLRHI) {
        glEnable(GL_PROGRAM_POINT_SIZE); // Permite controlar o tamanho das partículas via shader
        
        // Configura o buffer de vértices
        GLuint VBO;
        glGenBuffers(1, &VBO);
        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        
        // Erro comum: esquecer de verificar o contexto
        if (!glGetCurrentContext()) {
            UE_LOG(LogTemp, Error, TEXT("Falha ao criar contexto OpenGL"));
            return;
        }
    }
}
```

A saída esperada quando tudo funciona corretamente é silêncio - o contexto gráfico é criado sem mensagens de erro. Se você vir o erro no log, significa que a inicialização falhou.

Para renderizar nossas partículas, vamos criar uma classe especializada:

```cpp
// ParticleRenderer.h
#pragma once
#include "CoreMinimal.h"

class PARTICLEPLUGIN_API FParticleRenderer {
public:
    void Initialize();
    void RenderParticles(const TArray<FVector>& Positions);
    
private:
    GLuint ShaderProgram;
    GLuint VAO, VBO;
};

// ParticleRenderer.cpp
#include "ParticleRenderer.h"
#include "OpenGLDrv.h"

void FParticleRenderer::Initialize() {
    // Compila o shader de partículas
    const GLchar* VertexShaderSource = R"(
        #version 330 core
        layout (location = 0) in vec3 aPos;
        void main() {
            gl_Position = vec4(aPos, 1.0);
            gl_PointSize = 10.0;
        }
    )";
    
    GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &VertexShaderSource, NULL);
    glCompileShader(vertexShader);
    
    // Verificação de erros do shader omitida por brevidade
    
    ShaderProgram = glCreateProgram();
    glAttachShader(ShaderProgram, vertexShader);
    glLinkProgram(ShaderProgram);
    
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
}

void FParticleRenderer::RenderParticles(const TArray<FVector>& Positions) {
    glUseProgram(ShaderProgram);
    glBindVertexArray(VAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, Positions.Num() * sizeof(FVector), 
                Positions.GetData(), GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(FVector), (void*)0);
    
    glDrawArrays(GL_POINTS, 0, Positions.Num());
    glBindVertexArray(0);
}
```

Um erro comum é tentar chamar funções OpenGL sem o contexto ativo, resultando em:

```
OpenGL Error: 1282 (Invalid operation)
```

Isso ocorre quando você chama glDrawArrays sem vincular os buffers corretamente. A solução é sempre verificar o estado antes de renderizar:

```cpp
if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
    UE_LOG(LogTemp, Warning, TEXT("Framebuffer incompleto!"));
    return;
}
```

Para integrar com o pipeline de renderização da Unreal, sobrescreva o método de renderização de seu Actor:

```cpp
// No seu Actor customizado
void AGLParticleActor::PostRenderFor(UPrimitiveComponent* Component, 
                                    FCanvas* Canvas, FSceneView* View) {
    Super::PostRenderFor(Component, Canvas, View);
    
    FScopeLock Lock(&RenderCriticalSection);
    ParticleRenderer->RenderParticles(CurrentParticlePositions);
}
```

Aqui está uma comparação entre OpenGL e DirectX 11 no contexto da Unreal:

| Característica          | OpenGL                  | DirectX 11              |
|-------------------------|-------------------------|-------------------------|
| Inicialização           | Contexto explícito      | Dispositivo e swapchain |
| Shaders                 | GLSL                    | HLSL                    |
| Sincronização           | glFlush/glFinish        | DeviceContext->Flush()  |
| Compatibilidade         | Multiplataforma         | Windows/Xbox            |
| Debug                   | glGetError()            | D3D11_CREATE_DEVICE_DEBUG |

Exercício: Crie um sistema de partículas que muda de cor baseado na distância do jogador. Use o seguinte código base:

```cpp
// No seu shader de fragmentos:
uniform vec3 PlayerPosition;
uniform sampler1D ColorGradient;

void main() {
    float dist = distance(gl_FragCoord.xyz, PlayerPosition);
    float normalizedDist = clamp(dist / 100.0, 0.0, 1.0);
    FragColor = texture1D(ColorGradient, normalizedDist);
}
```

Solução passo a passo:

1. Adicione as variáveis uniformes ao seu shader
2. Atualize a posição do jogador a cada frame:
```cpp
GLint playerPosLoc = glGetUniformLocation(ShaderProgram, "PlayerPosition");
glUniform3f(playerPosLoc, PlayerPos.X, PlayerPos.Y, PlayerPos.Z);
```
3. Crie uma textura 1D para o gradiente de cores
4. Ligue a textura antes de renderizar

A principal vantagem da integração direta com APIs gráficas é o controle fino sobre o pipeline de renderização, permitindo otimizações específicas e efeitos visuais exclusivos que não são possíveis com os sistemas de alto nível da Unreal Engine.