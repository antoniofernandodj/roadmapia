## Mapas de empatia

Imagine que você precisa projetar uma interface para um aplicativo de finanças pessoais. Você sabe quem são seus usuários — jovens adultos, profissionais que buscam controlar melhor seus gastos —, mas ainda sente que falta uma compreensão mais profunda de como eles pensam, sentem e se comportam diante dos desafios financeiros. É nesse ponto que o mapa de empatia se torna uma ferramenta essencial.

O mapa de empatia é uma técnica prática e visual usada para entender o usuário de forma holística, indo além do que ele diz explicitamente. Ele ajuda a revelar sentimentos, pensamentos, necessidades e dores que muitas vezes ficam implícitas ou até mesmo desconhecidas para o próprio usuário. Ao contrário de pesquisas quantitativas, que trazem dados frios, o mapa de empatia é qualitativo e foca na experiência subjetiva do usuário, criando uma base sólida para decisões de design verdadeiramente centradas no ser humano.

### Por que criar um mapa de empatia?

Quando projetamos uma interface, tendemos a nos apoiar em dados demográficos ou requisitos técnicos, mas isso raramente captura o contexto emocional e cognitivo do usuário. O mapa de empatia organiza essas informações em seis áreas principais: o que o usuário **vê**, **ouve**, **pensa e sente**, **fala e faz**, suas **dores** (medos, frustrações) e seus **ganhos** (necessidades, desejos). Essa estrutura estimula o designer a refletir sobre o comportamento do usuário em diferentes dimensões, facilitando a empatia verdadeira e a definição de soluções mais eficazes.

### Como construir um mapa de empatia

Para construir um mapa de empatia completo, você precisa coletar dados qualitativos — por exemplo, entrevistas, observações ou anotações de testes com usuários. Com essas informações em mãos, siga as etapas abaixo para preencher cada quadrante:

1. **O que o usuário vê?**  
   Inclua o ambiente em que o usuário está inserido, as ofertas disponíveis, as influências visuais e sociais. Por exemplo: “O usuário vê muitos aplicativos de finanças com interfaces complexas e pouco intuitivas.”

2. **O que o usuário ouve?**  
   Considere as vozes que influenciam o usuário, como amigos, familiares, especialistas ou mídia. Exemplo: “Ele ouve amigos dizerem que controlar gastos é difícil e que os bancos não facilitam.”

3. **O que o usuário pensa e sente?**  
   Aqui, identifique as emoções, preocupações e pensamentos que podem não ser verbalizados. Exemplo: “Sente ansiedade ao abrir o app do banco, pensa ‘vou perder o controle das minhas finanças’.”

4. **O que o usuário fala e faz?**  
   Observe o comportamento e as expressões públicas do usuário. Exemplo: “Ele reclama sobre a complexidade dos apps em conversas e tenta anotar manualmente seus gastos.”

5. **Quais são as dores do usuário?**  
   Liste os obstáculos, medos e frustrações. Exemplo: “Medo de cometer erros financeiros, frustração com interfaces confusas, sentimento de incapacidade.”

6. **Quais são os ganhos do usuário?**  
   Apontar as necessidades, desejos e expectativas. Exemplo: “Quer controlar gastos facilmente, receber dicas personalizadas, sentir-se seguro e confiante.”

### Exemplo prático completo

Vamos construir um mapa de empatia para um usuário hipotético chamado Lucas, que usa um aplicativo para controlar despesas mensais. Suponha que você tenha coletado essas informações em entrevistas e observação:

| Quadrante           | Conteúdo                                                   |
|---------------------|------------------------------------------------------------|
| **Vê**              | Muitos apps financeiros com gráficos complicados; anúncios de investimentos; amigos usando apps diferentes. |
| **Ouve**            | “Você precisa economizar mais!” (família); “Não entendo esses apps.” (colegas); podcast sobre finanças pessoais. |
| **Pensa e sente**   | Ansiedade ao revisar as finanças; medo de não conseguir pagar as contas; pensa “não tenho tempo para isso”. |
| **Fala e faz**      | Reclama da complexidade dos apps; tenta organizar gastos no papel; compartilha dúvidas em grupos online. |
| **Dores**           | Confusão com termos financeiros; dificuldade em manter disciplina; medo de dívidas; sensação de incompetência. |
| **Ganhos**          | Quer uma interface simples; deseja alertas fáceis de entender; procura motivação para economizar; quer sentir controle. |

### Visualização do mapa de empatia

Para facilitar, você pode representar essas informações em um quadro dividido em seis áreas, assim:

```
+--------------------+--------------------+
|        Vê          |       Ouve         |
| (ambiente, mídia)  | (influências)      |
+--------------------+--------------------+
| Pensa e Sente       |   Fala e Faz       |
| (emoções, pensamentos) | (comportamentos)  |
+--------------------+--------------------+
|       Dores         |       Ganhos       |
| (medos, frustrações)| (necessidades, desejos)|
+--------------------+--------------------+
```

Preencher o mapa com dados reais torna mais fácil detectar padrões, validar hipóteses e evitar erros comuns, como criar uma interface que não considera o medo do usuário ou suas limitações cognitivas, mesmo que ele verbalize apenas necessidades superficiais.

### Erro comum: mapa superficial ou genérico

Um erro frequente é preencher o mapa com suposições ou informações muito superficiais, como “usuário quer facilidade” sem detalhar o que significa para ele facilidade, ou “usa smartphone” sem contextualizar o ambiente. Isso gera mapas genéricos que não ajudam no design e podem levar a soluções irrelevantes.

Por exemplo, um mapa pouco detalhado pode ter:

