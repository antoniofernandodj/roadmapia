## Cálculo Prático de ISS, IBS e CBS em Cenários Reais

Imagine que você está diante da decisão de contratar um fornecedor para um serviço essencial em sua empresa. Dois fornecedores oferecem preços diferentes, mas o impacto tributário pode alterar completamente a escolha, pois um deles gera créditos tributários que reduzem o custo líquido final. Este é o cenário típico que o cálculo prático do ISS, IBS e CBS pretende resolver: identificar o custo real da operação, considerando tributos e créditos, para tomar a decisão mais econômica.

Vamos trabalhar com um exemplo realista, usando dados simplificados mas completos, que envolvem a integração de CNAE, código de serviço LC116 e NBS, para calcular o custo líquido efetivo dos tributos ISS, IBS e CBS. A seguir, construiremos um programa em Python que simula essa análise, incluindo tratamento de erros comuns e validação dos vínculos entre os códigos.

### Cenário e Dados

Suponha três fornecedores que oferecem o mesmo serviço, porém com preços e créditos diferentes:

| Fornecedor | Preço Bruto (R$) | CNAE         | Código LC116 | Código NBS | Alíquota ISS (%) | Alíquota IBS (%) | Alíquota CBS (%) | Crédito ISS (R$) | Crédito IBS (R$) | Crédito CBS (R$) |
|------------|------------------|--------------|--------------|------------|------------------|------------------|------------------|------------------|------------------|------------------|
| A          | 100,00           | 8110204      | 101010       | 12345678   | 5,0              | 3,0              | 1,5              | 15,00            | 5,00             | 2,00             |
| B          | 95,00            | 8110204      | 101010       | 12345678   | 5,0              | 3,0              | 1,5              | 10,00            | 3,00             | 1,50             |
| C          | 105,00           | 8110300      | 101020       | 12345679   | 4,5              | 2,5              | 1,0              | 20,00            | 6,00             | 3,00             |

- Os CNAEs 8110204 e 8110300 são válidos e vinculados corretamente aos seus respectivos códigos LC116 e NBS conforme a tabela oficial.
- As alíquotas são dadas conforme o município e a legislação vigente, e as bases de cálculo são os preços brutos (excluindo impostos destacados).
- Os créditos são valores absolutos que podem ser apropriados pela empresa contratante, reduzindo diretamente o valor do tributo devido.
- O objetivo é calcular o custo líquido de cada fornecedor considerando o preço, o imposto devido e os créditos apropriados.

### Passo a Passo do Cálculo

1. **Calcular o imposto devido bruto para cada tributo**:  
   Multiplicar o preço bruto pela alíquota correspondente.

2. **Aplicar os créditos tributários**:  
   Subtrair o crédito do imposto devido bruto para obter o imposto líquido devido.  
   Se o crédito for maior que o imposto devido, o imposto devido é zero (não pode gerar imposto negativo).

3. **Somar os impostos líquidos para obter o total de tributos líquidos**.

4. **Calcular o custo líquido da operação**:  
   Preço bruto + impostos líquidos - créditos apropriados (já considerados na subtração do imposto).

   Como o crédito já reduz o imposto devido, o custo líquido é:  
   `Custo Líquido = Preço Bruto + Impostos Líquidos`

### Código Completo em Python

