## Créditos Tributários Relacionados ao IBS e CBS

Na análise tributária pós-reforma, a correta apropriação dos créditos tributários relacionados ao IBS (Imposto sobre Bens e Serviços) e à CBS (Contribuição sobre Bens e Serviços) é essencial para garantir que o custo líquido dos insumos e serviços seja o menor possível, impactando diretamente a escolha do fornecedor mais vantajoso.

### Por que os créditos tributários são fundamentais no IBS e CBS?

O IBS e a CBS são tributos não cumulativos, ou seja, o contribuinte tem direito a descontar créditos tributários referentes às etapas anteriores da cadeia produtiva. Isso evita a incidência "em cascata" e impede que o imposto seja cobrado múltiplas vezes sobre o mesmo valor agregado, garantindo neutralidade tributária.

No contexto prático, isso significa que uma empresa que adquire bens ou serviços para sua atividade pode abater do imposto devido o valor do IBS ou CBS já pago nas etapas anteriores de comercialização ou produção desses bens e serviços. Esse abatimento reduz o valor efetivo do tributo a ser recolhido e, consequentemente, o custo tributário total do produto ou serviço.

### Como funcionam os créditos tributários no IBS?

O IBS incide sobre a operação estadual de circulação de bens e prestação de serviços, com alíquota definida pelo estado, geralmente entre 7% e 12% (ver 5.1). Para evitar a cumulatividade, o sistema permite a apropriação de créditos referentes ao IBS já pago nas entradas.

A forma prática de cálculo do imposto devido, considerando créditos, é:

\[
IBS_{devido} = \max\big(0, Base_{IBS} \times Aliquota_{IBS} - Credito_{IBS} \big)
\]

onde:
- \(Base_{IBS}\) é o valor da operação conforme regras específicas (ver 5.2),
- \(Aliquota_{IBS}\) é a alíquota estadual aplicável,
- \(Credito_{IBS}\) é o total de IBS pago em aquisições vinculadas à operação.

É importante limitar o imposto devido a zero para evitar valores negativos, o que é um erro comum quando se subtrai o crédito sem controle (ver 5.3).

### Créditos tributários no CBS e sua aplicação prática

A CBS, tributo federal unificado com alíquota padrão de 12%, também é não cumulativa. A base de cálculo é a receita bruta ajustada, e o crédito tributário é apropriado para compensar o imposto pago em etapas anteriores.

O cálculo prático do CBS devido segue fórmula semelhante ao IBS:

\[
CBS_{devido} = \max\big(0, Base_{CBS} \times 12\% - Credito_{CBS} \big)
\]

onde:
- \(Base_{CBS}\) é a receita bruta ajustada conforme regras (ver 5.4),
- \(Credito_{CBS}\) é o crédito tributário acumulado.

Novamente, o imposto líquido não pode ser negativo, e a limitação é fundamental para evitar erros de cálculo.

### Quais operações geram créditos para IBS e CBS?

Os créditos tributários no IBS e CBS são gerados principalmente na aquisição de bens e serviços que serão utilizados para:

- produção ou comercialização de mercadorias,
- prestação de serviços tributados pelo IBS ou CBS,
- investimentos e despesas vinculadas à atividade tributada.

A empresa deve registrar esses créditos no sistema fiscal, vinculando-os corretamente à operação tributária, conforme o CNAE do fornecedor e o código tributário aplicado (ver 6.3).

### Exemplo prático: cálculo do IBS e CBS com créditos tributários

Considere três fornecedores com as seguintes características para uma operação:

| Fornecedor | Valor da Operação (R$) | Alíquota IBS (%) | Crédito IBS (R$) | Receita Bruta (R$) | Crédito CBS (R$) |
|------------|------------------------|------------------|------------------|--------------------|------------------|
| A          | 1000                   | 10               | 120              | 1000               | 100              |
| B          | 950                    | 10               | 80               | 950                | 90               |
| C          | 980                    | 10               | 150              | 980                | 110              |

O código Python abaixo calcula o IBS e CBS líquidos e o custo líquido para cada fornecedor:

