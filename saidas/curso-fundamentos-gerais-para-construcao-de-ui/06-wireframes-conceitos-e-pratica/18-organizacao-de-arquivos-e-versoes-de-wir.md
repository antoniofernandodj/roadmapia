## Organização de arquivos e versões de wireframes

Imagine que você está desenvolvendo o wireframe de um aplicativo móvel para organização de tarefas, e após várias reuniões com stakeholders, precisa ajustar fluxos, inserir novas telas e revisar anotações. Se você simplesmente salvar um arquivo por cima do anterior, sem controle, quando um erro surgir ou uma decisão for revertida, será difícil recuperar versões anteriores, entender o que mudou ou justificar escolhas. Esse cenário, comum em projetos reais, gera confusão, retrabalho e desperdício de tempo.

A organização sistemática dos arquivos e o controle de versões dos wireframes são essenciais para manter o projeto claro, colaborativo e gerenciável, sobretudo quando o time cresce ou o projeto avança em complexidade. A seguir, você aprenderá boas práticas para estruturar seus arquivos e controlar versões de wireframes, garantindo transparência, rastreabilidade e facilidade de comunicação.

---

### 1. Estruture seus arquivos com nomenclatura clara e padronizada

Uma organização eficaz começa pela forma como você nomeia e organiza os arquivos. Evite nomes genéricos ou que se confundam, como “wireframe_final.sketch” ou “versão2.fig”, que não dizem muita coisa sobre o conteúdo ou o estágio do arquivo. Isso dificulta o entendimento rápido e provoca erros ao abrir versões erradas.

**Boas práticas para nomes de arquivos:**

- Use o nome do projeto ou funcionalidade principal, seguido da data e do estágio do wireframe.
- Inclua o nível de fidelidade (baixa, média, alta) ou o tipo de wireframe (fluxo, tela específica).
- Utilize um formato padronizado para datas, como AAAAMMDD, para facilitar ordenação automática.
- Exemplo:

```
appTarefas_wireframe_fluxo_20240415_baixaFidelidade.fig
appTarefas_wireframe_telaLogin_20240417_mediaFidelidade.fig
```

Assim, ao abrir a pasta, fica fácil identificar rapidamente qual arquivo corresponde a qual versão e etapa.

---

### 2. Crie uma hierarquia de pastas lógica e consistente

Além da nomenclatura, a organização em pastas também é fundamental. Ela deve refletir o projeto e sua evolução, facilitando o acesso e evitando duplicações desnecessárias.

**Sugestão de estrutura:**

```
/ProjetoAppTarefas
    /wireframes
        /baixa-fidelidade
        /media-fidelidade
        /alta-fidelidade
    /fluxos
    /prototipos
    /documentacao
```

- Coloque wireframes separados por fidelidade, para evitar confusão entre esboços iniciais e versões detalhadas.
- Tenha uma pasta específica para fluxos de navegação, com arquivos que conectam telas e indicam caminhos.
- Separe protótipos e documentação para manter o foco e facilitar a busca.

---

### 3. Controle versões com incrementos explícitos

Mesmo com boas pastas e nomes, você precisará controlar as versões para registrar a evolução do wireframe. Não basta salvar sempre com o mesmo nome, pois perde-se o histórico. Tampouco salve várias versões idênticas com nomes confusos como “wireframe_final_2”.

**Dica:** Use incrementos numéricos ou códigos de versão no nome do arquivo para indicar mudanças:

```
appTarefas_wireframe_telaLogin_v01.fig
appTarefas_wireframe_telaLogin_v02.fig
appTarefas_wireframe_telaLogin_v03.fig
```

Cada nova versão deve representar uma alteração significativa, seja na estrutura, fluxo ou anotações.

---

### 4. Documente mudanças em um arquivo de log ou changelog

Para acompanhar o que foi alterado entre versões, mantenha um arquivo de texto ou planilha simples onde você registre as principais modificações, o motivo e a data. Isso é especialmente útil para projetos longos ou com múltiplos envolvidos.

**Exemplo de entrada de changelog:**

| Versão | Data       | Alteração                                | Responsável |
|--------|------------|-----------------------------------------|-------------|
| v01    | 2024-04-15 | Wireframe inicial da tela de login      | Ana         |
| v02    | 2024-04-17 | Ajuste no fluxo de cadastro              | Pedro       |
| v03    | 2024-04-20 | Inclusão de anotações para validação    | Ana         |

Esse registro evita dúvidas e permite que qualquer membro do time entenda rapidamente a história do projeto.

---

### 5. Evite erros comuns na organização e versionamento

#### Erro: Sobrescrever arquivos antigos sem backup

Se você salvar um arquivo com o mesmo nome várias vezes, o histórico se perde. Isso dificulta voltar atrás em decisões e pode causar perda de trabalho importante.

**Mensagem de erro típico no time:**

> “Abrimos o wireframe e percebemos que as alterações feitas ontem sumiram porque o arquivo foi sobrescrito.”

**Correção:** Sempre salve uma nova versão com incremento, e mantenha backups regulares.

---

#### Erro: Nomes de arquivos confusos ou inconsistentes

