# Troubleshooting Avançado

Depois de configurar seu ambiente gráfico, instalar drivers e personalizar o ambiente desktop, você vai enfrentar problemas que não se resolvem com uma rápida busca no fórum. Quando a tela fica preta após o login, quando o cursor desaparece misteriosamente ou quando o sistema detecta monitores que não existem, você precisa de um método de diagnóstico preciso - não de palpites.  

Este capítulo assume que você já domina:  
1. A estrutura básica de uma sessão gráfica (desde o gerenciador de login até o compositor)  
2. A diferença entre Xorg e Wayland em nível operacional  
3. O uso intermediário do terminal para manipular serviços e arquivos de configuração  

Começamos com um **fluxo sistemático de diagnóstico**, onde você isolará o problema criando uma sessão mínima - se um terminal abre, o erro não está no servidor gráfico, mas no seu ambiente desktop. Aprenderá a decifrar os logs do Xorg (com seus códigos EE para erros fatais e WW para avisos) e contrastará com a abordagem do Wayland, que depende do journald.  

Os drivers gráficos merecem atenção especial: um comando malformado no `xorg.conf` ou um conflito entre bibliotecas OpenGL pode fazer seu ambiente travar sem mensagens claras. Veremos como forçar o fallback para renderização por software (útil quando o driver NVIDIA corrompe após uma atualização) e como reconstruir módulos do kernel.  

Dominando essas bases, enfrentaremos problemas **interdependentes**: um monitor não detectado pode ser falha do driver (verificável via `lspci -k`), mas também um conflito de permissões no `/tmp` ou um socket Wayland órfão em `/run/user/`. Ferramentas como `xrandr` e `loginctl` ajudarão a distinguir entre erros de configuração e limitações de hardware.  

Ao final do capítulo, você será capaz de:  
- Isolar a causa-raiz de falhas gráficas usando sessões mínimas e logs estruturados  
- Corrigir conflitos de drivers e bibliotecas sem reinstalar todo o sistema  
- Recuperar sessões travadas sem reboot forçado  
- Diagnosticar problemas complexos como loops de login ou monitores fantasmas

---

## Neste capítulo

1. [Método sistemático de diagnóstico](01-metodo-sistematico-de-diagnostico.md)
2. [Analisando logs do Xorg](02-analisando-logs-do-xorg.md)
3. [Problemas com drivers gráficos](03-problemas-com-drivers-graficos.md)
4. [Conflitos de bibliotecas gráficas](04-conflitos-de-bibliotecas-graficas.md)
5. [Problemas de permissão em sessões](05-problemas-de-permissao-em-sessoes.md)
6. [Sessões que não iniciam](06-sessoes-que-nao-iniciam.md)
7. [Problemas com múltiplos monitores](07-problemas-com-multiplos-monitores.md)
8. [Recuperação de sessões travadas](08-recuperacao-de-sessoes-travadas.md)
9. [Ferramentas de diagnóstico gráfico](09-ferramentas-de-diagnostico-grafico.md)
10. [Casos complexos e soluções criativas](10-casos-complexos-e-solucoes-criativas.md)

[↑ Sumário da obra](../README.md)