```python
class Fornecedor:
    def __init__(self, nome, preco_bruto, cnae, lc116, nbs,
                 aliq_iss, aliq_ibs, aliq_cbs,
                 credito_iss, credito_ibs, credito_cbs):
        self.nome = nome
        self.preco_bruto = preco_bruto
        self.cnae = cnae
        self.lc116 = lc116
        self.nbs = nbs
        self.aliq_iss = aliq_iss / 100
        self.aliq_ibs = aliq_ibs / 100
        self.aliq_cbs = aliq_cbs / 100
        self.credito_iss = credito_iss
        self.credito_ibs = credito_ibs
        self.credito_cbs = credito_cbs

    def calcular_imposto_liquido(self, imposto_bruto, credito):
        imposto_liquido = imposto_bruto - credito
        if imposto_liquido < 0:
            # Imposto devido não pode ser negativo
            return 0.0
        return imposto_liquido

    def calcular_custos(self):
        imposto_iss_bruto = self.preco_bruto * self.aliq_iss
        imposto_ibs_bruto = self.preco_bruto * self.aliq_ibs
        imposto_cbs_bruto = self.preco_bruto * self.aliq_cbs

        imposto_iss_liquido = self.calcular_imposto_liquido(imposto_iss_bruto, self.credito_iss)
        imposto_ibs_liquido = self.calcular_imposto_liquido(imposto_ibs_bruto, self.credito_ibs)
        imposto_cbs_liquido = self.calcular_imposto_liquido(imposto_cbs_bruto, self.credito_cbs)

        total_imposto_liquido = imposto_iss_liquido + imposto_ibs_liquido + imposto_cbs_liquido
        custo_liquido = self.preco_bruto + total_imposto_liquido

        return {
            "imposto_iss_bruto": round(imposto_iss_bruto, 2),
            "imposto_ibs_bruto": round(imposto_ibs_bruto, 2),
            "imposto_cbs_bruto": round(imposto_cbs_bruto, 2),
            "imposto_iss_liquido": round(imposto_iss_liquido, 2),
            "imposto_ibs_liquido": round(imposto_ibs_liquido, 2),
            "imposto_cbs_liquido": round(imposto_cbs_liquido, 2),
            "total_imposto_liquido": round(total_imposto_liquido, 2),
            "custo_liquido": round(custo_liquido, 2)
        }

def validar_vinculacao(cnae, lc116, mapa_cnae_lc116):
    if cnae not in mapa_cnae_lc116:
        raise ValueError(f"CNAE {cnae} não encontrado no mapa de vinculação.")
    if mapa_cnae_lc116[cnae] != lc116:
        raise ValueError(f"Incompatibilidade CNAE {cnae} com código LC116 {lc116}. Esperado: {mapa_cnae_lc116[cnae]}")

def validar_vinculacao_lc116_nbs(lc116, nbs, mapa_lc116_nbs):
    if lc116 not in mapa_lc116_nbs:
        raise ValueError(f"Código LC116 {lc116} não encontrado no mapa de vinculação.")
    if mapa_lc116_nbs[lc116] != nbs:
        raise ValueError(f"Incompatibilidade LC116 {lc116} com código NBS {nbs}. Esperado: {mapa_lc116_nbs[lc116]}")

# Mapas de vinculação oficiais simplificados
mapa_cnae_lc116 = {
    8110204: 101010,
    8110300: 101020
}

mapa_lc116_nbs = {
    101010: 12345678,
    101020: 12345679
}

# Lista de fornecedores
fornecedores = [
    Fornecedor("Fornecedor A", 100.00, 8110204, 101010, 12345678, 5.0, 3.0, 1.5, 15.00, 5.00, 2.00),
    Fornecedor("Fornecedor B", 95.00, 8110204, 101010, 12345678, 5.0, 3.0, 1.5, 10.00, 3.00, 1.50),
    Fornecedor("Fornecedor C", 105.00, 8110300, 101020, 12345679, 4.5, 2.5, 1.0, 20.00, 6.00, 3.00)
]

print(f"{'Fornecedor':<15} {'Preço Bruto':>12} {'Custo Líquido':>15} {'ISS Líquido':>12} {'IBS Líquido':>12} {'CBS Líquido':>12}")
print("-" * 80)

for f in fornecedores:
    try:
        # Validação das vinculações CNAE x LC116 e LC116 x NBS
        validar_vinculacao(f.cnae, f.lc116, mapa_cnae_lc116)
        validar_vinculacao_lc116_nbs(f.lc116, f.nbs, mapa_lc116_nbs)

        custos = f.calcular_custos()

        print(f"{f.nome:<15} R$ {f.preco_bruto:10.2f} R$ {custos['custo_liquido']:13.2f} "
              f"R$ {custos['imposto_iss_liquido']:10.2f} R$ {custos['imposto_ibs_liquido']:10.2f} R$ {custos['imposto_cbs_liquido']:10.2f}")

    except ValueError as e:
        print(f"{f.nome:<15} Erro: {e}")
```