Nomes como “wireframe_final2.fig”, “teste.fig”, “versão nova.fig” causam dúvidas e perda de tempo para encontrar a versão correta.

**Correção:** Adote a nomenclatura padronizada com datas e versões, conforme exemplificado acima.

---

#### Erro: Misturar wireframes de fidelidades diferentes no mesmo arquivo ou pasta

Misturar esboços iniciais com wireframes detalhados dificulta o controle e gera confusão sobre qual usar para cada fase do projeto.

**Correção:** Separe arquivos e pastas por níveis de fidelidade.

---

### 6. Use ferramentas digitais com recursos básicos de versionamento

Mesmo sem aprofundar em softwares específicos de controle de versão (como Git), algumas ferramentas para wireframes já oferecem recursos importantes:

- Histórico automático de versões.
- Comentários e anotações para cada versão.
- Possibilidade de restaurar versões anteriores.

Por exemplo, o Figma permite visualizar versões anteriores e comentar diretamente nos arquivos, facilitando a troca dentro do time.

Se usar ferramentas offline, combine a organização manual com backups frequentes e registro de versões.

---

### 7. Integre a organização dos arquivos ao seu fluxo de trabalho

A organização não é um fim em si, mas um suporte para o fluxo de criação, revisão e aprovação dos wireframes:

- Antes de iniciar uma nova fase ou alteração, crie uma nova versão do arquivo.
- Documente as mudanças em um log e compartilhe com o time.
- Use nomes e pastas que facilitem a localização rápida, evitando abrir versões erradas.
- Mantenha o fluxo de feedback estruturado, vinculando versões e comentários.

---

### Exemplo prático de organização e versionamento

Suponha que você esteja trabalhando em um wireframe para o app de tarefas, começando com baixa fidelidade para a tela inicial.

1. Crie a pasta do projeto:

```
/ProjetoAppTarefas/wireframes/baixa-fidelidade/
```

2. Salve o arquivo com o nome:

```
ProjetoAppTarefas_wireframe_telaInicial_20240415_v01.fig
```

3. Após feedback, faça ajustes e salve como:

```
ProjetoAppTarefas_wireframe_telaInicial_20240418_v02.fig
```

4. Documente as alterações em um arquivo `changelog.txt` dentro da pasta principal:

```
v01 - 2024-04-15 - Wireframe inicial da tela inicial, layout básico e navegação simples.
v02 - 2024-04-18 - Ajuste no posicionamento dos botões e inclusão de anotações de fluxo.
```

5. Se for necessário fazer um wireframe de média fidelidade da mesma tela, crie a pasta e salve:

```
/wireframes/media-fidelidade/ProjetoAppTarefas_wireframe_telaInicial_20240420_v01.fig
```

---

### Exercício prático

Crie a organização de arquivos para um projeto fictício chamado "AppNotas", com pelo menos três telas: login, cadastro e lista de notas. Para cada tela, crie duas versões de wireframes (baixa e média fidelidade), e registre as alterações em um arquivo changelog.txt.

**Critérios a cumprir:**

- Pastas e subpastas organizadas e nomeadas claramente.
- Arquivos nomeados com padrão que inclua projeto, tela, fidelidade, data e versão.
- Arquivo changelog.txt com entradas para cada versão, descrevendo as mudanças.
- Simule um erro comum, como salvar duas versões com o mesmo nome, e corrija renomeando e organizando corretamente.

---

### Solução comentada do exercício

1. Estrutura de pastas criada:

```
/AppNotas
    /wireframes
        /baixa-fidelidade
        /media-fidelidade
    /documentacao
```

2. Exemplo de arquivos salvos em `/wireframes/baixa-fidelidade`:

```
AppNotas_wireframe_login_20240425_v01.fig
AppNotas_wireframe_cadastro_20240425_v01.fig
AppNotas_wireframe_listaNotas_20240425_v01.fig
```

3. Versões médias em `/wireframes/media-fidelidade`:

```
AppNotas_wireframe_login_20240427_v01.fig
AppNotas_wireframe_cadastro_20240427_v01.fig
AppNotas_wireframe_listaNotas_20240427_v01.fig
```

4. Arquivo `/documentacao/changelog.txt`:

```
v01 - 2024-04-25 - Criação dos wireframes de baixa fidelidade para login, cadastro e lista de notas.
v01 - 2024-04-27 - Desenvolvimento dos wireframes de média fidelidade para as três telas, com detalhamento de navegação.
```

5. Erro simulado: ao tentar salvar o segundo wireframe de média fidelidade da tela de login, nomeou como `AppNotas_wireframe_login_20240427_v01.fig` sobrescrevendo o anterior. Ao perceber, renomeou para `AppNotas_wireframe_login_20240427_v02.fig` e atualizou o changelog:

```
v02 - 2024-04-27 - Ajuste no wireframe média fidelidade da tela de login, corrigindo posicionamento de campos.
```

---

Manter essa disciplina de organização e versionamento trará transparência, facilidade de comunicação e agilidade no processo de design, preparando você para colaborar com equipes maiores e enfrentar desafios reais de projetos de UI/UX.