## Otimização de Estruturas de Dados

Um sistema de gerenciamento de eventos processa milhões de mensagens por segundo. Cada evento tem um payload de 32 bytes e metadados. Usando `Vec<Evento>`, você nota no profiling que 23% do tempo é gasto em realocações. O problema não é o Rust, mas como escolhemos a estrutura de dados.

### Capacidade vs Tamanho: O Segredo do `Vec`

```rust
let mut eventos = Vec::with_capacity(1_000_000);
for _ in 0..1_000_000 {
    eventos.push(Evento::novo()); // Sem realocações!
}
```

A chave está em `with_capacity`. Um `Vec` comum começa pequeno e dobra de tamanho cada vez que fica cheio (fator comum é 2x). Para 1 milhão de itens, isso significa ~20 realocações e cópias desnecessárias. Com capacidade pré-definida, eliminamos todas elas.

**Erro comum:**
```rust
let mut eventos = Vec::new();
eventos.reserve(100); // Capacidade para 100
eventos.push(Evento::novo()); // OK
eventos.push(Evento::novo()); // OK...
// 98 itens depois...
eventos.push(Evento::novo()); // Panic! Esqueceu de atualizar a capacidade
```

### Quando `Vec` Não é a Resposta

Para filas onde você remove do início frequentemente, `Vec` força cópias O(n):

```rust
let mut fila = vec![1, 2, 3, 4];
let primeiro = fila.remove(0); // Todos os elementos são deslocados!
```

A alternativa é `std::collections::VecDeque`:

```rust
use std::collections::VecDeque;

let mut fila = VecDeque::with_capacity(100);
fila.push_back(1);
fila.push_back(2);
let primeiro = fila.pop_front(); // O(1), sem cópias
```

Benchmark (1M operações):
- `Vec`: 187ms
- `VecDeque`: 23ms

### Estruturas de Dados Especializadas

Para lookup rápido, um `HashMap` padrão pode não ser o ideal. O Rust oferece:

1. `std::collections::BTreeMap` - Ordenado e com previsibilidade de memória
2. `fnv::FnvHashMap` - Hash rápido para chaves pequenas (crate `fnv`)
3. `std::collections::HashSet` vs `std::collections::BTreeSet`

Exemplo com FNV:
```toml
# Cargo.toml
[dependencies]
fnv = "1.0"
```

```rust
use fnv::FnvHashMap;

let mut map = FnvHashMap::default();
map.insert("chave", 42); // Hash otimizado para pequenas chaves
```

### Zero-Cost Abstractions: `Box` vs Referências

```rust
struct DadosPesados([u8; 1024]);

// Alocação desnecessária
struct Caso1 {
    dados: Box<DadosPesados>
}

// Melhor: diretamente na estrutura
struct Caso2 {
    dados: DadosPesados
}
```

Use `Box` apenas quando:
1. Precisa de trait objects (`dyn Trait`)
2. Tipos recursivos (como árvores)
3. Dados realmente grandes que não cabem no stack

### Strings: A Armadilha das Alocações

```rust
// Alocação implícita
let nome = "Carlos".to_string();

// Mais eficiente para literais
let nome: &'static str = "Carlos";

// Para construção incremental
let mut buffer = String::with_capacity(100);
buffer.push_str("Olá, ");
buffer.push_str("Carlos!");
```

### Exercício Prático

Suponha um sistema de cache que mapeia IDs (u64) para perfis de usuário (struct de 256 bytes). O cache tem ~1000 itens ativos com taxa de hit de 75%. Implemente a estrutura ideal.

**Solução comentada:**

```rust
use std::collections::HashMap;
use fnv::FnvHashMap;

struct PerfilUsuario([u8; 256]);

// Versão otimizada
struct Cache {
    dados: FnvHashMap<u64, PerfilUsuario>, // FNV para IDs numéricos
    capacidade: usize,
}

impl Cache {
    fn new(capacidade: usize) -> Self {
        Cache {
            dados: FnvHashMap::with_capacity_and_hasher(
                capacidade,
                Default::default()
            ),
            capacidade,
        }
    }
    
    fn inserir(&mut self, id: u64, perfil: PerfilUsuario) {
        if self.dados.len() >= self.capacidade {
            self.dados.clear(); // Estratégia simples para o exercício
        }
        self.dados.insert(id, perfil);
    }
}
```

Por que funciona:
1. `FnvHashMap` é ideal para chaves numéricas pequenas
2. Pré-alocação exata evita realocações
3. `PerfilUsuario` fica inline, sem alocação extra
4. Clear mantém a capacidade alocada

Alternativas a considerar em casos reais:
- LRU cache para evicção mais inteligente
- `Box<PerfilUsuario>` se perfis forem muito variáveis em tamanho