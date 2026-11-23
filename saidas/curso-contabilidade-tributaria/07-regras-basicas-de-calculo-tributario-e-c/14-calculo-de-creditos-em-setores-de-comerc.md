## Cálculo de Créditos em Setores de Comércio e Serviços

Na prática da contabilidade tributária, um dos maiores desafios para empresas dos setores de comércio e serviços é determinar o custo líquido real das operações, considerando não só o preço bruto dos fornecedores, mas também os créditos tributários gerados. A nova reforma tributária, ao uniformizar e integrar os sistemas de ISS, IBS e CBS, além de vincular códigos como CNAE, LC116 e NBS, exige que o cálculo dos créditos seja feito de forma correta e simples para que a decisão de escolha do fornecedor seja realmente vantajosa.

### Por que calcular créditos em setores de comércio e serviços?

Imagine que você tenha dois fornecedores para o mesmo serviço:

- Fornecedor A cobra R$ 100,00 e gera R$ 15,00 em crédito tributário.
- Fornecedor B cobra R$ 95,00 mas não gera créditos.

À primeira vista, Fornecedor B parece mais barato. Porém, ao descontar o crédito, o custo líquido de A fica R$ 85,00, mais vantajoso. Se esse aspecto tributário não for considerado, a empresa pode pagar mais caro.

### Passos básicos para o cálculo de créditos

No contexto dos setores de comércio e serviços, o cálculo de créditos tributários deve respeitar as regras da legislação vigente e as vinculações estabelecidas entre os códigos CNAE, LC116 e NBS, para garantir a apropriação correta dos créditos.

1. **Identificar o CNAE do fornecedor**: Classifica sua atividade econômica, fundamental para vincular o código LC116.
2. **Vincular o CNAE ao código de serviço LC116**: Determina qual serviço está sendo contratado e qual o ISS incidente.
3. **Vincular o código LC116 ao código NBS**: Garante a correta classificação do serviço para incidência do tributo e apuração do crédito.
4. **Calcular a base de cálculo ajustada**: Considerar o preço bruto menos descontos condicionais e excluir impostos destacados, conforme regra para ISS e IBS; no CBS, a base é o preço bruto integral.
5. **Aplicar a alíquota correta**: ISS, IBS e CBS têm alíquotas específicas que incidem sobre a base de cálculo.
6. **Aplicar o crédito tributário**: Deduzir o crédito até o limite do imposto devido, nunca gerando imposto negativo.

### Exemplo prático: serviço em setor de comércio

Considere um serviço prestado por um fornecedor com CNAE que indica comércio varejista e prestação de serviços associados, com as seguintes informações:

- Preço bruto do serviço: R$ 2.000,00
- Desconto condicional: R$ 100,00 (excluído da base de cálculo do ISS e IBS)
- Alíquota do IBS: 12%
- Crédito tributário disponível: R$ 250,00

#### Passo 1: Calcular a base de cálculo do IBS

Base de cálculo IBS = Preço bruto - Desconto condicional  
Base de cálculo IBS = R$ 2.000,00 - R$ 100,00 = R$ 1.900,00

#### Passo 2: Calcular o imposto bruto

Imposto bruto IBS = Base de cálculo × Alíquota  
Imposto bruto IBS = R$ 1.900,00 × 12% = R$ 228,00

#### Passo 3: Aplicar o crédito tributário

Aqui, o crédito de R$ 250,00 é maior que o imposto bruto de R$ 228,00, então o imposto líquido será zero (não há restituição).

Imposto líquido = max(0, Imposto bruto - Crédito tributário)  
Imposto líquido = max(0, R$ 228,00 - R$ 250,00) = R$ 0,00

#### Passo 4: Calcular o custo líquido

Custo líquido = Preço bruto - Desconto condicional + Imposto líquido  
Custo líquido = R$ 2.000,00 - R$ 100,00 + R$ 0,00 = R$ 1.900,00

Este cálculo demonstra que, apesar de o preço bruto ser R$ 2.000,00, após o desconto e a apropriação do crédito, o custo líquido efetivo é R$ 1.900,00.

### Exemplo prático: serviço em setor de serviços

Agora, considere um fornecedor do setor de serviços com as seguintes condições:

- Preço bruto do serviço: R$ 1.500,00
- Desconto condicional: R$ 0,00
- Alíquota do ISS: 5%
- Crédito tributário disponível: R$ 50,00

#### Passo 1: Calcular a base de cálculo do ISS

