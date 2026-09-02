## Exceções e tratamento de erros

Imagine um jogo onde o jogador tenta carregar uma fase que não existe. Sem tratamento de erros, o jogo simplesmente crasharia com uma mensagem obscura. Em C++, usamos exceções para lidar com esses cenários de forma elegante.

No coração de um jogo, o código frequentemente precisa se recuperar de situações imprevistas:

```cpp
void CarregarFase(const FString& NomeFase) {
    if (!FPlatformFileManager::Get().GetPlatformFile().FileExists(*NomeFase)) {
        throw std::runtime_error("Fase não encontrada: " + TCHAR_TO_UTF8(*NomeFase));
    }
    // Código para carregar a fase...
}
```

Quando chamamos essa função sem verificação, o resultado é claro:

```
terminate called after throwing an instance of 'std::runtime_error'
  what(): Fase não encontrada: FaseInexistente.umap
```

Para capturar essa exceção, usamos o bloco `try-catch`:

```cpp
try {
    CarregarFase("FaseInexistente.umap");
} catch (const std::runtime_error& Erro) {
    UE_LOG(LogTemp, Error, TEXT("%s"), UTF8_TO_TCHAR(Erro.what()));
    // Mostra mensagem amigável ao jogador
    MostrarMensagemErro("Não foi possível carregar a fase solicitada");
}
```

A saída no Output Log da Unreal fica:
```
LogTemp: Error: Fase não encontrada: FaseInexistente.umap
```

Erros comuns incluem:
1. Esquecer de capturar exceções (levando a crashes)
2. Capturar exceções muito genéricas (perdendo informações específicas)

A hierarquia padrão de exceções em C++ inclui:
- `std::exception` (base para todas)
- `std::runtime_error` (para erros detectáveis apenas em runtime)
- `std::logic_error` (para erros de programação)

Um exemplo prático no contexto de jogos:

```cpp
void ValidarInventario(const TArray<FItem>& Inventario) {
    if (Inventario.Num() > CapacidadeMaxima) {
        throw std::overflow_error("Inventário excede capacidade máxima");
    }
}

// Uso correto
try {
    ValidarInventario(InventarioJogador);
} catch (const std::overflow_error& e) {
    UE_LOG(LogTemp, Warning, TEXT("Inventário cheio: %s"), UTF8_TO_TCHAR(e.what()));
    InventarioJogador.SetNum(CapacidadeMaxima);
}
```

**Exercício**: Implemente uma função `CarregarTextura` que:
1. Verifica se o arquivo existe
2. Verifica se é um arquivo de textura válido (extensão .png ou .jpg)
3. Lança exceções específicas para cada caso
4. Captura as exceções na função chamadora

**Solução comentada**:

```cpp
void CarregarTextura(const FString& Caminho) {
    if (!FPaths::FileExists(Caminho)) {
        throw std::runtime_error("Arquivo não encontrado");
    }
    
    FString Extensao = FPaths::GetExtension(Caminho).ToLower();
    if (Extensao != "png" && Extensao != "jpg") {
        throw std::invalid_argument("Formato de textura inválido");
    }
    
    // Código para carregar a textura...
}

// Chamada segura
try {
    CarregarTextura("Texturas/Personagem.txt");
} catch (const std::exception& e) {
    UE_LOG(LogTemp, Error, TEXT("Erro ao carregar textura: %s"), UTF8_TO_TCHAR(e.what()));
}
```