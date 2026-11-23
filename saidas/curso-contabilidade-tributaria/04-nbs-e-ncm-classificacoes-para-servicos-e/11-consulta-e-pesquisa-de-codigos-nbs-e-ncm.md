## Consulta e Pesquisa de Códigos NBS e NCM

Na prática da contabilidade tributária, a correta identificação e classificação dos códigos NBS e NCM são essenciais para garantir a correta aplicação dos tributos e a apuração adequada de créditos tributários. Para isso, é fundamental saber consultar e pesquisar esses códigos nas bases oficiais, atualizadas e reconhecidas pelos órgãos fiscais. Esta habilidade evita erros comuns que impactam diretamente no cálculo tributário e, consequentemente, na decisão de escolha do fornecedor mais vantajoso.

### Por que consultar códigos NBS e NCM nas bases oficiais?

Apesar de já conhecermos a estrutura e a finalidade dos códigos NBS (serviços) e NCM (mercadorias), a simples memorização ou uso de códigos genéricos pode levar a erros fiscais, rejeições de documentos eletrônicos como NFS-e e NF-e, e perda de créditos tributários importantes para a redução do custo líquido. As bases oficiais garantem que o código pesquisado esteja atualizado, correto e vinculado às descrições oficiais, além de permitir a integração com os demais códigos vinculados (CNAE e LC116).

### Onde consultar os códigos NBS?

A NBS é mantida e atualizada pelo Comitê Gestor do Simples Nacional (CGSN) e está disponível para consulta pública em portais oficiais do Governo Federal e da Receita Federal, além de órgãos municipais que integram a base para emissão de NFS-e.

- **Portal do Simples Nacional**: https://www8.receita.fazenda.gov.br/SimplesNacional/  
  Aqui é possível baixar a tabela oficial da NBS, com códigos e suas descrições atualizadas. Também são disponibilizadas versões para integração em sistemas.

- **Portais municipais de NFS-e**: Muitas prefeituras disponibilizam sistemas integrados de consulta para validação do código NBS utilizado na emissão da nota fiscal de serviço eletrônica.

#### Exemplo prático de pesquisa NBS

Suponha que você precise verificar o código NBS para o serviço de "consultoria em segurança da informação". A consulta oficial indicará o código NBS específico, por exemplo, `62041001`, que detalha esse serviço dentro da hierarquia da NBS, diferenciando-o de outros serviços de consultoria em TI.

O uso correto deste código, em vez de um genérico, evitará erros na apuração do ISS e garantirá o reconhecimento do crédito tributário correspondente.

### Onde consultar os códigos NCM?

O código NCM é administrado pela Receita Federal e disponibilizado no portal oficial para consulta, sendo essencial para a emissão correta das notas fiscais eletrônicas de mercadorias e para a apuração dos tributos federais e estaduais.

- **Portal da Receita Federal – NCM**:  
  https://www.gov.br/receitafederal/pt-br/assuntos/aduana-e-comercio-exterior/nomenclatura-comum-do-mercosul-ncm  
  Nesse portal, você pode pesquisar pelo código exato ou descrição da mercadoria. Também é possível baixar a tabela completa em formato XML ou CSV para uso em sistemas fiscais.

- **Sistemas de emissão de NF-e**: Geralmente incorporam as tabelas oficiais da NCM e realizam validação automática do código informado.

#### Exemplo prático de pesquisa NCM

Imagine que sua empresa vá adquirir um notebook usado para escritório. Você deve consultar a tabela NCM para identificar o código correto, por exemplo, `8471.30.12`, que representa notebooks usados. Encontrar o código correto permite aplicar as alíquotas tributárias corretas e calcular os créditos tributários de forma precisa, impactando diretamente no custo líquido desse bem.

### Como evitar erros comuns na consulta e uso dos códigos NBS e NCM

