## Jornadas do usuário

Imagine que você está desenvolvendo um aplicativo para agendamento de consultas médicas. Seu desafio é garantir que o usuário consiga marcar uma consulta de forma rápida, clara e sem frustrações. Porém, só saber as funcionalidades do app não é suficiente para criar uma experiência fluida. É aí que o **mapa da jornada do usuário** entra em cena: ele revela cada passo que o usuário percorre, mostrando onde ocorrem dificuldades, dúvidas ou insatisfações, mesmo que sutis.

### O que é uma jornada do usuário?

A jornada do usuário é a representação visual e narrativa do caminho que um usuário percorre para atingir um objetivo específico dentro de um produto ou serviço. Ela detalha as ações, pensamentos, emoções e pontos de contato ao longo desse caminho.

Mais do que um simples fluxo, a jornada ajuda a **identificar pontos críticos** — momentos em que o usuário pode se perder, se frustrar ou desistir — e oportunidades para melhorias que impactam diretamente na usabilidade e satisfação.

### Por que mapear a jornada?

Ao mapear a jornada, você:

- Visualiza o processo real do usuário, não apenas o fluxo idealizado pelo time de desenvolvimento.
- Identifica pontos de atrito que não aparecem em dados quantitativos, como confusão na interface ou insegurança.
- Entende as emoções envolvidas em cada etapa, o que impacta a decisão e o engajamento.
- Gera insights para priorizar melhorias e validar hipóteses durante o design thinking.

### Como montar um mapa da jornada do usuário

Vamos criar um mapa para o exemplo do app de agendamento médico, focando na jornada para marcar uma consulta.

1. **Defina o objetivo do usuário**  
   Exemplo: "Marcar uma consulta com o especialista em cardiologia."

2. **Liste as etapas principais que o usuário percorre**  
   Essas etapas são os momentos-chave que o usuário vive. Por exemplo:

   - Abrir o aplicativo  
   - Procurar o especialista  
   - Escolher data e horário  
   - Confirmar dados pessoais  
   - Finalizar agendamento  
   - Receber confirmação

3. **Descreva as ações do usuário em cada etapa**  
   O que ele faz exatamente? Por exemplo, na etapa “Procurar o especialista”, a ação pode ser “digitar o nome do médico” ou “filtrar por especialidade”.

4. **Registre os pensamentos e emoções**  
   O que o usuário está pensando? Está confiante, inseguro, frustrado? Isso mostra as motivações e dificuldades ocultas.

5. **Identifique pontos de contato com o sistema**  
   Onde o usuário interage com o app? Botões, telas, mensagens, notificações.

6. **Anote dificuldades e oportunidades de melhoria**  
   Se o usuário sente dúvida ou demora, este é um ponto crítico a ser aprimorado.

### Exemplo prático: jornada para agendar uma consulta

| Etapa                  | Ações do usuário                         | Pensamentos/Emoções                  | Pontos de contato                   | Dificuldades / Oportunidades          |
|------------------------|-----------------------------------------|------------------------------------|------------------------------------|--------------------------------------|
| Abrir o aplicativo     | Tocar o ícone do app                    | "Espero que esteja rápido."        | Tela inicial                       | Tela demora para carregar             |
| Procurar o especialista| Digitar “cardiologista” na busca        | "Será que tem algum bom na minha cidade?" | Campo de busca                   | Filtro por cidade não é claro         |
| Escolher data e horário| Selecionar data no calendário, horário  | "Quero algo que encaixe no meu trabalho." | Calendário, lista de horários    | Horários indisponíveis não desabilitados|
| Confirmar dados pessoais| Revisar e editar informações            | "Meus dados estão corretos?"       | Formulário de dados                | Campos obrigatórios não marcados      |
| Finalizar agendamento  | Tocar botão “Confirmar”                  | "Será que vai dar certo?"          | Botão de confirmação               | Mensagem de erro vaga ao falhar       |
| Receber confirmação    | Ler mensagem e e-mail de confirmação    | "Ótimo, está tudo certo."          | Tela de confirmação, e-mail       | Notificação demora a chegar            |

### Erro comum: ignorar as emoções e dificuldades reais

Imagine um time que desenha um fluxo apenas com as telas do app, achando que isso basta. Eles criam um botão para “Confirmar”, mas não percebem que o texto do botão está confuso para o usuário, que teme estar cometendo um erro ao confirmar seus dados. Quando o app retorna uma mensagem genérica de erro, o usuário desiste.

Esse erro comum ocorre porque o time não mapeou a jornada do usuário de forma detalhada, incluindo os pensamentos e emoções, nem registrou os pontos onde o usuário pode se sentir inseguro. Sem isso, o design não resolve as dores reais, resultando em frustração e abandono.

### Como evitar esse erro

- Converse com usuários reais para entender o que sentem em cada etapa.
- Use post-its ou ferramentas digitais para mapear ações, pensamentos e emoções.
- Revise o mapa com a equipe multidisciplinar para captar diferentes perspectivas.
- Priorize melhorias nos pontos críticos identificados.

### Exercício prático

Escolha uma tarefa simples que você realiza em um aplicativo ou site popular (exemplo: comprar um ingresso, cadastrar um perfil, pedir um delivery). Mapeie a jornada do usuário para essa tarefa seguindo os passos:

1. Defina claramente o objetivo do usuário.
2. Liste as etapas principais.
3. Para cada etapa, descreva:
   - Ação do usuário
   - Pensamento ou emoção
   - Ponto de contato
   - Possível dificuldade ou oportunidade de melhoria

**Solução comentada para o exemplo “Comprar ingresso de cinema”**

| Etapa                   | Ação do usuário                      | Pensamento/Emoção                  | Ponto de contato              | Dificuldade/Oportunidade               |
|-------------------------|------------------------------------|----------------------------------|------------------------------|---------------------------------------|
| Abrir app de cinema      | Tocar ícone do app                  | "Quero ir ao filme hoje."        | Tela inicial                 | Carregamento lento                    |
| Escolher filme           | Navegar ou buscar filme             | "Qual está em sessão hoje?"      | Lista de filmes              | Filtro de horários pouco visível     |
| Selecionar sessão        | Escolher data e horário             | "Quero o melhor horário para mim"| Calendário e lista de sessões| Sessões esgotadas não ficam claras    |
| Selecionar assentos      | Escolher assentos no mapa           | "Quero sentar perto da tela."    | Mapa interativo de assentos  | Mapa não indica claramente os assentos ocupados |
| Confirmar pagamento      | Inserir dados e finalizar compra   | "Espero que seja seguro."        | Formulário de pagamento      | Campos obrigatórios pouco claros     |
| Receber ingresso        | Visualizar e salvar ingresso       | "Pronto, está tudo certo."       | Tela de confirmação e e-mail | Notificação demora para chegar       |

Esse exercício ajuda a perceber que, mesmo em tarefas simples, o usuário passa por várias etapas emocionais e técnicas que devem ser consideradas no design.

---