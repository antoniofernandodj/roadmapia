## Iteração no processo de design

Imagine que você acabou de criar um protótipo para um aplicativo de agendamento de consultas médicas. Você investiu horas planejando, desenhando e criando uma versão inicial que, na sua visão, resolve perfeitamente o problema do usuário. Porém, ao entregar para alguns usuários testarem, percebe que eles ficam confusos em como navegar entre as telas, algumas funções importantes estão esquecidas, e o fluxo não é tão intuitivo quanto você imaginava. O que fazer?

A resposta está na **iteração**, o processo de repetir, revisar e aprimorar continuamente seu design a partir do feedback real dos usuários e das observações feitas durante os testes.

### Por que iterar é essencial no design?

O design é, acima de tudo, uma atividade exploratória. Nenhum projeto nasce perfeito: mesmo com todo o conhecimento sobre o usuário, psicologia cognitiva e técnicas de prototipagem, o designer não consegue prever todas as reações e dificuldades que os usuários enfrentarão. A iteratividade permite:

- **Detectar erros ocultos** que só aparecem na interação real.
- **Ajustar a experiência** para torná-la mais clara, eficiente e agradável.
- **Evoluir o produto** de forma incremental, evitando grandes retrabalhos no fim do projeto.
- **Garantir que o design permaneça centrado no usuário,** corrigindo rumos sempre que necessário.

Sem essa repetição estruturada, o risco é desenvolver uma interface baseada em suposições, que pode ser rejeitada ou frustrar os usuários — por mais que a estética seja bonita ou as funcionalidades pareçam completas.

### Como funciona a iteração no design thinking?

No ciclo de design thinking, a iteração acontece em quase todas as etapas, mas principalmente após a prototipagem e o teste com usuários. O fluxo básico é:

1. **Criação de uma solução inicial** (protótipo, wireframe, ideia).
2. **Teste real com usuários** para colher observações e feedbacks.
3. **Análise crítica dos resultados** para identificar pontos fortes e fracos.
4. **Reformulação e refinamento do design,** corrigindo problemas e explorando melhorias.
5. **Nova rodada de testes** para validar as alterações.
6. Repetir o ciclo quantas vezes forem necessárias.

Esse processo não é linear nem único: o design evolui em espiral, aproximando-se cada vez mais da solução ideal ao longo das iterações.

### Exemplo prático: iterando um protótipo de tela de login

Vamos explorar um exemplo simples em Python para ilustrar um fluxo iterativo de design, simulando um protótipo testado com usuários e como o feedback gera melhorias.

```python
# Protótipo inicial: tela de login (simulada)
def tela_login_v1():
    print("=== Tela de Login v1 ===")
    print("Usuário:")
    usuario = input()
    print("Senha:")
    senha = input()
    if usuario == "admin" and senha == "123":
        print("Login bem-sucedido!")
    else:
        print("Erro: usuário ou senha incorretos. Tente novamente.")

# Teste com usuário simulado e coleta de feedback
def teste_usuario_v1():
    print("Teste com usuário: dificuldade em encontrar campo 'Senha', reclamação: 'não vi onde digitar a senha'")
    # Feedback identificado:
    # - Campo senha pouco destacado
    # - Mensagem de erro confusa (não indica o que fazer)
    return {
        "campo_senha_pouco_claro": True,
        "mensagem_erro_confusa": True
    }

# Aplicando feedback para criar versão 2 do protótipo
def tela_login_v2():
    print("=== Tela de Login v2 (com melhorias) ===")
    print("Usuário:")
    usuario = input()
    print("Senha (campo destacado):")  # destacando campo senha
    senha = input()
    if usuario == "admin" and senha == "123":
        print("Login bem-sucedido!")
    else:
        print("Erro: usuário ou senha incorretos.\nPor favor, verifique os dados e tente novamente.")

# Novo teste com usuário
def teste_usuario_v2():
    print("Teste com usuário: mensagem de erro melhor, mas reclamação: 'não sei se tem opção para recuperar senha'")
    return {
        "campo_senha_claro": True,
        "mensagem_erro_clara": True,
        "falta_recuperar_senha": True
    }

# Refinamento para versão 3 incluindo opção de recuperação de senha
def tela_login_v3():
    print("=== Tela de Login v3 (recuperação de senha adicionada) ===")
    print("Usuário:")
    usuario = input()
    print("Senha (campo destacado):")
    senha = input()
    print("[1] Esqueci minha senha")
    opcao = input("Escolha uma opção ou pressione Enter para continuar: ")
    if opcao == "1":
        print("Instruções para recuperação de senha enviadas ao seu e-mail.")
        return
    if usuario == "admin" and senha == "123":
        print("Login bem-sucedido!")
    else:
        print("Erro: usuário ou senha incorretos.\nPor favor, verifique os dados e tente novamente.")

# Simulação do processo iterativo
print("=== Processo Iterativo ===")
tela_login_v1()
feedback1 = teste_usuario_v1()
print("Feedback versão 1:", feedback1)

print("\nAplicando melhorias...\n")
tela_login_v2()
feedback2 = teste_usuario_v2()
print("Feedback versão 2:", feedback2)

print("\nAplicando melhorias...\n")
tela_login_v3()
```

