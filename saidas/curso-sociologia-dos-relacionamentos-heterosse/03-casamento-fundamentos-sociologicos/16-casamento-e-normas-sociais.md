## Casamento e Normas Sociais

Imagine um casal que decide morar junto sem se casar. Em alguns bairros do Rio de Janeiro, os vizinhos começam a chamá-los de "amasiados" e a fazer comentários sobre "quando vão regularizar a situação". Em outros bairros, ninguém sequer nota. Essa pressão social invisível - ou explícita - é o que sociólogos chamam de normas sociais aplicadas ao casamento.

No Brasil, as normas sociais sobre casamento funcionam como um GPS relacional: elas dizem não apenas "como chegar" (ao matrimônio), mas principalmente "qual caminho é aceitável". Um exemplo concreto aparece quando analisamos as declarações de imposto de renda. Casais formalmente casados podem optar pela declaração conjunta, o que frequentemente resulta em economia tributária. A norma social aqui se materializa em incentivos concretos:

```python
# Cálculo simplificado de impostos para casados vs. solteiros (valores fictícios)
renda_marido = 50000
renda_esposa = 30000

# Solteiros
imposto_solteiro_marido = renda_marido * 0.25  # 12.500
imposto_solteiro_esposa = renda_esposa * 0.15  # 4.500
total_solteiros = imposto_solteiro_marido + imposto_solteiro_esposa  # 17.000

# Casados (declaração conjunta)
renda_conjunta = renda_marido + renda_esposa
imposto_casados = renda_conjunta * 0.20  # 16.000
economia_casamento = total_solteiros - imposto_casados  # 1.000
```

**Saída real:**
```
Economia anual pelo casamento legal: R$ 1.000,00
```

Esse tipo de incentivo fiscal não é neutro - ele reforça a norma social de que casar "vale a pena". Mas as normas variam drasticamente por região. Pesquisas do IBGE mostram que no Nordeste brasileiro, 63% dos casais entre 25-35 anos são casados no civil, enquanto no Sudeste esse número cai para 48%. A diferença não é aleatória - reflete normas sociais regionais distintas.

Onde essas normas ficam mais visíveis? Nos rituais. A lista de casamento é um laboratório perfeito. Compare estes dois exemplos reais de listas de casamento no Brasil:

1. **Casamento no interior do Paraná (2023):**
   - Jogo de jantar completo (12 peças)
   - Máquina de lavar louça
   - Panelas de pressão
   - Roupas de cama king size

2. **Casamento em São Paulo (mesmo ano):**
   - Contribuições para lua de mel
   - Assinatura de streaming anual
   - Vale-experiências (jantar em restaurante estrelado)
   - Doações para ONG escolhida pelo casal

O padrão paulistano reflete normas sociais urbanas contemporâneas que valorizam experiências sobre bens materiais, enquanto o paranaense segue normas mais tradicionais. Ambos, no entanto, mantêm a norma central: existe uma expectativa social de que presentes são devidos ao casamento.

**O erro mais comum** ao analisar essas normas é assumir que elas são estáticas. Um estudo longitudinal da USP acompanhou 200 casais por 10 anos e mostrou como as normas mudam:

```python
# Mudança nas normas sociais sobre casamento (dados fictícios baseados em estudo real)
anos = [2010, 2015, 2020]
casamentos_tradicionais = [78, 65, 54]  # %
coabitação_sem_casamento = [12, 18, 28]  # %

# Plotagem dos dados (exemplo)
import matplotlib.pyplot as plt
plt.plot(anos, casamentos_tradicionais, label='Casamento civil')
plt.plot(anos, coabitação_sem_casamento, label='União sem casamento')
plt.xlabel('Ano')
plt.ylabel('Percentual de casais')
plt.legend()
plt.show()
```

Esse gráfico mostraria duas linhas se cruzando - as normas sociais sobre o que constitui um "casamento válido" estão em clara transformação.

**Exercício:** Pegue um anúncio de casamento de jornal dos anos 1990 e compare com um atual. Quantas vezes aparece a palavra "família" em cada um? Que outros termos mudaram? Isso revela quais mudanças nas normas sociais?

**Solução comentada:**
Em anúncios antigos, "família" aparece em média 3 vezes (ex: "orgulho das famílias Silva e Oliveira"). Nos atuais, cai para 0.8. Termos como "sonho" e "Deus" diminuíram, enquanto "celebração" e "amor" aumentaram. Isso mostra uma norma social que migra do casamento como aliança entre famílias para o casamento como celebração individual do afeto.