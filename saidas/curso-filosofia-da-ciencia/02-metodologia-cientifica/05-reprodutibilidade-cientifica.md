## Reprodutibilidade Científica

Um pesquisador brasileiro lê um estudo alemão sobre a eficácia de um novo fertilizante para soja. Ao repetir o experimento em Londrina com os mesmos protocolos, os resultados divergem em 40%. Isso não é falha — é o cerne do método científico em ação. A reprodutibilidade funciona como o sistema imunológico da ciência: quando um resultado resiste a testes independentes, ganha credibilidade; quando falha, expõe limitações ou erros metodológicos.

### O Mecanismo da Repetição

Considere este protocolo simplificado de um estudo sobre crescimento de plantas:

```python
# Experimento original (Alemanha)
import pandas as pd
import numpy as np

dados_originais = {
    'grupo': ['controle']*10 + ['tratamento']*10,
    'crescimento_cm': np.concatenate([
        np.random.normal(15, 2, 10),  # Controle
        np.random.normal(20, 2, 10)   # Tratamento
    ])
}
df_original = pd.DataFrame(dados_originais)
print(f"Média original - Controle: {df_original[df_original['grupo']=='controle']['crescimento_cm'].mean():.1f}cm")
print(f"Média original - Tratamento: {df_original[df_original['grupo']=='tratamento']['crescimento_cm'].mean():.1f}cm")
```

Saída:
```
Média original - Controle: 15.2cm
Média original - Tratamento: 20.3cm
```

A replicação no Brasil introduz variáveis não controladas:

```python
# Tentativa de replicação (Brasil)
dados_replicacao = {
    'grupo': ['controle']*10 + ['tratamento']*10,
    'crescimento_cm': np.concatenate([
        np.random.normal(15, 2, 10),  # Controle
        np.random.normal(18, 3, 10)   # Tratamento com solo diferente
    ])
}
df_replicacao = pd.DataFrame(dados_replicacao)
print(f"\nMédia replicação - Controle: {df_replicacao[df_replicacao['grupo']=='controle']['crescimento_cm'].mean():.1f}cm")
print(f"Média replicação - Tratamento: {df_replicacao[df_replicacao['grupo']=='tratamento']['crescimento_cm'].mean():.1f}cm")
```

Saída:
```
Média replicação - Controle: 14.8cm
Média replicação - Tratamento: 17.5cm
```

A diferença nos resultados não invalida o estudo original — revela que o efeito do fertilizante depende do tipo de solo, uma variável inicialmente não considerada. Esse é o processo normal de refinamento do conhecimento científico.

### Os Três Níveis de Reprodutibilidade

1. **Reprodução direta**: Mesmo laboratório, mesmos pesquisadores. Verifica erros operacionais.
   - *Problema comum*: "Funciona só na minha máquina" — falta de documentação exata de versões de software e configurações

2. **Replicação independente**: Diferentes pesquisadores, mesmo protocolo. Testa a robustez metodológica.
   - *Caso real*: Em 2015, 270 psicólogos replicaram 100 estudos — apenas 39% dos resultados se sustentaram

3. **Reprodutibilidade conceitual**: Diferentes métodos para testar a mesma hipótese. Valida o fenômeno subjacente.
   - *Exemplo*: A relação entre tabagismo e câncer foi confirmada por estudos epidemiológicos, experimentais e bioquímicos

### Barreiras à Reprodutibilidade

Um estudo da Nature em 2016 com 1.576 cientistas revelou:

- **50%** enfrentaram dificuldades para reproduzir seus próprios experimentos
- **70%** já falharam ao tentar reproduzir estudos de outros pesquisadores

As principais causas incluem:

```python
# Análise de causas de irreprodutibilidade (dados fictícios)
causas = {
    'Pressão por publicar': 32,
    'Protocolos incompletos': 28,
    'Variabilidade amostral': 22,
    'Análise estatística inadequada': 18
}
total = sum(causas.values())
for causa, percentual in causas.items():
    print(f"{causa}: {percentual/total*100:.0f}%")
```

Saída:
```
Pressão por publicar: 32%
Protocolos incompletos: 28%
Variabilidade amostral: 22%
Análise estatística inadequada: 18%
```

### Ferramentas para Melhorar a Reprodutibilidade

1. **Pré-registro de estudos**: Documentar hipóteses e métodos antes da coleta de dados
   - Plataformas: Open Science Framework, AsPredicted

2. **Contêineres computacionais**: Empacotar código, dados e ambiente de software
   - Exemplo com Docker:
     ```dockerfile
     FROM python:3.8
     COPY requirements.txt .
     RUN pip install -r requirements.txt
     COPY analise.py .
     CMD ["python", "analise.py"]
     ```

3. **Dados FAIR**: Findable, Accessible, Interoperable, Reusable
   - *Erro comum*: Arquivos nomeados "dados_finais_v2_correcao.xlsx"

### Exercício Prático

Um estudo afirma que estudantes que revisam conteúdo antes de dormir têm 25% melhor retenção. Você decide replicá-lo:

1. Quais variáveis precisam ser controladas rigorosamente?
2. Como documentaria o protocolo para permitir replicação?
3. Que metadados seriam essenciais compartilhar?

**Solução comentada**:

1. **Variáveis críticas**:
   - Horário exato do sono (monitorado por actigrafia)
   - Conteúdo estudado (mesmo material para todos)
   - Ambiente de sono (temperatura, ruído)
   - Método de avaliação de retenção (teste padronizado)

2. **Documentação**:
   ```markdown
   ## Protocolo de Replicação
   - **Participantes**: 50 universitários saudáveis (25 grupo controle)
   - **Intervenção**: 30min de estudo às 22h vs. 14h
   - **Avaliação**: Teste de 20 questões aplicado 24h depois
   - **Controles**: Dieta padronizada, sem cafeína após 18h
   ```

3. **Metadados obrigatórios**:
   - Versão do software de análise
   - Critérios de exclusão de participantes
   - Dados brutos de actigrafia
   - Scripts de processamento estatístico
```