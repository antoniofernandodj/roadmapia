## Estratégias para Minimizar Alocações

Em Rust, a alocação dinâmica de memória é uma operação custosa, especialmente em cenários de alto desempenho, como servidores de alta vazão ou aplicações desktop que lidam com grandes volumes de dados. Minimizar essas alocações pode trazer ganhos significativos de desempenho. Uma das estratégias mais eficazes é a **reutilização de buffers**, que evita a criação repetida de novas alocações de memória.

### Reutilização de Buffers

Imagine que você está processando uma série de dados em um loop, onde cada iteração requer a criação de um novo vetor (`Vec`). Cada vez que você cria um novo vetor, o Rust precisa alocar memória dinamicamente, o que pode se tornar um gargalo de desempenho. A solução é **reutilizar o mesmo vetor** entre as iterações, limpando seu conteúdo antes de cada uso.

Considere o exemplo a seguir, onde processamos uma lista de números e armazenamos os resultados em vetores:

```rust
fn process_data(data: &[i32]) -> Vec<i32> {
    let mut result = Vec::new();
    for &num in data {
        result.push(num * 2);
    }
    result
}

fn main() {
    let data = vec![1, 2, 3, 4, 5];
    let processed_data = process_data(&data);
    println!("{:?}", processed_data);
}
```

Aqui, `process_data` cria um novo vetor (`result`) a cada chamada. Se `process_data` for chamada repetidamente, isso resultará em múltiplas alocações de memória. Para evitar isso, podemos modificar o código para reutilizar o mesmo vetor:

```rust
fn process_data_into_buffer(data: &[i32], buffer: &mut Vec<i32>) {
    buffer.clear();
    for &num in data {
        buffer.push(num * 2);
    }
}

fn main() {
    let data = vec![1, 2, 3, 4, 5];
    let mut buffer = Vec::new();
    
    process_data_into_buffer(&data, &mut buffer);
    println!("{:?}", buffer);
    
    // Reutilizando o mesmo buffer para outro processamento
    let more_data = vec![6, 7, 8, 9, 10];
    process_data_into_buffer(&more_data, &mut buffer);
    println!("{:?}", buffer);
}
```

Neste exemplo, `process_data_into_buffer` recebe um buffer (`buffer`) como parâmetro mutável. Antes de preencher o buffer com novos dados, chamamos `buffer.clear()` para remover os elementos anteriores. Isso permite que o mesmo vetor seja reutilizado em múltiplas chamadas, evitando alocações desnecessárias.

### Evitando Alocações Temporárias

Outra estratégia comum é evitar a criação de estruturas de dados temporárias. Por exemplo, ao concatenar strings, você pode usar `String::with_capacity` para pré-alocar memória suficiente, evitando realocações frequentes:

```rust
fn concatenate_strings(a: &str, b: &str) -> String {
    let mut result = String::with_capacity(a.len() + b.len());
    result.push_str(a);
    result.push_str(b);
    result
}

fn main() {
    let a = "Hello, ";
    let b = "world!";
    let combined = concatenate_strings(a, b);
    println!("{}", combined);
}
```

Aqui, `String::with_capacity` aloca memória suficiente para ambas as strings de uma vez, evitando a necessidade de realocar memória durante a concatenação.

### Uso de Coleções Pré-Alocadas

Em cenários onde você sabe o tamanho aproximado dos dados que serão armazenados, pode ser vantajoso pré-alocar memória para coleções como `Vec`, `HashMap`, ou `HashSet`. Isso reduz a necessidade de realocações conforme a coleção cresce:

```rust
fn main() {
    let mut numbers = Vec::with_capacity(100);
    for i in 0..100 {
        numbers.push(i);
    }
    println!("{:?}", numbers);
}
```

Neste exemplo, `Vec::with_capacity(100)` aloca memória suficiente para 100 elementos desde o início, evitando realocações durante o preenchimento do vetor.

### Exercício

Considere a seguinte função que processa uma lista de strings, convertendo cada uma para maiúsculas e armazenando o resultado em um vetor:

```rust
fn process_strings(strings: &[&str]) -> Vec<String> {
    let mut result = Vec::new();
    for s in strings {
        result.push(s.to_uppercase());
    }
    result
}

fn main() {
    let strings = vec!["hello", "world"];
    let processed = process_strings(&strings);
    println!("{:?}", processed);
}
```

Modifique a função para reutilizar um buffer ao invés de criar um novo vetor a cada chamada.

#### Solução

```rust
fn process_strings_into_buffer(strings: &[&str], buffer: &mut Vec<String>) {
    buffer.clear();
    for s in strings {
        buffer.push(s.to_uppercase());
    }
}

fn main() {
    let strings = vec!["hello", "world"];
    let mut buffer = Vec::new();
    
    process_strings_into_buffer(&strings, &mut buffer);
    println!("{:?}", buffer);
    
    // Reutilizando o mesmo buffer para outro processamento
    let more_strings = vec!["rust", "is", "awesome"];
    process_strings_into_buffer(&more_strings, &mut buffer);
    println!("{:?}", buffer);
}
```

Nesta solução, `process_strings_into_buffer` reutiliza o buffer passado como parâmetro, limpando-o antes de cada uso. Isso elimina a necessidade de múltiplas alocações de memória para armazenar os resultados.