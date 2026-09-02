## Documentação da arquitetura de informação

Seis meses depois de definida, uma arquitetura de informação existe em três lugares diferentes e incompatíveis: no código, na cabeça de quem a desenhou, e num arquivo do Figma que ninguém abre desde a última rodada de mudanças. Quando chega a pergunta "por que este item está no menu Configurações e não em Conta?", a resposta honesta costuma ser "não lembro". A partir daí, cada nova decisão é tomada por opinião, e a estrutura vai se degradando sem que ninguém tenha decidido degradá-la.

Documentar arquitetura de informação é o que impede isso. Não se trata de produzir um manual bonito — trata-se de deixar registrado o que a estrutura é, por que ela é assim, e qual regra decide onde uma coisa nova vai morar.

### Os quatro documentos que fazem diferença

Na prática, quatro artefatos cobrem quase tudo o que uma equipe precisa. Nenhum deles é longo.

**1. O mapa de estrutura.** É o inventário hierárquico completo, com todos os níveis e todos os nomes exatos que aparecem na interface. Pode ser um diagrama, mas na maioria dos projetos uma lista indentada é mais fácil de manter e de comparar entre versões:

```
Início
Pedidos
├── Pedidos abertos
├── Pedidos concluídos
└── Devoluções
Produtos
├── Catálogo
├── Estoque
└── Tabelas de preço
Relatórios
Conta
├── Meus dados
├── Usuários e permissões
└── Faturamento
Configurações
├── Preferências do sistema
├── Integrações
└── Notificações
```

O valor está no detalhe chato: o nome escrito aqui tem de ser **exatamente** o que aparece na tela, com a mesma capitalização. Divergência entre o mapa e a interface é o primeiro sinal de que o documento morreu.

**2. O dicionário de rótulos.** Uma tabela com cada termo do sistema, sua definição e — o campo mais importante — os sinônimos que foram **rejeitados**:

| Termo usado | Significa | Não usar |
|---|---|---|
| Pedido | Solicitação de compra feita pelo cliente, ainda não faturada | Ordem, requisição, solicitação |
| Devolução | Retorno de item já entregue | Estorno, cancelamento, troca |
| Usuário | Pessoa com acesso ao sistema | Operador, colaborador, conta |

Essa coluna de termos rejeitados vale mais que as outras duas juntas. Ela é o que impede que, daqui a um ano, alguém introduza "Requisições" como um novo menu ao lado de "Pedidos" — criando duas caixas para a mesma coisa.

**3. As regras de colocação.** Duas ou três frases que dizem, de forma verificável, o que entra em cada seção de primeiro nível. Exemplo:

> **Conta** — tudo o que pertence a esta organização e a estas pessoas: dados cadastrais, quem tem acesso, cobrança.
> **Configurações** — tudo o que altera o comportamento do sistema para toda a organização, e que não é dado de ninguém.
> Critério de desempate: se a alteração muda o que outra pessoa vê ou pode fazer, é Configurações. Se muda apenas informação sobre alguém, é Conta.

Sem o critério de desempate, a regra não decide nada nos casos difíceis — e os casos difíceis são os únicos em que ela é consultada.

**4. O registro de decisões.** Uma entrada curta por decisão estrutural relevante, com data, o que foi decidido, as alternativas consideradas e a razão da escolha. Três a cinco linhas cada. É o documento que responde à pergunta do começo deste texto, e o único que não pode ser reconstruído depois — as alternativas descartadas desaparecem da memória de todo mundo em semanas.

### O erro que você vai cometer: documentar o desenho em vez da regra

A versão comum desse erro é um belo diagrama de fluxo, exportado em PNG, colado no wiki, e nada mais. Ele mostra a estrutura tal como ela estava naquele dia. O que acontece nas semanas seguintes: aparece um item novo — digamos, "Assinaturas". Ninguém sabe se é Conta, Faturamento ou uma seção nova. O diagrama não ajuda, porque ele descreve o passado e não contém critério. A decisão sai de uma conversa rápida no chat, é tomada por quem estava disponível, e nunca é registrada.

Multiplique por vinte itens ao longo de dois anos e você tem a arquitetura degradada de qualquer sistema interno maduro: seções que crescem por acúmulo, nomes que se sobrepõem, e um menu "Outros".

A correção é priorizar os documentos 2 e 3 — dicionário e regras — sobre o 1. O mapa fica desatualizado sozinho; as regras continuam válidas mesmo quando o mapa muda, e é com elas que se decide.

### Onde a documentação deve morar

O critério é um só: no lugar onde a decisão é tomada. Um documento de arquitetura numa pasta de design, longe do código, é consultado por designers e ignorado por quem implementa. Três opções que funcionam, em ordem de robustez:

1. **No repositório**, em Markdown, versionado junto com o código. Muda por pull request, o que significa que a mudança de estrutura passa por revisão como qualquer outra.
2. **No wiki da equipe**, com link fixado no canal onde o time conversa.
3. **No próprio arquivo de design**, como uma página de texto ao lado das telas — funciona, mas só enquanto o arquivo de design continuar sendo a fonte de verdade, o que raramente dura.

A opção 1 tem uma vantagem que costuma decidir a escolha: o diff. Ver que a linha `├── Devoluções` mudou de lugar em um pull request é infinitamente mais revelador do que comparar dois PNGs.

### Exercício prático

**Objetivo:** documentar a arquitetura de um sistema que você já conhece, no formato mínimo viável.

Escolha um sistema que você mantém ou usa com frequência. Em no máximo uma hora:

1. Escreva o mapa de estrutura completo, em lista indentada, usando os rótulos exatos da interface.
2. Liste os cinco termos mais importantes do domínio e, para cada um, um sinônimo que circula na equipe mas não deve aparecer na interface.
3. Escreva as regras de colocação para as seções de primeiro nível, incluindo um critério de desempate.
4. Teste as regras: pegue três itens que existem hoje e verifique se as suas regras os colocariam onde eles de fato estão.

### Solução comentada

O passo 4 é onde o exercício mostra a que veio, e o resultado quase nunca é limpo.

O padrão mais comum é que **um dos três itens não obedece à própria regra**. Isso não significa que a regra está errada — significa que você encontrou um item mal colocado, que estava lá por razões históricas que ninguém mais lembra. É exatamente esse tipo de descoberta que justifica o esforço de documentar: a regra escrita transformou um desconforto vago ("aquele item está num lugar estranho") em um problema nomeado e corrigível.

O segundo padrão é a regra que não decide: você escreve "Configurações é onde ficam as opções do sistema" e descobre que essa frase acomoda qualquer item. Se a sua regra aceita tudo, ela não é uma regra, é uma descrição. O teste é tentar usá-la para **rejeitar** alguma coisa; se nada é rejeitado, reescreva incluindo o que fica de fora.

Quanto ao passo 2, o exercício costuma revelar que a equipe usa dois ou três termos como sinônimos na conversa diária, enquanto a interface usa um só — e que essa diferença já vazou para algum lugar: um texto de ajuda, uma mensagem de erro, um e-mail automático. Anotar o termo rejeitado é barato; encontrar depois onde ele vazou é o trabalho de verdade, e agora você tem a lista para procurar.

---
