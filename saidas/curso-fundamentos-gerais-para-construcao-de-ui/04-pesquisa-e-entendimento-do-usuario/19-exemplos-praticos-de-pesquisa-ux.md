## Exemplos práticos de pesquisa UX

Imagine que você está desenvolvendo um aplicativo para organizar eventos sociais. Sua equipe tem várias ideias para funcionalidades, mas não sabe ao certo o que os usuários realmente precisam, como preferem interagir com o app e quais problemas enfrentam ao planejar eventos. Para evitar criar um produto que ninguém queira usar, você precisa coletar dados reais — e é aí que a pesquisa UX entra.

### Pesquisa qualitativa: Entrevistas simples para entender motivações

Você organiza entrevistas individuais com cinco usuários que frequentemente criam eventos, como aniversários e reuniões de amigos. O objetivo é descobrir quais são as maiores dificuldades deles nesse processo.

**Planejamento rápido do roteiro:**

- Qual o maior desafio ao planejar um evento?
- Como você costuma convidar as pessoas?
- O que poderia facilitar essa tarefa?
- Conte sobre a última vez que organizou um evento.

**Condução da entrevista:**  
Você cria um ambiente tranquilo, evita perguntas que gerem "sim" ou "não" e incentiva o entrevistado a contar histórias. Por exemplo, ao invés de perguntar "Você usa listas para organizar convidados?", você pergunta "Como você gerencia a lista de convidados?".

**Possível erro comum e correção:**  
Se você perguntar "Você acha difícil enviar convites?", provavelmente ouvirá respostas superficiais, como "Não muito". Corrija trocando a pergunta para "Conte uma situação em que enviar convites foi complicado", e o usuário dará exemplos concretos.

**Resultado esperado:**  
Você descobre que muitos usam grupos de WhatsApp para avisar os convidados, mas perdem controle sobre quem confirmou presença, o que gera confusão.

### Pesquisa quantitativa: Questionário estruturado para medir comportamentos

Com base no que ouviu nas entrevistas, você cria um questionário online com perguntas objetivas para 50 usuários, focando em medir a frequência de uso de funcionalidades e preferências.

Exemplo de perguntas:

1. Quantas vezes você organiza eventos por mês?  
   ( ) 1-2  
   ( ) 3-5  
   ( ) Mais de 5  

2. Você usa algum aplicativo para enviar convites?  
   ( ) Sim  
   ( ) Não  

3. Avalie de 1 a 5 a facilidade para acompanhar confirmações de presença.

4. Quais métodos você usa para lembrar os convidados? (marque todas que se aplicam)  
   [ ] WhatsApp  
   [ ] E-mail  
   [ ] Telefonema  
   [ ] Outro: _______

**Análise dos dados:**  
Com Python, você pode gerar gráficos simples para visualizar as respostas, por exemplo, um gráfico de barras para a frequência de eventos e um gráfico de pizza para métodos de convite.

```python
import matplotlib.pyplot as plt

freq = [20, 25, 5]  # número de respostas por categoria
labels = ['1-2', '3-5', 'Mais de 5']

plt.figure(figsize=(6,4))
plt.bar(labels, freq, color='skyblue')
plt.title('Frequência de eventos por mês')
plt.xlabel('Número de eventos')
plt.ylabel('Quantidade de usuários')
plt.show()
```

