## Versionamento de código

Imagine que você está trabalhando no comportamento de um inimigo em seu jogo de plataforma. Você implementa uma inteligência artificial básica, mas depois decide experimentar uma abordagem diferente. Ao testar a nova versão, percebe que a anterior era melhor - mas já sobrescreveu o arquivo original. Como voltar atrás sem perder horas de trabalho? É aqui que o Git se torna essencial.

O Git é um sistema de controle de versão que registra todas as alterações em seus arquivos ao longo do tempo. Vamos configurá-lo para um projeto Unreal Engine. Primeiro, instale o Git (disponível em [git-scm.com](https://git-scm.com/)) e abra o terminal na pasta do seu projeto:

```bash
# Inicializa um repositório Git
git init

# Configura seu nome e email (importante para identificação)
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

Agora, vamos criar um arquivo `.gitignore` para evitar que arquivos temporários da Unreal sejam versionados:

```bash
# .gitignore para projetos Unreal Engine
Binaries/
Intermediate/
Saved/
DerivedDataCache/
*.sln
*.suo
*.opensdf
*.sdf
*.VC.db
*.VC.opendb
```

Para registrar as alterações atuais:

```bash
git add .
git commit -m "Primeiro commit: configuração inicial do projeto"
```

Suponha que você alterou o arquivo `EnemyAI.cpp` para melhorar o comportamento do inimigo. Após testar, quer salvar essa versão:

```bash
# Verifica quais arquivos foram modificados
git status

# Adiciona as alterações específicas
git add Source/MyGame/EnemyAI.cpp

# Registra as alterações com uma mensagem descritiva
git commit -m "Melhoria no algoritmo de perseguição do inimigo"
```

E se você cometer um erro? Digamos que alterou o arquivo errado por engano. O Git mostra a situação atual:

```
$ git status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   Source/MyGame/PlayerController.cpp
        modified:   Source/MyGame/EnemyAI.cpp

no changes added to commit (use "git add" and/or "git commit -a")
```

Para descartar alterações indesejadas em um arquivo:

```bash
git restore Source/MyGame/PlayerController.cpp
```

Uma das funcionalidades mais poderosas são os branches (ramos), que permitem trabalhar em features separadas sem afetar o código principal. Vamos criar um branch para testar um novo algoritmo de pathfinding:

```bash
# Cria e muda para um novo branch
git checkout -b experimental-pathfinding

# Faz suas alterações...
# Testa o novo algoritmo...

# Se funcionar, mescla com o branch principal
git checkout main
git merge experimental-pathfinding

# Se não funcionar, simplesmente descarta o branch
git branch -d experimental-pathfinding
```

Ao trabalhar em equipe, você precisará sincronizar seu código com um repositório remoto. No GitHub, GitLab ou similar, crie um novo repositório e vincule-o ao seu projeto local:

```bash
git remote add origin https://github.com/seu-usuario/meu-jogo.git
git push -u origin main
```

Um erro comum é esquecer de atualizar o repositório local antes de trabalhar:

```
$ git push
To https://github.com/seu-usuario/meu-jogo.git
 ! [rejected]        main -> main (non-fast-forward)
error: failed to push some refs to 'https://github.com/seu-usuario/meu-jogo.git'
```

A solução é puxar as alterações remotas primeiro:

```bash
git pull origin main
# Resolva eventuais conflitos...
git push origin main
```

**Exercício Prático:**
1. Crie um novo branch chamado `enemy-attack`
2. Modifique o arquivo `EnemyAI.cpp` para implementar um novo sistema de ataque
3. Comite as alterações com uma mensagem descritiva
4. Volte para o branch `main` e veja que suas alterações não estão lá
5. Mescle o branch `enemy-attack` com `main`

**Solução:**

```bash
git checkout -b enemy-attack
# Edite EnemyAI.cpp...
git add EnemyAI.cpp
git commit -m "Implementa novo sistema de ataque para inimigos"
git checkout main
git merge enemy-attack
```