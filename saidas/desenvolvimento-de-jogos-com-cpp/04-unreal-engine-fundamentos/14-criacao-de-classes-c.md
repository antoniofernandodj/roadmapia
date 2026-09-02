## Criação de classes C++

Um personagem que não se move, uma porta que não abre, um inimigo que não ataca - todos esses problemas começam com a necessidade de criar comportamentos personalizados. Na Unreal Engine, isso se faz através de classes C++ que estendem as funcionalidades básicas dos Actors.

Vamos criar um objeto simples que gira continuamente. No Unreal Editor, clique em "File" > "New C++ Class". Selecione "Actor" como classe pai e nomeie como "RotatingObject". O editor gerará dois arquivos:

```cpp
// RotatingObject.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "RotatingObject.generated.h"

UCLASS()
class YOURPROJECT_API ARotatingObject : public AActor
{
    GENERATED_BODY()
    
public:    
    ARotatingObject();

protected:
    virtual void BeginPlay() override;

public:    
    virtual void Tick(float DeltaTime) override;
};
```

```cpp
// RotatingObject.cpp
#include "RotatingObject.h"

ARotatingObject::ARatingObject()
{
    PrimaryActorTick.bCanEverTick = true;
}

void ARotatingObject::BeginPlay()
{
    Super::BeginPlay();
}

void ARotatingObject::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}
```

Agora adicione um componente de malha estática e a lógica de rotação. Modifique o arquivo de cabeçalho:

```cpp
// RotatingObject.h
// ... [código anterior]
private:
    UPROPERTY(VisibleAnywhere)
    UStaticMeshComponent* MeshComponent;
    
    UPROPERTY(EditAnywhere)
    float RotationSpeed = 45.0f;
```

E implemente no arquivo .cpp:

```cpp
// RotatingObject.cpp
#include "Components/StaticMeshComponent.h"

ARotatingObject::ARotatingObject()
{
    MeshComponent = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("MeshComponent"));
    RootComponent = MeshComponent;
    
    // Configuração do mesh diretamente no código (mais tarde faremos via Editor)
    static ConstructorHelpers::FObjectFinder<UStaticMesh> MeshAsset(TEXT("/Engine/BasicShapes/Cube.Cube"));
    if (MeshAsset.Succeeded())
    {
        MeshComponent->SetStaticMesh(MeshAsset.Object);
    }
}

void ARotatingObject::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    
    // Rotação contínua
    FRotator NewRotation = GetActorRotation();
    NewRotation.Yaw += RotationSpeed * DeltaTime;
    SetActorRotation(NewRotation);
}
```

Erro comum ao compilar:
```
error C2065: 'UStaticMeshComponent': undeclared identifier
```
Isso ocorre quando esquecemos de incluir o cabeçalho correto. A solução é adicionar `#include "Components/StaticMeshComponent.h"` no .cpp.

Para testar seu objeto:
1. Compile o projeto (Ctrl+Alt+F11 no Editor)
2. Arraste sua classe "RotatingObject" do Content Browser para a cena
3. Pressione Play

Você verá um cubo girando no eixo Y. No Editor, você pode modificar a velocidade de rotação diretamente nas propriedades do objeto.

**Exercício:** Crie uma nova classe "PulsingLight" que:
1. Contém um PointLightComponent
2. Pulsa suavemente entre intensidade mínima e máxima
3. Tem propriedades editáveis para velocidade e faixa de intensidade

**Solução:**

```cpp
// PulsingLight.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "PulsingLight.generated.h"

UCLASS()
class YOURPROJECT_API APulsingLight : public AActor
{
    GENERATED_BODY()
    
public:    
    APulsingLight();

protected:
    virtual void BeginPlay() override;

public:    
    virtual void Tick(float DeltaTime) override;

private:
    UPROPERTY(VisibleAnywhere)
    class UPointLightComponent* LightComponent;
    
    UPROPERTY(EditAnywhere)
    float PulseSpeed = 1.0f;
    
    UPROPERTY(EditAnywhere)
    float MinIntensity = 500.0f;
    
    UPROPERTY(EditAnywhere)
    float MaxIntensity = 3000.0f;
    
    float RunningTime = 0.0f;
};
```

```cpp
// PulsingLight.cpp
#include "PulsingLight.h"
#include "Components/PointLightComponent.h"

APulsingLight::APulsingLight()
{
    LightComponent = CreateDefaultSubobject<UPointLightComponent>(TEXT("LightComponent"));
    RootComponent = LightComponent;
    LightComponent->SetIntensity(MaxIntensity);
}

void APulsingLight::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    
    RunningTime += DeltaTime;
    float PulseValue = FMath::Sin(RunningTime * PulseSpeed);
    float NewIntensity = MinIntensity + (MaxIntensity - MinIntensity) * (PulseValue + 1.0f) / 2.0f;
    LightComponent->SetIntensity(NewIntensity);
}
```