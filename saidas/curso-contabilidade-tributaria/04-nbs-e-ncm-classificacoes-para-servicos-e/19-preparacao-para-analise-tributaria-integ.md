## Preparação para Análise Tributária Integrada com NBS e NCM

Para realizar uma análise tributária eficiente que permita comparar fornecedores além do preço bruto, é necessário integrar corretamente as classificações NBS (Nomenclatura Brasileira de Serviços) e NCM (Nomenclatura Comum do Mercosul) com os demais códigos tributários, especialmente CNAE e LC116. Essa integração permite identificar os serviços e mercadorias de forma detalhada e precisa, facilitando a aplicação correta das alíquotas, o cálculo dos tributos devidos e a apropriação dos créditos tributários que influenciam diretamente o custo líquido.

### Por que integrar NBS e NCM na análise tributária?

Imagine que você tem duas propostas de fornecedores para o mesmo serviço ou mercadoria. O fornecedor A cobra R$ 100,00, e o fornecedor B cobra R$ 95,00. À primeira vista, o fornecedor B parece mais vantajoso. No entanto, se o serviço do fornecedor A está classificado em um código NBS que gera R$ 15,00 de crédito tributário para a sua empresa, o custo real líquido desse serviço será R$ 85,00, tornando o fornecedor A a melhor escolha. Sem integrar as classificações NBS e NCM corretamente, essa análise não seria possível, pois faltariam as informações essenciais para calcular os créditos e os tributos aplicáveis.

### Como preparar os dados para a análise integrada?

A preparação começa a partir do CNAE do fornecedor, que identifica sua atividade econômica principal. A partir do CNAE, vincula-se o código de serviço LC116 correspondente, que detalha o serviço prestado segundo a legislação municipal do ISS. Em seguida, vincula-se o código LC116 ao código NBS, que especifica o serviço com a granularidade necessária para o cálculo correto do ISS e a apropriação dos créditos tributários.

Para mercadorias, o processo é similar: a identificação da mercadoria com o código NCM correto é essencial para aplicar tributos federais (IPI, IBS, CBS) e estaduais (ICMS), além de permitir a apropriação correta de créditos tributários.

### Mecanismos de integração e vinculação

1. **Vinculação CNAE → LC116**: Garante que o código de serviço corresponda à atividade econômica informada pela empresa fornecedora, evitando erros na classificação e tributação.

2. **Vinculação LC116 → NBS**: Detalha o serviço para garantir que o ISS seja aplicado corretamente, considerando a especificidade do serviço e permitindo a apropriação correta dos créditos tributários.

3. **Vinculação direta do NCM com códigos de tributação**: Para mercadorias, o código NCM é vinculado às tabelas federais e estaduais, definindo alíquotas e créditos para IPI, ICMS, IBS e CBS.

Essa vinculação hierárquica assegura que as operações sejam classificadas com precisão, evitando erros comuns como uso de códigos genéricos ou desatualizados, que geram rejeições fiscais e prejuízo financeiro.

### Exemplo prático: integração para análise tributária de fornecedor

Suponha que sua empresa esteja avaliando um serviço de consultoria em segurança da informação. O fornecedor informa o CNAE 62.04-0/00 (Desenvolvimento de programas de computador sob encomenda), o código de serviço LC116 03.01 (Consultoria em tecnologia da informação) e informa o código NBS 1234.56.78 (Consultoria em segurança da informação).

- **Passo 1:** O sistema valida se o CNAE 62.04-0/00 está corretamente vinculado ao código LC116 03.01.
- **Passo 2:** Valida-se a correlação entre LC116 03.01 e o código NBS 1234.56.78 para garantir que o serviço está perfeitamente detalhado.
- **Passo 3:** Com o código NBS específico, calcula-se o ISS devido com a alíquota correta e o crédito tributário aplicável.
- **Passo 4:** O sistema verifica se o crédito gerado pode ser apropriado, reduzindo o custo líquido do serviço.
- **Passo 5:** O custo líquido do fornecedor é calculado considerando o preço bruto menos o crédito tributário.

Se houver outro fornecedor com preço bruto menor, porém com código NBS que não gera crédito ou com crédito menor, o sistema indicará qual fornecedor oferece o menor custo líquido tributário, fundamentando a decisão de compra.

### Utilização para mercadorias: NCM

Para mercadorias, o processo de integração é semelhante, porém envolve a classificação correta do produto pelo código NCM, que define a incidência e alíquotas de tributos como IPI, ICMS, IBS e CBS.

