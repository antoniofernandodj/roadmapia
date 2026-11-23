## Escrituração Fiscal e Contábil Relacionada à Tributação

A escrituração fiscal e contábil constitui a base para o controle efetivo e a conformidade tributária das empresas, especialmente após a reforma tributária que trouxe maior integração entre classificações econômicas e códigos fiscais. A correta escrituração não é apenas uma obrigação legal, mas um instrumento essencial para a análise estratégica do custo tributário, permitindo a comparação precisa entre fornecedores, considerando tanto os preços quanto os créditos tributários gerados.

### O Papel da Escrituração na Gestão Tributária

Imagine que sua empresa adquiriu serviços de dois fornecedores diferentes para o mesmo tipo de atividade. O preço bruto do Fornecedor A é R$ 100,00, enquanto o do Fornecedor B é R$ 95,00. À primeira vista, o Fornecedor B parece mais vantajoso. Contudo, se o Fornecedor A gera um crédito tributário de R$ 15,00, seu custo líquido será de R$ 85,00, tornando-o mais econômico. Para que essa análise seja possível, a escrituração fiscal e contábil deve registrar corretamente as operações, vinculando as classificações econômicas e os códigos tributários, garantindo a apropriação dos créditos e a apuração correta do imposto devido.

A escrituração fiscal envolve o registro detalhado das operações tributáveis, relacionando documentos fiscais, códigos de atividade econômica (CNAE), códigos de serviço (LC116), classificações de serviços (NBS) e mercadorias (NCM). Já a escrituração contábil incorpora esses registros na contabilidade financeira, refletindo o impacto tributário nas demonstrações contábeis.

### Estrutura da Escrituração Fiscal Relacionada à Tributação

A escrituração fiscal deve contemplar os seguintes elementos para garantir a conformidade e a correta apropriação dos créditos:

- **Identificação da operação:** data, natureza, e valores envolvidos.
- **Classificação econômica do fornecedor:** código CNAE, que vincula a atividade à legislação tributária.
- **Código de serviço LC116:** identifica o serviço tributável e determina a incidência do ISS.
- **Código NBS:** detalha o serviço para fins de tributação e vinculação com LC116.
- **Classificação NCM (quando aplicável):** para mercadorias, vinculando ao ICMS, IPI, CBS.
- **Tributos incidentes:** ISS, IBS, CBS e demais tributos conforme a operação.
- **Créditos tributários gerados:** valores e condições para apropriação.
- **Documentos fiscais emitidos:** Notas Fiscais de Serviços Eletrônicas (NFS-e), Notas Fiscais Eletrônicas (NF-e), entre outros.
- **Dados para obrigações acessórias:** registros para EFD, declarações e relatórios fiscais.

### Exemplo Prático de Escrituração Completa

Suponha um serviço contratado cujo valor bruto é R$ 1.000,00. A escrituração deverá registrar:

- **CNAE do fornecedor:** 62.01-5/01 (Desenvolvimento de programas de computador sob encomenda).
- **Código LC116:** 1.01 (Serviços de programação e desenvolvimento de software).
- **Código NBS:** 1.01.01 (Desenvolvimento de software customizado).
- **Valor do serviço:** R$ 1.000,00.
- **ISS devido:** aplicar alíquota conforme município, digamos 5% → R$ 50,00.
- **Crédito tributário aproveitável:** R$ 50,00, conforme legislação vigente.
- **Documento fiscal:** NFS-e com todos os códigos vinculados corretamente.

Esse registro permite que o sistema fiscal e contábil automatize a apropriação do crédito, reduzindo o custo tributário líquido da operação. Além disso, a escrituração correta assegura a validade jurídica dos documentos fiscais e evita autuações.

### Erros Comuns na Escrituração Fiscal e Como Corrigi-los

Um erro frequente é a incompatibilidade entre o CNAE informado e o código de serviço LC116 utilizado na nota fiscal. Por exemplo, se a empresa classifica seu CNAE como 62.01-5/01, mas emite a NFS-e com o código LC116 3.03 (serviço de limpeza), o sistema de validação da prefeitura rejeitará a nota, emitindo mensagem de erro como:

```
Erro: Código LC116 incompatível com CNAE informado.
```

