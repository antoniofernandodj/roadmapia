## Encapsulamento e modificadores de acesso

Imagine que você está programando o sistema de vida do seu personagem. Se qualquer parte do código puder alterar diretamente a variável `Vidas` do jogador, um bug poderia fazer com que:

1. O inimigo diminuísse a vida duas vezes ao atacar
2. Um power-up aumentasse a vida além do limite máximo
3. A interface gráfica alterasse o valor sem atualizar a barra de vida na tela

```cpp
// ERRO COMUM: Acesso direto à variável sem controle
AJogador* Jogador = GetJogador();
Jogador->Vidas = -3; // Vida negativa? Isso não deveria ser possível!
```

A Unreal Engine exibirá o jogo normalmente, mas o comportamento será imprevisível. A solução é o **encapsulamento**: proteger os dados internos do objeto, permitindo acesso apenas através de métodos controlados.

### Implementação básica na Unreal Engine

Na classe `AJogador`, declare as variáveis como `private` e crie métodos públicos para acesso seguro:

```cpp
UCLASS()
class MEUJOGO_API AJogador : public AActor
{
    GENERATED_BODY()
    
private:
    // Variável privada - só pode ser acessada por métodos da classe
    UPROPERTY(EditAnywhere, Category = "Vida")
    int32 VidasAtuais;
    
    UPROPERTY(EditDefaultsOnly, Category = "Vida")
    int32 VidasMaximas;

public:
    // Métodos públicos para acesso controlado
    UFUNCTION(BlueprintCallable, Category = "Vida")
    void ReceberDano(int32 Dano);
    
    UFUNCTION(BlueprintPure, Category = "Vida")
    int32 GetVidas() const { return VidasAtuais; }
    
    UFUNCTION(BlueprintCallable, Category = "Vida")
    void Curar(int32 Quantidade);
};
```

A implementação dos métodos garante as regras de negócio:

```cpp
void AJogador::ReceberDano(int32 Dano)
{
    if(Dano <= 0) return; // Ignora danos inválidos
    
    VidasAtuais = FMath::Clamp(VidasAtuais - Dano, 0, VidasMaximas);
    
    if(VidasAtuais <= 0)
    {
        // Lógica de morte do jogador
        UE_LOG(LogTemp, Warning, TEXT("Jogador morreu!"));
    }
}

void AJogador::Curar(int32 Quantidade)
{
    if(Quantidade <= 0) return;
    
    VidasAtuais = FMath::Min(VidasAtuais + Quantidade, VidasMaximas);
}
```

### Modificadores de acesso na prática

1. **private**: Só a própria classe acessa
   ```cpp
   class AInimigo {
   private:
       float DanoBase; // Só métodos de AInimigo podem alterar
   };
   ```

2. **protected**: A classe e suas filhas acessam
   ```cpp
   class AInimigoBase {
   protected:
       float Velocidade; // Acessível por AInimigoBase e classes derivadas
   };
   ```

3. **public**: Qualquer código pode acessar
   ```cpp
   class APowerUp {
   public:
       void Ativar(); // Chamável por qualquer classe
   };
   ```

### Erro comum e correção

Ao tentar acessar uma variável privada de outra classe:

```cpp
// TENTATIVA INCORRETA
AInimigo* Inimigo = GetInimigo();
float Dano = Inimigo->DanoBase; // Erro de compilação: 'DanoBase' is private
```

A mensagem de erro será:
```
error C2248: 'AInimigo::DanoBase': cannot access private member declared in class 'AInimigo'
```

Solução correta - criar um método de acesso público:

```cpp
// Na classe AInimigo:
public:
    float GetDanoBase() const { return DanoBase; }

// Uso correto:
float Dano = Inimigo->GetDanoBase(); // Funciona!
```

### Exercício: Sistema de Mana

Implemente um sistema de mana para seu personagem seguindo estas regras:
1. Máximo de 100 mana
2. Gasta 20 mana por habilidade
3. Recupera 10 mana por segundo
4. Não pode ficar negativo

Solução comentada:

```cpp
// Declaração na classe
private:
    UPROPERTY(EditDefaultsOnly)
    float ManaAtual;
    
    UPROPERTY(EditDefaultsOnly)
    float ManaMaxima = 100.0f;

public:
    UFUNCTION(BlueprintCallable)
    bool UsarHabilidade(); // Retorna true se conseguiu usar
    
    UFUNCTION(BlueprintCallable)
    void RecarregarMana(float DeltaTime); // Chamar no Tick

// Implementação
bool AJogador::UsarHabilidade()
{
    if(ManaAtual >= 20.0f)
    {
        ManaAtual -= 20.0f;
        return true;
    }
    return false;
}

void AJogador::RecarregarMana(float DeltaTime)
{
    ManaAtual = FMath::Min(ManaAtual + 10.0f * DeltaTime, ManaMaxima);
}
```