## Exemplos práticos de melhorias em interfaces

Os trechos anteriores tratam de métodos isolados. Aqui eles aparecem juntos, em quatro casos completos: o problema, o diagnóstico, a correção, o custo e o resultado. Os quatro são de escopos diferentes de propósito — do ajuste de uma linha de CSS à revisão de um fluxo inteiro —, porque a lição principal é sobre proporção.

---

### Caso 1: a tabela onde ninguém achava nada

**Situação.** Sistema de gestão de chamados, tela principal com uma tabela de 40 linhas e 8 colunas. Reclamação: "demoro para achar o chamado".

**Diagnóstico.** Teste do desfoque: nada sobrevive dentro da tabela — todas as colunas com o mesmo peso, mesma cor, mesma fonte, separadas por bordas cinza de igual intensidade. Observação com três atendentes: todos usavam `Ctrl+F` do navegador em vez de olhar a tabela.

O problema não era falta de busca. Era ausência de âncora visual: sem uma coluna de identidade destacada, a varredura pré-atentiva não tem onde pousar, e o olho precisa ler célula por célula.

**Correção.** Apenas CSS:
- Coluna "Título do chamado" em peso semibold e cor de texto principal.
- Demais colunas em cinza secundário.
- Números e datas alinhados à direita.
- Bordas horizontais removidas, altura da linha aumentada de 28 para 34 pixels.
- Zebra removida (redundante com o espaçamento).

**Custo.** Uma tarde, incluindo a medição.

**Resultado.** Comparação moderada com seis atendentes, tarefa de localizar um chamado específico: tempo médio caiu de 14 para 9 segundos. Em 40 atendentes com dezenas de buscas diárias, o ganho anual é de centenas de horas.

**A lição.** A intervenção de melhor retorno do capítulo inteiro é dar peso à coluna de identidade em listas densas. Custa uma linha de estilo, não tem risco e não exige reaprendizado.

---

### Caso 2: o pedido que era registrado três vezes

**Situação.** Formulário de pedido com botão "Confirmar". Nos logs, 3% dos pedidos chegavam duplicados ou triplicados, gerando cerca de 12 estornos por mês.

**Diagnóstico.** A requisição levava em média 1,5 segundo, e o botão não mudava em nada durante esse tempo. Gravação de sessão mostrou o padrão: clique, pausa de cerca de um segundo, segundo clique, terceiro clique.

Não era desatenção. É o comportamento previsível quando a interface não confirma em menos de 100 milissegundos: a pessoa conclui que o clique não pegou.

**Correção.**
1. Estado pressionado no `mousedown`, imediato.
2. Botão desabilitado enquanto a requisição está em voo, com o rótulo trocado para "Registrando…" e um indicador.
3. Proteção de idempotência no backend, com chave por requisição — porque nenhuma correção de frontend elimina o duplo clique em conexões instáveis.

**Custo.** Meio dia de frontend, um dia de backend.

**Resultado.** Duplicações caíram a praticamente zero no mês seguinte. Os 12 estornos mensais desapareceram, junto com o trabalho de investigá-los.

**A lição.** O item 3 é o que separa uma correção de interface de uma correção completa. Feedback visual resolve a causa comportamental; a proteção no servidor resolve o caso em que a rede reenvia. As duas juntas.

---

### Caso 3: o rótulo que gerava nove chamados por mês

**Situação.** Um botão chamado "Conciliar" na tela de fechamento. O suporte recebia cerca de nove chamados mensais perguntando o que ele fazia — e, pior, alguns usuários o acionavam achando que era outra coisa.

**Diagnóstico.** Teste dos cinco segundos com seis pessoas: cinco não souberam dizer o que o botão faria. Investigação: "conciliar" era o termo do time financeiro que especificou a funcionalidade; os usuários da tela eram operadores de loja, que chamavam a mesma operação de "conferir o caixa".

**Correção.** Renomear para "Conferir caixa". Manter o termo antigo como sinônimo na busca interna. Aviso de duas linhas na semana anterior.

**Custo.** Uma linha de código, mais meia hora de comunicação.

**Resultado.** Chamados sobre o assunto caíram para um no trimestre seguinte.

**A lição.** Vocabulário é a correção de melhor razão entre impacto e esforço que existe em interface — e é a mais frequentemente ignorada, porque não parece "design". Note também a origem do problema: o rótulo veio de quem especificou, não de quem usa. É um padrão que se repete em praticamente todo sistema corporativo.

