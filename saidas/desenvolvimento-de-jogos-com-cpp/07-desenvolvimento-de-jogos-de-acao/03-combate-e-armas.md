## Combate e armas

Em um jogo de ação, o combate é o núcleo da experiência do jogador. Para criar um sistema de combate envolvente, precisamos implementar armas, dano e feedback visual. Vamos começar com o básico: criar uma arma que o jogador possa equipar e usar.

### Criando a arma

Primeiro, vamos definir uma classe `AWeapon` que representará uma arma no jogo. Essa classe terá propriedades como dano, taxa de tiro e alcance. Vamos também adicionar um método `Fire` que será chamado quando o jogador pressionar o botão de atirar.

```cpp
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Weapon.generated.h"

UCLASS()
class ACTIONGAME_API AWeapon : public AActor
{
    GENERATED_BODY()
    
public:    
    AWeapon();

protected:
    virtual void BeginPlay() override;

public:    
    virtual void Tick(float DeltaTime) override;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Weapon")
    float Damage;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Weapon")
    float FireRate;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Weapon")
    float Range;

    void Fire();
};
```

### Implementando o método Fire

O método `Fire` será responsável por instanciar um projétil e dispará-lo na direção em que o jogador está mirando. Primeiro, precisamos criar uma classe `AProjectile` que representará o projétil.

```cpp
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Projectile.generated.h"

UCLASS()
class ACTIONGAME_API AProjectile : public AActor
{
    GENERATED_BODY()
    
public:    
    AProjectile();

protected:
    virtual void BeginPlay() override;

public:    
    virtual void Tick(float DeltaTime) override;

    UPROPERTY(VisibleAnywhere, Category = "Components")
    class UProjectileMovementComponent* ProjectileMovement;

    void LaunchProjectile(float Speed);
};
```

Agora, vamos implementar o método `Fire` na classe `AWeapon`. Esse método criará um projétil e o lançará na direção em que o jogador está mirando.

```cpp
#include "Weapon.h"
#include "Projectile.h"
#include "GameFramework/PlayerController.h"

void AWeapon::Fire()
{
    if (!GetOwner()) return;

    APlayerController* PlayerController = Cast<APlayerController>(GetOwner()->GetInstigatorController());
    if (!PlayerController) return;

    FVector SpawnLocation = GetOwner()->GetActorLocation();
    FRotator SpawnRotation = PlayerController->PlayerCameraManager->GetCameraRotation();

    FActorSpawnParameters SpawnParams;
    SpawnParams.Owner = GetOwner();
    SpawnParams.Instigator = GetOwner()->GetInstigator();

    AProjectile* Projectile = GetWorld()->SpawnActor<AProjectile>(SpawnLocation, SpawnRotation, SpawnParams);
    if (Projectile)
    {
        Projectile->LaunchProjectile(1000.0f);
    }
}
```

### Integrando a arma ao personagem

Agora que temos uma arma funcional, precisamos integrá-la ao nosso personagem. Vamos modificar a classe `ACharacter` para permitir que o jogador equipe e use a arma.

```cpp
#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "Weapon.h"
#include "ActionCharacter.generated.h"

UCLASS()
class ACTIONGAME_API AActionCharacter : public ACharacter
{
    GENERATED_BODY()
    
public:    
    AActionCharacter();

protected:
    virtual void BeginPlay() override;

public:    
    virtual void Tick(float DeltaTime) override;

    virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

    void EquipWeapon(AWeapon* Weapon);

    void FireWeapon();

private:
    AWeapon* EquippedWeapon;
};
```

Na implementação da classe `AActionCharacter`, vamos adicionar o método `EquipWeapon` para permitir que o jogador equipe uma arma e o método `FireWeapon` para disparar a arma equipada.

```cpp
#include "ActionCharacter.h"
#include "Weapon.h"

void AActionCharacter::EquipWeapon(AWeapon* Weapon)
{
    if (Weapon)
    {
        EquippedWeapon = Weapon;
        Weapon->AttachToComponent(GetMesh(), FAttachmentTransformRules::SnapToTargetNotIncludingScale, "WeaponSocket");
    }
}

void AActionCharacter::FireWeapon()
{
    if (EquippedWeapon)
    {
        EquippedWeapon->Fire();
    }
}
```

### Mapeando o controle de disparo

Finalmente, vamos mapear o controle de disparo para que o jogador possa atirar pressionando um botão. Vamos usar o `InputComponent` para mapear o botão de disparo ao método `FireWeapon`.

```cpp
void AActionCharacter::SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAction("Fire", IE_Pressed, this, &AActionCharacter::FireWeapon);
}
```

### Testando o sistema de combate

Agora que tudo está configurado, podemos testar nosso sistema de combate. Quando o jogador pressionar o botão de disparo, a arma equipada será disparada, e um projétil será lançado na direção em que o jogador está mirando.

```cpp
// No GameMode ou em outro lugar apropriado
AActionCharacter* PlayerCharacter = Cast<AActionCharacter>(GetWorld()->GetFirstPlayerController()->GetPawn());
if (PlayerCharacter)
{
    AWeapon* Weapon = GetWorld()->SpawnActor<AWeapon>(WeaponClass);
    PlayerCharacter->EquipWeapon(Weapon);
}
```

### Erros comuns e como corrigi-los

Um erro comum ao implementar sistemas de combate é esquecer de configurar corretamente o `ProjectileMovementComponent` no projétil. Se você esquecer de configurar esse componente, o projétil não se moverá. Aqui está como configurá-lo corretamente:

```cpp
AProjectile::AProjectile()
{
    PrimaryActorTick.bCanEverTick = true;

    ProjectileMovement = CreateDefaultSubobject<UProjectileMovementComponent>(TEXT("ProjectileMovement"));
    ProjectileMovement->InitialSpeed = 1000.0f;
    ProjectileMovement->MaxSpeed = 1000.0f;
    ProjectileMovement->bRotationFollowsVelocity = true;
    ProjectileMovement->bShouldBounce = false;
}
```

Outro erro comum é esquecer de configurar o `WeaponSocket` no esqueleto do personagem. Se você não configurar esse socket, a arma não será posicionada corretamente no personagem. Certifique-se de que o socket `WeaponSocket` esteja configurado no esqueleto do personagem.

### Exercício

Modifique o sistema de combate para permitir que o jogador tenha duas armas equipadas e possa alternar entre elas pressionando uma tecla. Adicione também um sistema de recarga para cada arma, onde o jogador precisa pressionar uma tecla para recarregar após um certo número de tiros.

**Solução:**

```cpp
void AActionCharacter::SwitchWeapon()
{
    if (EquippedWeapon == Weapon1)
    {
        EquipWeapon(Weapon2);
    }
    else
    {
        EquipWeapon(Weapon1);
    }
}

void AActionCharacter::ReloadWeapon()
{
    if (EquippedWeapon)
    {
        EquippedWeapon->Reload();
    }
}
```

E no `SetupPlayerInputComponent`:

```cpp
PlayerInputComponent->BindAction("SwitchWeapon", IE_Pressed, this, &AActionCharacter::SwitchWeapon);
PlayerInputComponent->BindAction("Reload", IE_Pressed, this, &AActionCharacter::ReloadWeapon);
```