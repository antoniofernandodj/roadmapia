## Projeto prático: jogo completo

Vamos criar um jogo de plataforma 2D completo chamado "Pixel Adventurer", onde o jogador controla um cavaleiro que deve coletar relíquias antigas enquanto evade armadilhas e derrota inimigos. Comece criando um novo projeto na Unreal Engine selecionando o template "2D Side Scroller" e nomeando-o como "PixelAdventurer".

**Primeiro, configure o personagem principal:**
```cpp
// PixelAdventurerCharacter.h
#pragma once

#include "CoreMinimal.h"
#include "PaperZDCharacter.h"
#include "PixelAdventurerCharacter.generated.h"

UCLASS()
class PIXELADVENTURER_API APixelAdventurerCharacter : public APaperZDCharacter
{
    GENERATED_BODY()

public:
    APixelAdventurerCharacter();

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
    float Health = 100.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
    int32 CollectedRelics = 0;

    void TakeDamage(float DamageAmount);
    void CollectRelic();
};
```

```cpp
// PixelAdventurerCharacter.cpp
#include "PixelAdventurerCharacter.h"

APixelAdventurerCharacter::APixelAdventurerCharacter()
{
    // Configuração do Sprite
    GetSprite()->SetSpriteColor(FLinearColor::White);
}

void APixelAdventurerCharacter::TakeDamage(float DamageAmount)
{
    Health -= DamageAmount;
    if(Health <= 0)
    {
        // Lógica de morte do jogador
    }
}

void APixelAdventurerCharacter::CollectRelic()
{
    CollectedRelics++;
    // Efeito sonoro e visual de coleta
}
```

**Erro comum:** Se você esquecer de adicionar `#include "PaperZDCharacter.h"`, receberá o erro:
`error C2504: 'APaperZDCharacter': base class undefined`

**Sistema de inimigos básico:**
```cpp
// Enemy.h
UCLASS()
class PIXELADVENTURER_API AEnemy : public APaperZDCharacter
{
    GENERATED_BODY()

public:
    AEnemy();

    UPROPERTY(EditAnywhere, Category = "AI")
    float PatrolRadius = 500.0f;

    UFUNCTION(BlueprintCallable)
    void AttackPlayer();
};
```

**Implementando a física de plataforma:**
No Unreal Editor, vá para o Blueprint do seu personagem e configure o `CharacterMovementComponent`:
- Defina `Gravity Scale` para 2.5 (padrão para jogos 2D)
- Ajuste `Jump Z Velocity` para 800
- Marque `Use Flat Base for Floor Checks`

**Sistema de HUD:**
```cpp
// HUDWidget.h
UCLASS()
class PIXELADVENTURER_API UHUDWidget : public UUserWidget
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintCallable)
    void UpdateHealth(float NewHealth);

    UFUNCTION(BlueprintCallable)
    void UpdateRelics(int32 NewCount);
};
```

**Testando o jogo:**
Execute o projeto e você deverá ver:
1. Personagem que responde a inputs WASD e espaço para pular
2. Inimigos patrulhando a área
3. Sistema de saúde funcional
4. Contador de relíquias no canto da tela

**Exercício prático:**
Implemente um sistema de armas onde:
1. O jogador pode alternar entre espada (ataque corpo-a-corpo) e arco (ataque à distância)
2. Cada arma tem seu próprio dano e cooldown
3. Mostre o ícone da arma atual no HUD

**Solução:**
```cpp
// Weapon.h
UENUM(BlueprintType)
enum class EWeaponType : uint8
{
    Sword,
    Bow
};

UCLASS()
class PIXELADVENTURER_API AWeapon : public AActor
{
    GENERATED_BODY()
    
public:
    UPROPERTY(EditDefaultsOnly)
    EWeaponType WeaponType;
    
    UPROPERTY(EditDefaultsOnly)
    float Damage = 10.0f;
    
    UPROPERTY(EditDefaultsOnly)
    float Cooldown = 0.5f;
    
    void Attack();
};
```

**Próximos passos:**
1. Adicione mais níveis usando `PaperTileMap`
2. Implemente um sistema de save/load
3. Crie diferentes tipos de inimigos com comportamentos únicos
4. Adicione efeitos sonoros e partículas