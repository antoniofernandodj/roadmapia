## Conceitos Básicos de Contabilidade Tributária

Imagine que sua empresa precisa comprar um serviço ou mercadoria de diferentes fornecedores. O preço à vista pode ser menor em um deles, mas, dependendo do regime tributário e dos créditos fiscais que você pode aproveitar, o custo final pode ser maior. Como saber qual é a melhor escolha? É aqui que a contabilidade tributária entra, oferecendo uma visão integrada dos valores pagos e dos créditos tributários gerados, para uma decisão mais precisa e econômica.

### Por que a contabilidade tributária é essencial?

A contabilidade tributária não é apenas registrar impostos pagos. Ela envolve o controle, a apuração e o planejamento dos tributos que incidem sobre as operações da empresa, considerando as normas vigentes — e agora, com a reforma tributária, esse cenário mudou significativamente. Entender como os tributos são calculados, quais créditos são gerados e como esses créditos impactam o custo final é fundamental para que a empresa otimize suas compras e sua carga tributária.

Sem essa visão, é comum cometer erros como escolher o fornecedor com menor preço bruto, ignorando que outro pode oferecer condições tributárias que reduzem o custo líquido efetivo.

### O que a contabilidade tributária controla?

No âmbito da contabilidade tributária, são acompanhados diversos elementos:

- **Base de cálculo:** o valor sobre o qual o tributo é aplicado (exemplo: o preço da mercadoria ou serviço).
- **Alíquotas:** percentuais definidos em lei que incidem sobre a base de cálculo para determinar o valor do tributo.
- **Créditos tributários:** valores que a empresa pode abater do montante devido, provenientes de tributos pagos em etapas anteriores da cadeia produtiva.
- **Tributos envolvidos:** no contexto brasileiro, principalmente ISS (Imposto Sobre Serviços), IBS (Imposto sobre Bens e Serviços), CBS (Contribuição sobre Bens e Serviços, criada pela reforma), entre outros.
- **Códigos e classificações:** como CNAE, LC116, NBS, NCM, e cTribNac, que ajudam a identificar a natureza da atividade, o tipo de serviço ou mercadoria, e a forma correta de tributação.

### Como a contabilidade tributária se adapta à reforma?

A reforma tributária promoveu mudanças nas regras, simplificações e unificações de impostos, como a criação do IBS e CBS para substituir tributos federais, estaduais e municipais em muitos casos. Isso impacta diretamente a contabilidade tributária, que precisa atualizar seus processos para considerar:

- **Novas bases e alíquotas.**
- **Mudança no cálculo e apropriação de créditos.**
- **Atualização dos códigos fiscais e tabelas oficiais.**
- **Integração entre classificações econômicas e códigos de serviços/mercadorias.**

Entender essa nova dinâmica evita erros que, além de onerar a empresa, podem gerar autuações fiscais.

### Exemplo prático: impacto na escolha do fornecedor

Suponha que você precise escolher entre dois fornecedores:

| Fornecedor | Preço Bruto | Crédito Tributário Possível | Preço Líquido Considerando Crédito |
|------------|-------------|-----------------------------|------------------------------------|
| A          | R$ 100,00   | R$ 15,00                    | R$ 85,00                           |
| B          | R$ 95,00    | R$ 0,00                     | R$ 95,00                           |

O fornecedor A parece mais caro à primeira vista, mas seu crédito tributário reduz o custo líquido para R$ 85,00, tornando-o a opção mais vantajosa.

Para calcular isso corretamente, é necessário:

1. Identificar o CNAE do fornecedor para entender sua atividade econômica.
2. Vincular o CNAE ao código de serviço na LC116, que formaliza o serviço tributado.
3. Relacionar o código LC116 à NBS, que detalha a natureza do serviço para fins tributários.
4. Conhecer as alíquotas e regras de crédito aplicáveis para ISS, IBS ou CBS, conforme o caso.
5. Calcular o crédito tributário que pode ser apropriado pela sua empresa.

