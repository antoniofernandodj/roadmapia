## Salvamento e carregamento de dados

Imagine que o jogador passou horas coletando itens e avançando fases, mas ao fechar o jogo, todo o progresso é perdido. Isso acontece quando seu jogo não implementa um sistema de salvamento. Vamos resolver isso criando um sistema simples para persistir dados entre sessões.

### Salvando dados básicos

Na Unreal Engine, usamos `UGameplayStatics` para salvar e carregar dados. Comecemos salvando a pontuação do jogador:

```cpp
// No arquivo MinhaClasseJogador.h
UPROPERTY(VisibleAnywhere, Category = "Salvamento")
int32 PontuacaoAtual;

UFUNCTION(BlueprintCallable, Category = "Salvamento")
void SalvarProgresso();

// No arquivo MinhaClasseJogador.cpp
void AMinhaClasseJogador::SalvarProgresso()
{
    FString SaveSlot = "SaveSlot1";
    int32 UserIndex = 0;
    
    USaveGame* SaveGameInstance = UGameplayStatics::CreateSaveGameObject(USaveGame::StaticClass());
    UGameplayStatics::SaveGameToSlot(SaveGameInstance, SaveSlot, UserIndex);
    
    UE_LOG(LogTemp, Warning, TEXT("Progresso salvo com sucesso!"));
}
```

Ao executar este código, você verá no Output Log:
```
LogTemp: Warning: Progresso salvo com sucesso!
```

Mas espere - isso só cria um arquivo de salvamento vazio! Precisamos criar uma classe personalizada para armazenar nossos dados:

```cpp
// Crie um novo arquivo chamado MeuSaveGame.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/SaveGame.h"
#include "MeuSaveGame.generated.h"

UCLASS()
class MEUJOGO_API UMeuSaveGame : public USaveGame
{
    GENERATED_BODY()
    
public:
    UPROPERTY(VisibleAnywhere, Category = "Dados")
    int32 PontuacaoSalva;
    
    UPROPERTY(VisibleAnywhere, Category = "Dados")
    FString NomeJogador;
    
    UMeuSaveGame();
};
```

Agora atualizamos nossa função de salvamento:

```cpp
void AMinhaClasseJogador::SalvarProgresso()
{
    FString SaveSlot = "SaveSlot1";
    int32 UserIndex = 0;
    
    UMeuSaveGame* SaveGameInstance = Cast<UMeuSaveGame>(UGameplayStatics::CreateSaveGameObject(UMeuSaveGame::StaticClass()));
    SaveGameInstance->PontuacaoSalva = PontuacaoAtual;
    SaveGameInstance->NomeJogador = "Jogador1";
    
    UGameplayStatics::SaveGameToSlot(SaveGameInstance, SaveSlot, UserIndex);
    
    UE_LOG(LogTemp, Warning, TEXT("Salvou pontuação %d para %s"), 
        SaveGameInstance->PontuacaoSalva, 
        *SaveGameInstance->NomeJogader);
}
```

### Carregando os dados salvos

Para recuperar os dados salvos, usamos uma abordagem similar:

```cpp
UFUNCTION(BlueprintCallable, Category = "Salvamento")
void CarregarProgresso();

void AMinhaClasseJogador::CarregarProgresso()
{
    FString SaveSlot = "SaveSlot1";
    int32 UserIndex = 0;
    
    if (UGameplayStatics::DoesSaveGameExist(SaveSlot, UserIndex))
    {
        UMeuSaveGame* LoadedGame = Cast<UMeuSaveGame>(UGameplayStatics::LoadGameFromSlot(SaveSlot, UserIndex));
        PontuacaoAtual = LoadedGame->PontuacaoSalva;
        
        UE_LOG(LogTemp, Warning, TEXT("Carregou pontuação %d para %s"), 
            LoadedGame->PontuacaoSalva, 
            *LoadedGame->NomeJogador);
    }
    else
    {
        UE_LOG(LogTemp, Error, TEXT("Arquivo de salvamento não encontrado!"));
    }
}
```

### Erros comuns e como resolvê-los

1. **Arquivo de salvamento corrompido**:
   ```
   Error: Failed to load save game (file may be corrupt)
   ```
   Solução: Sempre verifique se o arquivo existe antes de tentar carregar, como fizemos com `DoesSaveGameExist`.

2. **Classe de salvamento não registrada**:
   ```
   Warning: Failed to find class 'MeuSaveGame'
   ```
   Solução: Certifique-se de incluir o cabeçalho correto (#include "MeuSaveGame.h") e que a classe está marcada como UCLASS().

3. **Dados não persistem entre sessões**:
   Verifique se você está usando o mesmo SaveSlot e UserIndex para salvar e carregar.

### Salvando estruturas complexas

Para salvar arrays ou estruturas personalizadas, adicione-as à sua classe de salvamento:

```cpp
// Em MeuSaveGame.h
UPROPERTY(VisibleAnywhere, Category = "Dados")
TArray<FVector> PosicoesItensColetados;

UPROPERTY(VisibleAnywhere, Category = "Dados")
TMap<FString, bool> ItensDesbloqueados;
```

A Unreal Engine serializa automaticamente esses tipos de dados complexos.

### Exercício prático

Implemente um sistema que:
1. Salve a posição atual do jogador
2. Salve os itens coletados (usando um TArray de FNames)
3. Carregue esses dados quando o jogo iniciar

Solução comentada:

```cpp
// 1. Adicione estas propriedades ao MeuSaveGame.h
UPROPERTY(VisibleAnywhere, Category = "Dados")
FVector PosicaoJogador;

UPROPERTY(VisibleAnywhere, Category = "Dados")
TArray<FName> ItensColetados;

// 2. Modifique SalvarProgresso()
void AMinhaClasseJogador::SalvarProgresso()
{
    // ... [código anterior]
    SaveGameInstance->PosicaoJogador = GetActorLocation();
    SaveGameInstance->ItensColetados = ItensInventario; // Supondo que você tem esta variável
    // ... [restante do código]
}

// 3. Modifique CarregarProgresso()
void AMinhaClasseJogador::CarregarProgresso()
{
    if (UGameplayStatics::DoesSaveGameExist(SaveSlot, UserIndex))
    {
        // ... [código anterior]
        SetActorLocation(LoadedGame->PosicaoJogador);
        ItensInventario = LoadedGame->ItensColetados;
        // ... [restante do código]
    }
}
```