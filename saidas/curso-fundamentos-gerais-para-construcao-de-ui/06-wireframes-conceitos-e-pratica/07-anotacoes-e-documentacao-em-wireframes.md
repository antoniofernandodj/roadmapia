## Anotações e documentação em wireframes

Ao criar wireframes, a estrutura visual simplificada da interface é fundamental para planejar a experiência do usuário e a arquitetura da informação. No entanto, o wireframe sozinho nem sempre é suficiente para garantir que todas as intenções de design e decisões sejam compreendidas por todos os envolvidos no projeto. É aí que entram as anotações e a documentação: elas complementam o wireframe com explicações claras, instruções e justificativas, facilitando a comunicação e evitando mal-entendidos.

### Por que anotar e documentar em wireframes?

Wireframes são representações visuais que mostram a disposição dos elementos na interface, mas carecem de detalhes sobre comportamentos, interações específicas ou razões para certas escolhas. Sem anotações, quem recebe o wireframe pode interpretar de formas distintas:

- O que acontece ao clicar em um botão?
- Por que determinado elemento está destacado?
- Qual é o fluxo esperado após essa tela?
- Quais dados o campo de entrada deve aceitar?

Essas dúvidas geram retrabalho, atrasos e problemas na implementação. Anotações claras previnem esses problemas ao registrar o raciocínio do designer e as regras básicas da interface.

### Como fazer anotações eficientes?

O objetivo das anotações é ser claro, objetivo e direto, sem poluir o wireframe visualmente. Algumas práticas essenciais:

- **Posicionar as anotações próximas ao elemento a que se referem**, usando linhas ou setas para indicar relação.
- **Usar linguagem simples e descritiva**, evitando termos técnicos obscuros ou ambíguos.
- **Ser específico sobre comportamento e intenção**, por exemplo: “Este botão abre um modal para cadastro rápido” ou “Campo aceita somente números, formato CPF”.
- **Indicar estados e variações**, como “Botão desabilitado até que o campo ‘email’ seja preenchido corretamente”.
- **Registrar decisões de design importantes**, por exemplo: “Menu lateral fixa para facilitar navegação em telas longas”.
- **Evitar excesso de texto** no wireframe; se necessário, criar um documento complementar para detalhes mais longos.

### Formatos comuns de anotações em wireframes

Embora não foquemos em ferramentas específicas, os formatos mais usados na prática são:

- **Balões ou caixas de texto ao lado dos elementos**, para comentários curtos.
- **Numeração sequencial com referência no wireframe**, quando há muitos comentários, para manter o visual limpo.
- **Tabelas ou listas separadas**, que relacionam números ou códigos do wireframe às explicações detalhadas.
- **Setas ou linhas conectando anotações aos elementos**, para evitar confusão sobre o que está sendo explicado.

### Exemplo prático de anotação em um wireframe simples

Imagine um wireframe para a tela de cadastro de um app de tarefas. Os elementos principais são:

- Campo "Nome"
- Campo "Email"
- Botão "Cadastrar"
- Link "Já tem conta? Faça login"

Um wireframe básico, sem anotações, mostraria caixas para os campos e botões na posição correta. Agora, veja como as anotações melhoram a comunicação:

---

**Wireframe:**

```
+--------------------------------------+
| Cadastro                             |
|                                      |
| Nome: ____________________________  | 1
| Email: ___________________________  | 2
|                                      |
| [ Cadastrar ]                       | 3
|                                      |
| Já tem conta? Faça login             | 4
+--------------------------------------+
```

**Anotações:**

1. Campo "Nome": obrigatório, aceita letras e espaços, máximo 50 caracteres.
2. Campo "Email": obrigatório, valida formato de email, exibe mensagem de erro em caso de inválido.
3. Botão "Cadastrar": desabilitado enquanto os campos obrigatórios não estiverem preenchidos corretamente. Ao clicar, envia dados para API `/user/register`.
4. Link "Já tem conta? Faça login": redireciona para a tela de login. Deve ter estilo de link azul sublinhado.