Exemplo prático: compra de um notebook usado.

- O fornecedor A utiliza o código NCM correto para notebook usado (por exemplo, 8471.30.11).
- O fornecedor B utiliza um código genérico para equipamentos usados (8473.99.99).

Apesar do preço bruto do fornecedor B ser menor, o código genérico pode não garantir a apropriação adequada de créditos tributários, enquanto o código específico do fornecedor A pode gerar crédito maior, reduzindo o custo líquido da compra.

### Erros comuns na preparação e integração

- **Uso de códigos genéricos:** Classificações genéricas em NBS ou NCM dificultam a correta aplicação das alíquotas e apropriação dos créditos, levando a rejeições fiscais ou perda de créditos.
- **Desatualização de tabelas:** NBS e NCM são atualizadas periodicamente. Sistemas que não mantêm as tabelas atualizadas aplicam códigos incorretos.
- **Incompatibilidade entre códigos:** Falta de validação cruzada entre CNAE, LC116 e NBS gera erros de classificação e cálculo tributário.
- **Não aproveitamento dos créditos:** Sem a integração correta, créditos tributários relevantes podem ser ignorados, aumentando o custo líquido.

### Preparação dos sistemas para análise integrada

Para automatizar essa análise, o sistema deve:

- Manter atualizadas as tabelas oficiais de CNAE, LC116, NBS e NCM.
- Validar automaticamente as vinculações entre os códigos para evitar incompatibilidades.
- Calcular o ISS, IBS e CBS considerando as alíquotas específicas e créditos tributários.
- Permitir comparação entre fornecedores considerando o custo líquido tributário.
- Registrar e manter histórico das classificações para auditoria e compliance.

### Exemplo de código simplificado para validação e cálculo

```python
# Tabelas fictícias simplificadas para exemplo
cnae_lc116 = {
    "6204-0/00": "0301",  # CNAE para consultoria TI vinculado ao LC116 0301
}

lc116_nbs = {
    "0301": "1234.56.78",  # LC116 0301 vinculado ao código NBS específico
}

# Alíquotas e créditos por código NBS
nbs_tributos = {
    "1234.56.78": {"aliquota_iss": 0.05, "credito": 15.0},  # 5% ISS e R$15 crédito
    "0000.00.00": {"aliquota_iss": 0.05, "credito": 0.0},   # código genérico, sem crédito
}

def calcular_custo_liquido(preco_bruto, cnae, preco_licitado):
    lc116 = cnae_lc116.get(cnae)
    if not lc116:
        raise ValueError(f"CNAE {cnae} não vinculado a código LC116.")
    
    nbs = lc116_nbs.get(lc116)
    if not nbs:
        raise ValueError(f"Código LC116 {lc116} não vinculado a código NBS.")
    
    trib = nbs_tributos.get(nbs)
    if not trib:
        raise ValueError(f"Código NBS {nbs} não encontrado na tabela de tributos.")
    
    credito = trib["credito"]
    custo_liquido = preco_bruto - credito
    return custo_liquido

# Exemplo de uso
fornecedor_a_preco = 100.0
fornecedor_a_cnae = "6204-0/00"

fornecedor_b_preco = 95.0
fornecedor_b_cnae = "6204-0/00"  # mesmo CNAE, mas sem crédito

try:
    custo_a = calcular_custo_liquido(fornecedor_a_preco, fornecedor_a_cnae, fornecedor_a_preco)
    custo_b = calcular_custo_liquido(fornecedor_b_preco, fornecedor_b_cnae, fornecedor_b_preco)
    print(f"Custo líquido fornecedor A: R$ {custo_a:.2f}")
    print(f"Custo líquido fornecedor B: R$ {custo_b:.2f}")
except ValueError as e:
    print("Erro na análise:", e)
```

Saída esperada:

```
Custo líquido fornecedor A: R$ 85.00
Custo líquido fornecedor B: R$ 95.00
```

Esse exemplo demonstra como a integração dos códigos permite identificar que, apesar do preço bruto maior, o fornecedor A oferece custo líquido menor por gerar crédito tributário relevante.

### Exercício proposto

Dado um serviço de consultoria em segurança da informação com CNAE 62.04-0/00 e código LC116 0301, pesquise o código NBS atualizado para 2024 correspondente a este serviço e explique como essa classificação integrada permite calcular corretamente o ISS devido e o crédito tributário, influenciando a comparação entre dois fornecedores com preços diferentes.

---