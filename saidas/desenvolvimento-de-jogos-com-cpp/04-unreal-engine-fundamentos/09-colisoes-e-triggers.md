## Colisões e triggers

Em jogos, colisões são fundamentais para definir como objetos interagem uns com os outros. Imagine um jogo de plataforma onde o personagem precisa pular sobre inimigos ou coletar itens. Sem colisões, o personagem simplesmente passaria através de tudo, tornando o jogo impossível de jogar. Na Unreal Engine, colisões são gerenciadas através de **Collision Components** e **Collision Presets**, que definem como os objetos devem reagir quando entram em contato.

### Configurando colisões

Para começar, vamos criar um cenário simples: um personagem que precisa coletar moedas. Primeiro, adicione um `Static Mesh` para representar o personagem e outro para a moeda. No `Details Panel`, selecione o componente `Static Mesh` do personagem e role até a seção `Collision`. Aqui, você pode escolher entre vários **Collision Presets**, como `BlockAll`, `OverlapAll`, ou `Custom`.

```cpp
// Exemplo de código para configurar colisão em C++
UPROPERTY(VisibleAnywhere, Category = "Components")
UStaticMeshComponent* MeshComp;

MeshComp = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("MeshComp"));
MeshComp->SetCollisionProfileName(TEXT("BlockAll"));
```

Selecione `BlockAll` para o personagem e `OverlapAll` para a moeda. Isso faz com que o personagem bloqueie outros objetos (como paredes) e sobreponha a moeda quando entrar em contato.

### Detectando colisões com triggers

Para detectar quando o personagem coleta a moeda, usamos **triggers**. Um trigger é um tipo especial de colisão que não bloqueia fisicamente o objeto, mas dispara um evento quando ocorre uma sobreposição.

No `Details Panel` da moeda, role até a seção `Collision` e marque a opção `Generate Overlap Events`. Isso habilita a detecção de eventos de sobreposição.

Agora, vamos adicionar um evento no Blueprint para detectar quando o personagem coleta a moeda.

1. Abra o Blueprint da moeda e vá para o `Event Graph`.
2. Adicione um nó `Event ActorBeginOverlap`.
3. Conecte este nó a um `DestroyActor` para remover a moeda da cena quando o personagem a coletar.

```cpp
// Exemplo de código para detectar colisão em C++
void ACoin::OnOverlap(AActor* OtherActor)
{
    if (OtherActor->IsA(APlayerCharacter::StaticClass()))
    {
        Destroy();
    }
}

// No construtor da classe Coin
OnActorBeginOverlap.AddDynamic(this, &ACoin::OnOverlap);
```

### Erros comuns e como corrigi-los

Um erro comum é esquecer de habilitar `Generate Overlap Events` no componente de colisão. Se isso acontecer, o evento `OnOverlap` não será disparado, e o jogo não funcionará como esperado.

Outro erro é não configurar corretamente os **Collision Presets**. Se você definir `BlockAll` para a moeda, o personagem não conseguirá coletá-la, pois será bloqueado pela colisão. Sempre verifique se os presets estão configurados conforme o comportamento desejado.

### Exercício prático

Crie um cenário com um personagem e três tipos de objetos: um que bloqueie o personagem (como uma parede), um que seja coletável (como uma moeda), e um que cause dano ao personagem (como uma armadilha). Configure as colisões e triggers para cada objeto e teste o comportamento no jogo.

**Solução comentada:**

1. **Parede**: Configure o `Collision Preset` como `BlockAll`. Isso impede que o personagem passe através dela.
2. **Moeda**: Configure o `Collision Preset` como `OverlapAll` e habilite `Generate Overlap Events`. No Blueprint, adicione um evento `ActorBeginOverlap` que destrói a moeda quando o personagem a coleta.
3. **Armadilha**: Configure o `Collision Preset` como `OverlapAll` e habilite `Generate Overlap Events`. No Blueprint, adicione um evento `ActorBeginOverlap` que reduz a vida do personagem quando ele entra em contato com a armadilha.

```cpp
// Exemplo de código para armadilha em C++
void ATrap::OnOverlap(AActor* OtherActor)
{
    if (OtherActor->IsA(APlayerCharacter::StaticClass()))
    {
        APlayerCharacter* Player = Cast<APlayerCharacter>(OtherActor);
        Player->TakeDamage(DamageAmount);
    }
}

// No construtor da classe Trap
OnActorBeginOverlap.AddDynamic(this, &ATrap::OnOverlap);
```