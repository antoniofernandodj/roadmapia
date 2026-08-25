## Métodos Quantitativos e Qualitativos

Quando um pesquisador estuda o efeito da poluição sonora em escolas, pode medir decibéis e notas em provas (quantitativo) ou entrevistar professores sobre mudanças no comportamento dos alunos (qualitativo). Essas abordagens respondem a perguntas diferentes com ferramentas distintas, mas complementares.

### O que os números revelam (e ocultam)

Métodos quantitativos convertem observações em dados numéricos. Um estudo sobre acesso à internet em áreas rurais poderia gerar esta tabela:

```python
import pandas as pd
dados = pd.DataFrame({
    'Região': ['Norte', 'Nordeste', 'Centro-Oeste'],
    'Domícilios com internet (%)': [42.7, 38.1, 45.3],
    'Velocidade média (Mbps)': [5.2, 4.7, 6.1]
})
print(dados)
```

Saída:
```
         Região  Domícilios com internet (%)  Velocidade média (Mbps)
0         Norte                        42.7                      5.2
1     Nordeste                        38.1                      4.7
2  Centro-Oeste                        45.3                      6.1
```

Esses dados permitem testes estatísticos como correlação entre velocidade e penetração, mas não explicam por que famílias sem acesso recusam pacotes sociais de conectividade. É aqui que os métodos qualitativos completam o quadro.

### Profundidade versus generalização

Entrevistas em profundidade revelam nuances que questionam os números. Um trecho de transcrição codificado com NVivo:

```
Entrevistado 14 (agricultor, 52 anos):
"Não quero essa internet do governo porque já vi o vizinho ficar com a conta 
aumentando depois do primeiro ano. Prefiro meu rádio mesmo."

Códigos atribuídos: [Desconfiança institucional], [Custo percebido], [Preferência por mídia tradicional]
```

Enquanto o método quantitativo mostra "38% de adoção", o qualitativo desvenda os motivos por trás dos 62% de não-adoção. O erro comum é tratar essas abordagens como rivais, quando na verdade respondem a questões diferentes:

1. **Quantitativo**: "Quantos?" "Com que frequência?" "Qual a magnitude?"
2. **Qualitativo**: "Por quê?" "Como se sentem?" "Quais significados atribuem?"

### Triangulação metodológica

O estudo clássico de Whyte sobre gangues urbanas combinou:
- Análise estatística de arrestos (quantitativo)
- Observação participante por 3 anos (qualitativo)
- Análise de documentos oficiais (qualitativo)

Essa combinação revelou que a maioria dos crimes ocorria em certos bairros não por maior criminalidade, mas por maior policiamento - um viés quantificável cuja causa só emergiu nas entrevistas.

### Quando cada método falha

**Quantitativo puro**:
- Erro: Assumir que questionários padronizados capturam experiências complexas
- Exemplo: Medir "felicidade" apenas por escala de 1-10 ignora contextos culturais

**Qualitativo puro**:
- Erro: Generalizar a partir de poucos casos não representativos
- Exemplo: Concluir que "todos os idosos rejeitam tecnologia" baseado em 5 entrevistas

### Exercício: Projeto integrado

**Problema**: Alta rotatividade em uma startup de tecnologia

1. Proponha uma abordagem quantitativa (quais dados coletar? como analisar?)
2. Proponha uma abordagem qualitativa (quem entrevistar? que perguntas fazer?)
3. Como integraria os resultados?

**Solução comentada**:

1. **Quantitativo**:
   - Dados HR: tempo médio de permanência, departamentos com maior rotatividade
   - Survey anônimo: escala Likert sobre satisfação com benefícios, carga horária
   - Análise: Correlação entre horas extras e desligamentos

2. **Qualitativo**:
   - Entrevistas com ex-funcionários (amostragem por snowball)
   - Grupos focais com equipes estáveis
   - Análise temática de avaliações no Glassdoor

3. **Integração**:
   - Se números mostram alta rotatividade em engenharia e qualitativo revela pressão por prazos irreais, a solução envolve ajuste de processos, não apenas aumento salarial