## Limitações e Exclusões na Lista de Serviços LC116

Ao trabalhar com a Lei Complementar 116 (LC116) e sua lista de serviços tributáveis pelo ISS, é crucial compreender que nem todos os serviços prestados no Brasil estão sujeitos a essa tributação. A LC116 apresenta limitações e exclusões explícitas que impactam diretamente a vinculação do código de serviço LC116 ao CNAE e, consequentemente, a análise tributária para comparação entre fornecedores.

### Por que entender as limitações é essencial?

Imagine que sua empresa contrate um fornecedor para um serviço classificado em um CNAE que, aparentemente, está vinculado a um código LC116 para cálculo do ISS. Se o serviço em questão estiver excluído da lista da LC116, haverá erro na apuração do ISS, podendo resultar em autuação fiscal, bloqueio na emissão de notas ou perda indevida de créditos tributários. Portanto, conhecer os serviços que não são tributados ou possuem tratamento especial evita erros comuns de integração e cálculo tributário.

### Quais serviços são excluídos ou têm tratamento especial na LC116?

A LC116 delimita claramente os serviços sujeitos ao ISS e, por exclusão, aqueles que não são tributados por esse imposto municipal. As principais exclusões são:

1. **Serviços cuja tributação é exclusiva de outros tributos**:  
   Serviços relacionados a mercadorias, produtos industrializados ou bens móveis, que são tributados pelo ICMS ou IPI, ficam fora do ISS. Por exemplo, transporte de cargas (exceto transporte municipal de passageiros) e atividades de comunicação são tributadas por impostos federais ou estaduais, não pelo ISS.

2. **Serviços com regime especial ou isenção**:  
   Alguns serviços listados na LC116 podem ter isenções ou imunidades específicas, como serviços educacionais, de saúde e culturais, desde que atendam a requisitos legais. Essa isenção não os exclui da lista, mas altera a forma de tributação.

3. **Atividades não consideradas prestação de serviço para fins de ISS**:  
   Atividades como locação de bens móveis e imóveis, venda de mercadorias, intermediação comercial, e atividades financeiras geralmente não são tributadas pelo ISS, mesmo que vinculadas a um CNAE que, em outras circunstâncias, poderia indicar serviço.

4. **Serviços que a LC116 não prevê explicitamente**:  
   Serviços tecnológicos emergentes ou novas modalidades podem não estar ainda contemplados na lista da LC116, exigindo análise específica ou atualização da legislação.

### Exemplo prático: erro comum ao ignorar exclusões

Suponha que você vincule o CNAE de uma empresa de transporte rodoviário interestadual de cargas ao código de serviço LC116 para cálculo do ISS, por associar genericamente "transporte" ao ISS. Ao tentar emitir a nota fiscal, o sistema emite o erro:

```
Erro: Código LC116 incompatível com o CNAE informado – serviço não tributável pelo ISS.
```

Isso ocorre porque o transporte interestadual de cargas é tributado pelo ICMS, não pelo ISS, sendo excluído da lista da LC116. A correção envolve validar a exclusão da atividade da lista do ISS e, se necessário, aplicar códigos de tributação adequados para ICMS, evitando a vinculação errada com LC116.

### Tratamento especial para atividades mistas ou integradas

Alguns fornecedores oferecem serviços mistos que combinam atividades tributáveis e não tributáveis pelo ISS. Nesses casos, a correta segregação das receitas e a vinculação adequada dos códigos LC116 são essenciais para evitar erros fiscais.

Por exemplo, uma empresa de tecnologia que presta serviços de desenvolvimento de software (tributável pelo ISS) e comercializa licenças de software (tributável pelo ICMS) deve separar as receitas para aplicar corretamente LC116 apenas ao serviço, vinculando adequadamente ao CNAE e NBS.

### Como aplicar a exclusão na prática para vinculação CNAE x LC116

Para garantir a conformidade e evitar erros:

- Consulte sempre a lista oficial atualizada da LC116 para identificar se o serviço correspondente ao CNAE está sujeito ao ISS.  
- Verifique as exclusões explícitas, principalmente para atividades relacionadas a mercadorias, transporte interestadual, comunicação e operações financeiras.  
- Utilize a integração com a NBS para detalhamento dos serviços e confirmação da tributação pelo ISS (ver 4.1).  
- Atualize regularmente as tabelas de códigos LC116 e vinculações para acompanhar as mudanças pós-reforma.  
- Caso um serviço não conste na lista do ISS, avalie o uso dos códigos cTribNac adequados para ICMS, IBS, CBS, conforme o caso (ver 6.1 e 5.4).

### Exemplo prático completo: aplicação da exclusão em sistema

Imagine que seu sistema fiscal recebeu o seguinte dado:

| CNAE          | Descrição Atividade                           | Código LC116 Aplicado | Resultado Esperado             |
|---------------|----------------------------------------------|----------------------|-------------------------------|
| 4930-2/01     | Transporte rodoviário interestadual de carga | 2601 (Transporte)     | Rejeição: serviço excluído do ISS |

O código LC116 2601 pode representar genericamente "transporte", mas para o transporte interestadual de carga, o ISS não incide. O sistema deve rejeitar a aplicação do código LC116 e sugerir o código cTribNac correto para ICMS.

**Mensagem de erro do sistema:**

```
Erro fiscal: Serviço não tributável pelo ISS conforme LC116. Verifique a classificação e aplique o código de tributação adequado (ICMS).
```

**Correção:** Remover o código LC116 e aplicar o código cTribNac correto para ICMS, garantindo que o crédito tributário e apuração sejam feitos conforme a legislação.

---

### Exercício prático

A partir da lista abaixo, identifique quais das atividades econômicas (com seus respectivos CNAEs) estão sujeitas ao ISS conforme a LC116, considerando exclusões e limitações, e justifique a não aplicação do ISS para as atividades excluídas.

| CNAE       | Descrição da Atividade                               |
|------------|-----------------------------------------------------|
| 6201-5/01  | Desenvolvimento de programas de computador          |
| 4930-2/01  | Transporte rodoviário interestadual de cargas       |
| 8621-5/01  | Atividades de atendimento hospitalar                 |
| 4617-4/03  | Comércio atacadista de produtos farmacêuticos       |
| 6619-3/99  | Atividades auxiliares dos serviços financeiros       |
| 8299-7/99  | Atividades de serviços combinados de escritório e apoio administrativo |

---