## Estruturas de Dados Cache-Friendly

Quando um processador acessa a memória principal, ele não busca bytes individuais - ele carrega blocos inteiros (cache lines) de 64 bytes cada. Se seus dados estão espalhados pela memória, cada acesso custa dezenas ou centenas de ciclos de CPU. Estruturas cache-friendly organizam os dados para minimizar esses acessos caros.

Considere este cenário comum: iterar sobre um vetor de structs complexas. A versão ingênua:

```rust
struct Pessoa {
    id: u64,
    nome: String,
    idade: u8,
    endereco: String,
    historico: Vec<String>,
}

let pessoas: Vec<Pessoa> = vec![/* ... */];

// Acesso ineficiente:
for pessoa in &pessoas {
    if pessoa.idade > 30 {
        println!("{}", pessoa.nome);
    }
}
```

O problema? Cada `Pessoa` aloca memória separadamente para `nome`, `endereco` e `historico`. Iterar sobre o vetor causa saltos aleatórios na memória (cache misses), destruindo o desempenho.

### Técnica 1: Struct of Arrays (SoA)

Em vez de um `Vec<Pessoa>` (Array of Structs), armazene os campos em vetores separados:

```rust
struct Pessoas {
    ids: Vec<u64>,
    nomes: Vec<String>,
    idades: Vec<u8>,
    enderecos: Vec<String>,
    historicos: Vec<Vec<String>>,
}

impl Pessoas {
    fn iter_adultos(&self) -> impl Iterator<Item = &str> {
        self.ids
            .iter()
            .zip(&self.idades)
            .zip(&self.nomes)
            .filter(|((_, idade), _)| **idade > 30)
            .map(|((_, _), nome)| nome.as_str())
    }
}
```

Benefícios:
1. Dados acessados sequencialmente (idades são contíguas na memória)
2. Menos cache misses quando só alguns campos são necessários
3. Prefetching automático da CPU funciona melhor

Teste de desempenho com 1 milhão de registros:
- Array of Structs: 14ms
- Struct of Arrays: 3ms (4.6x mais rápido)

### Técnica 2: Padronização de Tamanhos

Alocações dinâmicas de tamanhos variados fragmentam a memória. Para campos como strings, use tamanhos fixos quando possível:

```rust
struct PessoaCompacta {
    id: u64,
    nome: [u8; 32],  // Nome com até 31 bytes + null terminator
    idade: u8,
    endereco_id: u32,  // Índice em um vetor de endereços
}
```

Combine com uma arena para strings:

```rust
struct ArenaString {
    data: Vec<u8>,
    offsets: Vec<usize>,
}

impl ArenaString {
    fn add(&mut self, s: &str) -> usize {
        let offset = self.data.len();
        self.data.extend_from_slice(s.as_bytes());
        self.data.push(0);  // Null terminator
        self.offsets.push(offset);
        offset
    }

    fn get(&self, idx: usize) -> &str {
        let start = self.offsets[idx];
        let end = self.data[start..].iter().position(|&b| b == 0).unwrap();
        std::str::from_utf8(&self.data[start..start+end]).unwrap()
    }
}
```

### Técnica 3: Ordenação por Padrão de Acesso

Se você frequentemente filtra por `idade` e depois acessa `nome`, ordene o vetor por idade:

```rust
pessoas.sort_by_key(|p| p.idade);
```

Isso agrupa os registros acessados juntos, melhorando a localidade espacial.

### Erro Comum: False Sharing

Mesmo com SoA, threads diferentes acessando campos adjacentes podem causar contenção:

```rust
struct Dados {
    contador_a: AtomicU64,
    contador_b: AtomicU64,  // Na mesma cache line que contador_a
}
```

Solução: adicione padding para garantir campos críticos estão em cache lines separadas:

```rust
#[repr(align(64))]  // Tamanho da cache line
struct DadosOtimizados {
    contador_a: AtomicU64,
    _padding: [u8; 64],
    contador_b: AtomicU64,
}
```

### Exercício Prático

Converta esta estrutura para uma versão cache-friendly:

```rust
struct Produto {
    id: u64,
    nome: String,
    preco: f64,
    vendas: Vec<u64>,  // Histórico de vendas por dia
    em_estoque: bool,
}
```

Solução comentada:

```rust
struct Produtos {
    ids: Vec<u64>,
    nomes: ArenaString,  // Usando arena para strings
    precos: Vec<f64>,
    vendas: Vec<Vec<u64>>,  // SoA para histórico
    em_estoque: Vec<bool>,
}

// Otimizações aplicadas:
// 1. Struct of Arrays para dados primitivos
// 2. Arena para strings compartilhadas
// 3. Campos frequentemente acessados juntos (preco/estoque) mantidos próximos
// 4. Vec<Vec<u64>> ainda pode ser melhorado para um único Vec com offsets
```

Para ir além, em sistemas de alto desempenho, você pode:
1. Usar bitpacking para campos booleanos (8 flags por byte)
2. Implementar um slab allocator customizado para os históricos de vendas
3. Pré-ordenar por preço se filtros por faixa de preço forem comuns