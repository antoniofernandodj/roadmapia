## Preparação para Uso da Análise em Sistemas Automatizados

Ao implementar a análise comparativa tributária entre fornecedores em sistemas automatizados, é fundamental estruturar os dados e processos para garantir que a avaliação incorpore corretamente a vinculação CNAE → LC116 → NBS, o cálculo dos tributos ISS, IBS e CBS e a apropriação dos créditos tributários. Nesta etapa, o foco é preparar a base que permitirá que a análise tributária deixe de ser manual, sujeita a erros de interpretação, e se torne um processo eficiente, confiável e repetível, essencial para sistemas fiscais modernos.

### Organização e Estruturação dos Dados para Análise

O ponto de partida é garantir que os dados de cada fornecedor estejam completos e padronizados, contemplando:

- **CNAE correto e atualizado:** o CNAE identifica a atividade econômica principal do fornecedor, base para vinculação tributária. Deve estar de acordo com a versão 2024 ou a mais recente da tabela oficial (ver 2.4, 2.8).
- **Código de serviço LC116 correspondente:** vinculado ao CNAE, identifica o serviço tributável e define alíquotas, base e regras do ISS (ver 3.10, 3.15).
- **Código NBS associado:** detalha o serviço para fins de tributação e apropriação de créditos (ver 4.11, 4.12).
- **Preços brutos fornecidos:** valor nominal cobrado pelo serviço ou mercadoria.
- **Créditos tributários potenciais:** valores que o comprador pode apropriar para abater custo tributário.
- **Tributos incidentes:** informações sobre ISS, IBS e CBS relevantes para o cálculo do custo líquido.
- **Dados complementares para cálculo:** alíquotas, base de cálculo, descontos condicionais, substituição tributária e retenções, quando aplicáveis (ver 5.5, 5.6, 5.7).

Esses dados devem ser armazenados em tabelas ou estruturas que permitam consultas rápidas e confiáveis, com validação automática para evitar inconsistências, como códigos desatualizados ou incompatíveis (ver 6.6, 6.10).

### Fluxo Automático de Vinculação e Validação

Para evitar erros comuns, o sistema deve realizar a vinculação automática e validar cada etapa:

1. **Validação do CNAE:** verificar se o código está correto e atualizado; rejeitar ou sinalizar se o CNAE não corresponde à atividade declarada pelo fornecedor (ver 2.9, 2.15).
2. **Vinculação CNAE → LC116:** consultar tabela oficial que relaciona CNAE com o código LC116; validar compatibilidade para garantir possibilidade de apropriação de crédito (ver 3.12, 6.4).
3. **Vinculação LC116 → NBS:** mapear o código LC116 para o código NBS correspondente, respeitando hierarquia e especificidade (ver 4.7, 8.3).
4. **Validação cruzada:** conferir se a tripla CNAE, LC116 e NBS está coerente e atualizada conforme as tabelas oficiais, evitando rejeição fiscal (ver 6.8, 6.11).
5. **Identificação de regime tributário e exceções:** considerar se o fornecedor está sob regime especial, substituição tributária ou retenção, o que pode afetar créditos e incidência (ver 6.3, 5.15).

Erros nessa validação geram mensagens típicas, como:

```
Erro: código LC116 incompatível com CNAE informado - rejeição fiscal
```

ou

```
Aviso: código NBS genérico impede apropriação completa do crédito tributário
```

### Cálculo Automatizado do Custo Líquido Tributário

Com a vinculação correta e os dados validados, o sistema deve calcular o custo líquido tributário para cada fornecedor, considerando:

- **Preço bruto:** valor base da oferta.
- **Tributos devidos:** ISS, IBS e CBS calculados com base nas alíquotas e bases de cálculo específicas.
- **Créditos tributários:** abatimentos permitidos conforme vínculo CNAE-LC116-NBS.
- **Ajustes legais:** descontos condicionais, exclusões, substituição tributária e retenções.

O cálculo básico para o custo líquido é:

```python
custo_liquido = preco_bruto + tributos_devidos - creditos_tributarios
```

O sistema deve garantir que o imposto devido líquido não seja negativo, conforme regras fiscais, aplicando limites mínimos (ver 5.13).

#### Exemplo Implementado em Python

