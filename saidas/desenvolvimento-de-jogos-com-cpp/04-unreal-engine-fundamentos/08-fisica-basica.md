## Física básica

A física é um elemento essencial para criar jogos realistas e interativos. Na Unreal Engine, você pode simular comportamentos físicos como gravidade, colisões e movimento de objetos sem precisar escrever código complexo. Vamos explorar como aplicar física básica aos objetos na sua cena.

### Adicionando física a um objeto

Para começar, vamos criar um objeto simples e aplicar física a ele. Abra a Unreal Engine e crie um novo projeto usando o template "Blank". No `Content Browser`, clique com o botão direito e selecione `Basic > Cube` para adicionar um cubo à cena. Com o cubo selecionado, vá até o `Details Panel` e localize a seção `Physics`. Ative a opção `Simulate Physics`. Agora, quando você executar o jogo, o cubo cairá devido à gravidade.

```cpp
// Exemplo de código C++ para habilitar física em um objeto
UStaticMeshComponent* CubeMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("CubeMesh"));
CubeMesh->SetSimulatePhysics(true);
```

Ao executar o jogo, você verá o cubo cair e interagir com o chão. Se você não tiver um chão na cena, o cubo continuará caindo indefinidamente. Para evitar isso, adicione um `Plane` ao seu projeto (`Basic > Plane`) e posicione-o abaixo do cubo.

### Configurando propriedades físicas

Agora que temos um objeto com física, vamos explorar algumas propriedades que podem ser ajustadas para controlar seu comportamento. No `Details Panel`, você encontrará opções como `Mass` (massa), `Linear Damping` (amortecimento linear) e `Angular Damping` (amortecimento angular).

- `Mass`: Controla o peso do objeto. Objetos com maior massa são mais difíceis de mover.
- `Linear Damping`: Reduz a velocidade do objeto ao longo do tempo. Valores mais altos fazem o objeto parar mais rapidamente.
- `Angular Damping`: Reduz a rotação do objeto ao longo do tempo. Útil para evitar que objetos girem indefinidamente.

Experimente ajustar esses valores e observe como o comportamento do cubo muda ao executar o jogo.

```cpp
// Exemplo de código C++ para configurar propriedades físicas
CubeMesh->SetMassOverrideInKg(NAME_None, 10.0f); // Define a massa como 10kg
CubeMesh->SetLinearDamping(0.5f); // Define o amortecimento linear
CubeMesh->SetAngularDamping(0.5f); // Define o amortecimento angular
```

### Adicionando força a um objeto

Você também pode aplicar forças a objetos para movê-los de maneira controlada. No `Details Panel`, encontre a opção `Add Impulse` ou `Add Force`. Essas opções permitem aplicar uma força instantânea (`Impulse`) ou contínua (`Force`) ao objeto.

Vamos aplicar um impulso ao cubo para fazê-lo se mover para frente. No `Event Graph` de um Blueprint, adicione um evento `Event BeginPlay` e conecte-o a um nó `Add Impulse`. Configure o vetor de impulso para `(1000, 0, 0)` para aplicar uma força ao longo do eixo X.

```cpp
// Exemplo de código C++ para aplicar um impulso
FVector Impulse = FVector(1000.0f, 0.0f, 0.0f);
CubeMesh->AddImpulse(Impulse);
```

Ao executar o jogo, o cubo será impulsionado para frente e continuará se movendo até que a força da gravidade e o amortecimento o parem.

### Erros comuns e como corrigi-los

Um erro comum ao trabalhar com física é esquecer de definir um `Collision` (colisão) para o objeto. Sem uma colisão, o objeto pode passar por outros objetos na cena. Para corrigir isso, certifique-se de que o objeto tenha um `Collision Component` adequado.

Outro erro é aplicar uma força muito grande, fazendo o objeto se mover de maneira não natural. Para evitar isso, comece com valores menores e ajuste gradualmente até conseguir o efeito desejado.

```cpp
// Exemplo de código C++ para verificar colisão
if (CubeMesh->IsSimulatingPhysics())
{
    CubeMesh->SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
}
```

### Exercício prático

Crie uma cena com dois cubos e um plano. Aplique física a ambos os cubos, mas configure diferentes massas e amortecimentos. Aplique um impulso a um dos cubos e observe como eles interagem entre si e com o plano.

**Solução comentada:**
1. Adicione dois cubos e um plano à cena.
2. Ative `Simulate Physics` para ambos os cubos.
3. Configure `Mass` e `Damping` para valores diferentes em cada cubo.
4. Aplique um impulso a um dos cubos usando `Add Impulse`.
5. Execute o jogo e observe as interações físicas.

Este exercício ajudará você a entender como diferentes propriedades físicas afetam o comportamento dos objetos na cena.