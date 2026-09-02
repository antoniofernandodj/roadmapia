## Sons e música

Em um jogo de plataforma 2D, os efeitos sonoros e a trilha musical são essenciais para criar imersão. Vamos implementar desde o simples efeito de pulo até uma trilha de fundo que muda conforme o jogador avança.

Primeiro, importe seus arquivos de áudio para a Unreal Engine. No Content Browser, clique em Import e selecione arquivos .wav ou .mp3. A Unreal automaticamente criará um Sound Wave asset para cada arquivo.

Para tocar um som quando o jogador pula, crie um novo Blueprint baseado em Character. No Event Graph, conecte o evento InputAction Jump a um nó Play Sound:

```blueprint
Event InputAction Jump
    -> Play Sound (selecione seu som de pulo)
```

Teste o jogo e pressione a tecla de pulo. Se nada acontecer, verifique:
- Se o som foi importado corretamente (deve aparecer no Content Browser)
- Se o Input Action "Jump" está configurado nas Project Settings
- Se o volume do som não está em 0 (verifique no Details Panel)

Para música de fundo, usaremos um Audio Component. No Blueprint do seu nível (Level Blueprint), adicione:

```blueprint
Begin Play
    -> Spawn Sound Attached (selecione sua música)
        -> Attach To (Get Player Character)
        -> Auto Play (True)
```

Isso fará a música tocar assim que o nível começar, seguindo o jogador. Um erro comum é esquecer de marcar "Loop" nas propriedades do som, fazendo a música parar após terminar.

Para controlar volumes separadamente (efeitos vs. música), crie duas variáveis Sound Class no Content Browser (Botão direito -> Sounds -> Sound Class). Nomeie-as "SFX" e "Music". Depois, no código:

```blueprint
Set Sound Class (Music) -> Volume Multiplier (0.5)
Set Sound Class (SFX) -> Volume Multiplier (0.8)
```

Para um sistema mais avançado, onde a música muda em áreas específicas, use Trigger Volumes:

```blueprint
Event ActorBeginOverlap (Trigger Volume)
    -> Spawn Sound Attached (nova música)
    -> Destroy (música anterior)
```

Exercício: Crie um sistema onde:
1. O personagem emite um som ao coletar um item
2. A música fica mais intensa quando o jogador entra em uma área de batalha
3. Todos os efeitos sonoros param quando o jogador morre

Solução comentada:

1. Crie um Blueprint para os itens coletáveis. No Event ActorBeginOverlap:
```blueprint
Play Sound (som de coleta)
Destroy Actor (item)
```

2. Na Trigger Volume da área de batalha:
```blueprint
Begin Overlap
    -> Set Sound Class (Music) -> Volume Multiplier (1.2)
    -> Set Pitch (1.1) // Aumenta a velocidade
```

3. No Blueprint do jogador, quando a vida chega a zero:
```blueprint
Set Sound Class (SFX) -> Volume Multiplier (0)
Set Sound Class (Music) -> Volume Multiplier (0)
```