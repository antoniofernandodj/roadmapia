## Exceções e tratamento de erros

Imagine um jogador tentando carregar um save game corrompido ou um inimigo tentando acessar um item que não existe no inventário. Sem tratamento de erros, seu jogo simplesmente crasharia - uma experiência frustrante para o jogador. Em C++, usamos exceções para lidar com esses cenários de forma elegante.

### O problema do código frágil

Considere esta função que calcula dano em um combate:

```cpp
float CalculateDamage(float baseDamage, float defenseMultiplier) {
    return baseDamage / defenseMultiplier;
}
```

Se `defenseMultiplier` for zero, temos uma divisão por zero. Sem tratamento, o programa termina abruptamente:

```
Fatal error: Division by zero
```

### Implementando try-catch

O mecanismo básico envolve três partes:
1. `try`: bloco onde código potencialmente perigoso é executado
2. `catch`: captura e trata a exceção
3. `throw`: lança a exceção quando algo dá errado

Vamos proteger nossa função de dano:

```cpp
float CalculateDamage(float baseDamage, float defenseMultiplier) {
    if (defenseMultiplier == 0.0f) {
        throw std::invalid_argument("Defense multiplier cannot be zero");
    }
    return baseDamage / defenseMultiplier;
}

void ApplyDamage(AActor* Target, float DamageAmount) {
    try {
        float defense = Target->GetDefenseMultiplier();
        float finalDamage = CalculateDamage(DamageAmount, defense);
        Target->TakeDamage(finalDamage);
    } 
    catch (const std::invalid_argument& e) {
        UE_LOG(LogTemp, Error, TEXT("Damage calculation failed: %s"), *FString(e.what()));
        Target->TakeDamage(DamageAmount); // Fallback: apply base damage
    }
}
```

Se ocorrer um erro, o log mostrará:
```
Error: Damage calculation failed: Defense multiplier cannot be zero
```

### Exceções padrão da Unreal Engine

A Unreal Engine estende o tratamento de exceções com macros específicas:

```cpp
void LoadGameLevel(const FString& LevelName) {
    CHECK_LEVEL_EXISTS(LevelName); // Macro que pode lançar FLevelNotFoundException
    
    try {
        UGameplayStatics::OpenLevel(GetWorld(), *LevelName);
    }
    catch (const FLevelNotFoundException& e) {
        UE_LOG(LogLoad, Warning, TEXT("Failed to load level: %s"), *e.GetMessage());
        UGameplayStatics::OpenLevel(GetWorld(), TEXT("MainMenu"));
    }
}
```

As principais exceções da UE incluem:
- `FAssetNotFoundException`: Quando um asset não é encontrado
- `FInvalidOperationException`: Para operações inválidas no contexto atual
- `FNetworkException`: Problemas de rede em multiplayer

### Boas práticas na UE

1. **Não abuse de exceções**: Use apenas para erros excepcionais, não para fluxo normal do jogo
2. **Capture por referência**: `catch (const ExceptionType& e)` é mais eficiente
3. **Log detalhado**: Inclua contexto útil nas mensagens de erro
4. **Recuperação graciosa**: Sempre forneça um fallback

Exemplo completo de tratamento ao carregar texturas:

```cpp
UTexture2D* LoadGameTexture(const FString& TexturePath) {
    if (!FPaths::FileExists(TexturePath)) {
        throw FFileNotFoundException(FString::Printf(TEXT("Texture file not found: %s"), *TexturePath));
    }

    try {
        return Cast<UTexture2D>(StaticLoadObject(UTexture2D::StaticClass(), nullptr, *TexturePath));
    }
    catch (const FFileNotFoundException& e) {
        UE_LOG(LogTexture, Error, TEXT("%s"), *e.GetMessage());
        return LoadDefaultTexture();
    }
    catch (const std::exception& e) {
        UE_LOG(LogTexture, Error, TEXT("Unknown error loading texture: %s"), *FString(e.what()));
        return nullptr;
    }
}
```

### Erro comum: esquecer de lançar

Um erro frequente é detectar o problema mas não lançar a exceção:

```cpp
// ERRADO - apenas loga o erro mas continua a execução
if (Enemy == nullptr) {
    UE_LOG(LogTemp, Error, TEXT("Enemy is null!"));
    return; // Isso mascara o problema
}

// CORRETO
if (Enemy == nullptr) {
    throw FNullPointerException(TEXT("Enemy pointer is null"));
}
```

### Exercício: Sistema de inventário resiliente

Implemente uma função `AddItemToInventory` que:
1. Verifica se o item é válido (não nulo)
2. Verifica se há espaço no inventário
3. Lança exceções específicas para cada caso
4. Fornece fallbacks adequados

Solução comentada:

```cpp
void APlayerCharacter::AddItemToInventory(UItem* NewItem) {
    if (!NewItem) {
        throw FNullPointerException(TEXT("Item pointer is null"));
    }

    try {
        if (Inventory.Num() >= MaxInventorySlots) {
            throw FInventoryFullException(GetName());
        }
        
        Inventory.Add(NewItem);
        OnInventoryUpdated.Broadcast();
    }
    catch (const FInventoryFullException& e) {
        UE_LOG(LogInventory, Warning, TEXT("%s"), *e.GetMessage());
        TryAutoSortInventory(); // Fallback: tenta rearranjar
        if (Inventory.Num() < MaxInventorySlots) {
            AddItemToInventory(NewItem); // Tenta novamente
        } else {
            DropItem(NewItem); // Último recurso: deixa cair no chão
        }
    }
    catch (const std::exception& e) {
        UE_LOG(LogInventory, Error, TEXT("Unexpected error: %s"), *FString(e.what()));
        DropItem(NewItem); // Garante que o item não seja perdido
    }
}
```