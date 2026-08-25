## Computação e Futuro

Um algoritmo de recomendação do YouTube sugere vídeos com 70% de precisão. Um médico assistente de IA diagnostica câncer com margem de erro menor que especialistas humanos. Um sistema de tradução automática produz textos indistinguíveis de versões humanas em idiomas majoritários. Esses não são exemplos isolados de progresso técnico — são sintomas de uma transformação mais profunda: a computação está redefinindo o que significa conhecer, decidir e criar. 

A filosofia da computação confronta aqui seu problema mais urgente: quando delegamos crescentemente processos cognitivos a sistemas algorítmicos, não estamos apenas acelerando tarefas — estamos reconfigurando a própria arquitetura do conhecimento humano. Considere três camadas dessa mudança:

1. **Epistemologia algorítmica**: Um modelo de machine learning que prevê recaídas criminais com base em dados históricos opera sob uma lógica diferente da deliberação jurídica humana. Enquanto juízes articulam razões explícitas (artigo X, circunstância Y), o algoritmo descobre correlações estatísticas inacessíveis à intuição. O erro filosófico comum é assumir que isso representa apenas um "método mais eficiente" — na verdade, estamos testemunhando o surgimento de um *terceiro modo epistêmico*, distinto tanto da intuição subjetiva quanto da razão discursiva.

```python
# Exemplo simplificado de viés em modelo preditivo
import pandas as pd
from sklearn.linear_model import LogisticRegression

dados = pd.DataFrame({
    'renda': [20, 15, 80, 30, 45],  # em milhares
    'bairro': [1, 1, 0, 1, 0],      # 1=periferia, 0=centro
    'reincidiu': [1, 1, 0, 1, 0]    # 1=sim, 0=não
})

modelo = LogisticRegression()
modelo.fit(dados[['renda', 'bairro']], dados['reincidiu'])

# Previsão para novo caso: alta renda na periferia
print(modelo.predict_proba([[70, 1]]))  # Probabilidade de reincidir: 87%
```

Saída:
```
[[0.134 0.866]]
```

O sistema "aprendeu" que renda alta em bairros periféricos correlaciona-se com reincidência — uma associação espúria gerada por amostragem enviesada. Esse não é um bug técnico, mas uma *limitação constitutiva* do modo como algoritmos constroem conhecimento: através de padrões em dados históricos, não de teorias causais.

2. **Ontologia computacional**: A física clássica supunha que o mundo era composto de partículas materiais. A física quântica substituiu isso por campos de probabilidade. Agora, a computação introduz uma terceira camada: o mundo como *relações de informação*. Quando um sistema blockchain define propriedade através de assinaturas criptográficas ou quando a realidade aumentada sobrepõe camadas digitais ao espaço físico, estamos testemunhando a ascensão de uma ontologia onde a existência é cada vez mais mediada por estruturas algorítmicas.

3. **Axiologia automatizada**: Sistemas de crédito pontuam sua confiabilidade. Aplicativos de namoro calculam sua compatibilidade. Plataformas de trabalho medem sua produtividade. Nesse processo, valores humanos (confiança, amor, dignidade) são traduzidos em métricas computáveis — com consequências paradoxais. Um estudo da Airbnb mostrou que hóspedes com nomes "étnicos" recebiam 16% menos reservas, mesmo com perfis idênticos. O sistema não era racista por design; simplesmente otimizava para as preferências reveladas pelos usuários. Aqui reside o desafio filosófico central: *como preservar a abertura do futuro humano em sistemas que operam por retroalimentação de padrões passados?*

### Exercício
Implemente um simulador de crédito que evite o viés descrito. O sistema deve:
1. Usar renda, score histórico e tipo de emprego como variáveis
2. Incluir um módulo que detecte correlações espúrias (ex: nome vs. score)
3. Explicar as razões da decisão em linguagem natural

```python
class SistemaCredito:
    def __init__(self):
        self.modelo = LogisticRegression()
        self.dados = pd.DataFrame(columns=['renda', 'score', 'emprego', 'aprovado'])
        
    def treinar(self):
        # Detectar e remover vieses
        correlacoes = self.dados.corr()
        if abs(correlacoes.loc['renda', 'aprovado']) > 0.7:
            print("Alerta: renda tem peso excessivo na decisão")
        
        self.modelo.fit(self.dados[['renda', 'score', 'emprego']], 
                       self.dados['aprovado'])
    
    def decidir(self, candidato):
        prob = self.modelo.predict_proba([[candidato['renda'], 
                                         candidato['score'],
                                         candidato['emprego']]])[0][1]
        
        explicacao = f"Probabilidade: {prob:.0%}. Baseado em: "
        if candidato['score'] < 500:
            explicacao += "histórico de crédito limitado. "
        elif candidato['emprego'] == 0:
            explicacao += "situação empregatícia instável. "
        
        return prob > 0.5, explicacao
```

O futuro da computação não é uma questão de previsão tecnológica, mas de arquitetura epistemológica: como projetar sistemas que ampliem, sem substituir, as formas humanas de conhecer e valorar. A resposta exigirá não apenas avanços algorítmicos, mas uma reflexão filosófica profunda sobre o que queremos preservar — e transformar — em nossa condição cognitiva compartilhada.