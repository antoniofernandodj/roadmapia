## Como Incorporar Créditos Tributários na Análise de Custos

Para tomar decisões eficazes na escolha de fornecedores, especialmente após a reforma tributária, não basta comparar apenas o preço bruto. É imprescindível incorporar os créditos tributários que cada fornecedor gera, transformando o custo aparente em custo líquido tributário. Essa abordagem evita a armadilha de contratar o fornecedor com menor preço nominal que, na prática, pode resultar no maior custo para a empresa, pois não gera créditos suficientes para compensar o valor pago.

### Por que incorporar créditos tributários?

Imagine que você tenha dois fornecedores para um serviço:

- Fornecedor A cobra R$ 100,00, mas gera um crédito tributário de R$ 15,00 para sua empresa.
- Fornecedor B cobra R$ 95,00, porém não gera crédito tributário algum.

Se você considerar apenas o preço bruto, o Fornecedor B parece mais barato. Entretanto, descontando o crédito gerado pelo fornecedor A, o custo líquido para sua empresa será R$ 85,00 (R$ 100 - R$ 15), tornando essa a opção mais vantajosa. Ignorar isso pode levar a decisões econômicas equivocadas.

### Como calcular o custo líquido incorporando créditos tributários

O custo líquido tributário é o valor efetivamente pago pelo serviço ou mercadoria, já considerando os créditos tributários que podem ser apropriados. A fórmula básica é:

```markdown
Custo Líquido = Preço Bruto - Créditos Tributários Apropriáveis
```

Para fazer essa análise de forma consistente, o processo deve ser baseado em dados fiscais confiáveis e integrados, utilizando as classificações e códigos oficiais que garantem a correta identificação dos créditos.

### Passo a passo para incorporar créditos na análise

1. **Identificar a atividade econômica do fornecedor via CNAE**  
   O CNAE do fornecedor define a sua atividade econômica principal, essencial para vincular corretamente os códigos de tributação, como LC116 para serviços.

2. **Vincular o CNAE ao código de serviço LC116**  
   A partir do CNAE, vincula-se o código LC116 que define o serviço tributável pelo ISS, baseando-se na lista oficial e hierarquia atualizada pós-reforma.

3. **Vincular o código LC116 ao código NBS**  
   O código NBS detalha o serviço para a apuração correta do ISS e a identificação dos créditos possíveis de apropriação.

4. **Identificar os tributos incidentes: ISS, IBS, CBS**  
   Analisar quais tributos incidem sobre o serviço ou mercadoria, e quais geram créditos tributários. O IBS e CBS, por exemplo, possuem regras específicas para crédito integral ou acumulável.

5. **Calcular o valor dos créditos tributários**  
   Com base nas alíquotas e regras de apropriação dos tributos identificados, calcula-se o crédito que pode ser usado para redução do custo tributário líquido.

6. **Ajustar o preço bruto pela apropriação dos créditos**  
   Subtrai-se o valor dos créditos do preço bruto para obter o custo líquido tributário.

### Exemplo prático completo usando Python

Vamos simular a comparação entre dois fornecedores com dados fictícios para ilustrar o cálculo do custo líquido com créditos tributários.

```python
# Dados dos fornecedores
fornecedor_A = {
    'preco_bruto': 100.00,
    'credito_iss': 5.00,
    'credito_ibs': 8.00,
    'credito_cbs': 2.00
}

fornecedor_B = {
    'preco_bruto': 95.00,
    'credito_iss': 0.00,
    'credito_ibs': 0.00,
    'credito_cbs': 0.00
}

def calcular_custo_liquido(fornecedor):
    total_creditos = fornecedor['credito_iss'] + fornecedor['credito_ibs'] + fornecedor['credito_cbs']
    custo_liquido = fornecedor['preco_bruto'] - total_creditos
    return custo_liquido

custo_liquido_A = calcular_custo_liquido(fornecedor_A)
custo_liquido_B = calcular_custo_liquido(fornecedor_B)

print(f"Custo líquido do Fornecedor A: R$ {custo_liquido_A:.2f}")
print(f"Custo líquido do Fornecedor B: R$ {custo_liquido_B:.2f}")

if custo_liquido_A < custo_liquido_B:
    print("Fornecedor A é mais vantajoso considerando os créditos tributários.")
else:
    print("Fornecedor B é mais vantajoso considerando os créditos tributários.")
```

### Saída esperada:

```
Custo líquido do Fornecedor A: R$ 85.00
Custo líquido do Fornecedor B: R$ 95.00
Fornecedor A é mais vantajoso considerando os créditos tributários.
```

### Erro comum: ignorar os créditos e optar pelo menor preço bruto

Um erro muito comum é basear a escolha apenas no preço bruto, ignorando créditos tributários. O resultado típico disso é a contratação de um fornecedor aparentemente barato que acaba onerando mais a empresa, pois não gera créditos para compensar o valor pago.

Se você calcular apenas o preço bruto, poderia escolher o fornecedor B, porém o custo líquido efetivo será maior.

### Cuidados práticos ao incorporar créditos

- **Confirme sempre a correta vinculação CNAE-LC116-NBS** para garantir que os créditos são legítimos e que a atividade do fornecedor corresponde à tributação aplicada.
- **Atualize as tabelas e códigos regularmente**, pois a reforma tributária e atualizações oficiais impactam diretamente as possibilidades de crédito.
- **Considere os regimes tributários dos fornecedores**, pois regimes especiais podem limitar ou impedir a apropriação de créditos.
- **Verifique a documentação fiscal** para comprovar o direito aos créditos gerados.

### Simplificando a análise para sistemas

Em sistemas fiscais e contábeis, a incorporação dos créditos na análise de custos deve ser automatizada pela integração dos códigos CNAE, LC116 e NBS, além da consulta aos códigos cTribNac para identificar corretamente os tributos e créditos.

Isso permite:

- Cálculo automático do custo líquido tributário.
- Comparação entre fornecedores considerando o impacto fiscal real.
- Geração de relatórios para decisões estratégicas.

### Exercício prático

Considere dois fornecedores de serviços com os seguintes dados:

| Fornecedor | Preço Bruto | Crédito ISS | Crédito IBS | Crédito CBS |
|------------|-------------|-------------|-------------|-------------|
| Fornecedor X | R$ 120,00 | R$ 10,00   | R$ 12,00    | R$ 3,00     |
| Fornecedor Y | R$ 110,00 | R$ 5,00    | R$ 7,00     | R$ 1,00     |

Calcule o custo líquido tributário para cada fornecedor e indique qual oferece a melhor opção econômica considerando os créditos tributários.

---