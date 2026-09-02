## Preparação para apresentação das melhorias em portfólio

Trabalho de melhoria em interface existente é, de longe, o melhor material de portfólio que alguém em transição de desenvolvimento pode ter — e é sistematicamente subaproveitado, porque não parece "design de verdade". Não tem tela nova bonita, não tem processo de descoberta completo, não tem produto lançado.

Tem outra coisa, que vale mais para quem contrata: um problema real, com usuários reais, resolvido com restrições reais e resultado mensurado. É exatamente o que um caso de estudo precisa ter, e o que quase todo portfólio júnior não tem.

### Por que esse tipo de caso é forte

Recrutadores da área avaliam **como você pensa**, e um caso de melhoria expõe isso melhor que um redesenho especulativo:

- Mostra que você **diagnostica antes de propor** — a competência mais escassa em candidatos júnior.
- Mostra que você trabalha com **restrição real**: sistema legado, usuários acostumados, orçamento curto, equipe ocupada.
- Tem **antes e depois de verdade**, com dados reais na tela, não com conteúdo escolhido para funcionar.
- Frequentemente tem **número**: tempo de tarefa, chamados, taxa de conclusão.
- Mostra que você sabe **priorizar** e escolher a intervenção proporcional, em vez de propor o ideal impossível.

O contraste é com o caso mais comum em portfólios júnior: o redesenho não solicitado de um aplicativo famoso, sem acesso a usuários, sem restrições, sem métricas e sem implementação. Avaliadores experientes descontam esse tipo de peça justamente porque nenhuma das competências acima aparece nela.

### A estrutura do caso

Seis seções, nesta ordem. A ordem importa mais que o conteúdo.

**1. Contexto e problema (2 a 4 frases).** Que sistema, quem usa, qual problema, com número.

> "Sistema interno de chamados usado por 40 atendentes. A tela principal lista os chamados abertos, e os atendentes relatavam demora para localizar um chamado específico. O suporte registrava, em média, 14 chamados por trimestre relacionados à busca."

**2. Como você diagnosticou.** O método, não a conclusão. É a seção que mais diferencia.

> "Observei três atendentes por 20 minutos cada, executando a tarefa real. Todos usavam a busca do navegador em vez de olhar a tabela. Apliquei o teste do desfoque na captura da tela: nenhum elemento da tabela sobrevivia — todas as colunas com o mesmo peso e cor."

**3. O que você considerou e descartou.** A seção que quase ninguém escreve e que mais impressiona.

> "Considerei adicionar uma busca dentro da tela, mas as pessoas já supriam isso com Ctrl+F — a correção não atacaria a causa. Considerei reduzir o número de colunas, mas todas eram consultadas em algum momento."

**4. A intervenção, com justificativa.** O que foi feito e por quê, ligando à causa diagnosticada.

**5. O resultado, com honestidade.** Número, se houver. Se não houver, diga o que foi validado e como.

**6. O que você faria diferente.** Curta, específica, e rara em portfólios júnior.

> "Não medi a linha de base antes de começar a mexer no CSS; tive que reconstruí-la depois, com uma comparação moderada. Hoje eu mediria antes de tocar em qualquer coisa."

### As peças visuais que valem a pena

**O antes e depois lado a lado.** É a peça central, e precisa ser honesta: mesma tela, mesmos dados, mesma resolução. Comparar a tela antiga cheia de dados com a nova com três linhas escolhidas é o tipo de manipulação que um avaliador experiente detecta e que custa credibilidade.

**A captura do diagnóstico.** A tela desfocada, a simulação de deuteranopia, o mapa de calor. Essas imagens mostram método, e método é o que se está avaliando.

**O trecho de gravação, se houver.** Quinze segundos de um usuário travando — desde que anonimizado e com autorização.

**A tabela de priorização.** Se você trabalhou uma lista de melhorias, mostrá-la com impacto, esforço e risco demonstra pensamento de produto, não só de tela.

**O que não incluir:** a lista completa de quarenta achados, os slides internos, o documento de nove campos inteiro. O caso é uma narrativa curta, não um relatório.

### Confidencialidade: o que fazer com trabalho de empresa