- Vê: “App no celular”  
- Ouve: “Dizem para economizar”  
- Pensa e sente: “Quer economizar”  
- Fala e faz: “Usa o app”  
- Dores: “Gasta demais”  
- Ganhos: “Quer economizar”

Esse mapa não esclarece os motivos, emoções ou comportamentos específicos, dificultando a criação de uma interface que realmente atenda o usuário.

### Dica prática para aprimorar o mapa

Após criar o mapa inicial, reúna a equipe para discutir cada quadrante e buscar evidências mais concretas. Use perguntas para aprofundar, como:

- O que exatamente causa ansiedade no usuário?  
- Que palavras ele usa para descrever suas frustrações?  
- Como o ambiente influencia suas decisões financeiras?  
- Quais atitudes revelam suas emoções não ditas?

Essa reflexão ajuda a evitar generalizações e direcionar o design para soluções concretas.

### Código Python para organizar dados de entrevistas em mapa de empatia

Para organizar as informações coletadas em entrevistas e facilitar o preenchimento do mapa, veja um exemplo simples de script Python que estrutura as respostas por categorias do mapa:

```python
# Dados simulados de uma entrevista com um usuário
respostas = {
    "ve": [
        "Muitos apps com gráficos confusos",
        "Anúncios de investimentos em redes sociais"
    ],
    "ouve": [
        "Família fala para economizar",
        "Amigos reclamam da dificuldade dos apps"
    ],
    "pensa_sente": [
        "Sente ansiedade ao revisar gastos",
        "Tem medo de dívidas"
    ],
    "fala_faz": [
        "Reclama da complexidade",
        "Anota gastos em papel"
    ],
    "dores": [
        "Confusão com termos financeiros",
        "Falta de disciplina para controlar despesas"
    ],
    "ganhos": [
        "Quer interface simples",
        "Deseja alertas fáceis de entender"
    ]
}

def imprimir_mapa(respostas):
    print("Mapa de Empatia\n" + "="*15)
    for chave, itens in respostas.items():
        titulo = {
            "ve": "Vê",
            "ouve": "Ouve",
            "pensa_sente": "Pensa e Sente",
            "fala_faz": "Fala e Faz",
            "dores": "Dores",
            "ganhos": "Ganhos"
        }[chave]
        print(f"\n{titulo}:")
        for item in itens:
            print(f" - {item}")

imprimir_mapa(respostas)
```

Saída:

```
Mapa de Empatia
===============

Vê:
 - Muitos apps com gráficos confusos
 - Anúncios de investimentos em redes sociais

Ouve:
 - Família fala para economizar
 - Amigos reclamam da dificuldade dos apps

Pensa e Sente:
 - Sente ansiedade ao revisar gastos
 - Tem medo de dívidas

Fala e Faz:
 - Reclama da complexidade
 - Anota gastos em papel

Dores:
 - Confusão com termos financeiros
 - Falta de disciplina para controlar despesas

Ganhos:
 - Quer interface simples
 - Deseja alertas fáceis de entender
```

Esse script ajuda a organizar as informações coletadas para posterior análise e discussão em equipe.

### Exercício prático

Escolha um produto ou serviço digital que você utiliza ou conhece bem. Realize uma breve entrevista com um usuário real ou imagine as respostas baseadas em suas observações e experiências pessoais. Preencha um mapa de empatia completo para esse usuário, detalhando as seis áreas: o que ele vê, ouve, pensa e sente, fala e faz, quais são suas dores e quais são seus ganhos. 

Depois, responda:

- Como as dores identificadas influenciam o comportamento do usuário?  
- Que insights sobre ganhos podem orientar a criação de funcionalidades?  
- Existe alguma contradição entre o que o usuário pensa/sente e o que fala/faz? Como isso pode impactar seu design?

### Solução comentada (exemplo com app de meditação)

Suponha que entrevistamos Ana, usuária de um app de meditação:

| Quadrante           | Conteúdo                                                   |
|---------------------|------------------------------------------------------------|
| **Vê**              | Vê muitos apps com visual calmo, anúncios de bem-estar; amigos recomendando apps. |
| **Ouve**            | Ouve podcasts sobre saúde mental; família falando sobre estresse; amigos comentando apps caros. |
| **Pensa e sente**   | Sente estresse e ansiedade; pensa que meditar é difícil e toma tempo; quer relaxar rápido. |
| **Fala e faz**      | Diz que tenta meditar diariamente mas esquece; abre o app só quando está muito ansiosa. |
| **Dores**           | Falta de tempo; dificuldade em manter rotina; sente culpa por não praticar. |
| **Ganhos**          | Quer sessões rápidas; interface simples; lembretes motivadores; sensação de calma. |

**Comentários:**  
- As dores de falta de tempo e culpa indicam que o design deve focar em meditações curtas e motivação constante, talvez com notificações customizáveis.  
- A contradição entre o que Ana pensa (meditar é difícil) e o que fala/faz (tenta mas esquece) mostra necessidade de reforço positivo na interface.  
- Os ganhos apontam para um design visual tranquilo e funcional, que facilite o uso imediato e o engajamento.

Esse tipo de análise direciona o design para atender necessidades reais, não apenas supostas.

---

O mapa de empatia é, portanto, uma ferramenta simples, mas poderosa, para ampliar a compreensão do usuário e fundamentar decisões de design que gerem impacto positivo na experiência real. Usá-lo com rigor e profundidade evita o erro de criar interfaces desconectadas das emoções e comportamentos dos usuários, garantindo que o processo de design seja verdadeiramente centrado no ser humano.