## Comparação de Custos Totais Entre Fornecedores

Ao escolher um fornecedor, a decisão baseada apenas no preço bruto pode levar a custos finais maiores. Isso ocorre porque cada fornecedor está sujeito a regras tributárias diferentes, que impactam o custo líquido da operação por meio da geração ou não de créditos tributários. A comparação eficiente entre fornecedores, portanto, deve considerar o custo total, que é o preço pago menos os créditos tributários que a empresa pode apropriar.

### Por que considerar créditos tributários na comparação?

Imagine que um fornecedor ofereça um preço menor, mas sua atividade econômica, representada pelo CNAE, vincula-se a um código de serviço LC116 que não gera créditos tributários significativos para sua empresa. Outro fornecedor, com preço nominal maior, oferece serviços com códigos que permitem apropriar créditos robustos de ISS, IBS e CBS. Ao ignorar essa diferença, você pode pagar mais no custo líquido.

Esse cenário é comum no pós-reforma tributária, onde a integração dos códigos CNAE, LC116 e NBS determina a correta identificação dos tributos e a possibilidade de apropriação de créditos, como visto em 1.9, 2.9 e 3.12. Portanto, a análise tributária integrada é decisiva para a escolha econômica correta.

### Mecanismo da comparação integrada

1. **Identificação do CNAE do fornecedor:** Partindo do CNAE, identificamos a atividade econômica específica do fornecedor, essencial para vincular corretamente ao código de serviço LC116 (ver 2.9, 3.12).

2. **Vinculação CNAE x LC116:** O código LC116 define a natureza do serviço para fins de ISS e sua possibilidade de gerar créditos (3.12, 5.12).

3. **Vinculação LC116 x NBS:** A NBS detalha o serviço para fins de apuração do ISS e integração com os códigos tributários nacionais (4.7, 6.8).

4. **Cálculo do imposto devido e créditos:** Com base nesses códigos, calculamos o ISS, IBS e CBS, aplicando as alíquotas e regras específicas, e identificamos os créditos tributários disponíveis (5.9, 5.13).

5. **Determinação do custo líquido:** O custo líquido é o preço bruto menos os créditos tributários apropriáveis, sempre respeitando o limite de imposto devido mínimo zero (5.9, 5.13).

### Exemplo prático: comparação entre três fornecedores

Considere três fornecedores com as seguintes informações:

| Fornecedor | Preço Bruto (R$) | CNAE         | Código LC116 | Código NBS    | Créditos Tributários (R$) |
|------------|------------------|--------------|--------------|---------------|---------------------------|
| A          | 100,00           | 8120302      | 14.01        | 14010100      | 15,00                     |
| B          | 95,00            | 8120302      | 14.02        | 14020200      | 5,00                      |
| C          | 105,00           | 8120303      | 14.01        | 14010100      | 20,00                     |

O objetivo é calcular o custo líquido para cada fornecedor e decidir qual representa a melhor opção econômica para a empresa.

#### Passo 1: validar vinculações

- O CNAE 8120302 corresponde a uma atividade de limpeza, vinculada ao código LC116 14.01 ou 14.02, ambos válidos para ISS.  
- O fornecedor C apresenta CNAE 8120303, atividade muito próxima, mas que também se vincula corretamente ao código LC116 14.01.  
- A NBS 14010100 corresponde ao serviço de limpeza padrão, enquanto 14020200 é um serviço correlato, com diferenças na apropriação de crédito.

Se a vinculação estiver incorreta, o sistema deve emitir erro, por exemplo:

```plaintext
Erro de vinculação: CNAE 8120302 incompatível com código LC116 14.03.
Verifique a classificação para evitar cálculo tributário incorreto.
```

Esse erro impede a análise até a correção, conforme visto em 3.15 e 6.10.

#### Passo 2: cálculo do custo líquido

Considerando ISS, IBS e CBS, vamos simplificar o cálculo para focar no efeito dos créditos tributários.

- Fornecedor A: Preço R$ 100,00 - Crédito R$ 15,00 = Custo Líquido R$ 85,00
- Fornecedor B: Preço R$ 95,00 - Crédito R$ 5,00 = Custo Líquido R$ 90,00
- Fornecedor C: Preço R$ 105,00 - Crédito R$ 20,00 = Custo Líquido R$ 85,00

#### Passo 3: análise do resultado