Para corrigir, é necessário consultar a tabela de vinculação CNAE x LC116 atualizada (ver 2.9 e 3.12), identificar o código LC116 correto para o CNAE do fornecedor, e reemitir a nota fiscal com o código compatível. Isso garante a apropriação correta dos créditos e evita a rejeição pela fiscalização.

Outro erro comum é a ausência ou incorreta vinculação do código NBS ao código LC116, o que pode resultar em inconsistências no cálculo do ISS e na emissão de relatórios fiscais. A validação cruzada entre CNAE, LC116 e NBS é fundamental para a escrituração correta (ver 6.4 e 8.7).

### Escrituração Contábil e Integração com a Fiscal

A escrituração contábil deve refletir os valores apurados na escrituração fiscal, incluindo o reconhecimento dos créditos tributários e a contabilização dos impostos a pagar. Por exemplo, o crédito tributário gerado na compra de serviços deve ser registrado como ativo tributário, enquanto o ISS devido é registrado como passivo.

Essa integração permite que a contabilidade financeira evidencie o impacto tributário real nas demonstrações, facilitando análises econômicas e financeiras mais precisas, essenciais para a tomada de decisão na escolha de fornecedores.

### Automação da Escrituração Fiscal e Contábil

Sistemas modernos de gestão tributária precisam automatizar a escrituração, integrando as tabelas oficiais do CNAE, LC116, NBS e NCM, assim como as regras de cálculo do ISS, IBS e CBS, para garantir a consistência dos dados.

Exemplo de rotina automatizada simplificada para registro de uma nota fiscal de serviço em Python:

```python
# Dados da nota fiscal
nota_fiscal = {
    "fornecedor_cnae": "6201501",
    "codigo_lc116": "1.01",
    "codigo_nbs": "1.01.01",
    "valor_bruto": 1000.00,
    "aliquota_iss": 0.05,
    "credito_iss": 50.00  # Crédito tributário aproveitável
}

# Validação simples CNAE x LC116 (exemplo)
vinculacoes_validas = {
    "6201501": ["1.01", "1.02"],
    # outros CNAEs...
}

if nota_fiscal["codigo_lc116"] not in vinculacoes_validas.get(nota_fiscal["fornecedor_cnae"], []):
    raise ValueError("Erro: Código LC116 incompatível com CNAE informado.")

# Cálculo do ISS devido (considerando crédito)
iss_devido = nota_fiscal["valor_bruto"] * nota_fiscal["aliquota_iss"]
custo_liquido = nota_fiscal["valor_bruto"] - nota_fiscal["credito_iss"] + iss_devido

print(f"ISS devido: R$ {iss_devido:.2f}")
print(f"Custo líquido do serviço: R$ {custo_liquido:.2f}")
```

Saída:

```
ISS devido: R$ 50.00
Custo líquido do serviço: R$ 1000.00
```

Nesse exemplo, o custo líquido ainda não reflete a apropriação do crédito, pois o crédito deve ser descontado do imposto devido, não do valor bruto diretamente. Corrigindo:

```python
iss_liquido = max(iss_devido - nota_fiscal["credito_iss"], 0)
custo_liquido_corrigido = nota_fiscal["valor_bruto"] + iss_liquido

print(f"ISS líquido após crédito: R$ {iss_liquido:.2f}")
print(f"Custo líquido corrigido do serviço: R$ {custo_liquido_corrigido:.2f}")
```

Saída:

```
ISS líquido após crédito: R$ 0.00
Custo líquido corrigido do serviço: R$ 1000.00
```

Aqui, o crédito anula o ISS devido, então o custo líquido é o valor bruto do serviço. Essa lógica é fundamental na escrituração para refletir corretamente o custo tributário.

### Exercício Prático

Pesquise e registre uma operação fictícia de prestação de serviço, incluindo:

- CNAE do fornecedor,
- Código LC116 correspondente,
- Código NBS aplicável,
- Valor bruto do serviço,
- Alíquota do ISS do município,
- Crédito tributário estimado.

Em seguida, elabore a escrituração fiscal que vincule corretamente esses códigos, calcule o ISS devido e o custo líquido do serviço considerando o crédito tributário, e registre os lançamentos contábeis correspondentes. Explique os impactos dos erros comuns na vinculação desses códigos na análise tributária e na emissão da NFS-e.

---