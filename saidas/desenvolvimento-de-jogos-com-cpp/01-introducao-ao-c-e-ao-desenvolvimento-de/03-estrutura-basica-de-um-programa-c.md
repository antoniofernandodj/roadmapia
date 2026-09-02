## Estrutura básica de um programa C++

Imagine que você está construindo um robô para um jogo. Antes de adicionar braços mecânicos ou sensores, precisa da estrutura básica que faz ele "existir". Em C++, todo programa começa com essa estrutura essencial - mesmo os jogos mais complexos da Unreal Engine.

Vamos criar nosso primeiro programa completo que exibe uma mensagem na tela:

```cpp
#include <iostream>

int main()
{
    std::cout << "Meu personagem acabou de nascer no jogo!" << std::endl;
    return 0;
}
```

Quando executado, este programa mostrará:
```
Meu personagem acabou de nascer no jogo!
```

Vamos dissecar cada parte:

1. `#include <iostream>` - Esta é a "caixa de ferramentas" que nos permite mostrar texto na tela. Sem ela, o computador não entenderia comandos como `cout`. É como o Starter Content da Unreal Engine que você já configurou.

2. `int main()` - Aqui começa a ação. Todo programa C++ precisa desta função, que é como o botão "Play" no editor da Unreal Engine. O computador começa executando o que está dentro das chaves `{}` logo após.

3. `std::cout` - Este é o comando para "falar" com o jogador. O `<<` envia o texto para a tela. Pense como o sistema de diálogos em um RPG.

4. `std::endl` - Cria uma nova linha, como quando você pressiona Enter em um editor de texto.

5. `return 0;` - Diz ao sistema que tudo terminou corretamente. Zero significa "sem erros".

Um erro comum é esquecer o ponto-e-vírgula no final das linhas. Se você fizer:

```cpp
std::cout << "Erro à vista!" << std::endl  // Falta o ;
```

O compilador vai reclamar:
```
error: expected ';' before 'return'
```

Na Unreal Engine, quando esquecer um símbolo essencial, os erros serão parecidos - a engine usa o mesmo compilador C++ por baixo dos panos.

Vamos modificar o programa para algo mais relacionado a jogos:

```cpp
#include <iostream>

int main()
{
    std::cout << "Inicializando motor de física..." << std::endl;
    std::cout << "Carregando modelos 3D..." << std::endl;
    std::cout << "Jogo pronto para iniciar!" << std::endl;
    return 0;
}
```

Saída:
```
Inicializando motor de física...
Carregando modelos 3D...
Jogo pronto para iniciar!
```

Isso simula o que a Unreal Engine faz quando você inicia um projeto. Na verdade, quando você clica "Play" no editor, ele está chamando uma função `main()` mais complexa que vem com a engine.

**Exercício**: Crie um programa que mostre a sequência de inicialização de um jogo de plataforma, incluindo:
1. Verificação de controles
2. Carregamento de cenário
3. Spawn do personagem principal

Solução comentada:

```cpp
#include <iostream>

int main()
{
    // Sequência típica de um jogo de plataforma
    std::cout << "1. Verificando controles do jogador..." << std::endl;
    std::cout << "2. Carregando tiles do cenário..." << std::endl;
    std::cout << "3. Criando instância do heroi..." << std::endl;
    std::cout << "4. Iniciando loop principal do jogo!" << std::endl;
    return 0;
}
```

Cada `cout` representa uma etapa crítica que a Unreal Engine gerencia quando você cria um projeto. Mais adiante, veremos como essas linhas se transformam em funções reais da engine.