---

### Caso 4: o cadastro que perdia metade das pessoas

**Situação.** Formulário de abertura de conta, 28 campos em tela única, 61% de abandono concentrado na segunda metade.

**Diagnóstico.** Analytics mostrou onde as pessoas paravam; observação com cinco participantes mostrou o comportamento: todas rolavam a página inteira antes de começar, e três verbalizaram alguma variação de "quanto falta?". Duas abandonaram no campo de dados bancários, que aparecia sem aviso no meio do formulário.

Dois problemas somados: ausência de percepção de progresso, e uma exigência inesperada surgindo no meio do caminho.

**Correção.** Divisão em três etapas — identificação, endereço, dados bancários — com indicador de progresso **nomeado**, não numerado ("2 de 3: Endereço"), e um aviso na primeira tela informando quais documentos seriam necessários.

Foi validada contra uma alternativa de cinco etapas curtas, que perdeu no teste: os participantes se irritaram por não perceber progresso.

**Custo.** Cerca de duas semanas, incluindo prototipagem, teste com seis participantes e implementação com preservação de estado entre etapas.

**Resultado.** Abandono caiu de 61% para 38% no primeiro mês após a mudança.

**A lição.** Esta é a única das quatro correções que exigiu projeto de verdade, e a única cujo resultado dependeu de validar duas alternativas antes. Note que o número de passos **aumentou** e o abandono caiu — contagem de cliques não é métrica.

---

### O que os quatro têm em comum

**O diagnóstico veio antes da solução, e usou mais de uma fonte.** Em todos, houve observação combinada com dado quantitativo. Nenhum partiu de "essa tela está feia".

**A correção foi proporcional ao problema.** Três dos quatro custaram menos de um dia. Só o quarto exigiu projeto — e foi o único cujo problema era estrutural.

**Houve medição antes e depois.** É o que permitiu afirmar o resultado, e é o que gerou permissão para as melhorias seguintes.

**O ganho maior veio das correções mais baratas.** A tabela, o feedback do botão e o rótulo custaram, somados, menos de dois dias, e resolveram problemas que afetavam todo mundo, todos os dias.

### Exercício prático

**Objetivo:** executar um caso completo, do diagnóstico ao resultado.

1. Escolha um problema pequeno e real de um sistema que você pode alterar (ou propor alteração).
2. Diagnostique com duas fontes: uma observacional e uma quantitativa.
3. Meça a linha de base — um número concreto, antes de qualquer mudança.
4. Proponha a correção mais barata que ataque a causa diagnosticada.
5. Implemente ou prototipe, e valide se houver troca envolvida.
6. Meça de novo, depois de pelo menos duas semanas se estiver em produção.
7. Escreva o caso no formato usado aqui: situação, diagnóstico, correção, custo, resultado, lição.

### Solução comentada

O passo 3, medir a linha de base, é o que costuma ser pulado e o que mais se lamenta depois. Uma vez implementada a mudança, a linha de base é irrecuperável — e sem ela, tudo o que se pode dizer é "acho que melhorou", que não sustenta nada.

O número não precisa ser sofisticado. Cronometrar três pessoas executando a tarefa é linha de base. Contar chamados por assunto nos últimos três meses é linha de base. O critério é ser o **mesmo** número medido depois, nas mesmas condições.

O passo 4, escolher a correção mais barata que ataque a causa, tem uma armadilha que vale antecipar: "mais barata" não é "mais superficial". No Caso 1, a correção barata atacava a causa real (ausência de âncora visual). Uma correção barata que **não** atacasse a causa — adicionar um campo de busca, por exemplo — teria custado pouco e resolvido pouco, porque as pessoas já usavam `Ctrl+F` e continuariam usando.

O passo 7 é o que transforma o exercício em ativo. Esse formato — situação, diagnóstico, correção, custo, resultado, lição — é exatamente a estrutura de um estudo de caso de portfólio, e é a mais convincente que existe para uma vaga júnior: mostra que você diagnostica antes de propor, escolhe a intervenção proporcional, e mede o resultado. Escrever isso enquanto o trabalho está fresco leva vinte minutos; reconstruir seis meses depois é impossível, porque os números e as falas dos usuários já se perderam.

---
