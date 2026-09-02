## Versionamento de código avançado

O versionamento de código é essencial para o desenvolvimento de projetos complexos, especialmente em equipes. Git é a ferramenta mais utilizada para esse fim, mas quando trabalhamos com Unreal Engine, alguns cuidados específicos são necessários devido à natureza dos arquivos de projeto.

### Configuração inicial do Git para Unreal Engine

Antes de iniciar o versionamento, é crucial configurar corretamente o Git para evitar problemas comuns. O arquivo `.gitignore` deve ser criado na raiz do projeto para excluir automaticamente arquivos desnecessários, como binários e temporários. Um exemplo básico para Unreal Engine seria:

```plaintext
# Ignorar arquivos gerados pela Unreal Engine
Binaries/
Intermediate/
Saved/
DerivedDataCache/
*.sln
*.suo
*.opensdf
*.sdf
*.user
*.log
```

Para criar o `.gitignore`, execute:

```bash
echo "Binaries/" >> .gitignore
echo "Intermediate/" >> .gitignore
echo "Saved/" >> .gitignore
```

### Commits eficientes

Commits devem ser pequenos e focados em uma única mudança. Isso facilita a revisão e a reversão de alterações específicas. Por exemplo, ao adicionar um novo inimigo ao jogo, o commit deve incluir apenas os arquivos relacionados a essa adição:

```bash
git add Source/MyGame/Public/Enemies/NewEnemy.h
git add Source/MyGame/Private/Enemies/NewEnemy.cpp
git commit -m "Adiciona novo inimigo 'NewEnemy'"
```

### Branching e merging

A criação de branches permite o desenvolvimento de funcionalidades sem interferir na linha principal do projeto. Suponha que você esteja trabalhando em um novo sistema de coleta de itens:

```bash
git checkout -b feature/item-collection
```

Após concluir o desenvolvimento, o merge deve ser feito com cuidado para evitar conflitos. Utilize o comando `git merge` com a opção `--no-ff` para manter o histórico claro:

```bash
git checkout main
git merge --no-ff feature/item-collection
```

### Resolução de conflitos

Conflitos acontecem quando duas alterações modificam a mesma parte do código. Suponha que dois desenvolvedores alteraram o método `CollectItem`:

```cpp
// Conflito no arquivo ItemCollector.cpp
<<<<<<< HEAD
void AItemCollector::CollectItem(AItem* Item) {
    Inventory.Add(Item);
=======
void AItemCollector::CollectItem(AItem* Item) {
    CollectedItems.Add(Item);
>>>>>>> feature/item-collection
}
```

Para resolver, escolha a versão correta ou combine as alterações manualmente, removendo os marcadores `<<<<<<<`, `=======`, e `>>>>>>>`.

### Tags e releases

Marcar versões estáveis com tags ajuda a identificar pontos importantes no histórico do projeto. Por exemplo, ao lançar a versão 1.0 do jogo:

```bash
git tag -a v1.0 -m "Versão 1.0 do jogo"
git push origin v1.0
```

### Exercício prático

Crie um novo branch chamado `feature/health-system`. Adicione uma classe `HealthComponent` que gerencia a vida do jogador. Faça o commit e mescle com a branch principal.

**Solução:**

```cpp
// HealthComponent.h
#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "HealthComponent.generated.h"

UCLASS()
class MYGAME_API UHealthComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    UHealthComponent();

    void TakeDamage(float Damage);
    float GetHealth() const;

protected:
    virtual void BeginPlay() override;

private:
    UPROPERTY(EditDefaultsOnly, Category = "Health")
    float MaxHealth;

    float CurrentHealth;
};
```

```cpp
// HealthComponent.cpp
#include "HealthComponent.h"

UHealthComponent::UHealthComponent()
{
    MaxHealth = 100.0f;
    CurrentHealth = MaxHealth;
}

void UHealthComponent::BeginPlay()
{
    Super::BeginPlay();
}

void UHealthComponent::TakeDamage(float Damage)
{
    CurrentHealth = FMath::Clamp(CurrentHealth - Damage, 0.0f, MaxHealth);
}

float UHealthComponent::GetHealth() const
{
    return CurrentHealth;
}
```

Commit e merge:

```bash
git checkout -b feature/health-system
git add Source/MyGame/Public/Components/HealthComponent.h
git add Source/MyGame/Private/Components/HealthComponent.cpp
git commit -m "Adiciona HealthComponent para gerenciamento de vida"
git checkout main
git merge --no-ff feature/health-system
```