A maior parte do trabalho de melhoria acontece em sistemas internos, sob acordo de confidencialidade. Três caminhos legítimos:

1. **Anonimizar.** Substituir nomes de empresa e de clientes por fictícios, alterar valores, borrar logotipos. Manter a estrutura da tela e a variedade dos dados — trocar tudo por "Lorem ipsum" apaga justamente o que torna o caso crível.
2. **Descrever sem mostrar.** "Sistema de gestão de chamados de uma empresa de serviços, 40 usuários internos." Nenhuma captura, apenas esquemas redesenhados que representam a estrutura sem reproduzir a identidade visual.
3. **Pedir autorização.** Frequentemente concedida, especialmente se o material for anonimizado. Vale perguntar antes de assumir que não.

Nunca publique capturas com dados reais de pessoas ou clientes. Além do risco jurídico, é um sinal negativo para quem contrata: mostra que você não considera privacidade.

### O erro que você vai cometer: apresentar o resultado sem o processo

A página do portfólio abre com o antes e depois, seguido de uma lista das mudanças aplicadas: hierarquia na coluna principal, cinzas reduzidos, bordas removidas.

O avaliador vê uma tabela mais bonita. E não vê nada do que ele estava procurando: como você descobriu o problema, por que escolheu essa correção e não outra, e como sabe que funcionou.

O antes e depois é a peça mais atraente e a menos informativa sobre a sua competência. Ele mostra gosto; o diagnóstico mostra pensamento.

A correção é de posicionamento: coloque o problema e o método **antes** das imagens finais, e mantenha o antes-e-depois como evidência do resultado, não como abertura. Se a página precisa de um elemento visual no topo, use a captura do diagnóstico — a tela desfocada com a anotação do que sobrevive é visualmente interessante e já conta que houve método.

### Exercício prático

**Objetivo:** transformar um trabalho de melhoria em caso de portfólio.

1. Escolha a melhoria mais bem documentada do seu trabalho neste capítulo.
2. Escreva as seis seções. Limite: 600 palavras no total.
3. Produza as peças visuais: antes e depois honesto, mais uma captura de diagnóstico.
4. Verifique a confidencialidade: há algo que precisa ser anonimizado ou autorizado?
5. Mostre a página a alguém de fora da área e peça que explique, com as próprias palavras: qual era o problema, o que você fez e como você sabe que funcionou.
6. Se a pessoa não conseguir responder às três, reescreva.

### Solução comentada

O passo 5 tem três perguntas de propósito, e o padrão de falha é sempre na primeira e na terceira.

A pessoa quase sempre consegue dizer **o que você fez** — as imagens contam isso sozinhas. Raramente consegue dizer **qual era o problema**, porque o contexto foi reduzido a uma linha em favor das imagens. E quase nunca consegue dizer **como você sabe que funcionou**, porque a seção de resultado costuma terminar em "ficou mais claro e organizado", que não é resultado, é opinião.

A correção da primeira falha é mover o problema para o topo, com o número, e repeti-lo. A da terceira é mais estrutural: se você não tem número, diga o que tem, com precisão. "Comparação moderada com seis atendentes: tempo médio de localização caiu de 14 para 9 segundos" é um resultado. "Testado com três colegas, que consideraram mais fácil" é fraco, mas honesto — e infinitamente melhor que uma afirmação vaga que soa como número sem ser.

O limite de 600 palavras do passo 2 costuma incomodar e é deliberado. Um caso de portfólio é lido em dois ou três minutos, na melhor das hipóteses, frequentemente em diagonal. A restrição força a escolher o que é essencial, e o que sobrevive ao corte é quase sempre o método e o resultado — que é exatamente o que deveria sobreviver.

Uma observação final sobre a seção 6, o que você faria diferente. Existe um receio natural de que admitir uma falha metodológica enfraqueça a candidatura. O efeito observado é o oposto: em entrevista, essa seção quase sempre vira a pergunta seguinte, e é a oportunidade de demonstrar raciocínio ao vivo. Um candidato que sabe apontar a fragilidade do próprio método demonstra o critério que se está tentando avaliar — e ninguém espera que um trabalho júnior tenha sido metodologicamente perfeito.

---
