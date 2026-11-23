## Resumo dos Passos para Cálculo e Comparação Tributária

Para realizar cálculos e comparações tributárias básicas que permitam escolher o fornecedor mais vantajoso do ponto de vista econômico e fiscal, é essencial seguir uma sequência lógica e integrada, garantindo a correta aplicação dos códigos CNAE, LC116 e NBS, bem como o cálculo adequado dos tributos ISS, IBS e CBS e a apropriação dos créditos tributários. A seguir, sintetizamos os passos práticos para esse processo.

---

### 1. Identificação do Fornecedor e Atividade Econômica via CNAE

Comece identificando o código CNAE correto do fornecedor, que representa a atividade econômica principal dele. Essa classificação é a base para vincular corretamente os demais códigos tributários e assegurar a aplicação das alíquotas e créditos adequados.

- Verifique a especificidade do CNAE, preferindo códigos completos e atualizados (2.8).
- Atenção a erros comuns, como uso de códigos genéricos ou incompatíveis com a atividade real (2.3, 2.7).

---

### 2. Vinculação do CNAE ao Código de Serviço LC116

Com o CNAE em mãos, vincule-o ao código de serviço previsto na LC116. Essa etapa é fundamental para identificar o serviço tributável pelo ISS e para definir a base legal da tributação municipal.

- Use tabelas oficiais e atualizadas para mapear CNAE → LC116 (3.12, 3.13).
- Valide a compatibilidade para evitar rejeição fiscal e perda de créditos (3.6, 3.9).
- Corrija incompatibilidades entre códigos para garantir a apropriação válida do crédito tributário (3.11).

---

### 3. Vinculação do Código LC116 ao Código NBS

Em seguida, vincule o código de serviço LC116 ao código NBS correspondente. A NBS detalha a classificação do serviço para fins de tributação, facilitando a aplicação correta do ISS e a integração com sistemas fiscais.

- Utilize a tabela vinculativa atualizada LC116 → NBS (4.7, 3.13).
- Evite o uso de códigos genéricos que podem gerar erros na emissão fiscal e cálculo tributário (4.12, 4.15).

---

### 4. Determinação da Base de Cálculo Ajustada para o Tributo

Para calcular o imposto devido, identifique e ajuste a base de cálculo conforme o tributo:

- **ISS e IBS:** A base deve ser o preço bruto menos descontos condicionais e quaisquer impostos destacados, conforme legislação vigente (5.5, 5.6).
- **CBS:** A base é o preço bruto integral, sem exclusão de descontos condicionais (5.7).

Exemplo de erro comum: aplicar a alíquota diretamente sobre o preço bruto sem excluir descontos condicionais, o que eleva indevidamente o imposto (5.5-5.7).

---

### 5. Aplicação da Alíquota Correta do Tributo

Com a base ajustada, aplique a alíquota vigente do tributo correspondente (ISS, IBS ou CBS).

- Alíquotas podem variar conforme município, estado e regime tributário (5.8).
- Use os códigos vinculados para garantir a alíquota correta (6.3, 6.4).
- Evite erro de aplicar alíquota incorreta ou de tributo não aplicável.

---

### 6. Cálculo do Imposto Bruto e Aplicação do Crédito Tributário

Calcule o imposto bruto multiplicando a base ajustada pela alíquota.

Aplique o crédito tributário disponível, que deve ser:

- Válido para o CNAE, LC116 e NBS vinculados (5.12, 5.13).
- Limitado para não gerar imposto líquido negativo (imposto mínimo zero) (5.9, 5.13).

Erro comum: descontar crédito maior que o imposto bruto, gerando imposto negativo, que não é permitido (5.9).

---

### 7. Cálculo do Custo Líquido da Operação

O custo líquido considera:

```text
Custo Líquido = Preço Bruto - Descontos Condicionais + Imposto Líquido
```

Note que o imposto líquido é o imposto bruto menos o crédito aplicado (limitado ao imposto bruto).

Esse valor representa o custo real para a empresa, refletindo a tributação e os créditos aproveitados.

---

### 8. Comparação entre Fornecedores

Para analisar e comparar fornecedores:

