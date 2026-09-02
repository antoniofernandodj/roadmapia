## Strings em C++

Em jogos, strings são essenciais para exibir mensagens, nomes de personagens, diálogos e informações de interface. Ao contrário de tipos básicos como `int` ou `float`, strings representam sequências de caracteres e exigem um tratamento especial em C++.

### O problema do array de caracteres

Originalmente, em C, strings eram representadas como arrays de caracteres terminados por `\0` (null terminator). Isso funciona, mas é trabalhoso:

```cpp
#include <iostream>

int main() {
    char nomeJogador[20] = {'M', 'a', 'r', 'i', 'o', '\0'}; // Forma tradicional
    char nomeInimigo[] = "Bowser"; // Forma simplificada, mas ainda array
    
    std::cout << "Jogador: " << nomeJogador << std::endl;
    std::cout << "Inimigo: " << nomeInimigo << std::endl;
    
    // Tentando concatenar - erro comum!
    // strcat(nomeJogador, " vs "); // Requer #include <cstring>
    // strcat(nomeJogador, nomeInimigo);
    
    return 0;
}
```

Saída:
```
Jogador: Mario
Inimigo: Bowser
```

O código comentado mostra a dificuldade: concatenar strings requer funções especiais como `strcat()`, e há risco de estourar o tamanho do array.

### A solução: std::string

A biblioteca padrão oferece a classe `std::string` no cabeçalho `<string>`, que resolve esses problemas:

```cpp
#include <iostream>
#include <string> // Necessário para std::string

int main() {
    std::string nomeJogador = "Mario";
    std::string nomeInimigo = "Bowser";
    
    // Concatenação simples com +
    std::string mensagem = nomeJogador + " vs " + nomeInimigo;
    
    std::cout << "Combate: " << mensagem << std::endl;
    std::cout << "Tamanho: " << mensagem.size() << " caracteres" << std::endl;
    
    return 0;
}
```

Saída:
```
Combate: Mario vs Bowser
Tamanho: 12 caracteres
```

### Operações com strings

`std::string` oferece métodos úteis para manipulação:

```cpp
#include <iostream>
#include <string>

int main() {
    std::string item = " Poção Mágica ";
    
    // Removendo espaços
    item.erase(0, 1); // Remove 1 caractere na posição 0
    item.pop_back();   // Remove último caractere (espaço)
    
    // Convertendo para maiúsculas
    for (char &c : item) {
        c = toupper(c);
    }
    
    // Buscando substring
    size_t pos = item.find("MÁGICA");
    if (pos != std::string::npos) {
        std::cout << "Item especial encontrado na posição " << pos << std::endl;
    }
    
    std::cout << "Item final: " << item << std::endl;
    
    return 0;
}
```

Saída:
```
Item especial encontrado na posição 7
Item final: POÇÃO MÁGICA
```

### Erros comuns e como corrigir

1. **Esquecer #include <string>**:
```
error: 'string' is not a member of 'std'
```

Solução: Sempre inclua `<string>` quando usar `std::string`.

2. **Misturar strings literais C e C++**:
```cpp
std::string nome = "Luigi";
const char* apelido = "Green Mario";

// Erro: não pode concatenar diretamente
// std::string completo = nome + " - " + apelido; // Erro!

// Correto:
std::string completo = nome + " - " + std::string(apelido);
```

3. **Acessar posições inválidas**:
```cpp
std::string vazia;
// std::cout << vazia[0]; // Comportamento indefinido!

// Correto:
if (!vazia.empty()) {
    std::cout << vazia[0];
}
```

### Aplicação em jogos

Strings são essenciais para sistemas de diálogo e interface. Veja um exemplo:

```cpp
#include <iostream>
#include <string>
#include <vector>

void mostrarDialogo(const std::vector<std::string>& linhas) {
    for (const auto& linha : linhas) {
        std::cout << "> " << linha << std::endl;
    }
}

int main() {
    std::vector<std::string> dialogo = {
        "Princesa: Mario, você veio me resgatar!",
        "Mario: Let's-a go!",
        "Bowser: Mwahahaha! Too late, plumber!"
    };
    
    mostrarDialogo(dialogo);
    
    return 0;
}
```

Saída:
```
> Princesa: Mario, você veio me resgatar!
> Mario: Let's-a go!
> Bowser: Mwahahaha! Too late, plumber!
```

### Exercício

Crie um sistema que:
1. Armazene três habilidades de um personagem (ex: "Fireball", "Double Jump", "Spin Attack")
2. Concatene-as em uma string no formato "Habilidades: [1], [2], [3]"
3. Substitua todas as letras 'a' por '@'
4. Exiba o resultado

Solução comentada:

```cpp
#include <iostream>
#include <string>
#include <vector>

int main() {
    // 1. Armazenar habilidades
    std::vector<std::string> habilidades = {"Fireball", "Double Jump", "Spin Attack"};
    
    // 2. Concatenar
    std::string listaHabilidades = "Habilidades: ";
    for (size_t i = 0; i < habilidades.size(); ++i) {
        listaHabilidades += habilidades[i];
        if (i != habilidades.size() - 1) {
            listaHabilidades += ", ";
        }
    }
    
    // 3. Substituir 'a' por '@'
    for (char& c : listaHabilidades) {
        if (c == 'a' || c == 'A') {
            c = '@';
        }

    }
    
    // 4. Exibir
    std::cout << listaHabilidades << std::endl;
    
    return 0;
}
```

Saída:
```
H@bilid@des: Fireb@ll, Double Jump, Spin @tt@ck
```