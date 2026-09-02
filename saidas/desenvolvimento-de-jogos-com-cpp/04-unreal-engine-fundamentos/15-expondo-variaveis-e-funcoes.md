## Expondo variáveis e funções

Você criou um inimigo em C++ com uma variável `Health` e quer que o designer ajuste esse valor diretamente no Editor da Unreal, sem precisar recompilar o código. Esse é o problema que a exposição de variáveis resolve. Veja como fazer isso na prática:

Crie uma nova classe C++ chamada `Enemy` herdando de `AActor` e adicione este código:

```cpp
// Enemy.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Enemy.generated.h"

UCLASS()
class MYGAME_API AEnemy : public AActor
{
    GENERATED_BODY()
    
public:
    AEnemy();

    UPROPERTY(EditAnywhere, Category = "Enemy Properties")
    float Health;

    UPROPERTY(EditAnywhere, Category = "Enemy Properties", meta = (ClampMin = "0", ClampMax = "100"))
    int32 AttackPower;
};
```

Agora compile o projeto e adicione um `Enemy` à cena. No Details Panel, você verá:

![Enemy properties in Unreal Editor](https://i.imgur.com/J7rQx2m.png)

**Erro comum**: esquecer a macro `UPROPERTY()`. Se fizer isso, a variável não aparecerá no editor:

```cpp
// ERRADO - não aparecerá no editor
float InvisibleHealth;
```

A mensagem de erro que você verá no Output Log será:
`LogBlueprint: Warning: Accessed None trying to read property InvisibleHealth`

Para funções, o processo é similar com `UFUNCTION()`. Crie uma função que o Blueprint possa chamar:

```cpp
// Enemy.h
UFUNCTION(BlueprintCallable, Category = "Enemy Actions")
void TakeDamage(float DamageAmount);

// Enemy.cpp
void AEnemy::TakeDamage(float DamageAmount)
{
    Health -= DamageAmount;
    if(Health <= 0)
    {
        Destroy();
    }
}
```

No Blueprint, você pode chamar essa função assim:

![Chamando função C++ do Blueprint](https://i.imgur.com/L5v3JxY.png)

**Comparação com variáveis locais**: Enquanto variáveis normais em C++ só existem durante a execução, as expostas com `UPROPERTY` mantêm seus valores entre sessões do editor.

Para expor eventos que Blueprints podem implementar, use `BlueprintImplementableEvent`:

```cpp
UFUNCTION(BlueprintImplementableEvent, Category = "Enemy Events")
void OnDeath();
```

No Blueprint, você verá:

![Evento implementável no Blueprint](https://i.imgur.com/Vr5XZzG.png)

**Exercício**: Crie uma classe `PowerUp` com:
1. Uma variável `HealAmount` editável no editor (entre 10 e 50)
2. Uma função `Activate` chamável do Blueprint
3. Um evento `OnActivated` que o Blueprint pode implementar

**Solução comentada**:

```cpp
// PowerUp.h
UCLASS()
class MYGAME_API APowerUp : public AActor
{
    GENERATED_BODY()
    
public:
    UPROPERTY(EditAnywhere, Category = "PowerUp", meta = (ClampMin = "10", ClampMax = "50"))
    int32 HealAmount;

    UFUNCTION(BlueprintCallable, Category = "PowerUp")
    void Activate() {
        OnActivated();
    }

    UFUNCTION(BlueprintImplementableEvent, Category = "PowerUp")
    void OnActivated();
};
```