## Mapas de site e fluxogramas

Quando projetamos uma interface digital, o desafio inicial é organizar uma grande quantidade de informação de forma que o usuário encontre o que busca sem esforço. A arquitetura de informação já define essa organização, mas para garantir que a estrutura está clara e navegável, usamos representações visuais: os mapas de site e os fluxogramas. Eles são ferramentas fundamentais para planejar, comunicar e validar a estrutura e o fluxo de navegação antes de qualquer desenvolvimento visual detalhado.

### O que é um mapa de site?

Um mapa de site é uma representação hierárquica e estática das páginas ou telas de um sistema digital, mostrando como o conteúdo está organizado e como as seções se relacionam. Pense nele como a planta baixa de uma casa: ele não mostra a decoração, mas revela a disposição dos cômodos e sua conexão — neste caso, as páginas e suas categorias.

Por exemplo, em um e-commerce, o mapa de site pode apresentar o nível superior com Home, Produtos, Sobre Nós, Contato, e dentro de Produtos, as categorias Eletrônicos, Roupas, e Acessórios. Cada uma dessas categorias pode ser subdividida em subcategorias, formando uma árvore de informação.

### Por que criar um mapa de site?

- **Visualizar a estrutura completa:** Ajuda a entender o escopo do projeto e a relação entre as páginas.
- **Detectar problemas de navegação:** Se uma página não está conectada ou está "escondida", o mapa evidencia isso facilmente.
- **Facilitar a comunicação:** Serve como um guia para desenvolvedores, designers e stakeholders alinharem expectativas.
- **Planejar a navegação e rotulagem:** Com o mapa em mãos, é possível definir menus, breadcrumbs e caminhos de navegação lógica.

### Como construir um mapa de site?

1. **Liste todas as páginas e conteúdos principais** do sistema, com base na pesquisa e levantamento de requisitos.
2. **Agrupe páginas relacionadas** em categorias (nível intermediário).
3. **Defina a hierarquia:** páginas principais no topo, subpáginas abaixo.
4. **Conecte as páginas com linhas** que indicam a relação de navegação direta.
5. **Revise para garantir coerência e simplicidade:** evite estruturas muito profundas (mais de 3-4 níveis) para não confundir o usuário.

Exemplo simples de mapa de site em texto:

```
Home
├── Produtos
│   ├── Eletrônicos
│   │   ├── Celulares
│   │   └── Computadores
│   ├── Roupas
│   └── Acessórios
├── Sobre Nós
└── Contato
```

Esse mapa revela a estrutura clara e organizada, facilitando a navegação.

### O que é um fluxograma?

Enquanto o mapa de site mostra a estrutura hierárquica estática, o fluxograma representa o caminho dinâmico que o usuário pode seguir dentro da interface, ilustrando processos, decisões e interações. É uma sequência lógica, indicando o que acontece quando o usuário realiza uma ação.

Imagine um usuário comprando um produto: o fluxograma pode mostrar o fluxo desde a seleção do produto, passando pelo carrinho, checkout, confirmação de pagamento, até a página de agradecimento.

### Por que usar fluxogramas?

- **Visualizar o fluxo de interação:** Entender como o usuário navega e que decisões toma.
- **Identificar gargalos e pontos críticos:** Como páginas que podem gerar confusão ou processos longos demais.
- **Planejar estados e condições:** Por exemplo, o que acontece se o pagamento é recusado ou se o usuário cancela a compra.
- **Comunicar processos complexos de forma clara** para equipes multidisciplinares.

### Como construir um fluxograma?

1. **Defina o ponto inicial** do fluxo (ex: tela inicial, login).
2. **Liste as etapas ou telas que o usuário pode acessar.**
3. **Inclua decisões e condições** com símbolos próprios, normalmente losangos, para indicar escolha ou verificação (ex: "Usuário logado?").
4. **Trace setas para indicar o caminho seguido em cada opção.**
5. **Inclua pontos de término claros** (ex: "Compra finalizada", "Erro de pagamento").

Exemplo básico de fluxograma em pseudocódigo visual:

```
[Início] --> [Tela Home]
    --> [Seleciona Produto]
        --> [Adiciona ao Carrinho]
            --> [Vai para Checkout]
                --> (Pagamento aprovado?)
                    --> Sim --> [Confirmação e Agradecimento]
                    --> Não --> [Erro e Tentar Novamente]
```

### Erros comuns ao criar mapas de site e fluxogramas

- **Mapa de site com hierarquia confusa ou muito profunda:** dificulta a navegação, pois o usuário precisa passar por muitas etapas para chegar ao conteúdo.
- **Fluxograma que ignora decisões importantes:** o fluxo fica linear demais, não contemplando exceções ou erros, o que gera surpresas na implementação.
- **Falta de atualização:** mapas e fluxogramas devem evoluir conforme o projeto; deixar desatualizados compromete seu valor.
- **Representação excessivamente complexa:** usar muitos símbolos e ramificações pode tornar o mapa ou fluxo ilegível.

### Exemplo prático: mapa de site e fluxograma para um blog pessoal

**Mapa de site:**

```
Home
├── Posts
│   ├── Tecnologia
│   ├── Viagens
│   └── Culinária
├── Sobre o Autor
└── Contato
```

**Fluxograma para publicação de um post:**

```
[Início] --> [Tela de Login]
    --> (Login válido?)
        --> Sim --> [Tela de Novo Post]
            --> [Escreve e salva]
            --> (Deseja publicar?)
                --> Sim --> [Publica e mostra post]
                --> Não --> [Salva rascunho]
        --> Não --> [Mostra erro e tenta novamente]
```

### Exercício prático

Imagine que você está projetando a arquitetura de informação para um aplicativo de agendamento de consultas médicas. Baseando-se nos conceitos apresentados, faça:

1. Um mapa de site listando as principais telas e suas hierarquias.
2. Um fluxograma para o processo de agendar uma consulta, considerando as etapas de login, seleção de médico, horário, confirmação e possíveis erros (ex: horário indisponível).

---

### Solução comentada

**Mapa de site possível:**

```
Tela Inicial
├── Login / Cadastro
├── Perfil do Usuário
├── Agendar Consulta
│   ├── Selecionar Especialidade
│   ├── Selecionar Médico
│   ├── Escolher Horário
│   └── Confirmar Agendamento
├── Consultas Agendadas
└── Configurações
```

**Fluxograma para agendamento:**

```
[Início] --> [Login]
    --> (Login válido?)
        --> Não --> [Mostrar erro e tentar novamente]
        --> Sim --> [Selecionar Especialidade]
            --> [Selecionar Médico]
                --> [Escolher Horário]
                    --> (Horário disponível?)
                        --> Não --> [Mostrar erro e voltar para escolher horário]
                        --> Sim --> [Confirmar Agendamento]
                            --> [Mostrar confirmação]
```

**Comentários:**

- O mapa de site mostra a organização das telas, com a seção "Agendar Consulta" subdividida para detalhar o processo.
- O fluxograma evidencia os pontos de decisão críticos, como a validação do login e a disponibilidade do horário, essenciais para a experiência do usuário.
- Esse planejamento prévio evita retrabalho e garante uma navegação lógica e intuitiva.

---

Mapas de site e fluxogramas são peças-chave para estruturar e comunicar a arquitetura da informação, criando bases sólidas para interfaces eficazes e centradas no usuário. Dominar essas ferramentas é fundamental para qualquer desenvolvedor que deseja transitar para UX com segurança e profissionalismo.