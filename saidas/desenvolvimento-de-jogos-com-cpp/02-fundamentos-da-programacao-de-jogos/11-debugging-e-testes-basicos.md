## Debugging e testes básicos

Você acabou de implementar um sistema de pontuação onde o jogador ganha pontos ao coletar moedas, mas algo está errado: às vezes a pontuação aumenta em 2 ou 3 pontos com uma única moeda. Como descobrir o que está acontecendo?

Vamos investigar usando o debugger integrado ao Visual Studio com Unreal Engine. Primeiro, crie um breakpoint no local onde a colisão com a moeda é processada:

```cpp
void AJogador::OnOverlapBegin(UPrimitiveComponent* OverlappedComp, AActor* OtherActor, 
    UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep, 
    const FHitResult& SweepResult)
{
    if (OtherActor->ActorHasTag("Moeda")) // Breakpoint nesta linha
    {
        Pontuacao += 10;
        OtherActor->Destroy();
        UE_LOG(LogTemp, Warning, TEXT("Pontuação atual: %d"), Pontuacao);
    }
}
```

Ao executar o jogo em modo debug (F5), o código pausará quando a colisão ocorrer. Use as ferramentas de inspeção:

1. **Watch Window**: Adicione `OtherActor` e `Pontuacao` para monitorar seus valores
2. **Call Stack**: Verifique a sequência de chamadas que levou a esta função
3. **Step Over (F10)**: Execute linha por linha

Você descobrirá que o problema ocorre porque o evento de colisão está sendo chamado múltiplas vezes para o mesmo objeto. A solução é adicionar uma verificação:

```cpp
if (OtherActor->ActorHasTag("Moeda") && !OtherActor->IsPendingKill())
{
    Pontuacao += 10;
    OtherActor->Destroy();
}
```

Outra ferramenta poderosa é o `UE_LOG`, que imprime mensagens no Output do Unreal. Vamos melhorar nosso log para ajudar no debug:

```cpp
UE_LOG(LogTemp, Warning, TEXT("Coletou moeda %s. Nova pontuação: %d"), 
    *OtherActor->GetName(), Pontuacao);
```

Isso mostrará no Output:
```
LogTemp: Warning: Coletou moeda BP_GoldCoin_C_0. Nova pontuação: 30
```

Para testar comportamentos específicos, crie funções de teste temporárias que simulam situações:

```cpp
void AJogador::TestarSistemaPontuacao()
{
    // Simula coletar 5 moedas
    for (int i = 0; i < 5; i++)
    {
        Pontuacao += 10;
        UE_LOG(LogTemp, Display, TEXT("Teste %d: Pontuação = %d"), i+1, Pontuacao);
    }
    
    // Verifica se o resultado é o esperado
    checkf(Pontuacao == 50, TEXT("Falha no teste: pontuação deveria ser 50 mas é %d"), Pontuacao);
}
```

Ao executar, se houver erro, você verá:
```
Assertion failed: Pontuacao == 50 [File:...] [Line: 42]
Falha no teste: pontuação deveria ser 50 mas é 60
```

Erros comuns e como resolver:

1. **Breakpoint não é acionado**: Verifique se está no modo Debug e se o código está realmente sendo executado
2. **Variáveis mostram "optimized out"**: Desative otimizações no menu Debug > Windows > Optimization
3. **Logs não aparecem**: No Editor Unreal, vá para Window > Developer Tools > Output Log

Exercício: Implemente um sistema de teste para as vidas do jogador que:
1. Reduz uma vida quando colide com um inimigo
2. Não permite que vidas fiquem negativas
3. Mostra mensagem de "Game Over" quando chega a zero

Solução comentada:

```cpp
void AJogador::PerderVida()
{
    Vidas = FMath::Max(0, Vidas - 1); // Garante não ficar negativo
    
    UE_LOG(LogTemp, Warning, TEXT("Vidas restantes: %d"), Vidas);
    
    if (Vidas <= 0)
    {
        UE_LOG(LogTemp, Error, TEXT("GAME OVER"));
        // Chama função de game over no GameMode
        GetWorld()->GetAuthGameMode()->GameOver(); 
    }
}

void AJogador::TestarSistemaVidas()
{
    Vidas = 3; // Reset para teste
    PerderVida(); // Deve ter 2
    PerderVida(); // Deve ter 1
    PerderVida(); // Deve ter 0 e mostrar GAME OVER
    PerderVida(); // Não deve diminuir além de 0
}
```