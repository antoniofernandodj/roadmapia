## Configurando o ambiente de desenvolvimento

Antes de começar a programar jogos com C++ e Unreal Engine, você precisará instalar duas ferramentas principais: o Visual Studio (IDE para escrever código) e a própria Unreal Engine. O processo tem algumas armadilhas comuns que vamos evitar desde o início.

### 1. Instalando o Visual Studio

Baixe o instalador do [Visual Studio Community](https://visualstudio.microsoft.com/) (versão gratuita). Ao abrir o instalador, você verá esta interface:

![Instalador do Visual Studio mostrando cargas de trabalho](https://docs.microsoft.com/pt-br/visualstudio/install/media/vs-installer-workloads.png?view=vs-2022)

Selecione a carga de trabalho "Desenvolvimento para Desktop com C++". Isso instala:
- O compilador MSVC (Microsoft Visual C++)
- Ferramentas de depuração
- IntelliSense para autocompletar código
- Gerenciador de pacotes NuGet

**Erro comum**: esquecer de marcar a opção "Windows 10 SDK" ou "Windows 11 SDK" na seção de componentes individuais. Se faltar, você verá este erro ao compilar projetos Unreal mais tarde:

```
MSB8036: The Windows SDK version 10.0.xxxxx.0 was not found
```

Para corrigir, volte ao instalador > Modificar > Componentes Individuais > marque o SDK correspondente ao seu Windows.

### 2. Instalando a Unreal Engine

1. Crie uma conta na [Epic Games](https://www.epicgames.com/)
2. Baixe o Epic Games Launcher
3. Acesse a aba "Unreal Engine" > "Biblioteca" > "+ ENGINE" para instalar a versão mais recente

Durante a instalação, reserve pelo menos 30GB de espaço livre - um projeto vazio já ocupa ~8GB. A instalação inclui:

- Editor Unreal
- Compilador de shaders
- Ferramentas de importação de assets
- Templates de projetos

**Problema frequente**: esquecer de instalar os componentes opcionais. Na tela de instalação, expanda "Opções" e marque:

- Starter Content (conteúdo básico para testes)
- Platform Support (suporte a Android/iOS se desenvolver para mobile)

### 3. Configurando a integração

Abra o Visual Studio, vá em Extensões > Gerenciar Extensões e procure por "Unreal Engine". Instale a extensão oficial - ela adiciona:

- Modelos de projeto Unreal
- Syntax highlighting específico
- Atalhos para compilação rápida

Para verificar se tudo está correto:

1. Abra o Epic Games Launcher
2. Crie um novo projeto C++ (Blueprint vai funcionar, mas não usa C++)
3. Visual Studio deve abrir automaticamente ao clicar em "Abrir no Visual Studio"

Se o Visual Studio não abrir, verifique no Editor Unreal:
Edit > Editor Preferences > General > Source Code > mudar "Source Code Editor" para Visual Studio

### Testando a instalação

No Visual Studio, pressione F5 para compilar e executar o projeto padrão. Você deve ver uma janela 3D com a mensagem "Level Loaded" no canto. Se aparecer:

```
Cannot find UnrealBuildTool
```

Significa que o caminho do Unreal Engine não está configurado. Corrija em:
Tools > Options > Unreal Engine > Associar a instalação

### Exercício prático

1. Instale o Visual Studio com os componentes listados
2. Adicione a Unreal Engine 5 via Epic Games Launcher
3. Crie um projeto C++ básico chamado "TesteInstalacao"
4. Compile e execute para ver a cena vazia
5. Modifique o arquivo `TesteInstalacaoCharacter.cpp` para que o personagem comece com o dobro da velocidade padrão (procure por `MaxWalkSpeed`)

**Solução comentada**:
No arquivo mencionado, localize o construtor `ATesteInstalacaoCharacter::ATesteInstalacaoCharacter()`. Adicione:

```cpp
GetCharacterMovement()->MaxWalkSpeed = 1200.0f; // Valor padrão é 600
```

Isso demonstra que:
1. O ambiente está configurado corretamente
2. Você pode editar código C++
3. As alterações afetam o comportamento do jogo