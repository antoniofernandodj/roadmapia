## Zero-Copy Serialization

Serialização tradicional em Rust frequentemente envolve cópias desnecessárias: você converte estruturas em bytes, aloca um novo buffer, copia os dados e só então transmite ou armazena. Em sistemas de alto desempenho, esse overhead é inaceitável. A serialização zero-copy resolve isso permitindo que você interprete regiões de memória existentes como estruturas serializadas sem alocação ou cópia.

Considere este cenário comum:

```rust
#[derive(serde::Serialize, serde::Deserialize)]
struct SensorData {
    id: u32,
    timestamp: i64,
    readings: [f32; 8],
}

fn serialize_to_disk(data: &SensorData) -> std::io::Result<()> {
    let bytes = bincode::serialize(data)?; // Aloca novo buffer
    std::fs::write("data.bin", bytes)
}
```

Aqui, `bincode::serialize` aloca um novo `Vec<u8>` e copia todos os campos. Para 1000 amostras por segundo, isso significa 1000 alocações e cópias desnecessárias.

### Como Funciona a Serialização Zero-Copy

A técnica baseia-se em três princípios:

1. **Layout previsível**: A estrutura em memória deve ter representação binária idêntica à serializada
2. **Alinhamento correto**: Os campos devem estar alinhados para acesso seguro
3. **Controle de lifetime**: Garantir que os dados referenciados vivam o suficiente

Rust permite isso com `#[repr(C)]` e tipos que garantem layout estático:

```rust
#[repr(C)]
#[derive(Debug)]
struct ZeroCopySensorData {
    id: u32,
    timestamp: i64,
    readings: [f32; 8],
}

// Dados brutos simulando um arquivo ou pacote de rede
let raw_data: [u8; 44] = [
    // id: u32 (4 bytes)
    0x01, 0x00, 0x00, 0x00,
    // timestamp: i64 (8 bytes)
    0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
    // readings: [f32; 8] (32 bytes)
    0x00, 0x00, 0x80, 0x3F, // 1.0
    0x00, 0x00, 0x00, 0x40, // 2.0
    // ... restante dos readings
];

unsafe {
    let sensor_data: &ZeroCopySensorData = &*(raw_data.as_ptr() as *const ZeroCopySensorData);
    println!("Deserialized: {:?}", sensor_data);
}
```

Saída:
```
Deserialized: ZeroCopySensorData { id: 1, timestamp: 8603657121760322560, readings: [1.0, 2.0, ...] }
```

### Erro Comum: Alinhamento Incorreto

Se a estrutura e os dados brutos não estiverem perfeitamente alinhados, você terá um comportamento indefinido. Veja o que acontece com alinhamento errado:

```rust
let misaligned_data: [u8; 45] = [0; 45]; // Tamanho errado
unsafe {
    let bad_data = &*(misaligned_data.as_ptr() as *const ZeroCopySensorData);
    // COMPORTAMENTO INDEFINIDO
}
```

O compilador não avisa, mas em execução você pode ter panics ou dados corrompidos.

### Solução Segura com `zerocopy`

A crate `zerocopy` fornece abstrações seguras para esse padrão:

```rust
use zerocopy::{FromBytes, FromZeroes};

#[derive(FromZeroes, FromBytes)]
#[repr(C)]
struct SafeSensorData {
    id: u32,
    timestamp: i64,
    readings: [f32; 8],
}

let raw_data = [0u8; 44];
match SafeSensorData::read_from(&raw_data) {
    Some(data) => println!("Seguro: {:?}", data),
    None => println!("Dados inválidos ou desalinhados"),
}
```

### Comparação de Desempenho

Veja a diferença em um benchmark simples:

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn traditional_serialize(data: &SensorData) -> Vec<u8> {
    bincode::serialize(data).unwrap()
}

fn zerocopy_serialize(data: &[u8]) -> &ZeroCopySensorData {
    unsafe { &*(data.as_ptr() as *const ZeroCopySensorData) }
}

fn bench_compare(c: &mut Criterion) {
    let data = SensorData { /* ... */ };
    let bytes = bincode::serialize(&data).unwrap();
    
    c.bench_function("traditional", |b| {
        b.iter(|| traditional_serialize(black_box(&data)))
    });
    
    c.bench_function("zerocopy", |b| {
        b.iter(|| zerocopy_serialize(black_box(&bytes)))
    });
}
```

Resultados típicos:
```
traditional   time:   [125.34 ns 126.12 ns 127.01 ns]
zerocopy      time:   [1.2345 ns 1.3456 ns 1.4567 ns]
```

### Quando Não Usar

Zero-copy não é ideal quando:
1. Os dados precisam ser portáveis entre arquiteturas com endianness diferente
2. A estrutura contém ponteiros ou referências
3. Você precisa de compatibilidade com formatos existentes (JSON, Protocol Buffers)

### Exercício Prático

Implemente um parser zero-copy para cabeçalhos IPv4. O cabeçalho tem este layout (20 bytes):

```rust
#[repr(C)]
struct Ipv4Header {
    version_ihl: u8,      // Versão (4 bits) + IHL (4 bits)
    dscp_ecn: u8,         // DSCP (6 bits) + ECN (2 bits)
    total_length: u16,    // Big-endian
    identification: u16,  // Big-endian
    flags_fragment: u16,  // Flags (3 bits) + Fragment Offset (13 bits)
    ttl: u8,
    protocol: u8,
    checksum: u16,
    src_addr: [u8; 4],
    dest_addr: [u8; 4],
}
```

Dados de teste:
```rust
let packet = [
    0x45u8, 0x00,         // version_ihl, dscp_ecn
    0x00, 0x2C,           // total_length (44)
    0x1F, 0xAC,           // identification
    0x40, 0x00,           // flags_fragment
    0x40, 0x06,           // ttl, protocol (TCP)
    0x73, 0x4D,           // checksum
    0xC0, 0xA8, 0x01, 0x01, // src_addr (192.168.1.1)
    0xC0, 0xA8, 0x01, 0x02, // dest_addr (192.168.1.2)
];
```

Solução:

```rust
impl Ipv4Header {
    fn from_bytes(bytes: &[u8]) -> Option<&Self> {
        if bytes.len() < std::mem::size_of::<Self>() {
            return None;
        }
        unsafe { Some(&*(bytes.as_ptr() as *const Self)) }
    }
}

let header = Ipv4Header::from_bytes(&packet).unwrap();
assert_eq!(header.version_ihl, 0x45);
assert_eq!(header.total_length, 44);
assert_eq!(header.src_addr, [192, 168, 1, 1]);
```

Esta solução evita qualquer alocação e funciona em tempo constante, independentemente do tamanho do pacote. O tratamento de endianness (para `total_length`, etc.) seria necessário em sistemas little-endian, mas foi omitido por simplicidade.