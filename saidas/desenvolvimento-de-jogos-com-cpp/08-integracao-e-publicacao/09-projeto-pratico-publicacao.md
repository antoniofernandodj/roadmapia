## Projeto prático: publicação

Seu jogo está pronto, os sistemas estão integrados e tudo funciona no editor. Mas como transformar esse projeto em um executável que qualquer pessoa pode instalar e jogar? A publicação é onde muitos desenvolvedores enfrentam problemas inesperados - builds que funcionam no editor mas travam quando executadas, assets que somem, ou configurações não aplicadas corretamente.

Vamos começar com a configuração básica de projeto. Abra `Project Settings > Packaging` e verifique:

```cpp
// Config/DefaultGame.ini
[/Script/UnrealEd.ProjectPackagingSettings]
DirectoriesToAlwaysCook=(Path="/Game/Assets")
BuildConfiguration=PPBC_Shipping
bCookAll=True
```

Esse trecho garante que todos os assets sejam incluídos no pacote final e que a build seja compilada em modo Shipping (com otimizações ativadas e símbolos de debug removidos). Um erro comum é esquecer de marcar `bCookAll`, resultando em mensagens como:

```
LogStreaming: Warning: Failed to read file '../../../ProjectName/Content/Assets/Texture.uasset' error.
```

Para criar o pacote, vá em `File > Package Project > Windows (64-bit)`. A Unreal gerará uma pasta com todos os arquivos necessários. Teste imediatamente o executável gerado - não no seu computador de desenvolvimento, mas em uma máquina limpa ou pelo menos fora do editor.

Se o jogo não inicia, verifique o log em `Saved/Logs/ProjectName.log`. Erros comuns incluem:

1. Plugins não embarcados:
```
Plugin 'PluginName' failed to load because module 'ModuleName' could not be found.
```
Solução: em `Edit > Plugins`, marque "Enabled" e "Installed" para todos os plugins essenciais.

2. Referências a assets não cozinhados:
```
Failed to load /Game/Assets/SoundWave.SoundWave
```
Solução: adicione o caminho em `DirectoriesToAlwaysCook` como mostrado acima.

3. Configurações de input não aplicadas:
```
Action Mappings not found for 'Jump'
```
Solução: verifique se `DefaultInput.ini` está no diretório `Config/` do pacote.

Para otimizar o tamanho do pacote, use estas configurações no arquivo `DefaultEngine.ini`:

```cpp
[/Script/Engine.RendererSettings]
r.ScreenPercentage=70
r.ViewDistanceScale=0.8
[/Script/Engine.StreamingSettings]
r.Streaming.PoolSize=500
```

Isso reduz a resolução interna para 70% e diminui a distância de renderização, economizando memória sem impacto visual significativo. O pool size limita a memória usada para streaming de texturas.

Quando estiver pronto para distribuir, crie um instalador usando tools como Inno Setup ou NSIS. Inclua os requisitos mínimos no instalador:

```cpp
// Requisitos para seu jogo
OS: Windows 10 64-bit
Processor: Intel Core i5-2500K / AMD FX-6300
Memory: 8 GB RAM
Graphics: NVIDIA GTX 770 2GB / AMD R9 280 3GB
DirectX: Version 11
Storage: 2 GB available space
```

Exercício: Crie um build shipping do seu projeto e teste em outra máquina. Identifique e corrija pelo menos um problema que só aparece na versão empacotada.

**Solução comentada:**

1. Execute `File > Package Project > Windows (64-bit)`
2. Copie a pasta gerada para outro computador
3. Se encontrar erros, verifique:
   - Assets faltando (adicionar em DirectoriesToAlwaysCook)
   - Plugins não incluídos (habilitar no projeto)
   - Configurações não aplicadas (copiar arquivos .ini manualmente)
4. Um problema comum é o esquecimento de incluir arquivos de configuração customizados - copie manualmente toda a pasta `Config/` para o build empacotado.