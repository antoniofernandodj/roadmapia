## Interface de Usuário para Consulta e Seleção de Códigos Tributários

A complexidade da contabilidade tributária, intensificada pela reforma tributária, exige sistemas que possibilitem consultas ágeis e precisas aos códigos tributários, principalmente CNAE, LC116 e NBS. Uma interface de usuário (UI) eficiente para consulta e seleção desses códigos é essencial para garantir a correta vinculação, evitar erros comuns e facilitar a comparação econômica entre fornecedores considerando créditos tributários.

### Problema Concreto: Por que uma Interface Amigável é Necessária?

Imagine um profissional fiscal que precisa analisar diversos fornecedores e identificar rapidamente o CNAE correto de cada um, vincular esse CNAE ao código de serviço LC116 adequado e, em seguida, confirmar a correspondência com o código NBS para apuração dos tributos ISS, IBS e CBS. Sem uma interface clara e orientada, o risco de erro na seleção dos códigos aumenta, podendo gerar cálculos incorretos, perda de créditos tributários e decisões equivocadas na escolha do fornecedor.

Além disso, as tabelas oficiais são atualizadas periodicamente (ver 1.19, 2.4, 3.4, 4.5, 6.6), e o usuário pode ficar confuso com códigos desatualizados ou incompatíveis, o que torna imprescindível um sistema com validação automática e feedback claro.

### Princípios e Boas Práticas para Construção da Interface

1. **Consulta Rápida e Filtragem Dinâmica**  
   A interface deve permitir pesquisa por descrição, código ou parte deles, com filtros progressivos para que o usuário refine a busca sem precisar conhecer o código exato. Por exemplo, ao iniciar a digitação do CNAE, o sistema apresenta sugestões hierarquizadas, mostrando se o código é de seção, divisão, grupo, classe ou subclasse (ver 2.2, 2.3).

2. **Exibição Hierárquica e Contextualizada**  
   Exibir os códigos em árvore ou listas agrupadas facilita a visualização da estrutura, reforçando a compreensão da hierarquia do CNAE, LC116 e NBS (ver 2.2, 3.2, 4.2). A UI deve mostrar a descrição completa e o nível do código, por exemplo:  
   - CNAE 62.01-5/01 – Desenvolvimento de programas de computador sob encomenda  
   - LC116 6201 – Serviços de informática e congêneres  
   - NBS 62010001 – Serviços de desenvolvimento de software personalizado

3. **Validação Cruzada Automática**  
   Após a seleção de um CNAE, o sistema deve automaticamente apresentar os códigos LC116 vinculáveis, bloqueando ou alertando se houver incompatibilidade (ver 6.4, 6.6). O mesmo vale para a vinculação LC116 → NBS, evitando o erro comum de códigos incompatíveis que geram rejeições fiscais (ver 3.5, 4.7, 6.10).

4. **Feedback Claro de Erros e Alertas**  
   Mensagens explícitas e orientadoras evitam frustrações e decisões erradas. Por exemplo, se o CNAE não possuir vinculação válida com nenhum código LC116, a mensagem pode ser:  
   *“Nenhum código LC116 encontrado para o CNAE selecionado. Verifique se o CNAE está atualizado ou se a atividade é enquadrada em regime especial.”*  
   Isso ajuda a identificar problemas de atualização ou necessidade de revisão manual.

5. **Histórico e Sugestões Baseadas em Uso**  
   Sistemas que memorizam códigos mais usados pelo usuário ou sugerem códigos baseados em atividades similares agilizam futuras consultas, especialmente em empresas com fornecedores recorrentes.

6. **Integração Visual com Dados de Cálculo**  
   Mostrar, na mesma interface, o impacto tributário estimado do código selecionado, incluindo alíquotas, bases de cálculo e créditos potenciais, reforça a consciência do usuário sobre a importância da seleção correta (ver 5.1, 5.4, 6.5).

### Exemplo Prático: Protótipo Simples em Python com Interface de Linha de Comando

O exemplo a seguir simula uma interface básica para consulta e seleção dos códigos CNAE, LC116 e NBS, validando as vinculações e calculando um custo líquido simplificado. Essa estrutura pode ser expandida para interfaces gráficas com frameworks modernos.

