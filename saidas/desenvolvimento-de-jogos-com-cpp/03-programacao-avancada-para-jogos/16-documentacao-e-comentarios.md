## Documentação e comentários

Você acaba de implementar um sistema de inteligência artificial para inimigos em seu jogo. O código funciona, mas quando você mostra para outro desenvolvedor, ele fica dez minutos tentando entender como o cálculo de distância funciona. Pior: quando você mesmo volta ao código após duas semanas, precisa ler linha por linha para lembrar a lógica. Essa situação comum mostra por que documentação e comentários são essenciais.

### O que são comentários úteis (e os inúteis)

Comentários são linhas ignoradas pelo compilador, mas essenciais para humanos. Veja dois exemplos com a função que calcula dano em um ataque:

```cpp
// Função de calcular dano
float CalculateDamage() {
    return Strength * WeaponMultiplier; 
}

// Ruim: repete o que o código já diz claramente
```

Versão útil:
```cpp
/**
 * Calcula dano do ataque considerando:
 * - Força base do personagem
 * - Bônus da arma equipada
 * - Penalidade se estiver envenenado (status effect)
 */
float CalculateDamage() {
    if (HasStatusEffect(Status::Poisoned)) {
        return (Strength * WeaponMultiplier) * 0.7f; // Reduz 30% quando envenenado
    }
    return Strength * WeaponMultiplier;
}
```

A diferença crucial: o bom comentário explica o **porquê** e o **contexto**, não o **como**. Quando você ler "reduz 30%", entenderá imediatamente que é um efeito de veneno, não um bug aleatório.

### Estilos de comentários em C++

C++ tem três formas de comentários:

1. Comentários de linha única:
```cpp
// Reinicia o contador após atingir o valor máximo
attackCombo = 0;
```

2. Comentários de múltiplas linhas (estilo C):
```cpp
/* Sistema de combate:
   - Mantém contagem de acertos consecutivos
   - Dá bônus a cada 3 acertos
   - Resetado ao errar ou após 5 segundos */
```

3. Comentários de documentação (Doxygen):
```cpp
/**
 * @brief Atualiza a posição do inimigo em direção ao jogador
 * @param DeltaTime Tempo desde o último frame (para movimento suave)
 * @param PlayerRef Referência à localização do jogador
 * @return Distância restante até o alvo
 */
float ChasePlayer(float DeltaTime, FVector PlayerRef);
```

### Quando comentar (e quando não)

**Comente quando:**
- Explicar algoritmos complexos (como pathfinding A*)
- Documentar parâmetros de funções públicas
- Justificar soluções não óbvias (por exemplo, "// Usamos 0.7f por limitação do motor")
- Alertar sobre código temporário ou problemático ("// TODO: Substituir por sistema de eventos")

**Não comente:**
- O óbvio ("x = 5; // Atribui 5 a x")
- Código que deve ser refatorado (melhor limpar do que comentar)
- Motivos que deveriam estar no controle de versão ("// Alterado por João em 10/05")

### Documentando classes para outros desenvolvedores

Na Unreal Engine, a documentação de classes usa um formato específico que integra com o editor. Veja como documentar uma classe de inimigo:

```cpp
/**
 * Inimigo básico com perseguição e ataque simples
 * 
 * Implementa:
 * - Perseguição ao jogador em raio de 1500 unidades
 * - Ataques corpo-a-corpo com cooldown
 * - Transição para estado de alerta quando avista jogador
 */
UCLASS()
class MYGAME_API AEnemyBasic : public ACharacter
{
    GENERATED_BODY()

public:
    /** Raio de detecção do jogador (em unidades Unreal) */
    UPROPERTY(EditDefaultsOnly, Category = "AI")
    float DetectionRadius = 1500.0f;

    /** Tempo entre ataques (em segundos) */
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
    float AttackCooldown = 2.0f;
};
```

Isso aparece como tooltips no editor da Unreal, ajudando designers a ajustar valores sem ler o código:

![Tooltip mostrando a documentação da propriedade no editor Unreal](https://i.imgur.com/JQZ1l9m.png)

### Erros comuns e como evitá-los

1. **Comentários desatualizados**: Quando você altera o código mas esquece de atualizar o comentário, cria desinformação. Exemplo:

```cpp
// Retorna true se o jogador estiver a menos de 10m (ANTES ERA 5m)
bool IsPlayerInRange() { return Distance < 1000.0f; } // Unreal usa cm, então 1000 = 10m
```

Solução: Remova comentários sobre versões antigas ou use sistemas de versionamento para histórico.

2. **Documentação ausente em interfaces públicas**: Se sua função é chamada por outras classes, documente:

```cpp
// RUIM - Quem usa não sabe o que esperar
FVector GetSpawnPoint();

// BOM - Explica comportamento e retorno
/**
 * Encontra posição segura para spawn longe de inimigos
 * @return Ponto válido ou ZeroVector se nenhum encontrado (avisa no log)
 */
FVector FindSafeSpawnLocation();
```

### Exercício prático

Documente esta função de movimentação do jogador, incluindo:
- Comentário de documentação para a função
- Explicação dos parâmetros
- Nota sobre o valor de retorno
- Comentário sobre a condição especial

```cpp
float UPlayerMovementComponent::MoveTo(FVector Target, float Speed, bool bIgnoreEnemies) {
    if (bIgnoreEnemies || !CheckEnemiesInPath(Target)) {
        FVector Direction = (Target - GetOwner()->GetActorLocation()).GetSafeNormal();
        GetOwner()->AddMovementInput(Direction, Speed);
        return FVector::Dist(GetOwner()->GetActorLocation(), Target);
    }
    return -1.0f; 
}
```

**Solução comentada:**

```cpp
/**
 * Move o dono deste componente em direção ao alvo com velocidade controlada
 * @param Target Posição destino no mundo
 * @Speed Velocidade de movimento (normalmente 0-1)
 * @param bIgnoreEnemies Se verdadeiro, ignora colisão com inimigos
 * @return Distância restante até o alvo, ou -1 se movimento bloqueado por inimigos
 */
float UPlayerMovementComponent::MoveTo(FVector Target, float Speed, bool bIgnoreEnemies) {
    // Verifica se podemos mover (ignorando ou checando inimigos no caminho)
    if (bIgnoreEnemies || !CheckEnemiesInPath(Target)) {
        // Cálculo normalizado da direção para movimento suave
        FVector Direction = (Target - GetOwner()->GetActorLocation()).GetSafeNormal();
        GetOwner()->AddMovementInput(Direction, Speed);
        return FVector::Dist(GetOwner()->GetActorLocation(), Target);
    }
    // Código de erro especial para movimento bloqueado
    return -1.0f; 
}
```