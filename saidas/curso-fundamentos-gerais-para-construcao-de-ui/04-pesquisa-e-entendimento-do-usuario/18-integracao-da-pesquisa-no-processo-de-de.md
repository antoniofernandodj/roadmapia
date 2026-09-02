## Integração da pesquisa no processo de design

Imagine que você está desenvolvendo uma interface para um aplicativo de agendamento de consultas médicas. Você já tem algumas ideias baseadas na sua experiência e no que “achou” que os usuários precisam. No entanto, sem dados concretos, suas decisões podem levar a um produto que não resolve os verdadeiros problemas do usuário, resultando em baixa adoção e frustração. É justamente para evitar esse cenário que a pesquisa deve ser integrada desde o início e ao longo de todo o processo de design.

### Por que integrar a pesquisa no design?

A pesquisa fornece as evidências necessárias para fundamentar as decisões de design, transformando suposições em dados confiáveis. Quando os resultados da pesquisa são incorporados diretamente na criação das interfaces, o design torna-se centrado no usuário, refletindo suas reais necessidades, comportamentos e contextos. Sem essa integração, o risco de criar soluções desconectadas da realidade do usuário aumenta significativamente.

### Como a pesquisa guia decisões específicas de design

#### 1. Definição clara dos problemas a resolver

A pesquisa qualitativa, como entrevistas e observações, revela as dores, motivações e contextos reais dos usuários. Por exemplo, ao entrevistar pacientes sobre o agendamento de consultas, você pode descobrir que muitos têm dificuldade em lembrar datas e horários por falta de notificações eficazes. Essa informação direciona a criação de lembretes e alertas na interface.

#### 2. Priorização de funcionalidades

Dados quantitativos, como questionários ou análise de uso, mostram o quanto determinadas funções são utilizadas ou desejadas. Suponha que, na pesquisa, 80% dos usuários indicaram que gostariam de visualização rápida dos médicos disponíveis por especialidade. Essa métrica ajuda a priorizar essa funcionalidade no roadmap, evitando desenvolver recursos pouco valorizados.

#### 3. Escolha de elementos visuais e interação

A psicologia cognitiva aplicada ao design (cap. 2) e os dados obtidos nas pesquisas indicam como organizar a interface para facilitar o entendimento. Por exemplo, se a pesquisa mostra que usuários mais velhos têm dificuldades com textos pequenos, o design pode ajustar a tipografia para tamanhos maiores e botões mais evidentes.

#### 4. Validação de hipóteses e protótippos

Após criar wireframes ou protótipos, a pesquisa retorna para validar se as soluções propostas realmente atendem ao usuário. Se testes de usabilidade apontam que o fluxo de agendamento está confuso, o design deve ser ajustado para simplificar etapas e melhorar a navegação.

### Exemplo prático: aplicando resultados da pesquisa

Suponha que, em entrevistas, usuários disseram: "Queria poder salvar meus médicos preferidos para agendar mais rápido". Paralelamente, a análise quantitativa mostrou que 65% deles agendam repetidamente com os mesmos profissionais.

**Decisão de design baseada nesses dados:** incluir um recurso de "favoritos" no aplicativo, facilitando o acesso rápido a esses médicos.

Se ignorarmos essa pesquisa, poderíamos não perceber essa necessidade, e o app perderia uma oportunidade de melhorar a experiência e fidelizar os usuários.

### Como evitar erros comuns na integração

- **Erro:** Desconsiderar dados da pesquisa por acreditar que "seu feeling sabe mais".
  
  **Mensagem de erro na prática:** "Não precisamos disso, sei o que o usuário quer" — que resulta em designs desalinhados.

  **Correção:** Sempre baseie decisões em dados e valide hipóteses com usuários reais, mesmo que questionem suas intuições.

- **Erro:** Usar resultados de pesquisas qualitativas isoladamente, sem cruzar com dados quantitativos.

  **Problema:** Pode levar a conclusões enviesadas, pois a amostra qualitativa pode não representar todo o público.

  **Correção:** Combine os dois tipos para ter visão completa, como nos exemplos de pesquisa combinada.

- **Erro:** Apresentar dados da pesquisa sem relacioná-los diretamente às decisões de design.

  **Problema:** A equipe pode entender os dados, mas não saber como aplicá-los no projeto.

  **Correção:** Sempre traduza insights em ações concretas, como ajustar fluxos, priorizar funcionalidades ou modificar elementos visuais.

### Ferramentas para incorporar pesquisa no design

- **Documentação estruturada:** organize os resultados da pesquisa em tabelas ou matrizes, relacionando cada insight a uma decisão de design específica. Por exemplo:

| Insight da Pesquisa                        | Decisão de Design                          |
|-------------------------------------------|--------------------------------------------|
| Usuários querem salvar médicos favoritos | Criar funcionalidade “Favoritos”           |
| Dificuldade com texto pequeno              | Aumentar tamanho da fonte e botões          |
| Preferência por agendamento rápido         | Simplificar fluxo para menos passos         |

- **Mapas de empatia e personas:** use personas criadas a partir da pesquisa para guiar escolhas durante o design, garantindo foco nos usuários reais.

- **Ferramentas visuais (ex: Miro, Figma):** para integrar visualmente dados da pesquisa em wireframes e protótipos, facilitando a comunicação com a equipe.

### Exercício prático

Você realizou uma pesquisa qualitativa com cinco usuários de um app de compras, que indicaram as seguintes dificuldades:

- "A busca por produtos demora muito para carregar."
- "Não entendo bem se os descontos são cumulativos."
- "Gostaria de uma forma rápida de repetir pedidos anteriores."

Paralelamente, um questionário quantitativo com 50 usuários apontou que:

- 70% reclamam da lentidão da busca.
- 40% não compreendem as promoções.
- 60% repetem pedidos anteriores mensalmente.

**Tarefa:** Com base nesses dados, escreva um plano de decisões de design para melhorar o app. Faça uma tabela relacionando os insights da pesquisa com decisões específicas que você tomaria.

---

### Solução comentada

| Insight da Pesquisa                         | Decisão de Design                              |
|--------------------------------------------|------------------------------------------------|
| Busca demora muito para carregar (70% queixam) | Otimizar backend para acelerar busca; implementar indicador de carregamento para feedback visual. |
| Confusão com descontos (40% usuários)       | Criar explicação clara e visual sobre regras de desconto, evitar linguagem técnica.                |
| Desejo de repetir pedidos anteriores (60%) | Implementar funcionalidade "Repetir pedido" na tela inicial ou histórico de compras.               |

**Comentário:** Ao integrar dados qualitativos e quantitativos, priorizamos otimizações que impactam a maioria dos usuários (ex: busca), enquanto também melhoramos a compreensão das promoções e facilitamos ações frequentes (repetir pedido). Essas decisões são diretamente guiadas pelos resultados da pesquisa, assegurando que o design atende necessidades reais.

---

Essa integração sistemática da pesquisa no processo de design é fundamental para criar interfaces e experiências que sejam úteis, usáveis e desejadas pelos usuários, evitando desperdício de esforço e recursos em soluções baseadas em suposições.