1. **Não use códigos genéricos ou desatualizados:** Códigos incompletos ou genéricos, como um código NBS apenas com os três primeiros dígitos ou um código NCM de capítulo apenas, causam rejeição fiscal e perda de créditos.  
2. **Sempre use as tabelas oficiais atualizadas:** Atualizações anuais ou periódicas dos códigos, incluindo exclusões e inclusões, devem ser acompanhadas para garantir a conformidade.  
3. **Valide a compatibilidade dos códigos com o CNAE e LC116:** A integração entre CNAE, LC116 e NBS é fundamental para o correto cálculo do ISS, enquanto o CNAE e NCM devem ser compatíveis para mercadorias.  
4. **Utilize ferramentas digitais de consulta:** Muitas prefeituras e a Receita Federal oferecem APIs e sistemas para automação da consulta e validação, evitando erros manuais.

### Pesquisa prática com ferramentas oficiais

Para facilitar o desenvolvimento da funcionalidade de comparação tributária entre fornecedores, considere os seguintes procedimentos:

- **Download e integração das tabelas oficiais:** Baixe as tabelas NBS e NCM atualizadas em formatos legíveis por sistemas (CSV, XML, JSON) e mantenha um processo automático de atualização conforme os lançamentos oficiais.

- **Consulta via API ou sistemas online:** Utilize APIs públicas ou serviços oficiais para validar códigos informados em tempo real na emissão de documentos ou na análise tributária.

- **Validação cruzada automática:** Ao receber o CNAE do fornecedor, vincule automaticamente o código LC116 correspondente, e este, por sua vez, ao código NBS correto. Para mercadorias, confirme o código NCM na base oficial, garantindo compatibilidade e evitando erros.

#### Código de exemplo para pesquisa automatizada (simulada)

```python
# Exemplo simplificado de função para validar código NBS em lista oficial atualizada
def validar_codigo_nbs(codigo_nbs, tabela_nbs):
    """Verifica se o código NBS está presente na tabela oficial."""
    return codigo_nbs in tabela_nbs

# Simulação de tabela NBS carregada do arquivo oficial (exemplo reduzido)
tabela_nbs = {'62041001', '62041002', '62041003'}  # Códigos válidos para consultoria TI

codigo_consultado = '62041001'
if validar_codigo_nbs(codigo_consultado, tabela_nbs):
    print(f"Código NBS {codigo_consultado} válido e atualizado.")
else:
    print(f"Código NBS {codigo_consultado} inválido ou desatualizado.")
```

Saída esperada:

```
Código NBS 62041001 válido e atualizado.
```

O mesmo princípio se aplica para o NCM, com tabelas oficiais e verificações programáticas para garantir que o código usado é válido, específico e atualizado.

### Erro comum e sua correção

**Erro:** Utilizar um código NBS genérico como `6204` para qualquer serviço de consultoria em TI.

**Mensagem típica na rejeição da NFS-e:**  
`Rejeição: Código NBS inválido ou não suportado para o serviço informado.`

**Correção:** Consultar a tabela oficial e utilizar o código completo, por exemplo, `62041001` para "consultoria em segurança da informação".

### Considerações finais para a implementação prática

Para que o sistema automatize a escolha do fornecedor mais vantajoso em termos tributários, a consulta e validação correta dos códigos NBS e NCM são etapas indispensáveis. Essas consultas garantem que os cálculos de ISS, IBS, CBS e apropriação de créditos sejam realizados com base em informações corretas e atualizadas, evitando erros fiscais e perdas financeiras.

A integração das bases oficiais ao sistema deve prever:

- Atualização automática das tabelas NBS e NCM (pelo menos semestralmente, ou conforme publicação oficial).  
- Validação cruzada com CNAE e LC116 para serviços.  
- Validação da compatibilidade do NCM para mercadorias com o CNAE do fornecedor.  
- Mensagens claras de erro e orientação para correção em caso de código inválido ou desatualizado.

Dessa forma, o sistema oferecerá segurança jurídica e eficiência na análise tributária para a comparação entre fornecedores, potencializando a tomada de decisão baseada em custo líquido tributário e créditos apropriáveis.

---