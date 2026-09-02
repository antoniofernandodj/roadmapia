## Marketing e divulgação

Seu jogo está pronto, mas sem jogadores, é como uma música tocada para uma plateia vazia. O problema real que enfrentamos aqui é simples: como fazer com que pessoas descubram e se interessem por um jogo entre milhares de lançamentos independentes? Isso exige mais do que postar "jogue meu jogo" nas redes sociais.

Começamos com o pitch - uma explicação curta que captura a essência do jogo. Na Unreal Engine, você já tem parte do trabalho feita: abra o projeto e pressione Alt+P para capturar um GIF automático da gameplay. Esse será seu material principal. Agora, escreva no bloco de notas:

```cpp
// Exemplo de pitch eficaz para um jogo de plataforma 2D
FString GamePitch = TEXT("SuperPlumber Adventures é um jogo de plataforma retro "
"onde você controla um encanador que deve resgatar cogumelos sequestrados. "
"Com mecânicas de wall-jump e power-ups que alteram a física, cada fase "
"transforma o ambiente em um playground vertical.");
```

Erro comum: criar pitches genéricos como "um jogo de ação emocionante". A ferramenta SteamDB mostra que 38% dos jogos usam essa descrição - seu jogo desaparece na multidão. A solução? Especificidade. Compare:

```
// Ruim - genérico demais
"Um jogo de tiro com muitos inimigos e armas"

// Bom - específico e memorável
"Um FPS onde você recarrega armas jogando os carregadores no ar e atirando neles"
```

Para imagens promocionais, a Unreal oferece ferramentas poderosas. No editor, pressione Ctrl+P para pausar o jogo no frame perfeito, depois use o console de comandos com `HighResShot 1920x1080` para uma captura em alta resolução. Cuidado com o erro comum de usar imagens da viewport - elas não mostram o jogo real. A mensagem de erro que você vai evitar parece com:

```
[Marketing Fail] Screenshot doesn't match final gameplay
```

Redes sociais exigem consistência. Crie um calendário de conteúdo usando a estrutura:

```cpp
TArray<FString> SocialMediaPlan;
SocialMediaPlan.Add(TEXT("Seg: GIF mostrando mecânica única"));
SocialMediaPlan.Add(TEXT("Qua: Arte conceito com progresso"));
SocialMediaPlan.Add(TEXT("Sex: Desafio para comunidade"));
```

A ferramenta de análise do Twitter mostrará o horário ideal para postar. Para a hashtag #IndieDev, o pico é às 15h UTC. Um código simples para lembrar:

```cpp
FDateTime OptimalPostTime = FDateTime::Now();
OptimalPostTime.SetTime(15, 0, 0); // 15:00 UTC
```

Press Kits são essenciais para imprensa. Na pasta do projeto, cione um diretório `Marketing/PressKit` com:
- 5 screenshots (16:9)
- 1 trailer (30 segundos)
- Logo em vetor (.svg)
- Fact sheet em .txt

O erro que você vai corrigir agora: assets não acessíveis. Execute no terminal do projeto:

```bat
REM Garante que os arquivos não estão bloqueados pelo Windows
unrealcv unlock Marketing/PressKit/*
```

Para comunidades como Reddit e Discord, crie uma demo jogável. Use o pacote de construção da Unreal com:

```bat
REM Gera build de demonstração
UE4Editor-Cmd.exe ProjectName -run=cook -targetplatform=Win64 -builddemo
```

Essa build deve conter apenas as primeiras 3 fases - o suficiente para mostrar o jogo, mas deixar o público querendo mais.

**Exercício:** Crie um post para Twitter com:
1. GIF capturado com Alt+P
2. Pitch de 2 frases
3. Hashtag #IndieDev e #UE4
4. Link para demo (use [itch.io](https://itch.io) para hospedagem gratuita)

**Solução comentada:**

```cpp
// 1. Captura o GIF durante gameplay especial
// (Execute durante uma sequência de wall-jump)
HighResShot 640x360 Marketing/Twitter/gameplay.gif

// 2. Pitch focado no diferencial
FString Tweet = TEXT("Pule, escale e rebata em paredes neste plataforma 2D "
"onde a gravidade é seu playground! Demo gratuita: ");

// 3. Hashtags no padrão da comunidade
FString Hashtags = TEXT("#IndieDev #UE4 #GameDev");

// 4. Link encurtado para a página da demo
FString DemoLink = TEXT("https://itch.io/my-game-demo");

// Combine tudo
FString FinalTweet = Tweet + Hashtags + DemoLink;
```