Fornecedor A e C têm custo líquido igual a R$ 85,00, apesar de C ter preço bruto maior, mas também crédito maior. Fornecedor B tem preço bruto menor, porém crédito insuficiente para superar os demais. Portanto, A e C são opções economicamente mais vantajosas.

#### Passo 4: decisão considerando outros fatores

Além do custo líquido, outros aspectos podem influenciar, como prazo, qualidade do serviço e regime tributário do fornecedor. No entanto, do ponto de vista tributário, A e C são equivalentes e superiores a B.

### Implementação prática em sistema

Para automatizar essa análise, o sistema deve:

- Receber o CNAE do fornecedor e validar sua vinculação ao código LC116 (2.9, 3.12).  
- Consultar a tabela de vinculação LC116 x NBS para identificar o serviço e a possibilidade de crédito (3.13, 4.7).  
- Calcular os tributos ISS, IBS e CBS conforme alíquotas vigentes e aplicar os créditos garantidos por legislação (5.9, 5.13).  
- Calcular o custo líquido e ordenar fornecedores para facilitar a decisão (9.6, 10.6).  

Segue exemplo completo em Python que simula essa comparação para três fornecedores, considerando preços, créditos e vínculo dos códigos:

```python
# Definição dos fornecedores
fornecedores = [
    {
        'nome': 'Fornecedor A',
        'preco_bruto': 100.00,
        'cnae': '8120302',
        'codigo_lc116': '14.01',
        'codigo_nbs': '14010100',
        'credito_tributario': 15.00
    },
    {
        'nome': 'Fornecedor B',
        'preco_bruto': 95.00,
        'cnae': '8120302',
        'codigo_lc116': '14.02',
        'codigo_nbs': '14020200',
        'credito_tributario': 5.00
    },
    {
        'nome': 'Fornecedor C',
        'preco_bruto': 105.00,
        'cnae': '8120303',
        'codigo_lc116': '14.01',
        'codigo_nbs': '14010100',
        'credito_tributario': 20.00
    }
]

# Função para validar vinculação CNAE x LC116
def validar_vinculacao(cnae, lc116):
    vinculacoes_validas = {
        '8120302': ['14.01', '14.02'],
        '8120303': ['14.01']
    }
    if cnae not in vinculacoes_validas:
        raise ValueError(f"CNAE {cnae} não encontrado na tabela de vínculos.")
    if lc116 not in vinculacoes_validas[cnae]:
        raise ValueError(f"Erro de vinculação: CNAE {cnae} incompatível com código LC116 {lc116}.")
    return True

# Função para calcular custo líquido com crédito tributário
def calcular_custo_liquido(preco_bruto, credito):
    custo_liquido = preco_bruto - credito
    # Imposto devido não pode ser negativo
    if custo_liquido < 0:
        custo_liquido = 0.0
    return custo_liquido

# Processar fornecedores
resultado = []
for f in fornecedores:
    try:
        validar_vinculacao(f['cnae'], f['codigo_lc116'])
        custo_liquido = calcular_custo_liquido(f['preco_bruto'], f['credito_tributario'])
        resultado.append({
            'nome': f['nome'],
            'custo_liquido': custo_liquido
        })
    except ValueError as e:
        print(f"Erro para {f['nome']}: {e}")

# Ordenar fornecedores por custo líquido
resultado.sort(key=lambda x: x['custo_liquido'])

# Exibir resultado
print("Comparação de Custos Líquidos Entre Fornecedores:")
for r in resultado:
    print(f"{r['nome']}: R$ {r['custo_liquido']:.2f}")
```

Saída esperada:

```
Comparação de Custos Líquidos Entre Fornecedores:
Fornecedor A: R$ 85.00
Fornecedor C: R$ 85.00
Fornecedor B: R$ 90.00
```

### Erro comum e correção

Se alterarmos o código LC116 de um fornecedor para um código incompatível, por exemplo, para '14.03' no Fornecedor B, ocorrerá erro:

```plaintext
Erro para Fornecedor B: Erro de vinculação: CNAE 8120302 incompatível com código LC116 14.03.
```

A correção é consultar a tabela oficial de vinculação CNAE x LC116 e ajustar o código para um válido, garantindo a correta apropriação de créditos e cálculo tributário confiável.

### Exercício proposto

Calcule e compare o custo líquido do Fornecedor C considerando seu CNAE, código LC116, código NBS, preço bruto e créditos tributários, para decidir qual fornecedor apresenta a melhor opção econômica tributária.