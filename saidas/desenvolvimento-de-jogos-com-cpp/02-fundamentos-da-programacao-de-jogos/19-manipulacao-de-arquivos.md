## Manipulação de arquivos

No desenvolvimento de jogos, frequentemente precisamos carregar configurações, salvar progresso ou ler dados de níveis. Imagine um jogo de plataforma onde cada fase é definida em um arquivo texto contendo a disposição dos blocos - sem manipulação de arquivos, teríamos que hardcodear tudo no programa.

O C++ oferece três principais classes para manipulação de arquivos no cabeçalho `<fstream>`:
- `ifstream` para leitura (input file stream)
- `ofstream` para escrita (output file stream)
- `fstream` para ambas operações

Vamos começar criando um arquivo de configuração simples para um jogo. Suponha que queremos salvar a última pontuação alta e as configurações de áudio:

```cpp
#include <fstream>
#include <iostream>

void SalvarConfiguracao() {
    std::ofstream arquivo("config.cfg");
    
    if (arquivo.is_open()) {
        arquivo << "highscore=12500\n";
        arquivo << "volume_musica=80\n";
        arquivo << "volume_efeitos=90\n";
        arquivo.close();
        std::cout << "Configuração salva com sucesso!\n";
    } else {
        std::cerr << "Erro ao criar arquivo de configuração!\n";
    }
}
```

Ao executar este código, será criado o arquivo `config.cfg` com o conteúdo:
```
highscore=12500
volume_musica=80
volume_efeitos=90
```

Um erro comum é esquecer de verificar se o arquivo foi aberto com sucesso. Se tentarmos escrever em um arquivo que não pode ser aberto (por falta de permissões, por exemplo), o programa continuará executando sem erros aparentes, mas os dados não serão salvos.

Para ler esses dados de volta, usamos `ifstream`:

```cpp
void CarregarConfiguracao() {
    std::ifstream arquivo("config.cfg");
    std::string linha;
    
    if (arquivo.is_open()) {
        while (getline(arquivo, linha)) {
            size_t pos = linha.find('=');
            if (pos != std::string::npos) {
                std::string chave = linha.substr(0, pos);
                std::string valor = linha.substr(pos + 1);
                
                std::cout << "Chave: " << chave << ", Valor: " << valor << "\n";
            }
        }
        arquivo.close();
    } else {
        std::cerr << "Arquivo de configuração não encontrado!\n";
    }
}
```

A saída será:
```
Chave: highscore, Valor: 12500
Chave: volume_musica, Valor: 80
Chave: volume_efeitos, Valor: 90
```

Na Unreal Engine, o processo é similar mas utiliza classes próprias para maior integração com o editor. Vamos criar um sistema simples para salvar a posição do jogador:

```cpp
#include "Misc/FileHelper.h"
#include "HAL/PlatformFilemanager.h"

void SalvarPosicaoJogador(FVector Posicao) {
    FString Conteudo = FString::Printf(TEXT("%f,%f,%f"), Posicao.X, Posicao.Y, Posicao.Z);
    FFileHelper::SaveStringToFile(Conteudo, TEXT("PosicaoJogador.save"));
}

FVector CarregarPosicaoJogador() {
    FString Conteudo;
    FVector Posicao(0, 0, 0);
    
    if (FFileHelper::LoadFileToString(Conteudo, TEXT("PosicaoJogador.save"))) {
        TArray<FString> Partes;
        Conteudo.ParseIntoArray(Partes, TEXT(","));
        
        if (Partes.Num() == 3) {
            Posicao.X = FCString::Atof(*Partes[0]);
            Posicao.Y = FCString::Atof(*Partes[1]);
            Posicao.Z = FCString::Atof(*Partes[2]);
        }
    }
    
    return Posicao;
}
```

Um erro frequente ao trabalhar com arquivos é não considerar os diferentes sistemas operacionais. No Windows, caminhos usam `\`, enquanto Linux/Mac usam `/`. A Unreal resolve isso com a classe `FPaths`:

```cpp
#include "Misc/Paths.h"

FString CaminhoCompleto = FPaths::ProjectDir() + TEXT("Config/") + TEXT("jogador.cfg");
```

**Exercício**: Crie um sistema para salvar o inventário do jogador, onde cada item é armazenado como "nome=quantidade" em um arquivo. Implemente funções para adicionar itens, remover itens e listar todo o inventário.

**Solução comentada**:

```cpp
#include <map>
#include <fstream>
#include <algorithm>

std::map<std::string, int> inventario;

void CarregarInventario() {
    std::ifstream arquivo("inventario.save");
    std::string linha;
    
    inventario.clear();
    
    if (arquivo.is_open()) {
        while (getline(arquivo, linha)) {
            size_t pos = linha.find('=');
            if (pos != std::string::npos) {
                std::string item = linha.substr(0, pos);
                int quantidade = std::stoi(linha.substr(pos + 1));
                inventario[item] = quantidade;
            }
        }
        arquivo.close();
    }
}

void SalvarInventario() {
    std::ofstream arquivo("inventario.save");
    
    if (arquivo.is_open()) {
        for (const auto& par : inventario) {
            arquivo << par.first << "=" << par.second << "\n";
        }
        arquivo.close();
    }
}

void AdicionarItem(const std::string& item, int quantidade) {
    inventario[item] += quantidade;
    SalvarInventario();
}

void RemoverItem(const std::string& item, int quantidade) {
    if (inventario.find(item) != inventario.end()) {
        inventario[item] = std::max(0, inventario[item] - quantidade);
        if (inventario[item] == 0) {
            inventario.erase(item);
        }
        SalvarInventario();
    }
}

void ListarInventario() {
    for (const auto& par : inventario) {
        std::cout << par.first << ": " << par.second << "\n";
    }
}
```