```python
# Dados simplificados para demonstração
cnae_data = {
    "6201-5/01": "Desenvolvimento de programas de computador sob encomenda",
    "4744-0/01": "Comércio varejista de equipamentos de informática",
}

lc116_data = {
    "6201": "Serviços de informática e congêneres",
    "4744": "Comércio de equipamentos eletrônicos",
}

nbs_data = {
    "62010001": "Serviços de desenvolvimento de software personalizado",
    "47440001": "Comércio de equipamentos de informática",
}

# Vinculações simplificadas
cnae_lc116_map = {
    "6201-5/01": "6201",
    "4744-0/01": "4744",
}

lc116_nbs_map = {
    "6201": "62010001",
    "4744": "47440001",
}

# Alíquotas e créditos fictícios para cálculo
tributos_info = {
    "6201": {"aliquota": 0.05, "credito": 0.10},  # 5% alíquota, 10% crédito
    "4744": {"aliquota": 0.06, "credito": 0.05},  # 6% alíquota, 5% crédito
}

def consulta_cnae(query):
    resultados = {k: v for k, v in cnae_data.items() if query in k or query.lower() in v.lower()}
    return resultados

def valida_vinculacao(cnae):
    lc116 = cnae_lc116_map.get(cnae)
    if not lc116:
        return None, "Erro: CNAE não possui código LC116 vinculado."
    nbs = lc116_nbs_map.get(lc116)
    if not nbs:
        return None, "Erro: Código LC116 não possui código NBS vinculado."
    return (lc116, nbs), None

def calcula_custo_liquido(preco_bruto, lc116):
    tributo = tributos_info.get(lc116)
    if not tributo:
        return None, "Erro: Informações tributárias não encontradas para o código LC116."
    imposto = preco_bruto * tributo["aliquota"]
    credito = preco_bruto * tributo["credito"]
    imposto_liquido = max(imposto - credito, 0)
    custo_liquido = preco_bruto + imposto_liquido
    return custo_liquido, None

def interface_simples():
    print("Consulta e Seleção de Código CNAE")
    query = input("Digite parte do código ou descrição CNAE: ").strip()
    resultados = consulta_cnae(query)
    if not resultados:
        print("Nenhum CNAE encontrado para o termo pesquisado.")
        return
    print("CNAEs encontrados:")
    for i, (code, desc) in enumerate(resultados.items(), 1):
        print(f"{i}. {code} – {desc}")
    escolha = input("Escolha o número do CNAE desejado: ").strip()
    if not escolha.isdigit() or int(escolha) < 1 or int(escolha) > len(resultados):
        print("Escolha inválida.")
        return
    cnae_selecionado = list(resultados.keys())[int(escolha)-1]
    print(f"CNAE selecionado: {cnae_selecionado} – {cnae_data[cnae_selecionado]}")

    vinc, err = valida_vinculacao(cnae_selecionado)
    if err:
        print(err)
        return
    lc116, nbs = vinc
    print(f"Código LC116 vinculado: {lc116} – {lc116_data[lc116]}")
    print(f"Código NBS vinculado: {nbs} – {nbs_data[nbs]}")

    preco_str = input("Informe o preço bruto do fornecedor (R$): ").strip().replace(',', '.')
    try:
        preco = float(preco_str)
    except ValueError:
        print("Preço inválido.")
        return

    custo_liquido, err = calcula_custo_liquido(preco, lc116)
    if err:
        print(err)
        return

    print(f"Custo líquido tributário estimado: R$ {custo_liquido:.2f}")

if __name__ == "__main__":
    interface_simples()
```

#### Saída Exemplo

```
Consulta e Seleção de Código CNAE
Digite parte do código ou descrição CNAE: informática
CNAEs encontrados:
1. 6201-5/01 – Desenvolvimento de programas de computador sob encomenda
2. 4744-0/01 – Comércio varejista de equipamentos de informática
Escolha o número do CNAE desejado: 1
CNAE selecionado: 6201-5/01 – Desenvolvimento de programas de computador sob encomenda
Código LC116 vinculado: 6201 – Serviços de informática e congêneres
Código NBS vinculado: 62010001 – Serviços de desenvolvimento de software personalizado
Informe o preço bruto do fornecedor (R$): 100
Custo líquido tributário estimado: R$ 100.00
```

### Erro Comum e Tratamento

Suponha que o usuário selecione um CNAE sem vinculação LC116:

```python
cnae_lc116_map = {
    # "6201-5/01": "6201",  # removido para simular erro
    "4744-0/01": "4744",
}
```

Ao executar a interface, a mensagem será:

```
Erro: CNAE não possui código LC116 vinculado.
```

Isso evita cálculos errados e indica a necessidade de atualização da base ou intervenção manual.

### Exemplos de Melhoria para Interfaces Gráficas

- **Autocomplete com sugestões instantâneas** para códigos e descrições.  
- **Visualização em árvore hierárquica**, expandindo níveis do CNAE e LC116 para facilitar a escolha.  
- **Botões de validação e alerta em tempo real**, evitando que o usuário avance com seleções inválidas.  
- **Painel lateral mostrando informações complementares**, como alíquotas, créditos e normas aplicáveis.  
- **Integração com tabelas oficiais atualizadas automaticamente**, garantindo conformidade.  
- **Exportação de relatórios de seleção e validação** para auditoria e documentação.

### Resumo das Boas Práticas

- Permitir busca fácil e intuitiva por código ou descrição.  
- Exibir estrutura hierárquica para facilitar compreensão dos níveis.  
- Automatizar validações cruzadas entre CNAE, LC116 e NBS.  
- Fornecer mensagens claras e instruções para correção de erros.  
- Apresentar impacto tributário estimado junto à escolha do código.  
- Manter tabelas atualizadas e sincronizadas para evitar inconsistências.  
- Suportar histórico e sugestões para agilizar processos repetitivos.

---

### Exercício Proposto

Desenvolva uma interface de consulta em linha de comando que, dado um termo para pesquisa, permita selecionar um CNAE, valide automaticamente a vinculação com o código LC116 e o código NBS, e calcule o custo líquido tributário para um preço bruto informado, exibindo mensagens claras em caso de erros de vinculação ou dados inválidos.

---