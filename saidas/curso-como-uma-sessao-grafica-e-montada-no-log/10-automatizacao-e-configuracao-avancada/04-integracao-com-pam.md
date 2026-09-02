## Integração com PAM

Quando você faz login em uma sessão gráfica, uma série de processos ocorrem em segundo plano para garantir que você tenha acesso aos recursos necessários. Um dos principais componentes envolvidos nesse processo é o **PAM** (Pluggable Authentication Modules), um sistema modular que gerencia a autenticação e autorização de usuários no Linux.

O PAM funciona como uma camada intermediária entre os aplicativos que solicitam autenticação (como o gerenciador de login) e os mecanismos de autenticação propriamente ditos (como senhas, chaves SSH, etc.). Ele permite que você configure políticas de autenticação de maneira flexível, sem precisar modificar cada aplicativo individualmente.

### Como o PAM afeta sua sessão gráfica

Quando você insere suas credenciais no gerenciador de login, ele não verifica diretamente se a senha está correta. Em vez disso, ele delega essa tarefa ao PAM, que segue uma sequência de módulos configurados para determinar se o login deve ser permitido. Esses módulos podem realizar diversas tarefas, como:

1. **Verificar a senha**: O módulo `pam_unix.so` é responsável por comparar a senha inserida com a armazenada no sistema.
2. **Estabelecer limites de recursos**: O módulo `pam_limits.so` define limites de recursos (como número máximo de processos ou memória) para a sessão do usuário.
3. **Registrar o login**: O módulo `pam_lastlog.so` registra o último login do usuário, útil para auditoria e segurança.
4. **Carregar variáveis de ambiente**: O módulo `pam_env.so` define variáveis de ambiente específicas para a sessão do usuário.

### Exemplo prático: Configuração básica do PAM

Vamos dar uma olhada em um exemplo de configuração do PAM para entender como ele funciona. Suponha que você queira adicionar uma camada adicional de segurança exigindo que o usuário insira um código de autenticação de dois fatores (2FA) ao fazer login.

Primeiro, você precisaria instalar um módulo PAM para autenticação de dois fatores, como o `pam_google_authenticator`. Em seguida, você editaria o arquivo de configuração do PAM para o gerenciador de login, geralmente localizado em `/etc/pam.d/`.

```bash
# /etc/pam.d/lightdm
auth    required    pam_google_authenticator.so
auth    required    pam_unix.so
session required    pam_limits.so
session required    pam_env.so
```

Neste exemplo, o módulo `pam_google_authenticator.so` é chamado antes do `pam_unix.so`, exigindo que o usuário insira o código de autenticação de dois fatores antes de verificar a senha.

### Erros comuns e como corrigi-los

Um erro comum ao configurar o PAM é a ordem incorreta dos módulos. Se você colocar o módulo `pam_unix.so` antes do `pam_google_authenticator.so`, o sistema verificará a senha primeiro e só depois pedirá o código de autenticação de dois fatores. Isso pode levar a uma experiência de usuário confusa ou até mesmo a falhas no login.

Outro erro comum é esquecer de configurar limites de recursos adequados. Se você não definir limites de memória ou número de processos, um usuário pode acabar consumindo todos os recursos do sistema, causando instabilidade.

### Exercício: Configuração de limites de recursos

Para praticar, vamos configurar limites de recursos para um usuário específico usando o PAM. Primeiro, edite o arquivo `/etc/security/limits.conf` e adicione as seguintes linhas:

```bash
# /etc/security/limits.conf
john        hard    nproc   100
john        hard    as      1000000
```

Isso limita o usuário `john` a um máximo de 100 processos e 1GB de memória virtual. Em seguida, verifique se o módulo `pam_limits.so` está presente no arquivo de configuração do PAM para o gerenciador de login:

```bash
# /etc/pam.d/lightdm
session required    pam_limits.so
```

Após reiniciar o sistema, faça login como `john` e verifique os limites aplicados:

```bash
ulimit -a
```

Você deve ver os limites de processos (`nproc`) e memória (`as`) configurados conforme definido no arquivo `limits.conf`.

### Solução comentada

O exercício acima demonstra como configurar limites de recursos para um usuário específico usando o PAM. Ao definir esses limites, você pode evitar que um usuário consuma todos os recursos do sistema, garantindo uma operação estável e segura. O uso do módulo `pam_limits.so` é essencial para aplicar essas configurações durante o login, e a verificação com `ulimit -a` permite confirmar que os limites foram corretamente aplicados.