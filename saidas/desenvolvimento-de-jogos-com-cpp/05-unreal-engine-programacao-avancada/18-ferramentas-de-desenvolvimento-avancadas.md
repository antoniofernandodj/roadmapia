## Ferramentas de desenvolvimento avançadas

Quando seu jogo começa a crescer em complexidade, encontrar e corrigir problemas pode se tornar uma tarefa demorada. A Unreal Engine oferece ferramentas poderosas que vão além do simples `UE_LOG`, permitindo inspecionar o jogo em tempo real e diagnosticar problemas complexos.

### Depuração avançada com Breakpoints Condicionais

Imagine que seu inimigo está se comportando de forma estranha apenas quando está com menos de 30% de vida. Um breakpoint comum pararia toda vez que o inimigo atualizasse seu estado, mas um breakpoint condicional resolve isso:

```cpp
void AEnemy::TakeDamage(float DamageAmount) 
{
    CurrentHealth -= DamageAmount;
    
    // Breakpoint condicional: CurrentHealth < MaxHealth * 0.3f
    if (CurrentHealth <= 0) 
    {
        Die();
    }
}
```

1. Clique na margem esquerda para adicionar um breakpoint
2. Botão direito → "Add Condition..."
3. Digite `CurrentHealth < MaxHealth * 0.3f`
4. Execute o jogo em modo Debug

O debugger só pausará quando a expressão for verdadeira, permitindo focar no problema real.

### Hot Reload para iteração rápida

Alterar uma classe e ter que recompilar todo o projeto pode consumir minutos preciosos. Com o Hot Reload ativo (ativado por padrão), faça pequenas alterações e pressione Ctrl+Alt+F11 para ver as mudanças sem reiniciar o editor:

```cpp
// Alteração em tempo real de propriedade
UPROPERTY(EditAnywhere, Category = "Combat")
float AttackRange = 200.0f; // Mude para 300.0f e aplique Hot Reload
```

Erro comum ao usar Hot Reload:
```
LogClass: Error: Failed to find function 'NewFunction' in 'MyActor'
```
Isso ocorre ao tentar chamar uma função recém-adicionada em Blueprints antes de recompilar totalmente. Solução: recompile o projeto completo após adicionar novas funções expostas a Blueprints.

### Visualização de Dados em Tempo Real com Unreal Insights

Para analisar performance, a ferramenta Unreal Insights coleta dados detalhados durante a execução. Ative no menu "Window → Developer Tools → Unreal Insights":

```cpp
// Marque um frame específico para análise
TRACE_BOOKMARK(TEXT("InimigoSpawnado")); 

// Meça uma seção crítica
TRACE_CPUPROFILER_EVENT_SCOPE(CalculatePathfinding);
PerformComplexPathfinding();
```

Saída típica no Unreal Insights:
```
| Frame | Thread | Event           | Duration (ms) |
|-------|--------|-----------------|---------------|
| 42    | Game   | CalculatePath   | 15.2          |
| 42    | Render | DrawParticles   | 8.7           |
```

### Console de Comandos para Debug Rápido

Acesse o console com til (~) e experimente comandos úteis:

```cpp
// Registre seus próprios comandos
static FAutoConsoleCommand CmdToggleDebug(
    TEXT("ai.ShowDebug"),
    TEXT("Mostra informações de debug da IA"),
    FConsoleCommandDelegate::CreateLambda([]()
    {
        AIDebugEnabled = !AIDebugEnabled;
    })
);
```

Comandos úteis nativos:
- `stat unit` - Mostra performance frame a frame
- `show collision` - Visualiza colisões
- `t.MaxFPS 60` - Limita taxa de quadros

### Data Breakpoints para Caçar Valores Alterados

Quando uma variável muda misteriosamente, defina um Data Breakpoint:

1. Execute até o ponto onde a variável está correta
2. No painel "Watch", clique com botão direito na variável
3. Selecione "Break when value changes"

Isso é especialmente útil para encontrar quem está modificando uma variável `bIsAlive` quando não deveria.

### Exercício Prático: Debug de IA com ECS

Seu inimigo está atacando quando deveria fugir. Crie um sistema para:

1. Ativar logs detalhados apenas quando `CurrentHealth < 50`
2. Usar Unreal Insights para medir o tempo gasto na árvore de decisão
3. Adicionar um comando de console `ai.DebugDecision` que mostra a lógica de decisão

Solução:

```cpp
// No arquivo EnemyAIController.cpp
void AEnemyAIController::MakeDecision() 
{
    TRACE_CPUPROFILER_EVENT_SCOPE(EnemyAI_Decision);
    
    if (CurrentHealth < 50) 
    {
        UE_LOG(LogAI, Warning, TEXT("Health low! Should flee but isn't"));
    }
    
    // Lógica existente...
}

// Comando de console
static FAutoConsoleCommand CmdDebugDecision(
    TEXT("ai.DebugDecision"),
    TEXT("Mostra processo de decisão"),
    FConsoleCommandDelegate::CreateLambda([]()
    {
        GEngine->AddOnScreenDebugMessage(-1, 5.f, FColor::Red, 
            TEXT("Decision Process: ") + LastDecision.ToString());
    })
);
```