---

Sem essas anotações, a equipe pode não saber que o botão deve ficar desabilitado ou qual endpoint a função de cadastro deve chamar. Documentar essas informações evita dúvidas que atrasariam o desenvolvimento.

### Erro comum: não documentar comportamento esperado

Um erro frequente é criar um wireframe visualmente correto, mas sem anotações que expliquem o comportamento esperado. Por exemplo, considere o wireframe acima sem as anotações. Um desenvolvedor pode implementar o botão “Cadastrar” sempre ativo, sem validação, ou ignorar a regra do formato do email.

Esse erro gera problemas que só aparecem em testes, aumentando a retrabalho. A mensagem típica de erro na equipe costuma ser:

```
Bug: botão cadastrar não valida campos corretamente.
Revisar wireframe para entender o comportamento esperado.
```

Corrigir isso exige voltar ao design, consumir tempo e recursos. Portanto, inclua anotações desde o início.

### Documentação além das anotações no wireframe

Quando o projeto cresce, anotações isoladas no wireframe podem não ser suficientes. É recomendável criar uma documentação complementar, que pode conter:

- **Descrição geral da tela**: objetivo, público, contexto.
- **Fluxos detalhados**: sequências possíveis, estados das telas.
- **Regras de negócio**: restrições, validações, dependências.
- **Referências de API ou dados**: endpoints, formatos.
- **Notas de usabilidade ou acessibilidade**: comportamentos desejados para todos os usuários.

Essa documentação pode ser vinculada ou associada ao wireframe, garantindo que toda a equipe tenha acesso às informações completas.

### Relacionando anotações a princípios já aprendidos

Lembre-se que as anotações são parte da comunicação no design thinking (cap. 3) e contribuem para a arquitetura da informação clara (cap. 5). Elas ajudam a tornar explícito o raciocínio que sustenta a organização visual, interação e fluxo (cap. 6). Isso fortalece a colaboração entre designers, desenvolvedores e demais stakeholders.

### Exercício prático

Crie um wireframe para a tela de login de um aplicativo, contendo os elementos:

- Campo "Usuário"
- Campo "Senha"
- Botão "Entrar"
- Link "Esqueci minha senha"

Adicione anotações para cada elemento, explicando:

- Tipos de dados aceitos
- Comportamentos esperados (validação, estados do botão)
- Fluxos relacionados (para onde o link redireciona)
- Regras importantes (ex: senha mínima de 8 caracteres)

---

### Solução comentada

**Wireframe:**

```
+--------------------------------------+
| Login                               |
|                                      |
| Usuário: _________________________  | 1
| Senha: ___________________________  | 2
|                                      |
| [ Entrar ]                         | 3
|                                      |
| Esqueci minha senha                 | 4
+--------------------------------------+
```

**Anotações:**

1. Campo "Usuário": obrigatório, aceita texto alfanumérico, sem espaços, máximo 30 caracteres.
2. Campo "Senha": obrigatório, campo oculto (password), mínimo 8 caracteres, exibe mensagem de erro se inválido.
3. Botão "Entrar": desabilitado até que os campos estejam válidos. Ao clicar, envia dados para API `/user/login`.
4. Link "Esqueci minha senha": redireciona para tela de recuperação de senha, onde o usuário pode solicitar redefinição por email.

**Comentários:**

- As anotações deixam claro como deve ser a validação e o comportamento do botão, evitando implementações erradas.
- O link “Esqueci minha senha” é indicado como fluxo alternativo, importante para o desenvolvimento.
- A descrição dos campos evita dúvidas sobre formato e restrições de entrada.

Esse processo garante que o wireframe não seja apenas um desenho, mas um documento vivo que orienta o desenvolvimento e mantém o foco na experiência do usuário.

---

Anotar e documentar wireframes é uma prática simples, mas poderosa para garantir que o design seja entendido e executado conforme o planejado, reduzindo erros, economizando tempo e alinhando toda a equipe em torno dos objetivos do projeto.