## Criação de personas para o projeto

Você tem cinco a oito entrevistas, um caderno de falas literais e uma lista de padrões. Persona é o instrumento que comprime esse material em algo que cabe na cabeça de quem vai tomar decisões de design — inclusive você, daqui a três semanas, quando os detalhes das conversas já tiverem se apagado.

E é também o artefato de UX mais mal utilizado que existe. A versão inútil — nome bonito, foto de banco de imagens, "gosta de viajar e tomar café" — não ajuda em decisão nenhuma. A versão útil é feita de outra coisa.

### O que entra e o que não entra

| Entra | Não entra |
|---|---|
| Comportamento observado nas entrevistas | Traços de personalidade genéricos |
| Objetivo concreto ao usar o produto | Hobbies e preferências irrelevantes |
| Contexto de uso (onde, quando, com que pressa) | Foto de banco de imagens |
| Frustrações citadas, com fala literal | Marcas favoritas |
| Nível de familiaridade com tecnologia | Renda, salvo se afetar a decisão |
| Ferramentas e contornos que usa hoje | Uma biografia inventada |

O critério que decide cada linha: **essa informação mudaria alguma decisão de design?** Se não muda, é ruído — e ruído numa persona é pior que ausência, porque dá aparência de rigor a um documento decorativo.

### Quantas personas

Para um projeto do tamanho deste, **uma ou duas**. Uma se os participantes se comportaram de forma parecida; duas se apareceram dois padrões claramente distintos.

O sinal de que são duas personas e não uma: os dois grupos têm **objetivos diferentes** ou **contextos de uso diferentes**, e uma decisão de design que ajuda um atrapalha o outro. Idade e profissão diferentes não bastam — se duas pessoas de perfis distintos fazem a mesma coisa, pelo mesmo motivo, na mesma situação, são uma persona só.

Três ou mais personas, num projeto pequeno, quase sempre significam que você segmentou por características demográficas em vez de comportamento.

### O formato que funciona

```
PERSONA 1 — Marcos, paciente em tratamento contínuo
Baseada em: P1, P3, P4, P6 (4 de 6 participantes)

CONTEXTO
Faz fisioterapia 3× por semana há 4 meses. Trabalha em horário comercial;
consegue ligar para a clínica apenas no intervalo do almoço.
Usa o celular para quase tudo; nunca usou o site da clínica.

OBJETIVO
Manter o tratamento em dia sem que ele atrapalhe o trabalho.

COMPORTAMENTO OBSERVADO
• Guarda os horários em uma foto do papel que a clínica entrega (4 de 4)
• Coloca alarme no dia anterior (3 de 4)
• Quando precisa remarcar, liga várias vezes e às vezes desiste (4 de 4)
• Já perdeu sessão por não conseguir remarcar a tempo (2 de 4)

FRUSTRAÇÃO PRINCIPAL
"Marcar é fácil. Mudar é que é o problema." (P3)

CONTORNO ATUAL
Foto do papel + alarme. Nenhum registro no sistema da clínica.

O QUE ISSO IMPLICA PARA O DESIGN
• A remarcação precisa ser mais acessível que a marcação — não o contrário
• Os próximos horários precisam estar visíveis sem login complexo
• Precisa funcionar bem em celular, com uma mão, em pouco tempo
```

A última seção é a que transforma persona em ferramenta. Sem ela, o documento é uma descrição; com ela, é um conjunto de critérios que você vai consultar ao decidir a hierarquia de cada tela.

E a linha "baseada em" é o que separa uma persona de uma invenção: ela diz de quais participantes reais o perfil foi extraído, e quantos.

### Como derivar das entrevistas

O processo, em três passos concretos:

**1. Extraia os comportamentos.** Percorra as folhas de registro e liste cada comportamento observado, com o participante. Uma linha por comportamento.

**2. Agrupe por semelhança.** Quais participantes fazem as mesmas coisas, pelos mesmos motivos? Os agrupamentos costumam ser evidentes — e quando não são, é sinal de que há uma persona só.

**3. Escreva o perfil a partir do agrupamento**, usando apenas o que foi observado, e citando as falas literais.