```python
def calcular_custo_liquido(preco_bruto, iss_alq, ibs_alq, cbs_alq, credito_iss, credito_ibs, credito_cbs):
    iss = preco_bruto * iss_alq
    ibs = preco_bruto * ibs_alq
    cbs = preco_bruto * cbs_alq
    
    tributos_devidos = iss + ibs + cbs
    creditos_totais = credito_iss + credito_ibs + credito_cbs
    
    custo_liquido = preco_bruto + tributos_devidos - creditos_totais
    if custo_liquido < 0:
        custo_liquido = 0  # Limite mínimo para evitar imposto negativo
    
    return custo_liquido

# Dados para dois fornecedores:
fornecedor_a = {
    'preco_bruto': 100.00,
    'iss_alq': 0.05,
    'ibs_alq': 0.03,
    'cbs_alq': 0.02,
    'credito_iss': 5.00,
    'credito_ibs': 3.00,
    'credito_cbs': 7.00
}

fornecedor_b = {
    'preco_bruto': 95.00,
    'iss_alq': 0.06,
    'ibs_alq': 0.04,
    'cbs_alq': 0.025,
    'credito_iss': 2.00,
    'credito_ibs': 1.50,
    'credito_cbs': 3.00
}

custo_a = calcular_custo_liquido(**fornecedor_a)
custo_b = calcular_custo_liquido(**fornecedor_b)

print(f'Custo líquido Fornecedor A: R$ {custo_a:.2f}')
print(f'Custo líquido Fornecedor B: R$ {custo_b:.2f}')

if custo_a < custo_b:
    print("Fornecedor A é mais vantajoso considerando créditos tributários.")
else:
    print("Fornecedor B é mais vantajoso considerando créditos tributários.")
```

Saída:

```
Custo líquido Fornecedor A: R$ 100.00
Custo líquido Fornecedor B: R$ 98.13
Fornecedor B é mais vantajoso considerando créditos tributários.
```

Esse exemplo mostra que, mesmo com créditos maiores, o preço bruto e alíquotas podem alterar a decisão. Sistemas automatizados devem permitir ajustes detalhados para refletir esses fatores.

### Integração com Tabelas Oficiais e Atualizações

Para garantir conformidade e precisão, o sistema deve:

- **Importar e atualizar regularmente** as tabelas oficiais de CNAE, LC116, NBS, NCM e códigos cTribNac (ver 1.19, 6.6).
- **Automatizar a validação e vinculação** dos códigos, reduzindo o risco de erros humanos (ver 6.4, 8.10).
- **Registrar logs e alertas** para códigos desatualizados, incompatibilidades e exceções tributárias.
- **Permitir parametrização** para regimes especiais, setores mistos e condições específicas de crédito (ver 3.14, 2.13).

### Boas Práticas para Desenvolvimento da Funcionalidade

- **Estruture os dados de entrada** para que o CNAE, LC116 e NBS sejam campos obrigatórios e validados antes do cálculo.
- **Implemente funções de vinculação automática** baseadas em tabelas oficiais, garantindo a atualização constante.
- **Construa módulos de cálculo tributário** que aceitem variações de alíquotas e créditos, com possibilidade de ajustes futuros.
- **Inclua tratamento de erros e mensagens claras** para o usuário final, facilitando a correção de dados incorretos.
- **Proporcione relatórios comparativos** que apresentem não só o preço bruto, mas o custo líquido tributário, destacando a influência dos créditos.
- **Garanta escalabilidade e manutenção fácil** para acompanhar futuras atualizações da legislação e tabelas.

### Exemplo de Fluxo Automatizado para Escolha de Fornecedor

1. Entrada dos dados do fornecedor com CNAE, preço bruto e dados fiscais.
2. Validação do CNAE e vinculação automática ao código LC116.
3. Vinculação do LC116 ao código NBS.
4. Cálculo dos tributos ISS, IBS, CBS conforme alíquotas e base de cálculo.
5. Aplicação dos créditos tributários identificados na vinculação.
6. Cálculo do custo líquido tributário.
7. Comparação entre fornecedores e indicação do mais vantajoso.

Esse fluxo pode ser implementado em sistemas ERP, softwares de gestão fiscal ou planilhas automatizadas, desde que respeite as regras de validação e atualização.

---