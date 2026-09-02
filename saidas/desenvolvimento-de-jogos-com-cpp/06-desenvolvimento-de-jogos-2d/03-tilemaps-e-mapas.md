## Tilemaps e mapas

Em jogos 2D, criar ambientes complexos manualmente, tijolo por tijolo, é inviável. Imagine construir um castelo com centenas de blocos idênticos - é aí que tilemaps entram em cena. Eles são grades onde cada célula contém uma referência a um tile (bloco gráfico padrão), permitindo montar mapas grandes com poucos assets.

Vamos implementar um tilemap básico na Unreal Engine. Primeiro, crie uma nova classe `ATilemap` herdando de `AActor`:

```cpp
// Tilemap.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Tilemap.generated.h"

UCLASS()
class MEUJOGO_API ATilemap : public AActor
{
    GENERATED_BODY()
    
public:    
    ATilemap();

    UPROPERTY(EditAnywhere, Category = "Tilemap")
    int32 Width = 10;
    
    UPROPERTY(EditAnywhere, Category = "Tilemap")
    int32 Height = 10;
    
    UPROPERTY(EditAnywhere, Category = "Tilemap")
    float TileSize = 64.f;

protected:
    virtual void BeginPlay() override;

private:
    TArray<UPaperSpriteComponent*> Tiles;
    
    void GenerateTilemap();
};
```

A implementação inicial:

```cpp
// Tilemap.cpp
#include "Tilemap.h"
#include "PaperSpriteComponent.h"
#include "PaperSprite.h"

ATilemap::ATilemap()
{
    PrimaryActorTick.bCanEverTick = false;
}

void ATilemap::BeginPlay()
{
    Super::BeginPlay();
    GenerateTilemap();
}

void ATilemap::GenerateTilemap()
{
    // Limpe tiles existentes
    for (auto Tile : Tiles)
    {
        if (Tile) Tile->DestroyComponent();
    }
    Tiles.Empty();

    // Carregue um sprite padrão (crie um asset 'T_DefaultTile' primeiro)
    ConstructorHelpers::FObjectFinder<UPaperSprite> DefaultTileRef(
        TEXT("/Game/Sprites/T_DefaultTile"));
    if (!DefaultTileRef.Succeeded()) return;

    // Crie a grade de tiles
    for (int32 Y = 0; Y < Height; ++Y)
    {
        for (int32 X = 0; X < Width; ++X)
        {
            UPaperSpriteComponent* NewTile = 
                NewObject<UPaperSpriteComponent>(this);
            NewTile->SetSprite(DefaultTileRef.Object);
            NewTile->SetupAttachment(RootComponent);
            NewTile->SetRelativeLocation(FVector(
                X * TileSize, 
                0.f, 
                Y * TileSize));
            NewTile->RegisterComponent();
            
            Tiles.Add(NewTile);
        }
    }
}
```

Erro comum: esquecer de chamar `RegisterComponent()`. Se fizer isso, o tile não aparecerá e você verá o erro:

```
LogActor: Warning: Component [NewTileComponent] has not been registered.  
Components must be registered before they can be used.
```

Para testar, arraste seu `ATilemap` para a cena e ajuste as propriedades no editor. Você verá uma grade 10x10 de sprites idênticos. 

Agora vamos tornar isso útil adicionando diferentes tipos de tiles:

```cpp
// Adicione ao Tilemap.h
UPROPERTY(EditAnywhere, Category = "Tilemap")
TArray<UPaperSprite*> TileTypes;

UPROPERTY(EditInstanceOnly, Category = "Tilemap")
TArray<int32> TileData;
```

Modifique `GenerateTilemap()` para usar os tipos:

```cpp
// Dentro do loop de criação de tiles
if (TileData.IsValidIndex(Y * Width + X) && 
    TileTypes.IsValidIndex(TileData[Y * Width + X]))
{
    NewTile->SetSprite(TileTypes[TileData[Y * Width + X]]);
}
else
{
    NewTile->SetSprite(DefaultTileRef.Object);
}
```

No editor, você pode agora:
1. Adicionar sprites ao array `TileTypes`
2. Preencher `TileData` com índices correspondentes
3. Ver o mapa atualizado automaticamente

Para um exemplo concreto, crie três sprites (grama, terra, água) e defina:

```cpp
TileTypes = [GramaSprite, TerraSprite, AguaSprite]
TileData = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 1, 0, 0, 1, 1, 1, 0,
    0, 1, 2, 1, 0, 0, 1, 2, 1, 0,
    // ... continue o padrão
]
```

**Exercício:** Implemente um método `GetTileAtPosition(FVector WorldPosition)` que retorna o tipo do tile em coordenadas do mundo. Considere que (0,0,0) é o canto inferior esquerdo do tilemap.

Solução:

```cpp
int32 ATilemap::GetTileAtPosition(FVector WorldPosition)
{
    FVector LocalPos = GetActorTransform().InverseTransformPosition(WorldPosition);
    
    int32 X = FMath::FloorToInt(LocalPos.X / TileSize);
    int32 Y = FMath::FloorToInt(LocalPos.Z / TileSize); // Z porque trabalhamos no plano XZ
    
    if (X >= 0 && X < Width && Y >= 0 && Y < Height && 
        TileData.IsValidIndex(Y * Width + X))
    {
        return TileData[Y * Width + X];
    }
    return -1; // Posição inválida
}
```

Este método é útil para mecânicas como:
- Verificar se o jogador está na água
- Implementar tiles com propriedades especiais
- Criar sistemas de construção/edição de mapas