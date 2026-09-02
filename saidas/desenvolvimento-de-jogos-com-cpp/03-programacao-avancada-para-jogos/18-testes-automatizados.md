## Testes automatizados

Imagine que você acabou de implementar uma nova habilidade para seu personagem - um dash rápido que consome stamina. Você testa manualmente algumas vezes: parece funcionar. Mas quando seu colega tenta usar durante um pulo, o jogo trava. Eis o problema que testes automatizados resolvem: garantir que cada parte do código funcione corretamente em todas situações, mesmo após futuras alterações.

Na Unreal Engine, usamos o framework de testes integrado. Veja como testar um componente simples de stamina:

```cpp
// No arquivo StaminaComponent.h
#pragma once
#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "StaminaComponent.generated.h"

UCLASS()
class MYGAME_API UStaminaComponent : public UActorComponent
{
    GENERATED_BODY()
public:
    void ConsumeStamina(float Amount);
    void RecoverStamina(float DeltaTime);
    bool CanUseStamina(float Amount) const;
    
private:
    UPROPERTY(EditAnywhere)
    float MaxStamina = 100.f;
    
    float CurrentStamina = MaxStamina;
};
```

A implementação básica:

```cpp
// StaminaComponent.cpp
#include "StaminaComponent.h"

void UStaminaComponent::ConsumeStamina(float Amount)
{
    CurrentStamina = FMath::Max(0.f, CurrentStamina - Amount);
}

void UStaminaComponent::RecoverStamina(float DeltaTime)
{
    CurrentStamina = FMath::Min(MaxStamina, CurrentStamina + DeltaTime * 10.f);
}

bool UStaminaComponent::CanUseStamina(float Amount) const
{
    return CurrentStamina >= Amount;
}
```

Agora, os testes automatizados. Crie uma nova classe no Editor:

```cpp
// No arquivo StaminaComponentTest.h
#pragma once
#include "CoreMinimal.h"
#include "Tests/AutomationTest.h"
#include "StaminaComponent.h"

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FStaminaComponentTest, "Gameplay.Components.Stamina", 
    EAutomationTestFlags::ApplicationContextMask | EAutomationTestFlags::ProductFilter)

bool FStaminaComponentTest::RunTest(const FString& Parameters)
{
    UStaminaComponent* StaminaComp = NewObject<UStaminaComponent>();
    
    // Teste 1: Consumo básico de stamina
    StaminaComp->ConsumeStamina(30.f);
    TestEqual("Stamina após consumo", StaminaComp->GetCurrentStamina(), 70.f);
    
    // Teste 2: Não pode consumir mais que o disponível
    StaminaComp->ConsumeStamina(80.f);
    TestEqual("Stamina não pode ser negativa", StaminaComp->GetCurrentStamina(), 0.f);
    
    // Teste 3: Recuperação com DeltaTime
    StaminaComp->RecoverStamina(1.5f); // 1.5 segundos
    TestEqual("Stamina após recuperação", StaminaComp->GetCurrentStamina(), 15.f);
    
    // Teste 4: Verificação de uso disponível
    TestTrue("Pode usar stamina suficiente", StaminaComp->CanUseStamina(10.f));
    TestFalse("Não pode usar stamina insuficiente", StaminaComp->CanUseStamina(20.f));
    
    return true;
}
```

Para executar os testes, vá no Editor da Unreal:
1. Abra a janela "Session Frontend" (Window → Developer Tools)
2. Vá para a aba "Automation"
3. Selecione os testes desejados e clique em "Start Tests"

A saída mostrará algo como:

```
[Passed] Gameplay.Components.Stamina - Stamina após consumo
[Passed] Gameplay.Components.Stamina - Stamina não pode ser negativa
[Passed] Gameplay.Components.Stamina - Stamina após recuperação
[Passed] Gameplay.Components.Stamina - Pode usar stamina suficiente
[Passed] Gameplay.Components.Stamina - Não pode usar stamina insuficiente
```

Erro comum: esquecer de adicionar `GENERATED_BODY()` na classe de teste. O erro será:

```
error: 'GENERATED_BODY': is not a member of 'FStaminaComponentTest'
```

Para testar componentes que dependem do mundo do jogo, use `FAutomationTestFramework::Get().GetWorld()` para obter um mundo de teste. Exemplo testando colisão:

```cpp
// Teste de colisão simplificado
bool FCollisionTest::RunTest(const FString& Parameters)
{
    UWorld* World = FAutomationTestFramework::Get().GetWorld();
    AActor* Actor1 = World->SpawnActor<AActor>();
    AActor* Actor2 = World->SpawnActor<AActor>();
    
    // Configura colisões...
    TestTrue("Colisão detectada", Actor1->IsOverlappingActor(Actor2));
    
    return true;
}
```

Exercício prático: Implemente testes para uma função que calcula dano crítico baseado em chance. A função deve:
1. Sempre retornar pelo menos o dano normal
2. Nunca exceder 3x o dano base
3. Ter distribuição aproximadamente correta de críticos

Solução comentada:

```cpp
// Implementação da função
float CalculateCriticalDamage(float BaseDamage, float CriticalChance)
{
    float RandomValue = FMath::FRand();
    if(RandomValue < CriticalChance)
    {
        float Multiplier = 1.5f + FMath::FRand() * 1.5f; // 1.5x a 3x
        return BaseDamage * Multiplier;
    }
    return BaseDamage;
}

// Teste
bool FDamageTest::RunTest(const FString& Parameters)
{
    // Teste 1: Dano mínimo
    float Damage = CalculateCriticalDamage(10.f, 0.5f);
    TestTrue("Dano nunca menor que base", Damage >= 10.f);
    
    // Teste 2: Limite máximo
    for(int i = 0; i < 100; ++i)
    {
        Damage = CalculateCriticalDamage(10.f, 1.0f);
        TestTrue("Dano nunca maior que 3x base", Damage <= 30.f);
    }
    
    // Teste 3: Distribuição (aproximada)
    int CriticalHits = 0;
    for(int i = 0; i < 1000; ++i)
    {
        if(CalculateCriticalDamage(10.f, 0.3f) > 10.f)
            CriticalHits++;
    }
    TestTrue("Distribuição dentro de margem razoável", 
        CriticalHits > 250 && CriticalHits < 350);
    
    return true;
}
```