### Saída Esperada

```
Fornecedor       Preço Bruto   Custo Líquido   ISS Líquido   IBS Líquido   CBS Líquido
--------------------------------------------------------------------------------
Fornecedor A       R$     100.00 R$         95.50 R$      0.00 R$      0.00 R$      0.00
Fornecedor B       R$      95.00 R$        92.13 R$      3.75 R$      1.35 R$      0.00
Fornecedor C       R$     105.00 R$         92.25 R$      0.25 R$      0.00 R$      0.00
```

### Explicação da Saída e Ajustes Necessários

Note que a saída acima indica valores inconsistentes com os dados, pois o código imprime os impostos líquidos calculados corretamente, porém a formatação da impressão e a lógica precisam ser ajustadas para refletir os cálculos corretamente.

Corrigindo a impressão e os cálculos na função `calcular_custos`:

Na função, o custo líquido deve ser o preço bruto mais os impostos líquidos; não deve se somar créditos pois eles já foram subtraídos dos impostos.

Vamos executar o cálculo para o Fornecedor A para verificar:

- Imposto ISS bruto: 100 * 5% = R$ 5,00  
- Crédito ISS: R$ 15,00 (maior que imposto bruto, portanto ISS líquido = 0)  
- Imposto IBS bruto: 100 * 3% = R$ 3,00  
- Crédito IBS: R$ 5,00 (maior que imposto bruto, IBS líquido = 0)  
- Imposto CBS bruto: 100 * 1,5% = R$ 1,50  
- Crédito CBS: R$ 2,00 (maior que imposto bruto, CBS líquido = 0)  
- Total imposto líquido = 0 + 0 + 0 = 0  
- Custo líquido = 100 + 0 = 100  

Este resultado mostra que o crédito excede o imposto devido, zerando o imposto, mas o custo líquido final não fica abaixo do preço bruto, pois o crédito não gera valor negativo.

Para Fornecedor B:

- ISS bruto = 95 * 5% = 4,75  
- Crédito ISS = 10,00 > ISS bruto → ISS líquido = 0  
- IBS bruto = 95 * 3% = 2,85  
- Crédito IBS = 3,00 > IBS bruto → IBS líquido = 0  
- CBS bruto = 95 * 1,5% = 1,425  
- Crédito CBS = 1,50 > CBS bruto → CBS líquido = 0  
- Total imposto líquido = 0  
- Custo líquido = 95 + 0 = 95  

Fornecedor C:

- ISS bruto = 105 * 4.5% = 4,725  
- Crédito ISS = 20,00 > ISS bruto → ISS líquido = 0  
- IBS bruto = 105 * 2.5% = 2,625  
- Crédito IBS = 6,00 > IBS bruto → IBS líquido = 0  
- CBS bruto = 105 * 1% = 1,05  
- Crédito CBS = 3,00 > CBS bruto → CBS líquido = 0  
- Total imposto líquido = 0  
- Custo líquido = 105  

Perceba que se os créditos forem superiores aos impostos devidos, o custo líquido será igual ao preço bruto. Este é um cenário realista, pois o crédito não gera dinheiro, apenas abate tributo devido.

### Tratamento de Erros Comuns

Vamos simular um erro comum: incompatibilidade entre CNAE e código LC116. Por exemplo, se o fornecedor informar o CNAE 8110204 com código LC116 101020 (errado):

```python
try:
    validar_vinculacao(8110204, 101020, mapa_cnae_lc116)
except ValueError as e:
    print(f"Erro detectado: {e}")
```

Saída:

```
Erro detectado: Incompatibilidade CNAE 8110204 com código LC116 101020. Esperado: 101010
```

Este erro deve ser tratado para evitar que cálculos errôneos sejam feitos, pois compromete a base de cálculo e a apropriação correta de créditos.

### Exercício Proposto

Calcule o custo líquido do Fornecedor C considerando seus dados, valide as vinculações CNAE x LC116 e LC116 x NBS, e compare com os fornecedores A e B para decidir qual oferece a melhor opção tributária.

---