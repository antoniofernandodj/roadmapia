## Divórcio e Sociedade Brasileira

O divórcio no Brasil não é apenas uma decisão pessoal - é um espelho das tensões sociais. Quando analisamos os dados do IBGE de 2022, vemos que a taxa de divórcios para cada 100 casamentos saltou de 14,9 em 2000 para 35,6 em 2020. Esse crescimento explosivo revela como mudanças estruturais na sociedade brasileira reconfiguraram os relacionamentos.

### A Revolução Silenciosa do Divórcio

Até 1977, o divórcio era proibido no Brasil. A Lei 6.515, conhecida como "Lei do Divórcio", mudou isso, mas com restrições: só era permitido após 3 anos de separação judicial ou 5 de separação de fato. Em 2010, a Emenda Constitucional 66 eliminou esses prazos, criando o divórcio direto. Veja como isso se reflete nos números:

```python
# Simulação do impacto legal nas taxas de divórcio
import matplotlib.pyplot as plt

anos = [1970, 1980, 1990, 2000, 2010, 2020]
divorcios_por_100_casamentos = [0, 3.2, 8.7, 14.9, 28.1, 35.6]

plt.plot(anos, divorcios_por_100_casamentos, marker='o')
plt.title('Evolução do Divórcio no Brasil (1970-2020)')
plt.xlabel('Ano')
plt.ylabel('Divórcios por 100 casamentos')
plt.grid(True)
plt.show()
```

O gráfico resultante mostra dois saltos claros: um após 1977 e outro após 2010. Mas as leis são só parte da história. A urbanização acelerada (85% da população em cidades em 2020 contra 56% em 1970) criou novos arranjos familiares e reduziu o controle social sobre os casamentos.

### O Peso das Desigualdades Regionais

Os dados revelam um Brasil dividido. Enquanto o Distrito Federal tem 42,5 divórcios por 100 casamentos, o Maranhão tem apenas 12,3. Essa diferença reflete:

1. **Acesso à justiça**: Em 2022, 67% dos divórcios nas capitais foram consensuais, contra 41% no interior nordestino
2. **Condições econômicas**: Famílias com renda acima de 5 salários mínimos divorciam-se 3 vezes mais que as abaixo de 2 salários
3. **Educação**: Mulheres com ensino superior divorciam-se 78% mais que aquelas com ensino fundamental incompleto

### O Paradoxo da Aceitação Social

Pesquisas do Datafolha mostram que 82% dos brasileiros consideram o divórcio aceitável hoje, contra 37% em 1980. Porém, na prática, ainda há estigma:

```python
# Estigma em diferentes gerações (dados simulados)
geracoes = ["60+", "40-59", "25-39", "18-24"]
concordam_que_divorciados_sao_vistos_com_maus_olhos = [43, 28, 19, 12]

plt.bar(geracoes, concordam_que_divorciados_sao_vistos_com_maus_olhos)
plt.title('Percepção do Estigma do Divórcio por Geração (%)')
plt.ylabel('Concorda que há preconceito')
plt.show()
```

Esse gráfico revela uma contradição: enquanto a sociedade aprova o divórcio abstratamente, na prática, especialmente entre os mais velhos, persistem julgamentos morais. Mulheres divorciadas relatam 37% mais críticas que homens nas mesmas condições, segundo pesquisa da USP.

### Exercício Prático

Analise este caso real do TJ-SP (nomes alterados):

"Casal com 12 anos de casamento, 2 filhos. Ele é engenheiro (R$ 15.000/mês), ela professora (R$ 4.500/mês). Ela pede divórcio alegando sobrecarga de trabalho doméstico e falta de apoio."

1. Quais fatores sociais explicam esse cenário?
2. Como as desigualdades de gênero no mercado de trabalho influenciam?
3. Por que casos assim aumentaram 142% desde 2010?

**Solução Comentada:**

1. **Fatores sociais**: A dissonância entre a independência econômica parcial da mulher (ela tem renda, mas significativamente menor) e a persistência da divisão sexual do trabalho cria tensão. A pesquisa do IBGE mostra que mulheres com renda própria divorciam-se 64% mais.

2. **Desigualdades de gênero**: A diferença salarial (ela ganha 30% do salário dele) mantém dependência econômica, enquanto a dupla jornada (ela trabalha fora e cuida da casa) gera estresse. Dados do IPEA revelam que 73% dos divórcios iniciados por mulheres citam "sobrecarga doméstica".

3. **Aumento dos casos**: A Lei 13.467/2017 (Reforma Trabalhista) precarizou empregos femininos, aumentando conflitos. Simultaneamente, as redes sociais amplificaram discussões sobre equidade de gênero, elevando a percepção de injustiça.