## Preparação para publicação

Seu jogo está completo, os sistemas funcionam, os testes foram feitos - mas ninguém pode jogá-lo enquanto estiver preso dentro do editor da Unreal Engine. Publicar um jogo envolve transformar seu projeto em um arquivo executável independente, com todos os recursos embutidos e otimizados para distribuição.

Na Unreal Engine, isso começa com a configuração de Build. No editor, vá em *File → Package Project → Build Configuration* e selecione *Shipping*. Esta configuração remove todas as ferramentas de debug e otimiza o código ao máximo. Se você esquecer e deixar em *Development*, o jogo ficará até 30% mais lento:

```cpp
// No arquivo YourProjectName.Build.cs
PublicDependencyModuleNames.AddRange(new string[] { 
    "Core", 
    "CoreUObject", 
    "Engine", 
    "InputCore",
    "UMG" 
});
```

O próximo passo crítico é configurar os *Packaging Settings* (*Edit → Project Settings → Packaging*). Aqui, dois erros comuns causam problemas graves:

1. **Assets não referenciados**: Por padrão, a UE não inclui assets não usados no build. Se você carrega dinamicamente, precisa marcá-los como *Always Cook*:

```cpp
// No construtor da sua classe de GameInstance
static ConstructorHelpers::FObjectFinder<USoundWave> SoundAsset(TEXT("/Game/Sounds/Ambient"));
if (SoundAsset.Succeeded()) {
    AmbientSound = SoundAsset.Object;
    AmbientSound->SetFlags(RF_Public); // Garante inclusão no pacote
}
```

2. **Texturas não POT (Power Of Two)**: Em jogos 2D, texturas devem ter tamanhos como 256x256 ou 512x512. Uma textura 300x300 causará este erro no log:
```
LogTexture: Warning: Texture /Game/Sprites/Character_300x300 non-power-of-two dimensions (300x300) 
```

Para o empacotamento real, use o *Project Launcher* (Window → Developer Tools → Project Launcher). Crie um novo perfil e selecione:

- **Platform**: Windows (ou sua plataforma alvo)
- **Configuration**: Shipping
- **Cook Mode**: By the book (mais lento mas mais seguro)
- **Archive**: Sim (gera um .zip pronto para distribuir)

Um erro comum durante o cook é esquecer dependências de plugins. Se receber:
```
Missing module 'Paper2D' while compiling...
```
Adicione no YourProjectName.Build.cs:
```cpp
PrivateDependencyModuleNames.AddRange(new string[] { "Paper2D" });
```

Ao final, você terá uma pasta com o executável e todos os arquivos necessários. Teste em uma máquina limpa (sem a UE instalada) para garantir que tudo funciona.

**Exercício**: Crie um build para Windows que inclui um asset carregado dinamicamente (uma textura ou som) sem referência direta no código. A solução requer:

1. Criar um Blueprint que referencia o asset
2. Adicionar esse Blueprint ao mapa inicial
3. Forçar o cook do asset via console command:
```cpp
// No arquivo DefaultGame.ini
[/Script/UnrealEd.ProjectPackagingSettings]
+CookDirectories=(Path="Game/Assets/Dynamic")
```