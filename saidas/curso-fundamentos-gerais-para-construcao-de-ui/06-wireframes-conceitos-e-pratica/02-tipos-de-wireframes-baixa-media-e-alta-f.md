## Tipos de wireframes: baixa, média e alta fidelidade

Imagine que você está começando a planejar a interface de um aplicativo. Antes de pensar em cores, fontes ou interações complexas, precisa garantir que a estrutura e o fluxo façam sentido para o usuário e para sua equipe. É aqui que os wireframes entram em cena, mas sua eficácia depende do nível de fidelidade com que são construídos. Saber quando e por que usar cada tipo — baixa, média ou alta fidelidade — é crucial para otimizar o processo de design e evitar retrabalho.

### Wireframes de baixa fidelidade

Os wireframes de baixa fidelidade são os esboços mais simples e rápidos de criar. Geralmente são feitos à mão ou com ferramentas digitais básicas, usando formas geométricas simples (retângulos, linhas) e texto genérico (como “botão”, “imagem”, “menu”). Não há preocupação com detalhes visuais nem precisão no layout.

**Por que usar?**  
- Para explorar ideias iniciais com rapidez e flexibilidade.  
- Para discutir conceitos amplos de arquitetura da informação e navegação.  
- Para envolver stakeholders e receber feedback de forma ágil.  

**O que esperar?**  
Eles não apresentam fidelidade visual ou interativa. São mais parecidos com um mapa mental da interface do que um desenho acabado. Isso pode gerar confusão se alguém tentar interpretar elementos como se fossem finais.

**Exemplo prático:**  
Imagine um wireframe de baixa fidelidade para uma tela de cadastro. Você desenha retângulos para campos de texto e botões, e anota o que cada bloco representa, sem se preocupar com alinhamento exato ou fontes.

```plaintext
[Logo]
[Campo: Nome]
[Campo: E-mail]
[Botão: Enviar]
```

Esse nível permite focar no fluxo e na estrutura, não no visual.

### Wireframes de média fidelidade

Com um wireframe de média fidelidade, você já começa a aproximar a estrutura da interface do formato real, mas ainda sem cores ou detalhes gráficos elaborados. Geralmente, utiliza-se uma grade mais precisa, alinhamentos corretos, ícones simples e texto mais realista. Pode-se incluir elementos básicos de interação, como indicação de botões clicáveis.

**Quando usar?**  
- Para validar a organização dos elementos e a hierarquia da informação.  
- Quando a equipe já tem uma noção clara da estrutura e quer começar a ajustar detalhes funcionais.  
- Para testes iniciais com usuários, focando na usabilidade e fluxo sem distrações visuais.

**O que diferencia da baixa fidelidade?**  
O wireframe é mais rigoroso na disposição dos elementos, facilitando a comunicação com desenvolvedores e designers. Ainda não é um produto visual final, o que mantém a flexibilidade para mudanças.

**Exemplo prático:**  
No wireframe de média fidelidade para a mesma tela de cadastro, você alinha os campos de forma consistente, usa rótulos reais, e indica estados básicos, como campos obrigatórios.

```plaintext
---------------------------------
|        LOGO                   |
---------------------------------
| Nome: [___________________]  |
| E-mail: [_________________]  |
|                             |
| [Enviar]                    |
---------------------------------
* Campos obrigatórios marcados
```

Esse nível já permite testes de usabilidade focados na navegação e no entendimento da interface.

### Wireframes de alta fidelidade

Wireframes de alta fidelidade são quase protótipos visuais — com um detalhamento que pode incluir tipografia, espaçamentos exatos, ícones, paleta de cores neutra e até simulações básicas de interatividade, como navegação entre telas. Eles servem para mostrar exatamente como a interface deve se comportar e parecer, sem ainda serem o design final.

**Por que usar?**  
- Para validar detalhes específicos de layout, espaçamento, alinhamento e fluxo.  
- Para coletar feedback detalhado de stakeholders ou usuários que precisam visualizar um modelo próximo do real.  
- Para facilitar a transição direta para a prototipagem ou desenvolvimento, reduzindo dúvidas.

**Perigo comum:**  
Confundir wireframes de alta fidelidade com mockups ou protótipos finais pode levar a expectativas erradas. Lembre-se que, apesar do detalhamento, o foco ainda está na estrutura e funcionalidade, não no design visual completo.

**Exemplo prático:**  
Na tela de cadastro em alta fidelidade, você inclui fontes reais, ícones de ajuda, botões estilizados, e até uma indicação visual de erro para campos vazios ou inválidos.

```plaintext
------------------------------------------------
| [LOGO]                                       |
------------------------------------------------
| Nome: [José da Silva         ] *             |
| E-mail: [jose@email.com      ] *             |
|                                              |
| [Enviar]                                     |
|                                              |
| * Campos obrigatórios                        |
| [!] Por favor, preencha os campos corretamente|
------------------------------------------------
```

Aqui, a interface se aproxima do produto final, pronta para testes finais e revisão detalhada.

### Quando escolher cada tipo de wireframe

| Nível de fidelidade | Objetivo principal                     | Tempo de criação | Feedback esperado                  | Uso típico                        |
|--------------------|--------------------------------------|------------------|----------------------------------|----------------------------------|
| Baixa fidelidade    | Explorar ideias rapidamente           | Minutos          | Conceitual, estrutura geral      | Brainstorm, alinhamento inicial  |
| Média fidelidade    | Validar organização, fluxo e usabilidade | Horas            | Funcional, layout estrutural     | Testes iniciais, comunicação com dev/designers |
| Alta fidelidade     | Refinar detalhes, simular interação  | Dias             | Visual, usabilidade detalhada    | Aprovação final, transição para prototipagem |

### Erro comum e solução prática

**Erro:** Desenvolvedores ou designers iniciantes tentam criar wireframes de alta fidelidade logo no começo do projeto, investindo muito tempo em detalhes visuais sem antes validar a estrutura. Isso pode atrasar o projeto e dificultar mudanças.

**Mensagem típica:**  
> "Por que estamos gastando tanto tempo desenhando o visual se ainda não temos certeza da navegação?"  

**Correção:**  
Comece pelo wireframe de baixa fidelidade para testar rapidamente a estrutura e o fluxo. Só avance para média e alta fidelidade após validar os aspectos essenciais da arquitetura de informação e navegação.

### Exercício prático

Crie três versões do wireframe para a tela inicial de um app de lista de tarefas:  
1. **Baixa fidelidade:** Use papel, caneta, ou uma ferramenta simples para esboçar blocos e funções básicas.  
2. **Média fidelidade:** Organize os elementos, use texto realista e defina botões e campos com alinhamento correto.  
3. **Alta fidelidade:** Adicione detalhes como ícones, indicação de estados (ex.: tarefa concluída), e mensagens de erro.

**Solução comentada:**  
- Na baixa fidelidade, o foco deve estar no posicionamento dos elementos: título, lista, botões principais. Não se preocupe com estética.  
- Na média fidelidade, o texto deve ser legível e organizado, com botões claramente identificáveis (ex: “Adicionar tarefa”, “Editar”). Alinhe os itens para facilitar a leitura.  
- Na alta fidelidade, incorpore pequenos ícones para ações e use marcações para estados (ex: checkbox marcado para tarefas concluídas). Inclua mensagens claras para erros, como ao tentar adicionar tarefa vazia.

Esse exercício ajuda a entender a evolução do wireframe e a importância de cada etapa para um design centrado no usuário e eficiente.

---