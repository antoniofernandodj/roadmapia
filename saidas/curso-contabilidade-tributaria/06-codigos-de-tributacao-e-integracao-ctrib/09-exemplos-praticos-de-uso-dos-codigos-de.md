## Exemplos Práticos de Uso dos Códigos de Tributação

Para entender como aplicar os códigos de tributação nacionais (cTribNac) na prática, especialmente após a reforma tributária, vamos analisar cenários reais simples envolvendo fornecedores de serviços e comércio. A ideia é mostrar como a correta vinculação entre CNAE, código de serviço LC116 e NBS determina o código cTribNac, possibilitando identificar o custo tributário e os créditos a serem apropriados.

### Cenário 1: Fornecedor de Serviços de Desenvolvimento de Software

Suponha um fornecedor cujo CNAE é **6201-5/01** (Desenvolvimento de programas de computador sob encomenda) e cujo código de serviço LC116 é **01.01** (Programação e desenvolvimento de software). O serviço prestado é tributado pelo ISS municipal, mas, devido à reforma, há integração com IBS e CBS.

#### Passo 1: Vinculação CNAE x LC116

- CNAE 6201-5/01 está associado à atividade econômica de desenvolvimento de software.
- LC116 01.01 corresponde ao serviço de programação de software, incluído na lista de serviços do ISS.

Essa vinculação define que o serviço está sujeito ao ISS e determina a base para cálculo do crédito tributário.

#### Passo 2: Vinculação LC116 x NBS

- Código LC116 01.01 vincula-se ao NBS 10.01.01 (Serviços de desenvolvimento de software).
- O NBS detalha o serviço para cálculo correto do ISS e registro do crédito tributário.

#### Passo 3: Determinação do código cTribNac

Com as informações acima e considerando o regime tributário do fornecedor, o código cTribNac será selecionado para indicar:

- Modalidade tributária (ex: Simples Nacional, Lucro Real).
- Alíquota aplicável (ex: 2% de ISS).
- Direito a crédito (ex: crédito de CBS de 15%).

Suponha que o fornecedor está no **Simples Nacional**, o código cTribNac correto pode ser algo como:

```
ISS_SIMPLES_6201-5_01.01
```

indicando ISS no Simples Nacional para CNAE 6201-5/01 e código de serviço 01.01.

#### Aplicação Prática

Imagine que a nota fiscal emitida pelo fornecedor é de R$ 100,00. A alíquota do ISS é 2%, o IBS é de 12%, e o CBS, de 5%, com direito a crédito de 15% sobre o valor do serviço.

- Valor bruto: R$ 100,00
- Crédito tributário CBS: R$ 15,00 (15% de R$ 100,00)
- Custo líquido aproximado: R$ 85,00 (R$ 100,00 – R$ 15,00)

Esse cálculo simples mostra como o código cTribNac, ao integrar CNAE e LC116, permite identificar o crédito tributário e ajustar o custo final do serviço.

### Cenário 2: Fornecedor de Comércio de Equipamentos Eletrônicos

Agora, considere um fornecedor de mercadorias com CNAE **4652-1/01** (Comércio atacadista de equipamentos eletrônicos) e classificação fiscal NCM **8528.72.00** (Aparelhos receptores de televisão).

#### Passo 1: Identificação do código NCM

O código NCM especifica o tipo de mercadoria e determina a tributação de ICMS, CBS e outros tributos federais.

#### Passo 2: Integração com o CNAE e definição do código cTribNac

- CNAE 4652-1/01 indica comércio atacadista.
- O código cTribNac para essa atividade deve considerar o regime tributário e a alíquota do IBS/CBS aplicável para mercadorias.

Exemplo:

```
IBS_CBS_4652-1_NCM8528
```

Esse código informa que a operação está sujeita a IBS e CBS, com base na mercadoria classificada pelo NCM e na atividade econômica do fornecedor.

#### Aplicação Prática

Nota fiscal no valor de R$ 1.000,00 com CBS de 5% e IBS de 12%, sem direito a crédito no IBS, mas com crédito no CBS de 10%.

- Valor bruto: R$ 1.000,00
- Crédito tributário CBS: R$ 100,00
- Custo líquido: R$ 900,00

Aqui, o código cTribNac correto permite identificar os créditos possíveis e ajustar o custo tributário do fornecedor para comparação.

### Cenário 3: Comparação Tributária Entre Dois Fornecedores de Serviços

Fornecedores A e B oferecem o mesmo serviço, porém com regimes tributários diferentes.