Base de cálculo ISS = Preço bruto - Desconto condicional  
Base de cálculo ISS = R$ 1.500,00 - R$ 0,00 = R$ 1.500,00

#### Passo 2: Calcular o imposto bruto

Imposto bruto ISS = Base de cálculo × Alíquota  
Imposto bruto ISS = R$ 1.500,00 × 5% = R$ 75,00

#### Passo 3: Aplicar o crédito tributário

Imposto líquido = max(0, Imposto bruto - Crédito tributário)  
Imposto líquido = max(0, R$ 75,00 - R$ 50,00) = R$ 25,00

#### Passo 4: Calcular o custo líquido

Custo líquido = Preço bruto - Desconto condicional + Imposto líquido  
Custo líquido = R$ 1.500,00 - R$ 0,00 + R$ 25,00 = R$ 1.525,00

### Erros comuns e como evitá-los

1. **Aplicar alíquota sobre preço bruto sem excluir descontos condicionais**: Isso aumenta indevidamente o imposto devido e o custo líquido.
2. **Deduzir descontos condicionalmente na base do CBS**: Diferentemente do ISS e IBS, a base do CBS é o preço bruto integral, sem exclusões.
3. **Aplicar crédito tributário além do imposto devido**: O imposto não pode ficar negativo; o excesso de crédito não gera restituição.
4. **Usar CNAE, LC116 ou NBS desatualizados ou incompatíveis**: Isso pode impedir a apropriação válida dos créditos e causar erros fiscais.

### Código Python completo ilustrando cálculo do IBS com crédito tributário no setor de comércio

```python
def calcular_custo_liquido(preco_bruto, desconto_condicional, aliquota, credito_tributario):
    # Base de cálculo ajustada para IBS e ISS: preço bruto menos descontos condicionais
    base_calculo = preco_bruto - desconto_condicional

    # Calcular imposto bruto
    imposto_bruto = base_calculo * aliquota / 100

    # Aplicar crédito tributário, limitando o imposto líquido a zero no mínimo
    imposto_liquido = max(0, imposto_bruto - credito_tributario)

    # Calcular custo líquido efetivo
    custo_liquido = preco_bruto - desconto_condicional + imposto_liquido

    return {
        "base_calculo": base_calculo,
        "imposto_bruto": imposto_bruto,
        "credito_aplicado": min(credito_tributario, imposto_bruto),
        "imposto_liquido": imposto_liquido,
        "custo_liquido": custo_liquido
    }

# Dados do exemplo para setor de comércio
preco_bruto = 2000.00
desconto_condicional = 100.00
aliquota_ibs = 12.0
credito_tributario = 250.00

resultado = calcular_custo_liquido(preco_bruto, desconto_condicional, aliquota_ibs, credito_tributario)

print("Base de Cálculo:", f"R$ {resultado['base_calculo']:.2f}")
print("Imposto Bruto:", f"R$ {resultado['imposto_bruto']:.2f}")
print("Crédito Aplicado:", f"R$ {resultado['credito_aplicado']:.2f}")
print("Imposto Líquido:", f"R$ {resultado['imposto_liquido']:.2f}")
print("Custo Líquido:", f"R$ {resultado['custo_liquido']:.2f}")
```

Saída esperada:

```
Base de Cálculo: R$ 1900.00
Imposto Bruto: R$ 228.00
Crédito Aplicado: R$ 228.00
Imposto Líquido: R$ 0.00
Custo Líquido: R$ 1900.00
```

### Aplicação prática para comparação entre fornecedores

Para comparar fornecedores, calcule o custo líquido de cada um, considerando seus preços brutos, descontos condicionais, alíquotas tributárias e créditos gerados. O fornecedor com menor custo líquido será a escolha mais econômica.

Por exemplo:

| Fornecedor | Preço Bruto | Desconto Condicional | Alíquota (%) | Crédito Tributário | Custo Líquido |
|------------|-------------|---------------------|--------------|--------------------|---------------|
| A          | R$ 100,00   | R$ 0,00             | 12% (IBS)    | R$ 15,00           | R$ 85,00      |
| B          | R$ 95,00    | R$ 0,00             | 12% (IBS)    | R$ 0,00            | R$ 106,40     |

Mesmo com preço bruto maior, o Fornecedor A é mais barato no custo efetivo.

### Exercício prático

Calcule o custo líquido e o imposto devido para um serviço com preço bruto de R$ 2.000,00, desconto condicional de R$ 100,00, alíquota do IBS de 12% e crédito tributário de R$ 250,00. Considere as regras de base de cálculo, limite de crédito e cálculo do imposto líquido.