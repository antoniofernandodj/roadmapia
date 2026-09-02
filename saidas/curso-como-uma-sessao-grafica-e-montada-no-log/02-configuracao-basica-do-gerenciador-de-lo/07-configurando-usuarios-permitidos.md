## Configurando usuários permitidos

Em ambientes corporativos ou domésticos compartilhados, é comum a necessidade de restringir quais usuários podem efetuar login no sistema. O Linux oferece mecanismos nativos para controlar isso sem depender de soluções externas. Vamos explorar três abordagens principais, começando pelo método mais direto.

### Método 1: Arquivo `/etc/login.defs`

Este arquivo contém configurações globais de login. Embora não seja específico para sessões gráficas, afeta todos os métodos de autenticação. Adicione estas linhas:

```bash
# /etc/login.defs
USERGROUPS_ENAB no
DEFAULT_HOME yes
LOGIN_RETRIES 3
LOGIN_TIMEOUT 60
UID_MIN 1000
UID_MAX 60000
SYS_UID_MIN 100
SYS_UID_MAX 999
```

Isso restringe logins a usuários com UID entre 1000 e 60000 (usuários normais), bloqueando contas de sistema (UID < 1000). Uma tentativa de login com um usuário restrito mostrará:

```
login: usuario_restrito 
Password: 
Login incorrect
```

### Método 2: Grupo especial (recomendado)

Crie um grupo para usuários permitidos e configure seu gerenciador de login:

```bash
sudo groupadd -r loginusers
sudo usermod -aG loginusers usuario_permitido
```

Para o **GDM**, edite `/etc/gdm/custom.conf`:

```ini
[security]
AllowGroup=loginusers
```

No **LightDM**, use `/etc/lightdm/lightdm.conf`:

```ini
[Seat:*]
greeter-hide-users=true
greeter-show-manual-login=true
allow-guest=false
```

Já no **SDDM**, crie ou edite `/etc/sddm.conf.d/access.conf`:

```ini
[Users]
HideUsers=root
HideShells=/bin/false,/usr/sbin/nologin
MinimumUid=1000
MaximumUid=60000
```

Após alterações, reinicie o serviço:

```bash
sudo systemctl restart gdm  # Ou lightdm/sddm
```

### Método 3: PAM (o mais flexível)

O subsistema Pluggable Authentication Modules permite controle granular. Edite `/etc/pam.d/gdm-password` (ou o arquivo correspondente ao seu gerenciador):

```
# Adicione no início
auth    required    pam_succeed_if.so user ingroup loginusers
```

Um erro comum é esquecer de instalar o módulo PAM necessário:

```
sudo apt install libpam-modules  # Debian/Ubuntu
sudo dnf install pam  # RHEL/Fedora
```

### Testando as configurações

Verifique com um usuário não permitido:

```bash
su - usuario_restrito
```

A mensagem de erro deve ser:

```
This account is currently not available.
```

### Exercício Prático

1. Crie dois usuários: `normal` e `restrito`
2. Aplique a restrição via grupo
3. Tente logar com ambos e documente os resultados

**Solução comentada:**

```bash
# 1. Criar usuários
sudo useradd -m -s /bin/bash normal
sudo useradd -m -s /bin/bash restrito

# 2. Criar grupo e adicionar apenas 'normal'
sudo groupadd -r loginusers
sudo usermod -aG loginusers normal

# 3. Configurar GDM (exemplo)
echo -e "[security]\nAllowGroup=loginusers" | sudo tee -a /etc/gdm/custom.conf
sudo systemctl restart gdm

# 4. Testar (saída esperada)
# Login com 'normal': sucesso
# Login com 'restrito': "Login incorrect"
```