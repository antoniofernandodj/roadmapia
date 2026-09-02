## Alternando entre versões do Xorg

Quando uma atualização do Xorg introduz regressões ou incompatibilidades com drivers proprietários, você precisa manter múltiplas versões instaladas. O problema clássico ocorre quando o NVIDIA 470.xx exige Xorg 1.20, enquanto seu sistema atualizou para 1.21 - resultando em falhas na inicialização gráfica com erros como:

```
(EE) NVIDIA(GPU-0): Failed to initialize the NVIDIA kernel module
(EE) No devices detected
```

### Gerenciando versões paralelas

Distribuições baseadas em Debian/Ubuntu permitem instalação lado a lado via pacotes `xserver-xorg-core` com sufixo de versão:

```bash
sudo apt install xserver-xorg-core=2:1.20.11-1ubuntu1 \
                xserver-xorg-video-all=1:7.7+20ubuntu1 \
                xserver-xorg-input-all=1:7.7+20ubuntu1 \
                --allow-downgrades
```

Para RHEL/Fedora, use `dnf versionlock`:

```bash
sudo dnf install xorg-x11-server-Xorg-1.20.14-1.el7
sudo dnf versionlock add xorg-x11-server-Xorg
```

### O mecanismo de alternância

O segredo está no link simbólico `/usr/bin/Xorg`. Ao instalar múltiplas versões, elas são colocadas em `/usr/lib/xorg/Xorg.<versão>`. A alternância se faz reconfigurando este link:

```bash
sudo update-alternatives --install /usr/bin/Xorg Xorg /usr/lib/xorg/Xorg.1.20 20
sudo update-alternatives --install /usr/bin/Xorg Xorg /usr/lib/xorg/Xorg.1.21 21
sudo update-alternatives --config Xorg
```

A saída mostrará o menu interativo:

```
There are 2 choices for the alternative Xorg...

Selection    Path                    Priority   Status
------------------------------------------------------------
* 0          /usr/lib/xorg/Xorg.1.21   21       auto mode
  1          /usr/lib/xorg/Xorg.1.20   20       manual mode
  2          /usr/lib/xorg/Xorg.1.21   21       manual mode

Press <enter> to keep the current choice[*], or type selection number: 1
```

### Validação prática

Após a troca, reinicie o gerenciador de display e verifique com:

```bash
Xorg -version
```

Saída esperada:

```
X.Org X Server 1.20.11
Release Date: 2021-05-07
X Protocol Version 11, Revision 0
```

### Erro comum e correção

Ao esquecer de atualizar os pacotes complementares, você encontrará:

```
(EE) Failed to load module "glx" (Module does not exist, 0)
```

A solução é sincronizar os pacotes de drivers:

```bash
sudo apt install libgl1-mesa-glx=20.0.8-0ubuntu1~18.04.1 # Ubuntu
sudo dnf downgrade mesa-libGL-20.1.4-1.el7 # Fedora
```

### Exercício: Recuperação de sessão gráfica

1. Simule um problema instalando uma versão incompatível:
   ```bash
   sudo apt install xserver-xorg-core=2:1.19.6-1ubuntu4
   ```
2. Observe a falha no log `/var/log/Xorg.0.log`
3. Restaure a versão funcional usando `update-alternatives`

**Solução comentada**:
```bash
# Lista versões disponíveis
update-alternatives --list Xorg

# Seleciona a versão estável anterior
sudo update-alternatives --config Xorg

# Verifica os módulos ausentes no log
grep -E "(EE|WW)" /var/log/Xorg.0.log

# Reinstala drivers correspondentes
sudo apt install --reinstall libgl1-mesa-glx xserver-xorg-video-all
```