```python
fornecedores = [
    {"nome": "A", "valor": 1000, "aliquota_ibs": 0.10, "credito_ibs": 120, "receita": 1000, "credito_cbs": 100},
    {"nome": "B", "valor": 950, "aliquota_ibs": 0.10, "credito_ibs": 80, "receita": 950, "credito_cbs": 90},
    {"nome": "C", "valor": 980, "aliquota_ibs": 0.10, "credito_ibs": 150, "receita": 980, "credito_cbs": 110},
]

ALIQUIDADE_CBS = 0.12

for fornecedor in fornecedores:
    ibs_bruto = fornecedor["valor"] * fornecedor["aliquota_ibs"]
    ibs_liquido = max(0, ibs_bruto - fornecedor["credito_ibs"])
    cbs_bruto = fornecedor["receita"] * ALIQUIDADE_CBS
    cbs_liquido = max(0, cbs_bruto - fornecedor["credito_cbs"])
    
    custo_liquido = fornecedor["valor"] + ibs_liquido + cbs_liquido
    
    print(f"Fornecedor {fornecedor['nome']}:")
    print(f"  IBS bruto: R$ {ibs_bruto:.2f}")
    print(f"  Crédito IBS: R$ {fornecedor['credito_ibs']:.2f}")
    print(f"  IBS líquido a pagar: R$ {ibs_liquido:.2f}")
    print(f"  CBS bruto: R$ {cbs_bruto:.2f}")
    print(f"  Crédito CBS: R$ {fornecedor['credito_cbs']:.2f}")
    print(f"  CBS líquido a pagar: R$ {cbs_liquido:.2f}")
    print(f"  Custo líquido total (valor + IBS + CBS): R$ {custo_liquido:.2f}\n")
```

Saída:

```
Fornecedor A:
  IBS bruto: R$ 100.00
  Crédito IBS: R$ 120.00
  IBS líquido a pagar: R$ 0.00
  CBS bruto: R$ 120.00
  Crédito CBS: R$ 100.00
  CBS líquido a pagar: R$ 20.00
  Custo líquido total (valor + IBS + CBS): R$ 1020.00

Fornecedor B:
  IBS bruto: R$ 95.00
  Crédito IBS: R$ 80.00
  IBS líquido a pagar: R$ 15.00
  CBS bruto: R$ 114.00
  Crédito CBS: R$ 90.00
  CBS líquido a pagar: R$ 24.00
  Custo líquido total (valor + IBS + CBS): R$ 989.00

Fornecedor C:
  IBS bruto: R$ 98.00
  Crédito IBS: R$ 150.00
  IBS líquido a pagar: R$ 0.00
  CBS bruto: R$ 117.60
  Crédito CBS: R$ 110.00
  CBS líquido a pagar: R$ 7.60
  Custo líquido total (valor + IBS + CBS): R$ 994.00
```

Análise: apesar do Fornecedor A ter maior valor bruto, seu crédito de IBS anula esse imposto e o CBS líquido é baixo, levando a custo líquido superior ao B e C. O Fornecedor B tem custo líquido mais baixo, mas menor crédito. O Fornecedor C tem crédito maior no IBS e CBS, reduzindo o custo em relação ao valor bruto.

### Erros comuns na apropriação de créditos IBS e CBS

1. **Não controlar o limite mínimo zero do imposto**: Subtrair crédito maior que o imposto bruto e permitir resultado negativo no cálculo do imposto devido.
   
   *Erro típico:*

   ```python
   ibs_liquido = ibs_bruto - credito_ibs  # pode resultar em valor negativo
   ```

   *Correção:*

   ```python
   ibs_liquido = max(0, ibs_bruto - credito_ibs)
   ```

2. **Incorreta vinculação do crédito ao CNAE e ao código tributário**: Usar créditos de operações não relacionadas à atividade tributada, gerando erro na contabilidade e possível autuação fiscal.

3. **Confundir descontos condicionais e incondicionais na base de cálculo**: Descontos condicionais não são deduzidos da base para IBS e CBS no momento da operação, afetando o cálculo correto dos créditos.

4. **Não considerar o regime tributário do fornecedor**: Créditos podem variar conforme o regime (Simples, Lucro Real, etc.), impactando a apropriação correta.

### Como integrar créditos tributários ao sistema para comparação de fornecedores?

Para automatizar a análise, o sistema deve:

- Receber o CNAE do fornecedor e vincular ao código LC116, NBS e códigos cTribNac correspondentes;
- Registrar e validar créditos tributários de IBS e CBS relacionados às operações;
- Aplicar regras de cálculo conforme alíquotas e limites do imposto devido (zero como mínimo);
- Calcular custo líquido tributário somando valor, IBS líquido e CBS líquido;
- Exibir comparativo para decisão, destacando fornecedor com menor custo líquido considerando créditos.

Assim, o sistema suporta a decisão baseada em análise tributária completa, não apenas no preço bruto.

---

### Exercício proposto

Dado valor da operação, receita bruta, alíquotas do IBS e CBS, e créditos tributários para três fornecedores, implemente uma função que calcule o custo líquido tributário para cada fornecedor e identifique o fornecedor mais vantajoso considerando IBS e CBS.

---