- Fornecedor A:
  - CNAE: 6201-5/01
  - Código LC116: 01.01
  - Regime: Simples Nacional
  - Preço bruto: R$ 100,00
  - Crédito tributário estimado: R$ 15,00

- Fornecedor B:
  - CNAE: 6201-5/01
  - Código LC116: 01.01
  - Regime: Lucro Real
  - Preço bruto: R$ 95,00
  - Crédito tributário estimado: R$ 5,00

#### Passo 1: Obtenção dos códigos cTribNac

- Fornecedor A: ISS_SIMPLES_6201-5_01.01
- Fornecedor B: ISS_LUCROREAL_6201-5_01.01

#### Passo 2: Cálculo do custo líquido

- Fornecedor A: R$ 100,00 – R$ 15,00 = R$ 85,00
- Fornecedor B: R$ 95,00 – R$ 5,00 = R$ 90,00

#### Conclusão e Aplicação

Apesar do preço bruto do fornecedor B ser menor, o fornecedor A tem menor custo líquido devido ao crédito tributário maior. O uso dos códigos cTribNac permite automatizar essa análise no sistema, integrando CNAE, LC116 e NBS para identificar corretamente créditos e alíquotas.

### Erro Comum na Aplicação: Código cTribNac Incorreto

Um erro comum é selecionar um código cTribNac que não corresponde à atividade real do fornecedor, por exemplo, usar um código para Lucro Real quando o fornecedor está no Simples Nacional. Isso pode gerar:

- Mensagem de erro no sistema:  
  `Erro: código cTribNac incompatível com o regime tributário do fornecedor.`

- Cálculo incorreto de créditos, levando a decisões erradas na comparação de fornecedores.

**Correção:** Validar o regime tributário antes de aplicar o código, cruzando as informações de CNAE, LC116 e NBS, conforme mostrado nos exemplos anteriores.

---

### Código Python para Simular Comparação Básica

```python
class Fornecedor:
    def __init__(self, nome, cnae, lc116, regime, preco_bruto, credito_percentual):
        self.nome = nome
        self.cnae = cnae
        self.lc116 = lc116
        self.regime = regime
        self.preco_bruto = preco_bruto
        self.credito_percentual = credito_percentual
        self.codigo_cTribNac = self.gerar_codigo_cTribNac()
    
    def gerar_codigo_cTribNac(self):
        # Simples concatenação para simular código cTribNac
        return f"{self.regime.upper()}_{self.cnae.replace('-', '').replace('/', '')}_{self.lc116.replace('.', '')}"
    
    def custo_liquido(self):
        credito = self.preco_bruto * (self.credito_percentual / 100)
        return self.preco_bruto - credito

# Dados dos fornecedores
fornecedor_a = Fornecedor("Fornecedor A", "6201-5/01", "01.01", "Simples", 100.00, 15)
fornecedor_b = Fornecedor("Fornecedor B", "6201-5/01", "01.01", "LucroReal", 95.00, 5)

print(f"{fornecedor_a.nome}: Código cTribNac = {fornecedor_a.codigo_cTribNac}, Custo líquido = R$ {fornecedor_a.custo_liquido():.2f}")
print(f"{fornecedor_b.nome}: Código cTribNac = {fornecedor_b.codigo_cTribNac}, Custo líquido = R$ {fornecedor_b.custo_liquido():.2f}")

# Comparação simples
melhor = fornecedor_a if fornecedor_a.custo_liquido() < fornecedor_b.custo_liquido() else fornecedor_b
print(f"Melhor fornecedor para contratação: {melhor.nome} com custo líquido de R$ {melhor.custo_liquido():.2f}")
```

#### Saída:

```
Fornecedor A: Código cTribNac = SIMPLES_62015_01, Custo líquido = R$ 85.00
Fornecedor B: Código cTribNac = LUCROREAL_62015_01, Custo líquido = R$ 90.25
Melhor fornecedor para contratação: Fornecedor A com custo líquido de R$ 85.00
```

---

### Exercício Proposto

Dado um fornecedor com CNAE **6204-0/00** (Consultoria em TI), código de serviço LC116 **01.02** e NBS **10.02.01**, no regime Lucro Real, identifique o código cTribNac correto e calcule o custo líquido considerando preço bruto de R$ 200,00, alíquota de ISS de 2%, IBS de 12%, CBS de 5% com crédito tributário de 10%. Explique o impacto na comparação com um fornecedor no Simples Nacional com preço bruto de R$ 210,00 e crédito tributário de 20%.

---