O que não fazer: começar escrevendo um personagem e depois procurar quais entrevistados se encaixam. A ordem inversa produz uma persona que reflete a sua expectativa inicial, que é exatamente o que a pesquisa existia para corrigir.

### Usar a persona depois

Uma persona guardada numa pasta não fez diferença nenhuma. Ela precisa aparecer nas decisões:

**Ao definir a hierarquia de uma tela:** "para o Marcos, o que precisa estar visível em meio segundo?"

**Ao escolher entre alternativas:** "qual das duas funciona com uma mão, em dois minutos, no intervalo do almoço?"

**Ao recusar uma ideia:** "isso ajuda quem usa uma vez por ano; o Marcos usa três vezes por semana."

**Ao recrutar para o teste:** os participantes precisam corresponder à persona — o que é, inclusive, uma verificação de que ela é real.

### O erro que você vai cometer: inventar o que não observou

O modelo pede idade, profissão, familiaridade com tecnologia. Você entrevistou seis pessoas e não perguntou a idade de três, nem investigou o quanto elas usam tecnologia. O reflexo é preencher com algo plausível.

O problema não é a imprecisão de um campo. É que, uma vez que a persona contém elementos inventados, ela perde a autoridade que a tornava útil — e ninguém, nem você, consegue distinguir depois o que foi observado do que foi preenchido. A partir daí, decisões de design são justificadas por características fictícias.

A correção é simples e melhora o documento: **deixe o campo vazio, ou escreva "não investigado"**. Uma persona com quatro campos sólidos e dois vazios é honesta e utilizável; uma com dez campos, dos quais quatro são invenção, não é.

E há um caso especial que vale nomear: a foto. Colocar uma imagem de banco de imagens não acrescenta informação e cria uma impressão específica de quem aquela pessoa é — normalmente uma impressão que não corresponde a nenhum dos participantes reais. Se quiser um elemento visual, use uma ilustração neutra ou apenas as iniciais.

### Exercício prático

**Objetivo:** derivar as personas do seu projeto a partir dos dados reais.

1. Extraia, das folhas de registro, todos os comportamentos observados, com o participante ao lado.
2. Agrupe por semelhança de comportamento e de objetivo — não por perfil demográfico.
3. Decida quantas personas os agrupamentos sustentam. Justifique em uma frase.
4. Escreva cada persona no formato acima, incluindo a linha "baseada em" e a seção de implicações para o design.
5. Marque com "não investigado" tudo o que você não observou.
6. Teste: pegue três decisões de design que você já tomou intuitivamente e verifique se a persona as sustenta, contradiz ou não diz nada.

### Solução comentada

O passo 6 é o que valida a persona, e produz três resultados possíveis — os três úteis.

**A persona sustenta a decisão.** Ótimo, e agora você tem a justificativa escrita para apresentar.

**A persona contradiz a decisão.** É o resultado mais valioso. Significa que você tomou a decisão pelo seu próprio modelo mental, e os dados apontam outra direção. O caso mais comum neste tipo de projeto: você deu destaque à marcação de nova sessão porque é a ação "principal" conceitualmente, e a persona mostra que a ação frequente e dolorosa é a remarcação.

**A persona não diz nada.** Também é informação: ou a decisão é irrelevante para o usuário — e você pode decidir pelo que for mais barato —, ou a sua pesquisa não cobriu aquele aspecto, e vale uma pergunta rápida a dois participantes antes de seguir.

O passo 3, justificar o número de personas em uma frase, evita o erro mais comum de segmentação. A justificativa válida tem a forma: "duas personas, porque os pacientes em tratamento contínuo e os de sessão avulsa têm objetivos diferentes — manter a rotina versus resolver um problema pontual — e a hierarquia da tela inicial que serve um não serve o outro". A justificativa inválida tem a forma: "duas personas, uma mais jovem e uma mais velha" — que descreve a amostra, não o comportamento.

E vale registrar o desconforto legítimo com o método: seis entrevistas são pouco para afirmar que existem exatamente dois perfis na população. A resposta honesta é declarar isso no caso de portfólio — "duas personas derivadas de seis entrevistas; uma amostra maior poderia revelar outros perfis" — o que é mais forte, e não mais fraco, do que apresentar as personas como fato estabelecido.

---