Sem essa cadeia de informações e classificações, a comparação entre fornecedores fica incompleta e sujeita a erros.

### O papel dos códigos e classificações na contabilidade tributária

A contabilidade tributária depende fortemente da correta aplicação e interpretação dos códigos e classificações, que funcionam como "linguagens fiscais" para identificar a atividade econômica, o serviço ou o produto e a tributação correta.

- **CNAE (Classificação Nacional de Atividades Econômicas):** identifica a atividade econômica principal do fornecedor.
- **LC116 (Lei Complementar 116):** define a lista de serviços tributados pelo ISS e seus códigos.
- **NBS (Nomenclatura Brasileira de Serviços):** detalha os serviços para fins de tributação.
- **NCM (Nomenclatura Comum do Mercosul):** classifica mercadorias para aplicação de tributos federais.
- **cTribNac:** códigos nacionais de tributação que indicam o regime e condições tributárias aplicáveis.

Essas classificações são cruzadas para definir a tributação correta e os créditos possíveis, permitindo que a contabilidade tributária calcule o custo líquido real das operações.

### O que acontece "por baixo do capô"?

Quando uma empresa realiza uma compra, o sistema contábil fiscal:

1. Recebe o CNAE do fornecedor e o vincula ao código de serviço LC116 correspondente.
2. A partir do código LC116, o sistema identifica o código NBS aplicável, detalhando o serviço.
3. Com o NBS e o CNAE, o sistema consulta as tabelas fiscais para determinar as alíquotas vigentes de ISS, IBS ou CBS e as regras de crédito.
4. Calcula o tributo devido e os créditos tributários que podem ser apropriados.
5. Apresenta o custo líquido da operação, considerando os créditos, para auxiliar a decisão.

### Erro comum e sua correção

Um erro típico é considerar apenas o preço bruto do fornecedor, ignorando os créditos tributários. Por exemplo, suponha que um sistema receba os dados abaixo para cálculo:

```python
fornecedor = {
    "nome": "Fornecedor A",
    "preco_bruto": 100.0,
    "cnae": "6201-5/01",  # Desenvolvimento de software
    "credito_tributario": 0.0  # Crédito não calculado ainda
}

# Cálculo incorreto, sem crédito:
custo_liquido = fornecedor["preco_bruto"]
print(f"Custo líquido sem crédito: R$ {custo_liquido:.2f}")
```

Saída:

```
Custo líquido sem crédito: R$ 100.00
```

Aqui, o sistema não aplica o crédito tributário, levando a uma decisão errada.

A correção envolve:

- Vincular o CNAE ao código LC116.
- Associar o código LC116 ao NBS.
- Consultar as alíquotas e regras para identificar o crédito tributário aplicável (exemplo: R$ 15,00).
- Ajustar o custo líquido considerando o crédito.

Exemplo corrigido:

```python
# Valores simulados para o exemplo
credito_tributario = 15.0
custo_liquido = fornecedor["preco_bruto"] - credito_tributario
print(f"Custo líquido considerando crédito: R$ {custo_liquido:.2f}")
```

Saída:

```
Custo líquido considerando crédito: R$ 85.00
```

Agora, a decisão de compra será mais acertada.

### Resumo da importância para desenvolvimento de sistemas

Para desenvolver funcionalidades que permitam a comparação tributária entre fornecedores, é imprescindível:

- Conhecer os conceitos básicos da contabilidade tributária para entender o que precisa ser calculado.
- Entender o funcionamento dos códigos fiscais (CNAE, LC116, NBS, NCM, cTribNac) para vincular corretamente dados e regras.
- Atualizar as tabelas e regras conforme a reforma tributária.
- Implementar cálculos que considerem créditos tributários, não apenas preços brutos.
- Permitir que o sistema apresente o custo líquido para decisões mais precisas.

Dessa forma, o sistema será capaz de fornecer uma análise tributária integrada, resultando em economia real para a empresa.

---