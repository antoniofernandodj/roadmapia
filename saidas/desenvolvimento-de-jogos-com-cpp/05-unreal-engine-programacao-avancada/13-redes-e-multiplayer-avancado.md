## Redes e multiplayer avançado

Quando um jogador atira em outro em um jogo multiplayer, como essa ação chega a todos os clientes? A Unreal Engine usa um sistema de replicação que sincroniza o estado do jogo entre servidor e clientes automaticamente. Vamos implementar um sistema de tiro multiplayer funcional.

Primeiro, criamos uma classe `Projectile` que será replicada:

```cpp
UCLASS()
class MYGAME_API AProjectile : public AActor
{
    GENERATED_BODY()
    
public:
    AProjectile();
    
    UPROPERTY(Replicated, VisibleAnywhere)
    UStaticMeshComponent* Mesh;
    
    UPROPERTY(ReplicatedUsing=OnRep_Exploded, BlueprintReadOnly)
    bool bExploded = false;
    
    UFUNCTION()
    void OnRep_Exploded();
    
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override;
    
    UFUNCTION(Server, Reliable, WithValidation)
    void Server_Explode();
};
```

A implementação mostra os principais conceitos de replicação:

```cpp
void AProjectile::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const
{
    Super::GetLifetimeReplicatedProps(OutLifetimeProps);
    
    DOREPLIFETIME(AProjectile, Mesh);
    DOREPLIFETIME(AProjectile, bExploded);
}

void AProjectile::OnRep_Exploded()
{
    if(bExploded)
    {
        // Efeitos visuais locais
        SpawnExplosionEffects();
    }
}

bool AProjectile::Server_Explode_Validate()
{
    return true; // Validação simples
}

void AProjectile::Server_Explode_Implementation()
{
    bExploded = true;
    OnRep_Exploded(); // Chama no servidor também
    
    // Replica a explosão para todos os clientes
    NetMulticast_Explode();
}

UFUNCTION(NetMulticast, Reliable)
void NetMulticast_Explode();
```

O sistema de armas precisa lidar com predição de clientes:

```cpp
void AShooterCharacter::FireWeapon()
{
    if(!HasAuthority()) // Se for cliente
    {
        Server_FireWeapon(GetActorRotation()); // Envia para servidor
        PlayLocalFireEffects(); // Predição local
    }
    else // Servidor
    {
        SpawnProjectile(GetActorRotation());
    }
}

UFUNCTION(Server, Reliable, WithValidation)
void Server_FireWeapon(FRotator Rotation);
```

Um erro comum é esquecer de chamar `SetReplicates(true)` no construtor do ator:

```cpp
AProjectile::AProjectile()
{
    SetReplicates(true); // Fundamental!
    Mesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Mesh"));
    Mesh->SetIsReplicated(true);
}
```

Se você esquecer isso, verá o erro:
```
LogNet: Warning: UActorChannel::ProcessBunch: Actor not replicatable: /Game/Projectile.Projectile_C_0
```

Para sincronizar variáveis de jogador, como vida e pontuação:

```cpp
UCLASS()
class MYGAME_API APlayerState : public APlayerState
{
    GENERATED_BODY()
    
    UPROPERTY(Replicated)
    int32 Health;
    
    UPROPERTY(ReplicatedUsing=OnRep_Score)
    int32 Score;
    
    UFUNCTION()
    void OnRep_Score();
};
```

A Unreal usa três tipos principais de RPCs:
1. **Server** - Cliente → Servidor
2. **Client** - Servidor → Cliente específico
3. **NetMulticast** - Servidor → Todos os clientes

Exercício: Implemente um sistema de chat multiplayer onde:
1. O cliente envia mensagem ao servidor
2. O servidor valida (tamanho máximo 100 chars)
3. O servidor replica para todos os clientes

Solução:

```cpp
// No PlayerController
UFUNCTION(Server, Reliable, WithValidation)
void Server_SendChatMessage(const FString& Message);

// No GameMode
UFUNCTION(NetMulticast, Reliable)
void Multicast_ReceiveChatMessage(APlayerController* Sender, const FString& Message);

bool AMyPlayerController::Server_SendChatMessage_Validate(const FString& Message)
{
    return Message.Len() <= 100;
}

void AMyPlayerController::Server_SendChatMessage_Implementation(const FString& Message)
{
    if(AGameModeBase* GM = GetWorld()->GetAuthGameMode())
    {
        Cast<AMyGameMode>(GM)->Multicast_ReceiveChatMessage(this, Message);
    }
}
```