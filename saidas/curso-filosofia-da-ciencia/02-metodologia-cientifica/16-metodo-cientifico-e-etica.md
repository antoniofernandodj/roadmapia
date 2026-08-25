## Método Científico e Ética

Um pesquisador testa um novo medicamento em ratos. Os resultados são promissores, mas ele decide pular etapas de segurança para publicar primeiro. Esse dilema não é técnico — é ético. A ciência opera dentro de limites morais que determinam não apenas como se faz pesquisa, mas se deve fazê-la.

### O Custo Humano das Decisões Metodológicas

O estudo de Tuskegee (1932-1972) mostrou sífilis não tratada em 399 homens negros, mesmo após a descoberta da penicilina. Os pesquisadores alegaram "observação natural", mas violaram três princípios éticos fundamentais:

1. **Autonomia**: participantes não consentiram com a omissão de tratamento
2. **Beneficência**: não maximizaram benefícios ("não maleficência" seria mais preciso aqui)
3. **Justiça**: selecionaram grupo vulnerável sem justificativa científica

```python
# Simulação ética: teste de novo fármaco
import random

grupo_controle = random.sample(populacao_vulneravel, 100)  # Antiético
grupo_experimental = random.sample(populacao_geral, 100)   # Correto
```

A mensagem de erro é clara: `ValueError: Cannot test on vulnerable population without informed consent and ethical approval`. Ferramentas modernas como o simulador IRB (Institutional Review Board) bloqueiam esse tipo de desenho experimental.

### O Dilema da Publicação versus Integridade

Em 2011, um estudo sobre vírus H5N1 gerado em laboratório causou polêmica. Os pesquisadores modificaram o vírus para torná-lo transmissível entre mamíferos. Dois problemas éticos emergiram:

- **Risco biológico**: 60% de letalidade em humanos
- **Dual use**: pesquisa legítima com potencial armamentista

A solução veio através de um **protocolo de revisão dupla**:
1. Painel científico avalia mérito acadêmico
2. Comitê de biossegurança avalia riscos sociais

```python
def publicar_estudo(artigo):
    if artigo.risco_biologico > artigo.beneficio_social:
        raise EthicsError("Risk-benefit ratio unacceptable")
    elif not artigo.revisao_dupla:
        raise PeerReviewError("Dual review required for sensitive topics")
```

### Viés na Seleção de Dados

Um pesquisador de psicologia exclui 20% dos participantes porque "não se encaixavam no padrão". Isso parece inócuo até verificarmos que eram todos idosos — uma exclusão sistemática que distorce conclusões sobre cognição.

**Teste de robustez ética**:

```python
dados_completos = coleta_original()
dados_filtrados = filtrar_por_idade(dados_completos, 18, 60)

# Teste t entre grupos incluídos/excluídos
resultado = stats.ttest_ind(dados_completos['memoria'], 
                          dados_filtrados['memoria'])
print(f"Diferença significativa? p = {resultado.pvalue:.4f}")
# Saída: p = 0.0032 → Exclusão criou viés
```

Quando p < 0.05, a exclusão alterou significativamente os resultados — sinal vermelho para práticas questionáveis.

### Autoria e Crédito

O caso Millikan (1913) mostrou como selecionar apenas dados que confirmam a carga do elétron pode persistir por décadas. Mas a ética vai além dos dados — inclui quem merece crédito:

```markdown
[✔] Autoria justa:
1. Quem concebeu o experimento
2. Quem executou >50% dos testes
3. Quem analisou os dados cruciais

[✘] Exclusão indevida:
- Estudante que processou 80% dos dados
- Técnico que calibrou o equipamento crítico
```

### Exercício: Análise de Caso Real

**Problema**: Um estudo sobre inteligência artificial em diagnósticos médicos usou apenas imagens de pacientes caucasianos. Quais os riscos éticos e como corrigir?

**Solução**:
1. **Viés algorítmico**: O modelo terá menor acurácia em grupos sub-representados
2. **Justiça distributiva**: Benefícios da tecnologia não alcançam toda a população
3. **Correção**:
   - Amostragem estratificada por etnia
   - Teste de desempenho por subgrupo
   - Relatório transparente de limitações

```python
# Correção ética no dataset
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(
    dados, etiquetas, 
    stratify=etnias,  # Preserva proporções
    test_size=0.2
)
```