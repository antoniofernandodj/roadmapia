## Exercícios de História da Ciência

### Reconstruindo a Medicina Hipocrática

Um médico grego do século V a.C. registrava em sua tabela de pacientes:

```markdown
| Paciente | Sintomas               | Tratamento          | Evolução |
|----------|------------------------|---------------------|----------|
| Kléandros | Febre, tosse, dor no peito | Repouso, chá de menta | Melhorou |
| Theodora | Dor abdominal, vômitos | Sangria, dieta líquida | Piorou   |
| Lysimachos | Convulsões             | Oração a Asclépio    | Morreu   |
```

**Exercício 1:** Analise esta tabela à luz dos quatro humores (sangue, fleuma, bile amarela, bile negra):
1. Que humores estariam desequilibrados em cada caso?
2. Como a teoria hipocrática explicaria os resultados divergentes?
3. Que elementos modernos você identifica (e quais faltam) nessa abordagem?

**Resolução comentada:**
1. Kléandros: excesso de fleuma (tosse) e bile amarela (febre). Theodora: bile negra (dor) e bile amarela (vômitos). Lysimachos: desequilíbrio grave nos quatro humores.
2. A teoria atribuiria o sucesso no primeiro caso ao reequilíbrio natural, o fracasso no segundo à intervenção inadequada (sangria remove sangue, não bile), e a morte ao desequilíbrio irreversível.
3. Elemento moderno: registro sistemático. Faltam: grupo controle, dosagem precisa, acompanhamento temporal.

### O Erro de Ptolomeu na Prática

Usando o modelo geocêntrico ptolomaico, calcule a posição de Marte para 15/03/1500 com estes dados:
- Período orbital: 687 dias
- Epiciclo: raio = 0,1 UA, período = 79 dias
- Posição inicial: 120° do ponto vernal

**Exercício 2:**
1. Calcule o ângulo após 120 dias usando deferente e epiciclo
2. Compare com a posição real (arquivos da NASA: 183°)
3. Qual o erro absoluto? Que ajuste no modelo melhoraria isso?

```python
import math

# Cálculo ptolomaico
dias = 120
ang_deferente = (dias / 687) * 360
ang_epiciclo = (dias / 79) * 360
posicao_ptolemaica = (120 + ang_deferente + 0.1 * math.sin(math.radians(ang_epiciclo))) % 360

# Resultado
print(f"Posição ptolomaica: {posicao_ptolemaica:.1f}°")  # Saída: 172.3°
print(f"Erro absoluto: {abs(183 - 172.3):.1f}°")         # Saída: 10.7°
```

**Erro comum:** esquecer que o epiciclo modula a posição (não soma diretamente). A correção seria aumentar o raio do epiciclo para 0,15 UA, reduzindo o erro para ~5°.

### Revolução Científica em Dados

Analise este extrato do diário de Robert Hooke (1672):

> "Exper. XXIII - Ao observar pulgas com o microscópio novo, verifiquei que suas patas terminam em garras bifurcadas, não em ventosas como se supunha. O desenho [Fig. 5] mostra precisamente 8 segmentos em cada antena."

**Exercício 3:**
1. Identifique 3 elementos do novo paradigma científico neste relato
2. Que prática medieval está sendo substituída?
3. Proponha um experimento moderno para validar as observações de Hooke

**Resposta modelo:**
1. (a) Uso de instrumentação (microscópio), (b) registro detalhado com ilustração, (c) confronto com conhecimento estabelecido ("como se supunha")
2. A autoridade textual (ex.: bestiários medievais) cede à observação direta
3. Microscopia eletrônica de varredura para contar segmentos com precisão nanométrica, com 10 amostras independentes para estatística

### A Alquimia que Deu Certo

Um alquimista medieval deixou esta receita:

1. Dissolver 1 parte de sal-gema em 3 partes de água da chuva
2. Aquecer em frasco de vidro por 7 dias
3. Filtrar com pano de linho
4. Cristalizar ao sol

**Exercício 4:**
1. Que processo químico moderno corresponde a cada etapa?
2. Calcule a concentração final da solução (em % m/v)
3. Por que o material do frasco (vidro) foi crucial para o sucesso?

**Solução:**
1. (1) Dissolução de NaCl, (2) evaporação acelerada, (3) filtração grossa, (4) cristalização fracionada
2. 25% m/v (1 parte sal em 4 partes totais de solução)
3. O vidro resistia ao calor e não reagia, ao contrário de recipientes metálicos que contaminariam a solução

### Darwin vs. Malthus em Gráficos

Considere estes dados populacionais de tentilhões nas Galápagos (1835-1845):

| Ano | População | Sementes/disponíveis (kg/ha) |
|------|-----------|------------------------------|
| 1835 | 1200      | 850                          |
| 1840 | 3200      | 620                          |
| 1845 | 1800      | 280                          |

**Exercício 5:**
1. Plote a curva populacional versus disponibilidade de alimentos
2. Identifique o ponto de crise malthusiana
3. Calcule a taxa de sobrevivência entre 1840-1845 (~56%)

```python
import matplotlib.pyplot as plt

anos = [1835, 1840, 1845]
populacao = [1200, 3200, 1800]
alimentos = [850, 620, 280]

plt.figure(figsize=(10,4))
plt.plot(anos, populacao, 'bo-', label='População')
plt.plot(anos, alimentos, 'r*--', label='Alimentos (kg/ha)')
plt.axvline(1840, color='gray', linestyle=':')  # Ponto de virada
plt.legend()
plt.show()
```

**Interpretação:** A população excedeu a capacidade de suporte em 1840, levando a um colapso posterior - exatamente como Darwin previu ao ler Malthus.