Ao executar esse código, a interação com o usuário simula a experiência e mostra como o feedback real leva a refinamentos importantes, mesmo em um protótipo simples.

### Erros comuns ao ignorar a iteração

- **Pular o ciclo iterativo para "ir rápido ao lançamento"**: Isso gera produtos com falhas graves e retrabalho caro.
- **Ignorar ou desvalorizar o feedback dos usuários**: Resulta em designs que não resolvem problemas reais.
- **Focar demais em um único aspecto (estética, tecnologia) e não iterar no todo da experiência**: A interface pode ficar bonita, mas difícil de usar.
- **Testar apenas com a equipe interna**, o que cria viés e reduz a qualidade do feedback.

### Iteração não é retrabalho, é aprendizado

Cada iteração é um passo para entender melhor o usuário e o contexto, corrigindo problemas antes que se tornem caros ou críticos. O objetivo não é fazer algo perfeito na primeira vez, mas sim evoluir o design com agilidade, clareza e foco no usuário. 

Para desenvolvedores em transição para UX, compreender a iteração significa entender que o código e a interface são vivas: precisam ser testados, corrigidos e aprimorados constantemente com base em evidências reais.

---

### Exercício prático

Você recebeu um protótipo de um formulário de cadastro de usuário com os seguintes campos: nome, e-mail, senha e confirmação de senha. Após testar com três usuários, você recebe estes feedbacks:

1. "Não entendi se a senha precisa ter caracteres especiais."
2. "A confirmação de senha ficou confusa, parece que é um campo separado."
3. "O botão de enviar fica muito no final, é difícil encontrar."

**Tarefa:** Liste as três melhorias que você faria para a próxima iteração do formulário, explicando o motivo de cada uma com base no feedback.

---

### Solução comentada

1. **Adicionar uma dica clara sobre os requisitos da senha** (ex.: "Senha deve conter ao menos 8 caracteres, incluindo letras e números").  
   *Motivo:* O usuário não sabe as regras, o que pode gerar erros e frustração.

2. **Agrupar visualmente o campo de confirmação de senha junto com o campo de senha, talvez com identidade visual similar e alinhamento próximo.**  
   *Motivo:* O usuário percebe que são campos relacionados para confirmar a senha, evitando confusão.

3. **Reposicionar o botão de enviar para uma área mais visível, acima do fim do formulário, ou fixá-lo para facilitar o acesso.**  
   *Motivo:* Facilita a ação final, melhorando a usabilidade e reduzindo esforço para completar o cadastro.

Esse exercício reforça como o feedback direto do usuário direciona as melhorias na interface, e como a iteração deve ser orientada por observações reais, não por suposições.

---