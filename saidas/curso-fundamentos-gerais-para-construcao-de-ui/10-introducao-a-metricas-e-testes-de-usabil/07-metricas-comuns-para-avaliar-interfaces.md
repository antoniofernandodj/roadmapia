## Métricas comuns para avaliar interfaces

Há um conjunto pequeno de métricas que cobre a maior parte das perguntas sobre uma interface. Conhecê-las bem — o que cada uma mede, o que ela não mede, e como calculá-la sem ambiguidade — vale mais que conhecer trinta superficialmente.

Este é o repertório de trabalho, organizado pelo que cada grupo responde.

### Eficácia: a pessoa consegue?

**Taxa de conclusão.** A porcentagem de participantes que concluíram a tarefa sem ajuda. É a métrica mais importante, e a primeira a olhar: se a pessoa não consegue concluir, nenhuma outra métrica importa.

A definição precisa de duas decisões: o que conta como conclusão (chegou à tela final? o registro foi criado corretamente?) e como tratar quem recebeu ajuda (recomendado: contar separadamente, como "concluiu com ajuda", nunca como sucesso).

**Taxa de erro.** Quantas ações incorretas por tarefa. Um erro é uma ação que afasta do objetivo — clicar no menu errado, preencher o campo errado, submeter dados inválidos.

**Taxa de acerto do primeiro clique.** Onde a pessoa clica primeiro, em cada tela. Barata de coletar, forte como preditor: acertar o primeiro clique correlaciona-se bem com concluir a tarefa.

### Eficiência: a que custo?

**Tempo até a conclusão.** Do momento em que a tela está pronta até a tarefa terminar. Só é comparável entre versões da **mesma** tarefa, com o mesmo enunciado, e é sensível a fatores externos — a pessoa que conversa enquanto executa demora mais sem que a interface seja pior.

**Tempo até o primeiro clique certo.** Isola a parte de busca e decisão, sem a execução. É frequentemente mais informativa que o tempo total, porque o tempo total mistura procurar com digitar.

**Número de passos.** Cliques, telas, campos. Útil como descrição do fluxo, ruim como meta — as pessoas percorrem sete passos claros e desistem no terceiro ambíguo. A "regra dos três cliques" não tem suporte em evidência.

**Hesitações.** Contagem de pausas maiores que três segundos. É o indicador mais sensível de atrito e o único que **localiza** o problema, em vez de apenas sinalizar que existe.

### Satisfação: como foi percebido?

Aqui as métricas são declaradas, e valem pelo que são — percepção, que afeta adoção, e não medida de usabilidade.

**SEQ (Single Ease Question).** Uma pergunta, aplicada logo após cada tarefa: "no geral, quão difícil ou fácil foi realizar esta tarefa?", em escala de 1 (muito difícil) a 7 (muito fácil). É a métrica de satisfação com melhor relação entre custo e valor: uma linha, aplicada na hora, comparável entre versões.

**SUS (System Usability Scale).** Dez afirmações com escala de concordância, produzindo uma nota de 0 a 100. É o instrumento padronizado mais usado, com décadas de dados de comparação — a média histórica fica em torno de 68, o que dá referência. Aplica-se ao sistema como um todo, ao fim da sessão, e leva dois minutos.

**NPS.** Mede intenção de recomendar. É métrica de relacionamento com a marca, não de usabilidade — usá-la para avaliar uma tela é o erro de escolha de métrica mais comum em produto.

### Métricas de produção

Quando o sistema já está no ar, três fontes que não exigem sessão:

**Taxa de abandono por etapa.** Em fluxos sequenciais, mostra onde as pessoas param. É o argumento mais direto que existe.

**Chamados de suporte por assunto.** Já vêm quantificados e com custo conhecido pela organização.

**Cliques em elementos não clicáveis e cliques repetidos.** Vindos de ferramentas de mapa de calor, revelam expectativa frustrada e ausência de feedback.

### Como reportar cada uma