![Gráfico de barras com frequência de eventos por mês](https://i.imgur.com/4q7uHqP.png)

### Observação direta: capturando o comportamento real

Você convida três usuários para uma sessão onde eles planejam um evento usando o app atual ou ferramentas que costumam usar. Durante a observação, você anota:

- Quais etapas eles executam com facilidade?
- Onde ficam confusos ou param por muito tempo?
- Se tentam atalhos ou soluções improvisadas.

**Erro comum:**  
Achar que o que o usuário diz na entrevista reflete exatamente o que faz na prática. A observação direta pode revelar, por exemplo, que embora digam usar o WhatsApp para convites, na verdade enviam mensagens separadas manualmente para cada pessoa, o que é trabalhoso.

**Registro dos eventos:**  
Durante a sessão, anote timestamps e descrições das ações, como este exemplo:

```python
observacoes = [
    {'tempo': '00:02', 'ação': 'Usuario abre app de eventos'},
    {'tempo': '00:05', 'ação': 'Usuario tenta adicionar convidados, mas não encontra lista'},
    {'tempo': '00:08', 'ação': 'Usuario desiste e abre WhatsApp para enviar convite'},
]
for evento in observacoes:
    print(f"{evento['tempo']} - {evento['ação']}")
```

Saída:

```
00:02 - Usuario abre app de eventos
00:05 - Usuario tenta adicionar convidados, mas não encontra lista
00:08 - Usuario desiste e abre WhatsApp para enviar convite
```

### Análise de concorrência: aprendendo com os outros

Você escolhe dois apps populares de organização de eventos para analisar: App A e App B.

| Critério                 | App A                      | App B                      |
|--------------------------|----------------------------|----------------------------|
| Facilidade para convidar | Lista clara, envio direto  | Confuso, múltiplas telas   |
| Confirmação de presença  | Notificações em tempo real | Atualização lenta           |
| Feedback dos usuários    | Elogios à rapidez          | Reclamações de bugs         |

**Insight:**  
App A usa notificações push para confirmar presença, o que pode ser uma funcionalidade a incorporar no seu produto para resolver o problema identificado nas entrevistas.

### Mapeamento rápido de stakeholders

Além dos usuários finais, identifique outros envolvidos:

- Equipe de marketing: quer recursos para promoções.
- Organizador profissional: precisa de relatórios detalhados.
- Desenvolvedores: buscam funcionalidades fáceis de implementar.

Classifique por poder e interesse para priorizar comunicações:

| Stakeholder          | Poder | Interesse | Estratégia                   |
|----------------------|-------|-----------|-----------------------------|
| Usuários             | Alto  | Alto      | Engajamento constante       |
| Marketing            | Médio | Alto      | Atualizações regulares      |
| Desenvolvedores      | Alto  | Médio     | Reuniões técnicas periódicas|

### Criação de personas a partir dos dados

Com os dados coletados, você cria duas personas:

1. **Ana, 28 anos, organizadora de festas entre amigos:**  
   - Usa WhatsApp para convites, mas quer uma solução que organize confirmações automaticamente.  
   - Frustração: perde tempo com mensagens individuais.

2. **Carlos, 35 anos, organizador profissional de eventos:**  
   - Precisa de relatórios de convidados e confirmações para clientes.  
   - Busca integração com calendário e alertas automáticos.

### Exercício prático

Você está desenvolvendo um app para gerenciamento de tarefas pessoais. Planeje e execute uma mini-pesquisa UX para entender quais dificuldades os usuários têm com os apps atuais. Siga estes passos:

1. Escolha 3 amigos ou colegas para entrevistar. Prepare um roteiro com pelo menos 4 perguntas abertas que explorem frustrações e hábitos no uso de apps de tarefas.

2. Crie um questionário simples com 5 perguntas objetivas para coletar dados quantitativos sobre frequência de uso, funcionalidades favoritas e problemas.

3. Observe uma pessoa usando seu app favorito de tarefas por 10 minutos, anotando problemas ou confusões.

4. Faça uma tabela para comparar dois apps de tarefas, listando pontos fortes e fracos.

5. A partir dos dados, esboce uma persona que represente o usuário típico.

---

### Solução comentada

A entrevista deve focar em perguntas que provoquem narrativas, por exemplo:  
- "Conte sobre a última vez que tentou usar um app de tarefas e não conseguiu completar o que precisava."  
- Evite perguntas que gerem respostas curtas.

No questionário, combine perguntas de múltipla escolha com escalas de satisfação (ex: Likert de 1 a 5). Exemplo:  
- "Com que frequência você usa lembretes em apps de tarefas? (Nunca, Raramente, Às vezes, Frequentemente, Sempre)"

Na observação, concentre-se em captar momentos de hesitação, erros e estratégias alternativas do usuário. Anote tudo com horário e descrição curta.

A tabela de concorrência pode ser simples, com critérios como facilidade de uso, recursos, estética e suporte.

Ao criar a persona, sintetize dados reais, dando nome e contexto para melhor empatia e foco no design.

Esse exercício ajuda a internalizar o processo de pesquisa realista, da coleta de dados à síntese e aplicação no design.

---