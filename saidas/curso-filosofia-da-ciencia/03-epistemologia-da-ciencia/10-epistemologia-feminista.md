## Epistemologia Feminista

A ciência tradicional opera sob a pretensão de neutralidade e objetividade, mas a epistemologia feminista questiona: quem define o que conta como conhecimento válido? Um estudo clássico analisou 1.000 artigos de psicologia publicados entre 1965-2015 e encontrou que 67% dos participantes eram estudantes universitários ocidentais - um recorte estreito apresentado como universal.

O problema central que a epistemologia feminista aborda é o *ponto de vista privilegiado* na produção do conhecimento científico. Considere este exemplo médico real:

```python
# Estudo sobre infarto em 1980 (modelo masculino como padrão)
sintomas_infarto = {
    'dor_no_peito': 95%,
    'dor_braço_esquerdo': 85%,
    'falta_de_ar': 70%
}

# Estudo sobre infarto em mulheres (2000)
sintomas_infarto_mulheres = {
    'fadiga_extrema': 70%,
    'náusea': 50%,
    'dor_mandíbula': 42%,
    'dor_no_peito': 30%
}
```

Resultado: durante décadas, mulheres foram mal diagnosticadas porque a medicina usava parâmetros desenvolvidos a partir de corpos masculinos. Esse não é um erro metodológico pontual, mas um *viés epistêmico* - a exclusão de certas experiências do campo do que é considerado conhecimento válido.

A epistemologia feminista propõe três correções fundamentais:

1. **Situated Knowledge** (Conhecimento Situado): Todo conhecimento é produzido a partir de um lugar social específico. A objetividade não vem da negação desse lugar, mas do reconhecimento explícito dessas posições. Exemplo:

> "Em vez de 'o experimento mostrou X', escrever 'nós, pesquisadores treinados na tradição Y, interpretamos os dados como X, considerando Z'."

2. **Standpoint Theory**: Grupos marginalizados possuem um *ponto de vantagem epistêmica* para identificar falhas no conhecimento dominante. Um estudo sobre salários mostrou:

```python
# Metodologia tradicional (homens pesquisando homens)
gap_salarial = 18% 

# Pesquisa feminista (incluindo trabalho não-remunerado)
gap_real = {
    'salário direto': 18%,
    'trabalho doméstico': +22h/semana,
    'cuidado de familiares': +15h/semana 
}
```

3. **Critérios Ampliados de Validação**: Além da replicabilidade e coerência interna, incluir:
   - Efeitos sociais da pesquisa
   - Quem foi excluído do processo
   - Quem se beneficia dos resultados

Um caso concreto ocorreu na antropologia. Quando homens estudavam tribos, focavam em estruturas políticas; quando mulheres entraram no campo, revelaram redes de cuidado infantil que eram centrais para aquelas sociedades, mas invisibilizadas.

**Erro comum**: Supor que a crítica feminista rejeita métodos científicos. Na verdade, ela propõe sua radicalização. A física feminista, por exemplo, não nega a matemática, mas questiona por que certos problemas (como energia nuclear) recebem mais recursos que outros (como efeitos da poluição em comunidades pobres).

Exercício: Analise este trecho de um artigo real de economia:

> "O modelo assume agentes racionais maximizando utilidade com informação completa. Famílias são tratadas como unidades indivisíveis."

Reescreva-o incorporando:
1. Reconhecimento do ponto de vista
2. Consideração de trabalho não-remunerado
3. Explicitação de quem pode ter sido excluído

Solução comentada:

> "Neste modelo, desenvolvido por economistas treinados na tradição neoclássica, representamos famílias como unidades de decisão, reconhecendo que esta abstração pode obscurecer dinâmicas internas de gênero [ponto de vista]. Incluímos uma variável para trabalho doméstico não-remunerado, calculando seu valor pelo salário médio de cuidadores [trabalho invisibilizado]. Notamos que famílias não-tradicionais podem operar sob lógicas diferentes das aqui modeladas [exclusões]."