| Métrica | Amostra pequena (< 20) | Amostra grande |
|---|---|---|
| Conclusão | "4 de 6" | "68% (n=340)" |
| Tempo | Mediana, não média | Média com dispersão |
| SEQ | Valores individuais | Média |
| Erros | Contagem absoluta | Média por tarefa |

A primeira coluna é a regra que mais se viola: **com menos de vinte participantes, use números absolutos**. "67% dos usuários" com seis pessoas é tecnicamente verdadeiro e materialmente enganoso — dá a um dado qualitativo a aparência de medida estatística.

Sobre tempo: use a **mediana** com amostras pequenas. Um participante que se distrai e leva quatro minutos onde os outros levaram quarenta segundos desloca a média inteira; a mediana resiste.

### O erro que você vai cometer: medir o que é fácil em vez do que importa

O tempo é fácil de cronometrar. O número de cliques é fácil de contar. Ambos aparecem em quase todo relatório de teste, e ambos são frequentemente irrelevantes para a pergunta que motivou o teste.

O caso típico: o relatório informa que a nova versão reduziu o tempo médio de 47 para 38 segundos. Parece bom. E omite que, na versão nova, dois de seis participantes **não concluíram** — e os que não concluem não entram na média de tempo, porque não há tempo de conclusão para eles.

Isso não é manipulação deliberada; é a consequência de olhar a métrica fácil primeiro. Mas produz uma conclusão invertida: a versão com tempo melhor era pior.

A ordem correta de leitura é sempre a mesma:

1. **Conclusão** — quantos conseguiram?
2. **Erros** — quantos tropeçaram no caminho?
3. **Tempo** — quanto custou, entre os que conseguiram?
4. **Satisfação** — como foi percebido?

Tempo é a terceira, nunca a primeira, e só faz sentido comparar tempos entre grupos com taxa de conclusão semelhante.

### Exercício prático

**Objetivo:** montar e aplicar um conjunto de métricas coerente.

1. Escolha uma tarefa de um fluxo seu.
2. Selecione **quatro** métricas: uma de eficácia, uma de eficiência, uma de satisfação e uma de produção (ou a que você instrumentaria se pudesse).
3. Escreva a definição operacional de cada uma: o que conta, o que não conta, quando começa e termina a medição.
4. Colete com cinco participantes.
5. Reporte no formato correto para o tamanho da amostra — absolutos, mediana para tempo.
6. Leia os resultados na ordem: conclusão, erros, tempo, satisfação. A conclusão muda dependendo da ordem?

### Solução comentada

O passo 6 costuma produzir a lição principal, e ela aparece quando os números discordam entre si.

O caso mais frequente: a taxa de conclusão é baixa e o SEQ é alto. As pessoas não concluíram e disseram que foi fácil. Isso não é contradição nem participante confuso — é um achado específico e conhecido: **as pessoas frequentemente não percebem que falharam**. Elas acham que concluíram, ou concluíram algo diferente do pedido, ou atribuem a dificuldade a si mesmas e avaliam a tarefa como fácil por educação.

Quando isso acontece, o dado de comportamento manda. E o próprio descompasso é informação valiosa para o produto: um fluxo em que as pessoas falham sem perceber é mais perigoso que um em que falham e sabem — porque no primeiro caso ninguém pede ajuda, ninguém abre chamado, e o erro chega silenciosamente ao resultado.

O passo 3, a definição operacional, é onde o exercício costuma revelar ambiguidades que pareciam inexistentes. "Tempo até a conclusão" precisa dizer se o cronômetro para quando a pessoa clica em "Confirmar" ou quando a tela de sucesso aparece — e, se o sistema demora dois segundos, essa diferença é 5% do tempo total. "Erro" precisa dizer se voltar uma tela conta como erro ou como exploração legítima.

Nenhuma dessas escolhas é mais certa que a outra. O que importa é que seja **a mesma** nas duas medições que você vai comparar — porque, se mudar entre o antes e o depois, você mediu a própria definição.

---