- Calcule o custo líquido para cada fornecedor usando os passos acima.
- Considere que um fornecedor com preço bruto maior pode ser mais vantajoso se gerar créditos tributários que reduzam seu custo líquido (1.8).
- Verifique a validade e compatibilidade dos créditos para garantir que possam ser apropriados (6.5).
- Utilize ferramentas digitais ou sistemas com integração das tabelas para automatizar o cálculo e evitar erros manuais (2.16, 6.14).

---

### Exemplo Prático Completo em Python

Este exemplo demonstra o cálculo do custo líquido para um serviço com:

- Preço bruto: R$ 2.000,00
- Desconto condicional: R$ 100,00
- Alíquota do IBS: 12%
- Crédito tributário: R$ 250,00

```python
def calcular_custo_liquido(preco_bruto, desconto_condicional, aliquota, credito):
    # Passo 1: Calcular base de cálculo ajustada (IBS desconta desconto condicional)
    base_calculo = preco_bruto - desconto_condicional
    # Passo 2: Calcular imposto bruto
    imposto_bruto = base_calculo * aliquota / 100
    # Passo 3: Aplicar crédito tributário com limite mínimo zero no imposto líquido
    imposto_liquido = max(imposto_bruto - credito, 0)
    # Passo 4: Calcular custo líquido
    custo_liquido = preco_bruto - desconto_condicional + imposto_liquido
    return base_calculo, imposto_bruto, imposto_liquido, custo_liquido

# Dados do exemplo
preco_bruto = 2000.00
desconto_condicional = 100.00
aliquota_ibs = 12.0
credito_tributario = 250.00

base, imposto_b, imposto_l, custo = calcular_custo_liquido(
    preco_bruto, desconto_condicional, aliquota_ibs, credito_tributario)

print(f"Base de cálculo: R$ {base:.2f}")
print(f"Imposto bruto: R$ {imposto_b:.2f}")
print(f"Imposto líquido (após crédito): R$ {imposto_l:.2f}")
print(f"Custo líquido da operação: R$ {custo:.2f}")
```

Saída gerada:

```
Base de cálculo: R$ 1900.00
Imposto bruto: R$ 228.00
Imposto líquido (após crédito): R$ 0.00
Custo líquido da operação: R$ 1900.00
```

---

### Erro Comum e Correção

**Erro:** Aplicar a alíquota diretamente sobre o preço bruto sem descontar o desconto condicional.

```python
# Código errado:
imposto_errado = preco_bruto * aliquota_ibs / 100  # 2000 * 12% = 240, maior que o correto
```

Esse erro aumenta o imposto indevidamente e prejudica a análise.

Além disso, tentar aplicar crédito maior que o imposto bruto gera resultado inválido (imposto negativo).

---

### Uso Prático na Escolha do Fornecedor

Suponha que:

- Fornecedor A: preço R$ 100,00; crédito R$ 15,00
- Fornecedor B: preço R$ 95,00; crédito R$ 0,00

Custo líquido:

- Fornecedor A: 100 - 15 = R$ 85,00 (após crédito)
- Fornecedor B: R$ 95,00 (sem crédito)

Assim, Fornecedor A é mais vantajoso, mesmo com preço bruto maior.

---

### Resumo dos Passos Essenciais

| Passo | Atividade                                                  |
|--------|------------------------------------------------------------|
| 1      | Identifique o CNAE do fornecedor                            |
| 2      | Vincule CNAE ao código LC116                                |
| 3      | Vincule LC116 ao código NBS                                 |
| 4      | Calcule base de cálculo ajustada para o tributo            |
| 5      | Aplique alíquota correta para ISS, IBS ou CBS              |
| 6      | Calcule imposto bruto e aplique crédito tributário (limite zero) |
| 7      | Calcule custo líquido da operação                           |
| 8      | Compare custos líquidos entre fornecedores para decisão    |

---

Seguindo esses passos, você garante o cálculo correto, evita erros comuns e consegue realizar comparações tributárias que refletem o custo real da operação, não apenas o preço bruto, alinhando-se ao novo contexto da reforma tributária.

---