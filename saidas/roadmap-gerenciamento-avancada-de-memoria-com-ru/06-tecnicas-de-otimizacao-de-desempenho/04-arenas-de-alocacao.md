## Arenas de Alocação

Quando você precisa alocar muitos objetos de vida útil similar—como em parsers, compiladores ou jogos—o padrão `Vec<T>` pode ser ineficiente. Cada `push()` pode desencadear uma realocação, e cada objeto alocado individualmente aumenta a fragmentação. A solução? Uma **arena**: um alocador que reserva um bloco contíguo de memória e distribui pedaços dele sequencialmente, sem realocações ou desalocações individuais.

### Implementação Básica

Vamos criar uma arena genérica que armazena qualquer tipo `T`. A chave é usar um `Vec<T>` como reservatório, mas gerenciar as alocações manualmente:

```rust
struct Arena<T> {
    chunks: Vec<Vec<T>>,
    current_chunk: Vec<T>,
    chunk_size: usize,
}

impl<T> Arena<T> {
    fn new(chunk_size: usize) -> Self {
        Arena {
            chunks: Vec::new(),
            current_chunk: Vec::with_capacity(chunk_size),
            chunk_size,
        }
    }

    fn allocate(&mut self, value: T) -> &mut T {
        if self.current_chunk.len() == self.current_chunk.capacity() {
            let new_chunk = Vec::with_capacity(self.chunk_size);
            let old_chunk = std::mem::replace(&mut self.current_chunk, new_chunk);
            self.chunks.push(old_chunk);
        }

        self.current_chunk.push(value);
        self.current_chunk.last_mut().unwrap()
    }
}
```

**Uso típico**:
```rust
let mut arena = Arena::<String>::new(1024);
let s1 = arena.allocate("Hello".to_string());
let s2 = arena.allocate("Arena".to_string());
println!("{} {}!", s1, s2); // Saída: Hello Arena!
```

### Por Que Funciona

1. **Alocação em Bloco**: A arena pré-aloca um `Vec` (`current_chunk`) com capacidade fixa (`chunk_size`). Enquanto houver espaço, `allocate()` simplesmente adiciona ao vetor.
2. **Troca sem Cópia**: Quando o chunk atual enche, `std::mem::replace` troca o vetor cheio por um novo vazio em O(1), sem copiar os dados.
3. **Referências Estáveis**: As referências retornadas (`&mut T`) permanecem válidas porque os vetores subjacentes nunca são realocados—apenas novos chunks são criados.

### Erro Comum e Correção

Um erro frequente é tentar usar a arena após esvaziá-la:

```rust
let mut arena = Arena::<i32>::new(2);
let x = arena.allocate(42);
let y = arena.allocate(43);
let z = arena.allocate(44); // Novo chunk criado aqui

// ⚠️ Isso compila, mas é logicamente errado:
std::mem::drop(arena); // Libera todos os chunks

println!("{}", x); // Referência inválida! Use-after-free potencial.
```

**Mensagem do compilador** (se usarmos `#![forbid(unsafe_code)]`):
```
error[E0505]: cannot move out of `arena` because it is borrowed
```

**Solução**: Restringir o tempo de vida das referências ou usar `Rc`/`Arc` para casos onde a arena precisa ser liberada antes das referências.

### Arena para Tipos Diferentes

Para alocar tipos heterogêneos (útil em ASTs), use um enum ou uma arena de bytes:

```rust
struct MultiArena {
    data: Vec<u8>,
    len: usize,
}

impl MultiArena {
    fn allocate<T>(&mut self, value: T) -> &mut T {
        let size = std::mem::size_of::<T>();
        let align = std::mem::align_of::<T>();

        // Alinha o ponteiro
        let start = (self.len + align - 1) / align * align;
        
        assert!(start + size <= self.data.capacity(), "Arena cheia");
        
        let ptr = &mut self.data[start] as *mut u8 as *mut T;
        unsafe { 
            ptr.write(value);
            &mut *ptr
        }
    }
}
```

**Limitação**: Esta versão requer `unsafe`. Uma alternativa segura é usar `Vec<Box<dyn Any>>`, mas com overhead de alocação dinâmica.

### Exercício

Implemente uma arena que permite desalocação seletiva sem fragmentação, usando um bitmap para marcar espaços livres. A assinatura desejada:

```rust
impl<T> Arena<T> {
    fn deallocate(&mut self, item: &mut T) -> bool { /* ... */ }
}
```

**Solução Esboçada**:
1. Armazene cada chunk como `Vec<(T, bool)>`, onde o `bool` marca se o slot está livre.
2. Em `allocate`, procure o primeiro slot livre antes de adicionar no final.
3. Em `deallocate`, marque o slot como livre e retorne `true` se o item pertencia à arena.

**Comparação de Desempenho**:
- Arena básica: Alocação O(1), desalocação O(1) apenas no final.
- Arena com desalocação: Alocação O(n) no pior caso (busca por slot livre), desalocação O(1).

Use arenas quando a ordem de desalocação for previsível (ex.: liberar todos os objetos juntos no final da fase de parsing). Caso contrário, considere um gerenciador de memória mais sofisticado.