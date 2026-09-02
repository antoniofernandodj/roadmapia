# Configuração Básica do Gerenciador de Login

Depois de concluir a instalação básica do sistema e dos drivers gráficos, surge o próximo desafio: controlar quem e como os usuários acessam o ambiente gráfico. É aqui que os gerenciadores de login entram em cena - eles são os porteiros digitais que decidem desde o tema visual até quais contas podem logar sem senha. 

Um sistema sem gerenciador configurado corretamente é como um prédio com portas giratórias quebradas: ou trava no meio do login, ou deixa entrar quem não deveria, ou mostra uma interface desleixada que frustra os usuários antes mesmo de começarem a trabalhar. Os problemas mais comuns incluem telas pretas após digitar a senha, temas que não aplicam as mudanças ou logins automáticos que simplesmente ignoram as configurações.

Este capítulo vem após a configuração gráfica básica porque você precisa ter o Xorg/Wayland funcionando antes de cuidar da tela de login. Ele precede a personalização do ambiente de desktop porque o gerenciador de login é o primeiro componente gráfico que os usuários veem.

Você aprenderá a transformar essa etapa muitas vezes negligenciada em um processo fluido e seguro: desde trocar o gerenciador padrão sem quebrar o sistema até configurar logins automáticos para quiosques ou estações compartilhadas. Ao final, será capaz de diagnosticar por que um tema customizado não aparece no SDDM, como restringir logins a grupos específicos no LightDM e quais arquivos de log verificar quando o GDM entra em loop infinito. Tudo isso enquanto mantém a segurança do sistema - porque conveniência nunca deve vir à custa de proteção.

---

## Neste capítulo

1. [Instalando e removendo gerenciadores de login](01-instalando-e-removendo-gerenciadores-de.md)
2. [Configurando o GDM: opções básicas](02-configurando-o-gdm-opcoes-basicas.md)
3. [Configurando o SDDM: opções básicas](03-configurando-o-sddm-opcoes-basicas.md)
4. [Configurando o LightDM: opções básicas](04-configurando-o-lightdm-opcoes-basicas.md)
5. [Alternando entre gerenciadores de login](05-alternando-entre-gerenciadores-de-login.md)
6. [Habilitando e desabilitando o login automático](06-habilitando-e-desabilitando-o-login-auto.md)
7. [Configurando usuários permitidos](07-configurando-usuarios-permitidos.md)
8. [Personalizando a tela de bloqueio](08-personalizando-a-tela-de-bloqueio.md)
9. [Configurando tempo de espera e suspensão](09-configurando-tempo-de-espera-e-suspensao.md)
10. [Solucionando problemas comuns em gerenciadores de login](10-solucionando-problemas-comuns-em-gerenci.md)

[↑ Sumário da obra](../README.md)