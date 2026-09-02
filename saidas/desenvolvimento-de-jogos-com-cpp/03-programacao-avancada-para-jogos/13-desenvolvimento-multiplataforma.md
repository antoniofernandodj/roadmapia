## Desenvolvimento multiplataforma

Quando você desenvolve um jogo, deseja que ele funcione em várias plataformas: Windows, macOS, Linux, consoles e dispositivos móveis. Isso parece complicado, mas a Unreal Engine facilita esse processo ao abstrair boa parte das diferenças entre plataformas. No entanto, ainda há algumas práticas que você precisa seguir para garantir que seu código funcione corretamente em todos os lugares.

### O problema das diferenças de plataforma

Imagine que você está desenvolvendo um jogo que usa a função `fopen` para abrir arquivos. No Windows, você pode escrever algo assim:

```cpp
FILE* file = fopen("C:\\caminho\\para\\arquivo.txt", "r");
```

Isso funciona bem no Windows, mas no Linux ou macOS, o caminho seria diferente. Além disso, o caractere `\` é um caractere de escape em C++ e precisa ser escapado (`\\`). Isso já é um problema. Para resolver isso, a Unreal Engine oferece uma abordagem multiplataforma:

```cpp
FString FilePath = FPaths::ProjectContentDir() + TEXT("arquivo.txt");
TUniquePtr<FArchive> File = TUniquePtr<FArchive>(IFileManager::Get().CreateFileReader(*FilePath));
```

Aqui, `FPaths::ProjectContentDir()` retorna o caminho correto para a pasta de conteúdo do projeto, independentemente da plataforma. `IFileManager::Get().CreateFileReader` abstrai a abertura de arquivos de forma multiplataforma.

### Diferenças de entrada

Outro exemplo comum é a entrada do usuário. No PC, você pode usar o mouse e o teclado, mas em um console, você depende de um joystick. A Unreal Engine fornece uma abstração para isso também. Em vez de verificar diretamente o estado do teclado, você pode usar o sistema de ações de entrada:

```cpp
void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &AMyCharacter::Jump);
}
```

Neste exemplo, a ação "Jump" pode ser mapeada para diferentes dispositivos de entrada, como uma tecla no teclado ou um botão no joystick, sem alterar o código.

### Diferenças de gráficos

As APIs gráficas também variam entre plataformas. DirectX é comum no Windows, enquanto OpenGL é usado em macOS e Linux. A Unreal Engine abstrai isso para você através do Material Editor e Shaders. No entanto, se você precisar de algo específico, pode usar pré-processadores para código condicional:

```cpp
#if PLATFORM_WINDOWS
    // Código específico para Windows
#elif PLATFORM_MAC
    // Código específico para macOS
#elif PLATFORM_LINUX
    // Código específico para Linux
#endif
```

Isso permite que você escreva código específico para cada plataforma sem quebrar o projeto.

### Diferenças de desempenho

Dispositivos móveis têm menos poder de processamento e memória do que PCs ou consoles. Para garantir que seu jogo funcione bem em todas as plataformas, você pode usar técnicas como `Object Pooling` e `Spatial Partitioning`, que já foram abordadas em capítulos anteriores. Além disso, a Unreal Engine permite ajustar a qualidade gráfica dinamicamente:

```cpp
UGameUserSettings* Settings = GEngine->GetGameUserSettings();
Settings->SetOverallScalabilityLevel(3); // Nível de qualidade médio
Settings->ApplySettings(false);
```

Isso ajusta a qualidade gráfica para garantir um bom desempenho em dispositivos menos potentes.

### Erro comum: esquecer de testar em todas as plataformas

Um erro comum é desenvolver apenas para uma plataforma e assumir que funcionará em todas as outras. Por exemplo, você pode ter um código que funciona perfeitamente no Windows, mas falha no macOS devido a diferenças na manipulação de arquivos ou entrada. A solução é testar seu jogo em todas as plataformas-alvo durante o desenvolvimento.

### Exercício prático

Crie um sistema simples que salva a pontuação do jogador em um arquivo. Use `FPaths` e `IFileManager` para garantir que o código funcione em todas as plataformas. Teste o código no Windows e simule o comportamento em outras plataformas usando pré-processadores.

**Solução:**

```cpp
void SaveScore(int32 Score)
{
    FString FilePath = FPaths::ProjectSavedDir() + TEXT("score.txt");
    TUniquePtr<FArchive> File = TUniquePtr<FArchive>(IFileManager::Get().CreateFileWriter(*FilePath));

    if (File)
    {
        *File << Score;
    }
}

int32 LoadScore()
{
    FString FilePath = FPaths::ProjectSavedDir() + TEXT("score.txt");
    TUniquePtr<FArchive> File = TUniquePtr<FArchive>(IFileManager::Get().CreateFileReader(*FilePath));

    int32 Score = 0;
    if (File)
    {
        *File << Score;
    }

    return Score;
}
```

Este código salva e carrega a pontuação de um arquivo, funcionando em todas as plataformas suportadas pela Unreal Engine.