## Consulta e Pesquisa do Código de Serviço LC116

A correta identificação do código de serviço LC116 é fundamental para a apuração do ISS e a análise tributária eficiente, especialmente após a reforma tributária que atualizou e padronizou os códigos e serviços tributáveis. Para garantir a conformidade, é imprescindível consultar as bases oficiais que disponibilizam a versão atualizada da lista de serviços e seus respectivos códigos LC116.

### Onde e Como Consultar o Código de Serviço LC116

A fonte oficial obrigatória para consulta do código de serviço LC116 é o **site da Confederação Nacional de Municípios (CNM)**, que mantém a tabela atualizada conforme as alterações legislativas e acordos entre os municípios. Além disso, o **portal da Receita Federal** e os **sites das Secretarias de Fazenda Estaduais ou Municipais** podem disponibilizar versões homologadas para consulta pública.

O caminho prático para a consulta é:

1. **Acessar o site da CNM:**  
   URL oficial: [https://www.cnm.org.br/](https://www.cnm.org.br/)

2. **Buscar na seção de ISS ou Tabelas de Serviços:**  
   Normalmente há uma área específica para a tabela do ISS atualizada, referenciando a LC116.

3. **Baixar a tabela oficial em formato Excel ou PDF:**  
   A tabela contém o código de serviço (4 dígitos), a descrição detalhada do serviço e eventuais observações relevantes.

4. **Consultar o código desejado pela descrição do serviço:**  
   Utilize a busca por palavra-chave para localizar o serviço correspondente à atividade econômica.

5. **Verificar a versão da tabela para garantir a atualização pós-reforma:**  
   A tabela oficial inclui data de atualização e versão, fundamental para evitar erros de códigos desatualizados.

### Exemplo Prático de Consulta no Site da CNM

Suponha que você queira consultar o código de serviço para “consultoria em tecnologia da informação”, um serviço comum e sujeito ao ISS.

- Acesse o site da CNM.  
- Na seção de ISS, localize a tabela atualizada da LC116.  
- Abra a tabela Excel e utilize a função de filtro ou busca (Ctrl+F) para “consultoria tecnologia”.  
- Encontre o código correspondente, por exemplo, `1701` (código fictício para ilustrar).  
- Leia a descrição para confirmar que atende ao serviço prestado.

### Consulta Programática da Tabela LC116

Para sistemas fiscais automatizados, é possível integrar a tabela oficial do código LC116 via base de dados atualizada, usando:

- Arquivos CSV ou Excel disponibilizados pela CNM ou entidades oficiais.  
- APIs de órgãos municipais ou integradores que disponibilizam a tabela em formato JSON ou XML.  
- Métodos de atualização periódica para garantir sincronização com as últimas versões.

Isso permite que o sistema valide automaticamente o código informado na emissão de notas fiscais, evitando erros como:

```
Erro: Código de serviço LC116 inválido ou desatualizado para o CNAE informado.
```

Ao tentar usar um código não existente ou incompatível, o sistema bloqueia a emissão da nota fiscal, forçando a correção.

### Erro Comum na Consulta e Como Corrigir

Um erro frequente é a utilização de tabelas antigas ou não oficiais, que geram inconsistências na aplicação do ISS. Por exemplo, ao informar um código desatualizado:

```
Erro: Código 1234 não encontrado na tabela LC116 vigente.
```

**Correção:** Atualize a tabela LC116 no sistema com a última versão oficial da CNM; verifique se o código corresponde à atividade econômica do fornecedor e ao CNAE vinculado.

### Dicas para Pesquisa Eficiente do Código LC116

- Utilize termos específicos e relacionados ao serviço prestado, evitando termos genéricos para não confundir categorias.  
- Verifique a categoria do código (1º dígito) para restringir a busca ao setor correto (exemplo: serviços de informática, saúde, educação etc.).  
- Confirme se o código faz parte dos serviços tributáveis pelo ISS, pois alguns serviços são excluídos na LC116.  
- Mantenha uma rotina de atualização da tabela LC116 no sistema, especialmente após mudanças na legislação municipal ou federal.  
- Consulte notas explicativas na tabela oficial, que indicam exclusões ou particularidades para certos códigos.

### Exemplo Completo de Consulta e Validação Manual

Suponha o seguinte cenário:

- Atividade econômica do fornecedor: Desenvolvimento de software personalizado.  
- CNAE do fornecedor: `6204-0/00` (desenvolvimento de programas de computador sob encomenda).  

Passos para consulta:

1. Buscar na tabela LC116 o serviço relacionado a “desenvolvimento de software”.  
2. Encontrar o código que descreve “desenvolvimento de software personalizado”, por exemplo, `1702`.  
3. Confirmar que o código está ativo e consta na tabela atualizada (2024 ou mais recente).  
4. Validar que o CNAE `6204-0/00` está vinculado corretamente ao código LC116 `1702` conforme regras do sistema fiscal (ver 8.2).  
5. Utilizar o código `1702` para calcular o ISS devido e apropriar créditos tributários (ver 5.1).

### Implementação Prática para Sistemas

Para seu sistema, implemente a função de consulta que:

- Receba como entrada um termo ou código provisório de serviço.  
- Busque na tabela LC116 atualizada os códigos mais próximos da descrição.  
- Apresente ao usuário a lista de possíveis códigos e descrições para escolha.  
- Valide a escolha com base no CNAE do fornecedor e regras de vinculação pré-configuradas.  
- Atualize automaticamente a base mensalmente ou conforme cronograma oficial.

### Exercício Prático

A partir da lista abaixo de atividades econômicas com seus CNAEs, utilize a tabela oficial da CNM para identificar o código de serviço LC116 correspondente e justifique a escolha:

| Atividade Econômica                  | CNAE        |
|------------------------------------|-------------|
| Serviços de contabilidade          | 6920-6/01   |
| Consultoria em tecnologia da informação | 6204-0/00   |
| Serviços de arquitetura            | 7111-1/00   |
| Serviços de publicidade            | 7311-4/00   |
| Serviços de transporte de passageiros| 4923-0/01 |

A tarefa consiste em acessar a tabela atualizada, localizar os códigos LC116 para cada atividade e confirmar a compatibilidade com o CNAE.

---