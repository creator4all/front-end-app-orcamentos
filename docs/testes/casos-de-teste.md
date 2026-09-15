# Casos de Teste do Aplicativo Mobile — Multimídia: Parceiro

> **Fonte funcional:** `docs/regras-de-negocios.md`
> **Fonte técnica:** telas, rotas e componentes do aplicativo Flutter em `lib/`
> **Escopo:** somente comportamentos observáveis ou acionáveis pela interface do aplicativo Android/iOS. Não inclui casos exclusivos do painel web, chamadas diretas de API, jobs, banco de dados ou regras internas sem efeito observável no App.
> **Convenção:** `CT-MOB-<DOMÍNIO>-NNN`.
> **Execução:** interação real pela interface, preferencialmente via mobile-MCP em emulador Android.
> **Atualização v2:** 12 casos existentes revisados e 6 casos novos (AUT-015/016, ORC-021/022, CAL-013, EXP-008). Total **196**. Nenhum ID anterior foi removido.

## 1. Regras da execução

Para cada execução, registrar: **resultado esperado**, **resultado obtido**, **status** (`Passou`, `Falhou`, `Parcial` ou `Bloqueado`), **emulador**, **usuário/papel**, **data** e **evidência**.

- Não considerar uma chamada direta de API como execução deste caso mobile.
- Consultas ao banco podem preparar ou confirmar dados, mas não substituem a interação pela interface.
- Restaurar dados alterados após cada cenário destrutivo.
- Usar contas descartáveis para cadastro, troca de senha e exclusão de conta.
- Não registrar senhas, tokens, OTPs ou outros segredos nas evidências.
- Casos de seletor de arquivos, compartilhamento ou aplicativos externos podem exigir imagem Android com os serviços correspondentes.
- Os relatórios anteriores à adoção do prefixo `CT-MOB-*` não devem ser associados automaticamente a estes IDs; a correspondência deve ser comprovada pelos passos e pela evidência.

## 2. Matriz de papéis no App

| Papel | Fluxos esperados no aplicativo |
|---|---|
| Visitante | Login, recuperação de senha, cadastro, solicitação de parceria, Wiki e links públicos |
| Vendedor | Orçamentos próprios, perfil, Wiki, Drive compartilhado e exclusão da própria conta |
| Gestor | Fluxos de vendedor, orçamentos da empresa, edição da própria empresa e gestão de usuários da empresa |
| Administrador | Todos os fluxos mobile disponíveis, incluindo configuração de produtos, prospecção, empresas, usuários e relatórios |

---

## 3. Autenticação e sessão (AUT)

### CT-MOB-AUT-001 — Login mobile válido sem OTP para todos os perfis
**Pré-condição:** Contas ativas de Administrador, Gestor e Vendedor com credenciais válidas.
**Passos:**
1. Executar o cenário como Administrador.
2. Informar e-mail e senha válidos.
3. Tocar em **Acessar**.
4. Repetir como Gestor.
5. Repetir como Vendedor.
**Esperado:**
- Os três perfis autenticam com e-mail e senha.
- Nenhum deles recebe tela de OTP no login mobile.
- O token de sessão é criado diretamente.
- A área autenticada correspondente ao perfil é exibida.
**Rastreabilidade:** RF-AUT-001; RN-AUT-001; CA-AUT-005.

### CT-MOB-AUT-002 — Login com senha incorreta
**Pré-condição:** Usuário ativo.
**Passos:** Informar e-mail cadastrado e senha incorreta; tocar em **Acessar**.
**Esperado:** Mensagem de erro; usuário permanece na tela de login; nenhuma sessão é criada.
**Rastreabilidade:** RF-AUT-001; CA-AUT-002.

### CT-MOB-AUT-003 — Login com e-mail não cadastrado
**Pré-condição:** E-mail inexistente.
**Passos:** Informar e-mail inexistente e senha sintaticamente válida; acessar.
**Esperado:** Login rejeitado sem revelar se a conta existe além da mensagem prevista pelo produto.
**Rastreabilidade:** RF-AUT-001.

### CT-MOB-AUT-004 — Login de usuário inativo
**Pré-condição:** Conta inativa preparada para teste.
**Passos:** Informar credenciais corretas; acessar.
**Esperado:** Login rejeitado e nenhuma tela autenticada acessível.
**Rastreabilidade:** RF-AUT-001.

### CT-MOB-AUT-005 — Validação de e-mail vazio
**Passos:** Deixar e-mail vazio; preencher senha válida; acessar.
**Esperado:** Validação no campo de e-mail e ausência de requisição de login bem-sucedida.
**Rastreabilidade:** Tela `login_page.dart`.

### CT-MOB-AUT-006 — Validação de formato de e-mail
**Passos:** Informar e-mail malformado; preencher senha válida; acessar.
**Esperado:** Validação de formato no campo de e-mail.
**Rastreabilidade:** Tela `login_page.dart`; `EmailValidator`.

### CT-MOB-AUT-007 — Validação de senha vazia
**Passos:** Informar e-mail válido; deixar senha vazia; acessar.
**Esperado:** Mensagem “Por favor, digite sua senha”.
**Rastreabilidade:** Tela `login_page.dart`.

### CT-MOB-AUT-008 — Validação de senha curta no login
**Passos:** Informar e-mail válido e senha com menos de 6 caracteres; acessar.
**Esperado:** Mensagem “A senha deve ter pelo menos 6 caracteres”.
**Rastreabilidade:** Tela `login_page.dart`.

### CT-MOB-AUT-009 — Alternar visibilidade da senha
**Passos:** Digitar senha; tocar no ícone de visibilidade duas vezes.
**Esperado:** Senha alterna entre visível e oculta sem perder o conteúdo.
**Rastreabilidade:** Tela `login_page.dart`.

### CT-MOB-AUT-010 — Logout confirmado
**Pré-condição:** Usuário autenticado.
**Passos:** Abrir menu do perfil; tocar em **Sair**; confirmar.
**Esperado:** Sessão encerrada, dados locais de autenticação limpos e tela de login exibida.
**Rastreabilidade:** RF-AUT-002; RN-AUT-005.

### CT-MOB-AUT-011 — Cancelar logout
**Pré-condição:** Usuário autenticado.
**Passos:** Abrir menu; tocar em **Sair**; tocar em **Cancelar**.
**Esperado:** Diálogo fechado e sessão mantida.
**Rastreabilidade:** `custom_top_bar.dart`.

### CT-MOB-AUT-012 — Restaurar sessão válida ao reabrir o App
**Pré-condição:** Login concluído e token válido armazenado.
**Passos:** Encerrar o App; iniciá-lo novamente.
**Esperado:** Splash valida a sessão e direciona à área autenticada sem novo login.
**Rastreabilidade:** RF-AUT-004; RN-AUT-008.

### CT-MOB-AUT-013 — Sessão expirada ao reabrir o App
**Pré-condição:** Token armazenado inválido, expirado ou revogado.
**Passos:** Iniciar o App.
**Esperado:** Dados de sessão removidos e tela de login exibida; conteúdo autenticado não aparece.
**Rastreabilidade:** RF-AUT-004; RN-AUT-008.

### CT-MOB-AUT-014 — Impedir múltiplos envios durante login
**Passos:** Informar credenciais; tocar repetidamente em **Acessar** durante o carregamento.
**Esperado:** Botão fica desabilitado/carregando e não gera múltiplas navegações ou sessões.
**Rastreabilidade:** Tela `login_page.dart`.

### CT-MOB-AUT-015 — 401 do webservice principal encerra a sessão
**Pré-condição:** Usuário autenticado e condição controlada para que uma operação no webservice principal responda `401`.
**Passos:**
1. Permanecer autenticado no App.
2. Executar uma operação que use o webservice principal.
3. Fazer a operação retornar `401`.
**Esperado:**
- A sessão é considerada inválida.
- Dados locais de autenticação são limpos.
- O usuário é direcionado ao login.
- Conteúdo autenticado deixa de ficar acessível.
**Rastreabilidade:** RF-AUT-004; RN-AUT-008.

### CT-MOB-AUT-016 — 401 do File Manager não encerra a sessão
**Pré-condição:**
- Sessão válida no webservice principal.
- Condição controlada para uma operação do Drive/File Manager retornar `401`.
**Passos:**
1. Abrir o Drive.
2. Provocar `401` somente na operação relacionada ao File Manager.
3. Fechar/tratar o erro.
4. Navegar para outro módulo autenticado do App.
**Esperado:**
- A operação do Drive apresenta erro.
- O usuário permanece autenticado.
- O App não redireciona automaticamente ao login.
- Demais operações autenticadas continuam funcionando.
**Rastreabilidade:** RN-AUT-008; RF-DRV-001/RF-DRV-004.

---

## 4. Recuperação de senha (RPS)

### CT-MOB-RPS-001 — Solicitar recuperação com e-mail cadastrado
**Pré-condição:** Conta ativa e e-mail acessível no ambiente de teste.
**Passos:** Tocar em **Esqueci minha senha**; informar e-mail; avançar.
**Esperado:** Solicitação aceita e tela de OTP exibida.
**Rastreabilidade:** RF-AUT-003; RN-AUT-006.

### CT-MOB-RPS-002 — Solicitar recuperação com e-mail vazio
**Passos:** Abrir recuperação; deixar e-mail vazio; avançar.
**Esperado:** Validação impede avanço.
**Rastreabilidade:** RF-AUT-003.

### CT-MOB-RPS-003 — Solicitar recuperação com e-mail inválido
**Passos:** Informar e-mail malformado; avançar.
**Esperado:** Validação de formato impede avanço.
**Rastreabilidade:** RF-AUT-003.

### CT-MOB-RPS-004 — Recuperação com e-mail não cadastrado
**Passos:** Informar e-mail inexistente; avançar.
**Esperado:** Mensagem de usuário não encontrado/inativo e permanência no fluxo controlado.
**Rastreabilidade:** RF-AUT-003.

### CT-MOB-RPS-005 — Validar OTP correto
**Pré-condição:** OTP vigente emitido para conta descartável.
**Passos:** Informar o código correto; avançar.
**Esperado:** Tela de definição da nova senha exibida.
**Rastreabilidade:** RF-AUT-003; RN-AUT-007.

### CT-MOB-RPS-006 — OTPs incorretos não bloqueiam a recuperação
**Pré-condição:** Solicitação de recuperação ativa e OTP ainda dentro do prazo de validade.
**Passos:**
1. Informar um OTP incorreto.
2. Repetir com outros códigos incorretos várias vezes.
3. Ainda dentro da validade do OTP, informar o código correto.
**Esperado:**
- Cada código incorreto é rejeitado.
- A conta não é bloqueada.
- O fluxo de recuperação não é encerrado por quantidade de tentativas.
- O OTP correto continua sendo aceito enquanto não tiver expirado.
**Rastreabilidade:** RF-AUT-003; RN-AUT-003.

### CT-MOB-RPS-007 — Rejeitar OTP expirado
**Pré-condição:** OTP expirado preparado no ambiente.
**Passos:** Informar o código expirado.
**Esperado:** Mensagem de código inválido/expirado e opção de solicitar novo código.
**Rastreabilidade:** RF-AUT-003.

### CT-MOB-RPS-008 — Reenviar OTP após cooldown de 60 segundos
**Pré-condição:** Usuário na tela de OTP da recuperação de senha.
**Passos:**
1. Tentar solicitar novo OTP imediatamente.
2. Verificar o estado do botão/contador de reenvio.
3. Aguardar o término dos 60 segundos.
4. Solicitar novo OTP.
5. Informar o OTP válido recebido.
**Esperado:**
- O reenvio fica indisponível durante os 60 segundos.
- O App apresenta o cooldown de forma coerente.
- Após os 60 segundos, uma nova solicitação pode ser realizada.
- Um OTP válido permite continuar a recuperação.
- A v2 não exige que o código anterior deixe de ser utilizável.
**Rastreabilidade:** RF-AUT-003; RN-AUT-002; RN-AUT-003.

### CT-MOB-RPS-009 — Rejeitar nova senha fora da política
**Pré-condição:** OTP validado.
**Passos:** Informar senha que não atende aos requisitos exibidos.
**Esperado:** Botão permanece desabilitado ou validação impede redefinição.
**Rastreabilidade:** RF-AUT-003; RN-AUT-006.

### CT-MOB-RPS-010 — Rejeitar confirmação divergente
**Pré-condição:** OTP validado.
**Passos:** Informar nova senha válida e confirmação diferente.
**Esperado:** Divergência informada; senha não alterada.
**Rastreabilidade:** RF-AUT-003.

### CT-MOB-RPS-011 — Redefinir senha com sucesso
**Pré-condição:** OTP válido e conta descartável.
**Passos:** Informar nova senha válida e confirmação igual; concluir; efetuar login com a nova senha.
**Esperado:** Redefinição confirmada; nova senha autentica e senha anterior não autentica.
**Rastreabilidade:** RF-AUT-003; CA-AUT-004.

---

## 5. Cadastro e solicitação de parceria (REG)

### CT-MOB-REG-001 — Abrir cadastro pelo login
**Passos:** Na tela de login, tocar em **Cadastrar**.
**Esperado:** Tela de pesquisa por CPF/CNPJ exibida.
**Rastreabilidade:** RF-REG-001; rota `/auth/register/`.

### CT-MOB-REG-002 — Formatar CPF durante digitação
**Passos:** Digitar 11 números no campo de documento.
**Esperado:** Máscara de CPF aplicada e apenas os dígitos normalizados usados na validação.
**Rastreabilidade:** RF-REG-001; `cnpj_search_page.dart`.

### CT-MOB-REG-003 — Formatar CNPJ durante digitação
**Passos:** Digitar 14 números no campo de documento.
**Esperado:** Máscara de CNPJ aplicada; caracteres excedentes não são aceitos.
**Rastreabilidade:** RF-REG-001; `cnpj_search_page.dart`.

### CT-MOB-REG-004 — Rejeitar CPF/CNPJ matematicamente inválido
**Passos:** Informar documento com dígitos verificadores inválidos; pesquisar.
**Esperado:** Diálogo “Documento inválido”; nenhuma confirmação de empresa.
**Rastreabilidade:** RF-REG-001; `DocumentValidators`.

### CT-MOB-REG-005 — Localizar empresa ativa por CNPJ
**Pré-condição:** Empresa parceira ativa.
**Passos:** Informar CNPJ válido cadastrado; pesquisar.
**Esperado:** Nome da empresa exibido em diálogo de confirmação com opções **Sim** e **Não**.
**Rastreabilidade:** RF-REG-001; CA-REG-001.

### CT-MOB-REG-006 — Recusar empresa encontrada
**Pré-condição:** Diálogo de confirmação aberto.
**Passos:** Tocar em **Não**.
**Esperado:** Diálogo fechado, documento limpo e estado da busca reiniciado.
**Rastreabilidade:** `cnpj_search_page.dart`.

### CT-MOB-REG-007 — Confirmar empresa encontrada
**Pré-condição:** Empresa ativa encontrada.
**Passos:** Tocar em **Sim**.
**Esperado:** Formulário de cadastro de usuário exibido com empresa vinculada.
**Rastreabilidade:** RF-REG-002.

### CT-MOB-REG-008 — Empresa não encontrada ou inativa
**Pré-condição:** Documento válido sem empresa ativa correspondente.
**Passos:** Pesquisar documento.
**Esperado:** Diálogo de documento não encontrado; cadastro vinculado não prossegue.
**Rastreabilidade:** RF-REG-001; RN-REG-001.

### CT-MOB-REG-009 — Validar campos obrigatórios do autocadastro
**Pré-condição:** Formulário de usuário aberto.
**Passos:** Tentar enviar sem preencher os campos obrigatórios.
**Esperado:** Campos inválidos identificados e cadastro não enviado.
**Rastreabilidade:** RF-REG-002.

### CT-MOB-REG-010 — Rejeitar e-mail duplicado no autocadastro
**Pré-condição:** Empresa ativa confirmada.
**Passos:** Preencher formulário com e-mail já cadastrado e demais dados válidos; enviar.
**Esperado:** Erro de e-mail já cadastrado; nenhum usuário duplicado criado.
**Rastreabilidade:** RF-REG-002; RN-USR-001.

### CT-MOB-REG-011 — Concluir autocadastro de vendedor
**Pré-condição:** Empresa ativa; e-mail novo.
**Passos:** Preencher dados válidos e enviar.
**Esperado:** Confirmação de cadastro; usuário criado como vendedor pendente/inativo até aprovação.
**Rastreabilidade:** RF-REG-002; CA-REG-003.

### CT-MOB-REG-012 — Usuário recém-cadastrado pendente não autentica
**Pré-condição:** Cadastro concluído, ainda não aprovado.
**Passos:** Voltar ao login e usar as credenciais cadastradas.
**Esperado:** Login rejeitado enquanto a conta estiver pendente/inativa.
**Rastreabilidade:** RF-REG-002; RN-REG-002.

### CT-MOB-REG-013 — Abrir formulário “Quero me tornar um parceiro”
**Passos:** Na tela de pesquisa de documento, acessar a opção de parceria.
**Esperado:** Tela explicativa/formulário de solicitação de parceria exibido.
**Rastreabilidade:** RF-PRO-001; rota `/auth/register/partner-request`.

### CT-MOB-REG-014 — Validar obrigatórios da solicitação de parceria
**Passos:** Tentar enviar a solicitação sem nome, e-mail ou telefone.
**Esperado:** Validação impede envio e identifica os campos obrigatórios.
**Rastreabilidade:** RF-PRO-001; RN-PRO-001.

### CT-MOB-REG-015 — Enviar solicitação de parceria válida
**Passos:** Preencher obrigatórios e, opcionalmente, empresa, CNPJ e experiência; enviar.
**Esperado:** Confirmação de envio sem autenticar automaticamente o visitante.
**Rastreabilidade:** RF-PRO-001.

---

## 6. Navegação e permissões por papel (NAV)

### CT-MOB-NAV-001 — Abrir e fechar menu do perfil
**Pré-condição:** Usuário autenticado.
**Passos:** Tocar no avatar; verificar dados; fechar pelo X e, em nova abertura, pelo fundo.
**Esperado:** Menu abre com nome/e-mail/papel/empresa disponíveis e fecha sem alterar a tela atual.
**Rastreabilidade:** `profile_modal.dart`.

### CT-MOB-NAV-002 — Menu de vendedor
**Pré-condição:** Vendedor autenticado.
**Passos:** Abrir menu.
**Esperado:** Exibe Editar perfil, Wiki, Drive, Sair e Deletar conta; não exibe Editar empresa, Configurar produtos, Prospecção ou Gestão administrativa.
**Rastreabilidade:** Matriz de papéis; `profile_modal.dart`.

### CT-MOB-NAV-003 — Menu de gestor
**Pré-condição:** Gestor autenticado com empresa.
**Passos:** Abrir menu.
**Esperado:**
- Exibe as opções comuns do Gestor.
- Exibe **Editar empresa**.
- Exibe o acesso à gestão dos usuários/vendedores da própria empresa.
- Não exibe **Configurar produtos**.
- Não exibe **Prospecção**.
- Não oferece acesso a relatórios de vendas/orçamentos.
- Não oferece funcionalidades administrativas exclusivas do Administrador.
**Rastreabilidade:** Matriz de papéis; RF-USR-001; matriz de permissões da v2; `profile_modal.dart`.

### CT-MOB-NAV-004 — Menu de administrador
**Pré-condição:** Administrador autenticado.
**Passos:** Abrir menu.
**Esperado:** Exibe Editar perfil, Editar empresa quando houver parceiro, Configurar produtos, Prospecção, Gestão administrativa, Wiki e Drive.
**Rastreabilidade:** Matriz de papéis; `profile_modal.dart`.

### CT-MOB-NAV-005 — Voltar preserva a tela anterior
**Pré-condição:** Abrir um módulo secundário pelo menu.
**Passos:** Usar seta de voltar.
**Esperado:** Retorna à lista de orçamentos sem encerrar o App nem duplicar rotas.
**Rastreabilidade:** `CustomTopBar` e módulos Flutter.

### CT-MOB-NAV-006 — Botão voltar na lista principal não fecha o App indevidamente
**Pré-condição:** Lista de orçamentos em primeiro plano.
**Passos:** Acionar voltar do Android.
**Esperado:** Comportamento definido da tela principal, sem tela preta ou navegação para área autenticada inválida.
**Rastreabilidade:** `budget_list_page.dart` (`PopScope`).

---

## 7. Lista e ações de orçamento (ORC)

### CT-MOB-ORC-001 — Listar orçamentos próprios como vendedor
**Pré-condição:** Vendedor com orçamentos próprios e de terceiros no ambiente.
**Passos:** Entrar no App.
**Esperado:** Somente orçamentos permitidos ao vendedor são exibidos.
**Rastreabilidade:** RF-ORC-011; CA-PER-001.

### CT-MOB-ORC-002 — Listar orçamentos da empresa como gestor
**Pré-condição:** Gestor e múltiplos vendedores da mesma empresa.
**Passos:** Entrar no App.
**Esperado:** Orçamentos da própria empresa exibidos; orçamentos de outras empresas ausentes.
**Rastreabilidade:** RF-ORC-011; CA-PER-002.

### CT-MOB-ORC-003 — Listar orçamentos de todos os parceiros como administrador
**Pré-condição:** Orçamentos de empresas diferentes.
**Passos:** Entrar como administrador.
**Esperado:** Lista contempla os orçamentos administrativos permitidos, com identificação de destino quando aplicável.
**Rastreabilidade:** RF-ORC-011.

### CT-MOB-ORC-004 — Buscar orçamento por texto
**Pré-condição:** Lista com registros conhecidos.
**Passos:** Digitar parte do nome/cidade/código no campo de busca.
**Esperado:** Lista filtrada coerentemente e restaurada ao limpar a busca.
**Rastreabilidade:** Tela `budget_list_page.dart`.

### CT-MOB-ORC-005 — Filtrar por status
**Pré-condição:** Registros em mais de um status.
**Passos:** Aplicar cada filtro disponível.
**Esperado:** Apenas registros correspondentes são exibidos; combinação e remoção de filtros funcionam.
**Rastreabilidade:** RF-ORC-011.

### CT-MOB-ORC-006 — Exibir arquivados e voltar aos realizados
**Pré-condição:** Ao menos um orçamento arquivado.
**Passos:** Selecionar filtro de arquivados; depois limpar/restaurar.
**Esperado:** Cabeçalho e lista alternam entre Arquivados e Realizados corretamente.
**Rastreabilidade:** RF-ORC-006; `budget_list_page.dart`.

### CT-MOB-ORC-007 — Resetar filtros
**Passos:** Aplicar busca e filtros; acionar reset.
**Esperado:** Estado padrão restaurado e lista recarregada sem filtros residuais.
**Rastreabilidade:** `budget_list_page.dart`.

### CT-MOB-ORC-008 — Paginação por rolagem
**Pré-condição:** Quantidade superior a uma página.
**Passos:** Rolar até o fim repetidamente.
**Esperado:** Próximas páginas carregadas sem duplicações, lacunas ou chamadas infinitas após o fim.
**Rastreabilidade:** RF-ORC-011; `budget_list_page.dart`.

### CT-MOB-ORC-009 — Atualizar lista por gesto de refresh
**Passos:** Alterar dados no ambiente; puxar para atualizar.
**Esperado:** Lista reflete o estado atual sem precisar reiniciar o App.
**Rastreabilidade:** `budget_list_page.dart`.

### CT-MOB-ORC-010 — Estado vazio da lista
**Pré-condição:** Usuário/filtro sem resultados.
**Passos:** Abrir a lista ou aplicar filtro sem correspondência.
**Esperado:** Mensagem “Nenhum orçamento encontrado” e nenhum erro visual.
**Rastreabilidade:** `budget_list_page.dart`.

### CT-MOB-ORC-011 — Recuperar falha de carregamento
**Pré-condição:** Backend/rede temporariamente indisponível.
**Passos:** Abrir lista; restaurar conexão; tocar em **Tentar novamente**.
**Esperado:** Erro legível, sem crash; nova tentativa carrega os dados.
**Rastreabilidade:** `budget_list_page.dart`.

### CT-MOB-ORC-012 — Abrir detalhes/edição de orçamento permitido
**Pré-condição:** Orçamento editável e usuário autorizado.
**Passos:** Tocar no cartão do orçamento.
**Esperado:** Tela de edição carrega censo, produtos, quantidades, validade e total corretos.
**Rastreabilidade:** RF-ORC-004.

### CT-MOB-ORC-013 — Aceitar nomes nos limites válidos ao renomear
**Pré-condição:** Orçamento permitido para edição.
**Passos:**
1. Renomear o orçamento utilizando um nome com exatamente 1 caractere.
2. Confirmar.
3. Repetir utilizando um nome com exatamente 255 caracteres.
**Esperado:**
- Nome com 1 caractere é aceito.
- Nome com 255 caracteres é aceito.
- O novo nome é persistido.
- O valor correto aparece após recarregar a lista/detalhe.
**Rastreabilidade:** RF-ORC-007; RN-ORC-010.

### CT-MOB-ORC-014 — Rejeitar nome vazio ao renomear
**Passos:** Abrir renomeação; apagar o nome; confirmar.
**Esperado:** Validação impede envio; nome anterior permanece.
**Rastreabilidade:** RF-ORC-007.

### CT-MOB-ORC-015 — Rejeitar nome acima do limite aceito pelo App/servidor
**Passos:** Informar nome com mais de 255 caracteres; confirmar.
**Esperado:** Operação rejeitada e nome anterior preservado.
**Rastreabilidade:** RF-ORC-007; regra funcional de 1–255 caracteres.

### CT-MOB-ORC-016 — Arquivar orçamento
**Pré-condição:** Orçamento ativo permitido.
**Passos:** Acionar arquivamento e confirmar, se solicitado.
**Esperado:** Registro sai dos realizados, aparece em arquivados e mantém seu status comercial.
**Rastreabilidade:** RF-ORC-006; RN-ORC-009.

### CT-MOB-ORC-017 — Desarquivar orçamento
**Pré-condição:** Orçamento arquivado.
**Passos:** Abrir arquivados; desarquivar.
**Esperado:** Registro retorna à listagem ativa sem mudança indevida do status.
**Rastreabilidade:** RF-ORC-006; RN-ORC-009.

### CT-MOB-ORC-018 — Versionar orçamento preservando versão anterior e censo
**Pré-condição:**
- Orçamento permitido com produtos, quantidades e censo conhecidos.
- Ter cenário de cidade única e cenário multi-cidade preparados.
**Passos:**
1. Registrar valores da versão atual.
2. Solicitar nova versão.
3. Alterar uma quantidade/produto na nova versão.
4. Concluir o versionamento.
5. Abrir a nova versão.
6. Consultar novamente a versão anterior.
7. Repetir o fluxo com orçamento multi-cidade.
**Esperado:**
- A versão original fica arquivada.
- A versão original permanece com seus valores anteriores.
- A alteração aparece somente na nova versão.
- A nova versão fica vinculada à anterior.
- O censo utilizado pela versão anterior é preservado na nova versão.
- O censo não é silenciosamente substituído pelo censo oficial mais recente.
- Cidade única e multi-cidade seguem a mesma regra de versionamento.
**Rastreabilidade:** RF-ORC-005; RN-ORC-007; RN-ORC-008; CA-ORC-012.

### CT-MOB-ORC-019 — Bloquear operações em orçamento sem permissão
**Pré-condição:**
- Vendedor autenticado.
- Existe orçamento pertencente a outro vendedor.
- Quando necessário, acesso preparado por rota/estado controlado sem substituir a interação real pela interface.
**Passos:**
Tentar, conforme as ações existentes no App:
1. Abrir o orçamento.
2. Editar.
3. Gerar PDF.
4. Exportar CSV.
5. Visualizar censo.
6. Arquivar/desarquivar.
7. Versionar.
**Esperado:**
- Nenhuma operação não autorizada é concluída.
- O usuário não recebe dados protegidos do orçamento.
- Nenhuma alteração é persistida.
- A autorização não depende apenas do orçamento estar oculto na listagem.
**Rastreabilidade:** RN-ORC-005; CA-PER-003; RF-ORC-004; RF-ORC-005; RF-ORC-006; RF-ORC-009; RF-ORC-010.

### CT-MOB-ORC-020 — Orçamento aprovado permanece editável
**Pré-condição:** Orçamento com status `aprovado` e usuário autorizado a editá-lo.
**Passos:** Abrir, alterar um dado permitido, salvar e reabrir o orçamento.
**Esperado:** A edição é permitida e persistida normalmente; o status `aprovado` não ativa modo somente leitura.
**Rastreabilidade:** RF-ORC-004; RN-ORC-005.

### CT-MOB-ORC-021 — Renomear usando exatamente o nome atual
**Pré-condição:** Orçamento permitido com nome conhecido.
**Passos:**
1. Abrir a ação de renomear.
2. Informar exatamente o mesmo nome atualmente salvo.
3. Confirmar.
**Esperado:**
- A operação não é rejeitada por “nome igual”.
- O sistema retorna sucesso/controla a operação normalmente.
- O orçamento continua com o mesmo nome.
- Nenhum dado adicional é alterado.
**Rastreabilidade:** RF-ORC-007; RN-ORC-010.

### CT-MOB-ORC-022 — Histórico de parceiro inativo continua acessível
**Pré-condição:**
- Parceiro atualmente inativo.
- Parceiro possui orçamento criado antes da inativação.
- Usuário autenticado com permissão para consultar esse orçamento.
**Passos:**
1. Abrir a lista de orçamentos.
2. Localizar o orçamento histórico do parceiro inativo.
3. Abrir o orçamento.
4. Gerar PDF, quando permitido.
5. Exportar o censo, quando permitido.
**Esperado:**
- A inativação do parceiro não apaga nem oculta automaticamente seu histórico.
- O orçamento anterior continua consultável conforme as permissões normais.
- Operações de leitura/exportação permitidas continuam disponíveis.
- A restrição do parceiro inativo aplica-se à criação de **novos** orçamentos, e não ao histórico.
**Rastreabilidade:** RN-PAR-001; RN-ORC-015.

---

## 8. Criação e configuração de orçamento (CRI)

### CT-MOB-CRI-001 — Abrir novo orçamento
**Pré-condição:** Usuário autenticado.
**Passos:** Na lista, tocar em **Novo Orç.**
**Esperado:** Tela “Novo orçamento” exibida com opções aplicáveis ao papel.
**Rastreabilidade:** RF-ORC-001 a RF-ORC-003.

### CT-MOB-CRI-002 — Campos de parceiro exclusivos do administrador
**Pré-condição:** Comparar administrador e vendedor/gestor.
**Passos:** Abrir novo orçamento em cada papel.
**Esperado:** Seleção “Gerar orçamento para” aparece apenas para administrador; demais criam no próprio parceiro.
**Rastreabilidade:** RF-ORC-001; matriz de papéis.

### CT-MOB-CRI-003 — Selecionar somente parceiro ativo como destino
**Pré-condição:**
- Administrador autenticado.
- Ao menos um parceiro ativo.
- Ao menos um parceiro inativo.
**Passos:**
1. Abrir novo orçamento.
2. Abrir **Gerar orçamento para**.
3. Buscar o parceiro ativo.
4. Buscar o parceiro inativo.
5. Selecionar o parceiro ativo.
6. Prosseguir com a criação.
**Esperado:**
- Parceiro ativo pode ser selecionado.
- Parceiro inativo não pode ser utilizado como destino de um novo orçamento.
- O orçamento criado fica associado ao parceiro ativo selecionado.
- Nomes duplicados continuam sendo desambiguados por CNPJ quando disponível.
**Rastreabilidade:** RF-ORC-001; RN-PAR-001.

### CT-MOB-CRI-004 — Validar estado e cidade obrigatórios
**Passos:** Tentar criar orçamento de cidade única sem selecionar localização.
**Esperado:** Mensagem “Selecione um estado e uma cidade”; nenhum rascunho válido criado.
**Rastreabilidade:** RF-ORC-001; `new_budget_page.dart`.

### CT-MOB-CRI-005 — Validar e-mail do responsável
**Passos:** Preencher localização e e-mail malformado; continuar.
**Esperado:** Mensagem “Email inválido” e fluxo bloqueado.
**Rastreabilidade:** `new_budget_page.dart`.

### CT-MOB-CRI-006 — Criar orçamento de cidade única
**Pré-condição:** Cidade ativa com censo.
**Passos:** Selecionar estado/cidade; preencher dados aplicáveis; continuar; selecionar produtos; definir validade; salvar.
**Esperado:** Orçamento salvo, status final esperado exibido e snapshot do censo associado à cidade.
**Rastreabilidade:** RF-ORC-001; CA-ORC-001.

### CT-MOB-CRI-007 — Abandonar rascunho não cria orçamento recuperável
**Pré-condição:** Rascunho criado e tela de configuração aberta.
**Passos:**
1. Voltar antes de finalizar a configuração.
2. Confirmar a saída quando solicitado.
3. Voltar à lista de orçamentos.
4. Atualizar a lista.
5. Encerrar e reabrir o App.
6. Procurar o orçamento abandonado.
**Esperado:**
- O fluxo é abandonado sem navegação inconsistente.
- O rascunho abandonado não aparece na lista de orçamentos.
- O rascunho não é oferecido para retomada.
- Reabrir o App não recupera o rascunho como orçamento do usuário.
**Rastreabilidade:** ciclo de vida do orçamento; estado `rascunho`; RN-ORC-015.

### CT-MOB-CRI-008 — Exigir nome no multi-cidade
**Passos:** Selecionar fluxo multi-cidade; deixar nome vazio; tentar avançar.
**Esperado:** Botão não avança ou validação informa obrigatoriedade.
**Rastreabilidade:** RF-ORC-002; seção 9.4 do documento funcional.

### CT-MOB-CRI-009 — Cancelar seleção multi-cidade
**Passos:** Abrir fluxo multi-cidade; informar nome; abrir seleção; cancelar.
**Esperado:** Nenhum orçamento criado e retorno seguro à tela anterior.
**Rastreabilidade:** RF-ORC-002.

### CT-MOB-CRI-010 — Criar orçamento multi-cidade
**Pré-condição:** Duas ou mais cidades ativas com censo.
**Passos:** Informar nome; selecionar cidades; confirmar; configurar produtos e validade; salvar.
**Esperado:** Orçamento criado com todas as cidades e censo agregado por etapa.
**Rastreabilidade:** RF-ORC-002; CA-ORC-002.

### CT-MOB-CRI-011 — Remover cidade antes de concluir multi-cidade
**Pré-condição:** Mais de uma cidade selecionada.
**Passos:** Remover uma cidade; confirmar seleção.
**Esperado:** Somente cidades restantes compõem o orçamento e o agregado.
**Rastreabilidade:** RF-ORC-002.

### CT-MOB-CRI-012 — Criar orçamento personalizado
**Status:** **PLANEJADO** — executar somente a partir da versão que disponibilizar o fluxo personalizado.
**Passos:** Selecionar fluxo personalizado; informar indicadores manuais; configurar produtos e validade; salvar.
**Esperado:** Orçamento criado sem município, usando valores manuais.
**Rastreabilidade:** RF-ORC-003; CA-ORC-003.

### CT-MOB-CRI-013 — Rejeitar valor inválido no censo personalizado
**Status:** **PLANEJADO** — executar somente a partir da versão que disponibilizar o fluxo personalizado.
**Passos:** Informar valor negativo, não numérico ou fora do formato aceito; continuar.
**Esperado:** Validação impede conclusão ou normaliza de forma explícita sem salvar valor inválido.
**Rastreabilidade:** RF-ORC-003.

### CT-MOB-CRI-014 — Visualizar censo do orçamento
**Pré-condição:** Orçamento com censo carregado.
**Passos:** Abrir a visualização de censo.
**Esperado:** Grupos, etapas, estudantes/professores e valores correspondentes são exibidos.
**Rastreabilidade:** RF-CEN-001; RN-CEN-001.

### CT-MOB-CRI-015 — Editar snapshot do censo
**Pré-condição:** Orçamento editável.
**Passos:** Alterar valor de uma etapa no censo do orçamento; voltar à configuração.
**Esperado:** Valor do snapshot e quantidades dependentes são atualizados sem alterar visualmente outros campos indevidos.
**Rastreabilidade:** RF-CEN-002; RN-CEN-002.

### CT-MOB-CRI-016 — Agregado multi-cidade após editar cidade
**Pré-condição:** Orçamento multi-cidade editável.
**Passos:** Alterar indicador de uma cidade.
**Esperado:** Agregado recalculado pela soma das cidades e produtos dependentes atualizados.
**Rastreabilidade:** RN-CEN-003; seção 12.7.

### CT-MOB-CRI-017 — Navegar categoria, subcategoria e produtos
**Pré-condição:** Catálogo ativo.
**Passos:** Abrir categoria; subcategoria; retornar pelo cabeçalho/seta; abrir outra opção.
**Esperado:** Hierarquia, títulos, contagens e seleção preservados corretamente.
**Rastreabilidade:** Estrutura de catálogo no App.

### CT-MOB-CRI-018 — Selecionar e desmarcar categoria inteira
**Pré-condição:** Categoria com produtos ativos.
**Passos:** Marcar categoria; verificar descendentes; desmarcar.
**Esperado:** Seleção em cascata coerente e total recalculado nos dois sentidos.
**Rastreabilidade:** RF-ORC-001; `ToggleCategoryUseCase`.

### CT-MOB-CRI-019 — Selecionar produto individual
**Passos:** Abrir subcategoria; selecionar apenas um produto e indicadores aplicáveis.
**Esperado:** Produto entra no orçamento com quantidade e subtotal coerentes; demais permanecem desmarcados.
**Rastreabilidade:** RF-ORC-001.

### CT-MOB-CRI-020 — Impedir finalização com total menor ou igual a zero
**Pré-condição:** Fluxo de criação na tela de configuração.
**Passos:**
1. Deixar todos os produtos desmarcados ou preparar configuração cujo total seja zero.
2. Tocar em salvar.
3. Caso o App apresente o diálogo **Orçamento sem produtos**, acionar também a opção que tenta continuar o salvamento.
**Esperado:**
- O orçamento não é finalizado enquanto o total for menor ou igual a zero.
- O registro não deve chegar ao estado final `pendente` com total zero.
- O usuário permanece no fluxo para corrigir a configuração.
- Não deve ser considerado sucesso apenas porque existe uma opção visual **Salvar mesmo assim**.
**Rastreabilidade:** RF-ORC-001; seção 9.4 da v2.

### CT-MOB-CRI-021 — Validade mínima válida
**Passos:** Definir validade em 1 dia e salvar orçamento válido.
**Esperado:** Salvo com validade correspondente.
**Rastreabilidade:** RF-ORC-001; seção 9.4.

### CT-MOB-CRI-022 — Rejeitar validade zero/negativa
**Passos:** Informar 0 ou valor negativo, quando o teclado permitir; salvar.
**Esperado:** Validação impede salvamento.
**Rastreabilidade:** RF-ORC-001; seção 9.4.

### CT-MOB-CRI-023 — Validade máxima válida
**Passos:** Definir 365 dias e salvar.
**Esperado:** Orçamento salvo.
**Rastreabilidade:** RF-ORC-001; seção 9.4.

### CT-MOB-CRI-024 — Rejeitar validade acima de 365
**Passos:** Informar 366 dias; salvar.
**Esperado:** Validação impede salvamento e preserva a edição para correção.
**Rastreabilidade:** RF-ORC-001; seção 9.4.

### CT-MOB-CRI-025 — Impedir duplo salvamento
**Passos:** Com orçamento válido, tocar repetidamente em salvar durante o carregamento.
**Esperado:** Uma única operação efetiva; sem registros duplicados ou múltiplos diálogos.
**Rastreabilidade:** Telas de configuração/edição.

---

## 9. Cálculos e edição (CAL)

### CT-MOB-CAL-001 — Livro calculado por indicadores de estudantes
**Pré-condição:** Produto livro e censo conhecido.
**Passos:** Selecionar etapas de estudantes.
**Esperado:** Quantidade é a soma dos indicadores selecionados e subtotal é quantidade × valor unitário.
**Rastreabilidade:** Seção 12.2; CA-CAL-001.

### CT-MOB-CAL-002 — Livro calculado por indicadores de professores
**Pré-condição:** Produto livro e indicadores com sufixo de professor conhecidos.
**Passos:** Selecionar etapa e opção de professores.
**Esperado:** Quantidade usa os indicadores de professores correspondentes conforme regra funcional.
**Rastreabilidade:** Seção 12.3; CA-CAL-002.

### CT-MOB-CAL-003 — Tecnologia com estudantes e professores
**Passos:** Selecionar produto tecnologia, etapa e professores.
**Esperado:** Quantidade soma estudantes e professores correspondentes.
**Rastreabilidade:** Seção 12.4; CA-CAL-003.

### CT-MOB-CAL-004 — Serviço calculado por produtos relacionados
**Pré-condição:** Serviço com percentual, horas fixas e produtos relacionados conhecidos.
**Passos:** Selecionar produtos relacionados e serviço.
**Esperado:** Quantidade e subtotal seguem `(soma relacionada × percentual) + horas fixas`; divergência de arredondamento, se observada, é registrada como falha/achado.
**Rastreabilidade:** Seção 12.5; CA-CAL-004.

### CT-MOB-CAL-005 — Total preserva precisão e apresenta valor monetário corretamente
**Pré-condição:** Produtos/quantidades preparados de forma que os cálculos intermediários possuam precisão superior a duas casas decimais.
**Passos:**
1. Selecionar os produtos.
2. Executar o cálculo.
3. Comparar os subtotais e total esperado utilizando a precisão completa dos valores.
4. Verificar a exibição monetária na interface.
**Esperado:**
- O cálculo utiliza a precisão dos valores intermediários sem truncamento/arredondamento antecipado.
- O total corresponde à soma matemática dos subtotais.
- A apresentação monetária ao usuário utiliza o formato pt-BR adequado.
- A formatação visual não altera o valor utilizado nos cálculos seguintes.
**Rastreabilidade:** seção 12.8 da v2; RN-ORC-006.

### CT-MOB-CAL-006 — Ativar quantidade manual
**Pré-condição:** Produto selecionado com quantidade automática.
**Passos:** Ativar modo manual; informar quantidade válida.
**Esperado:** Quantidade manual substitui o cálculo e total é atualizado.
**Rastreabilidade:** RF-ORC-008; CA-ORC-007.

### CT-MOB-CAL-007 — Desativar quantidade manual
**Pré-condição:** Produto com quantidade manual.
**Passos:** Desativar/resetar modo manual.
**Esperado:** Quantidade volta ao cálculo automático e total é atualizado.
**Rastreabilidade:** RF-ORC-008.

### CT-MOB-CAL-008 — Rejeitar quantidade manual inválida
**Passos:** Tentar informar valor negativo, vazio ou texto não numérico.
**Esperado:** Valor inválido não é persistido nem produz total negativo/NaN.
**Rastreabilidade:** RF-ORC-008.

### CT-MOB-CAL-009 — Salvar edição e refletir na lista
**Pré-condição:** Orçamento editável.
**Passos:** Alterar produto/indicador/quantidade/validade; salvar; retornar.
**Esperado:** Sucesso exibido; lista e reabertura apresentam os valores persistidos e total recalculado.
**Rastreabilidade:** RF-ORC-004; CA-ORC-004.

### CT-MOB-CAL-010 — Sair com alterações pendentes
**Classificação atualizada em 12/09/2026:** melhoria solicitada; resultados históricos permanecem históricos.
**Pré-condição:** Orçamento comum ou multi-cidade com alteração local efetiva não salva.
**Passos:** Alterar quantidade/preço/seleção/metadado; voltar pelo cabeçalho e pelo sistema; cancelar; repetir e descartar. Repetir sem alterações e após editar/desfazer. Salvar censo com quantidade local manual pendente e repetir.
**Esperado:** Um diálogo Cancelar/Descartar; cancelar preserva edição; descartar fecha uma vez sem gravar alterações locais. Sem mudança efetiva, sai diretamente. Censo já salvo permanece salvo e a lista recebe atualização. Sucesso no salvar sai normalmente; falha mantém alterações. Verificar gesto nativo Android/iOS separadamente dos widgets.
**Rastreabilidade:** `edit_budget_page.dart`.

### CT-MOB-CAL-011 — Bloquear compartilhamento com alterações pendentes
**Pré-condição:** Alteração não salva.
**Passos:** Acionar compartilhamento/PDF.
**Esperado:** App orienta salvar ou descartar antes; arquivo não é gerado com estado ambíguo.
**Rastreabilidade:** `edit_budget_page.dart`.

### CT-MOB-CAL-012 — Editar orçamento expirado com nova validade
**Pré-condição:** Orçamento expirado e editável.
**Passos:** Definir nova validade válida; salvar.
**Esperado:** Edição salva e status resultante segue a regra de retorno a pendente.
**Rastreabilidade:** Ciclo de vida, seção 10.1.

### CT-MOB-CAL-013 — Serviço aceita percentual zero
**Pré-condição:**
- Serviço com pelo menos um produto relacionado válido.
- Percentual configurado como `0%`.
- Horas fixas conhecidas, por exemplo `40`.
**Passos:**
1. Selecionar o produto relacionado.
2. Selecionar o serviço configurado com percentual `0%`.
3. Verificar quantidade e subtotal.
**Esperado:**
- Percentual `0%` é aceito.
- O serviço não é rejeitado por percentual zero.
- A quantidade é determinada pelas horas fixas.
- Exemplo: percentual `0%` + `40` horas fixas resulta em quantidade `40`.
**Rastreabilidade:** RN-CAT-005; regra de cálculo de serviços.

---

## 10. Geração e compartilhamento (EXP)

### CT-MOB-EXP-001 — Gerar PDF com dados completos
**Pré-condição:** Orçamento válido; nome, cargo, telefone e e-mail do responsável preenchidos.
**Passos:** Acionar geração/compartilhamento de PDF.
**Esperado:** PDF gerado e folha de compartilhamento do sistema aberta com arquivo identificável.
**Rastreabilidade:** RF-ORC-009; CA-ORC-008.

### CT-MOB-EXP-002 — Bloquear PDF sem nome do responsável
**Passos:** Remover/deixar vazio o nome no diálogo aplicável; gerar.
**Esperado:** Campo obrigatório informado e nenhum PDF compartilhado.
**Rastreabilidade:** RF-ORC-009.

### CT-MOB-EXP-003 — Bloquear PDF sem cargo
**Passos:** Remover/deixar vazio o cargo; gerar.
**Esperado:** Validação impede geração.
**Rastreabilidade:** RF-ORC-009.

### CT-MOB-EXP-004 — Bloquear PDF sem telefone
**Passos:** Remover/deixar vazio o telefone; gerar.
**Esperado:** Validação de telefone obrigatório impede geração.
**Rastreabilidade:** RF-ORC-009.

### CT-MOB-EXP-005 — Bloquear PDF sem e-mail válido
**Passos:** Informar e-mail vazio ou inválido; gerar.
**Esperado:** Validação impede geração.
**Rastreabilidade:** RF-ORC-009.

### CT-MOB-EXP-006 — Cancelar folha de compartilhamento
**Pré-condição:** PDF gerado.
**Passos:** Fechar/cancelar a folha do Android.
**Esperado:** Retorna ao orçamento sem crash, duplicação ou mudança indevida de estado.
**Rastreabilidade:** RF-ORC-009.

### CT-MOB-EXP-007 — Exportar censo em CSV
**Pré-condição:** Orçamento com censo.
**Passos:** Acionar exportação do censo.
**Esperado:** Arquivo CSV gerado e oferecido ao compartilhamento; indicadores e valores possuem estrutura legível.
**Rastreabilidade:** RF-ORC-010; CA-ORC-009.

### CT-MOB-EXP-008 — Gerar PDF renova pelo prazo salvo e recupera status expirado
**Regra atualizada em 12/09/2026:** a premissa de prazo fixo foi substituída pelo prazo configurado. Os resultados anteriores não são novos PASS.
**Pré-condição:**
- Orçamento com dados obrigatórios do vendedor preenchidos.
- Data de validade e prazo salvo conhecidos; executar matriz 15/60/90 dias e pendente/aprovado/não aprovado/expirado, com e sem arquivamento.

**Cenário A — orçamento ainda válido**
**Passos:**
1. Registrar a validade atual.
2. Gerar/compartilhar o PDF.
3. Atualizar/reabrir o orçamento.
**Esperado:**
- A validade passa a corresponder ao momento da operação mais `orc_dias_validade`.
- Prazo salvo, status não expirado, ID, versões, arquivamento, produtos e valores permanecem intactos.

**Cenário B — orçamento expirado**
**Passos:**
1. Usar orçamento em status expirado.
2. Gerar/compartilhar o PDF.
3. Atualizar/reabrir o orçamento.
**Esperado:**
- A geração é capaz de renovar a validade.
- A nova validade corresponde ao momento da operação mais o prazo salvo; não soma à validade anterior.
- Somente `expirado` muda para `pendente`, na mesma atualização da data.
- Repetir a geração conta o prazo a partir do novo momento. Geração negada/falha não renova; falha de renovação não entrega sucesso. Ao retornar/recarregar, a interface mostra data/status persistidos.
**Rastreabilidade:** RF-ORC-009; RN-ORC-013; CA-ORC-010.

---

## 11. Perfil e conta (PRF)

### CT-MOB-PRF-001 — Carregar perfil próprio
**Pré-condição:** Usuário autenticado.
**Passos:** Menu > **Editar perfil**.
**Esperado:** Nome, e-mail, cargo, telefone e avatar atuais exibidos; papel/status/senha não editáveis por esse fluxo.
**Rastreabilidade:** RF-PRF-001; RN-PRF-001.

### CT-MOB-PRF-002 — Editar dados válidos do perfil
**Passos:** Alterar nome, e-mail disponível, cargo e telefone; salvar; reabrir perfil.
**Esperado:** Confirmação de sucesso e dados persistidos também no menu do perfil.
**Rastreabilidade:** RF-PRF-001.

### CT-MOB-PRF-003 — Rejeitar e-mail duplicado no perfil
**Passos:** Informar e-mail pertencente a outro usuário; salvar.
**Esperado:** Erro exibido e dados anteriores preservados.
**Rastreabilidade:** RF-PRF-001; RN-PRF-001.

### CT-MOB-PRF-004 — Validar telefone do perfil
**Passos:** Informar telefone incompleto/inválido; salvar.
**Esperado:** Formatação/validação aplicada; valor inválido não é persistido.
**Rastreabilidade:** RF-PRF-001.

### CT-MOB-PRF-005 — Atualizar avatar válido
**Pré-condição:** Galeria com imagem suportada.
**Passos:** Selecionar imagem; recortar; confirmar.
**Esperado:** Upload confirmado e avatar atualizado no perfil/menu após refresh.
**Rastreabilidade:** RF-PRF-002; RN-PRF-002.

### CT-MOB-PRF-006 — Cancelar seleção/recorte do avatar
**Passos:** Abrir seletor ou recortador; cancelar.
**Esperado:** Avatar anterior mantido e nenhum erro fatal.
**Rastreabilidade:** RF-PRF-002.

### CT-MOB-PRF-007 — Rejeitar avatar inválido ou acima de 5 MiB
**Pré-condição:** Avatar atual e imagens de teste válidas, inválidas, vazias/corrompidas e de 5.242.880/5.242.881 bytes.
**Passos:** Selecionar original sem redução; repetir no limite, acima do limite e com conteúdo inválido; cancelar seletor/recorte e tentar novamente após falha.
**Esperado:** Validar tamanho e conteúdo antes do recorte; limite inclusivo de 5.242.880 bytes. Rejeição não abre recorte nem faz upload, informa motivo e preserva avatar/formulário. Imagem válida segue recorte quadrado/JPEG/upload; somente sucesso atualiza avatar. Registrar validação do original no dispositivo Android/iOS separadamente dos testes com fakes.
**Rastreabilidade:** RF-PRF-002; RN-PRF-002.

### CT-MOB-PRF-008 — Remover avatar com confirmação
**Pré-condição:** Usuário com avatar.
**Passos:** Tocar em remover; cancelar; repetir e confirmar.
**Esperado:** Cancelamento preserva imagem; confirmação remove e atualiza o avatar padrão.
**Rastreabilidade:** `profile_page.dart`.

### CT-MOB-PRF-009 — Cancelar exclusão da conta
**Pré-condição:** Conta descartável autenticada.
**Passos:** Menu > **Deletar conta**; cancelar.
**Esperado:** Conta e sessão permanecem ativas.
**Rastreabilidade:** RF-USR-006; `custom_top_bar.dart`.

### CT-MOB-PRF-010 — Excluir a própria conta
**Pré-condição:** Conta descartável e autorização explícita para executar o caso destrutivo.
**Passos:** Menu > **Deletar conta**; confirmar; fechar confirmação de sucesso; tentar novo login.
**Esperado:** Exclusão lógica concluída, credenciais locais apagadas, login exibido e nova autenticação rejeitada.
**Rastreabilidade:** RF-USR-006; RN-USR-012.

---

## 12. Empresa do usuário (EMP)

### CT-MOB-EMP-001 — Abrir edição da própria empresa como gestor/admin
**Pré-condição:** Gestor ou administrador com parceiro associado.
**Passos:** Menu > **Editar empresa**.
**Esperado:** Dados atuais da empresa carregados.
**Rastreabilidade:** RF-PAR-003.

### CT-MOB-EMP-002 — Vendedor não acessa edição da empresa
**Pré-condição:** Vendedor autenticado.
**Passos:** Abrir menu e tentar alcançar a função pela navegação normal.
**Esperado:** Opção ausente; nenhuma edição de empresa disponível.
**Rastreabilidade:** Matriz de papéis.

### CT-MOB-EMP-003 — Atualizar dados válidos da empresa
**Passos:** Alterar nome fantasia, razão social, e-mail, telefone e URL com valores válidos; salvar; reabrir.
**Esperado:** Sucesso e persistência dos novos dados.
**Rastreabilidade:** RF-PAR-003; RN-PAR-005.

### CT-MOB-EMP-004 — Rejeitar CNPJ inválido
**Passos:** Informar CNPJ inválido; salvar.
**Esperado:** Validação impede atualização e mantém dado anterior no servidor.
**Rastreabilidade:** RF-PAR-003.

### CT-MOB-EMP-005 — Rejeitar e-mail inválido da empresa
**Passos:** Informar e-mail malformado; salvar.
**Esperado:** Validação/erro legível e nenhuma atualização parcial indevida.
**Rastreabilidade:** RF-PAR-003.

### CT-MOB-EMP-006 — Atualizar logo válida da empresa
**Pré-condição:** Imagem suportada na galeria.
**Passos:** Selecionar logo; usar recorte quadrado ou 16:9 indicado; confirmar.
**Esperado:** Logo atualizada e refletida após refresh.
**Rastreabilidade:** RF-PAR-005; RN-PAR-008.

### CT-MOB-EMP-007 — Cancelar recorte da logo
**Passos:** Selecionar imagem; cancelar no recortador.
**Esperado:** Logo anterior preservada.
**Rastreabilidade:** `partner_edit_page.dart`.

### CT-MOB-EMP-008 — Rejeitar formato/proporção inválida de logo
**Passos:** Selecionar arquivo não permitido ou resultado fora das proporções aceitas.
**Esperado:** Aviso “Formato de logo inválido”/“Item não permitido”; logo anterior preservada.
**Rastreabilidade:** RF-PAR-005; `LogoAspectRatioValidator`.

---

## 13. Gestão mobile de usuários (USR)

### CT-MOB-USR-001 — Gestor lista usuários da própria empresa
**Pré-condição:** Gestor com vendedores cadastrados.
**Passos:** Menu > **Gestão administrativa**.
**Esperado:** Tela “Gestão de Usuários” mostra somente usuários permitidos da empresa.
**Rastreabilidade:** RF-USR-001; RF-USR-004.

### CT-MOB-USR-002 — Buscar usuário
**Pré-condição:** Lista com usuários.
**Passos:** Digitar parte de nome/e-mail; limpar busca.
**Esperado:** Filtro local coerente; mensagem específica quando não há resultado; lista restaurada ao limpar.
**Rastreabilidade:** RF-USR-001; `user_management_page.dart`.

### CT-MOB-USR-003 — Paginar e atualizar usuários
**Pré-condição:** Mais de uma página.
**Passos:** Rolar até o fim; puxar para atualizar.
**Esperado:** Novos itens sem duplicação e refresh reflete alterações atuais.
**Rastreabilidade:** RF-USR-001.

### CT-MOB-USR-004 — Alterar status de vendedor e salvar lote
**Pré-condição:** Vendedor da própria empresa.
**Passos:** Alternar status; verificar contador de alterações; salvar.
**Esperado:** Uma alteração pendente indicada, sucesso exibido e estado persistido.
**Rastreabilidade:** RF-USR-004; CA-USR-002.

### CT-MOB-USR-005 — Alterar papel permitido e salvar lote
**Pré-condição:** Usuário subordinado elegível.
**Passos:** Alterar papel entre vendedor/gestor; salvar.
**Esperado:** Alteração aceita e persistida conforme permissões.
**Rastreabilidade:** RF-USR-004; RN-USR-009.

### CT-MOB-USR-006 — Bloquear alteração do próprio gestor
**Pré-condição:** Gestor aparece na lista.
**Passos:** Tentar mudar o próprio status/papel.
**Esperado:** Ação bloqueada e nenhuma alteração pendente válida criada.
**Rastreabilidade:** RF-USR-004; CA-USR-003.

### CT-MOB-USR-007 — Bloquear alteração de papel superior ou igual
**Pré-condição:** Usuário-alvo com papel não alterável pelo ator.
**Passos:** Tentar alterar status/papel.
**Esperado:** Diálogo “Ação não permitida”; nenhuma persistência.
**Rastreabilidade:** `user_management_page.dart`.

### CT-MOB-USR-008 — Salvar sem alterações
**Passos:** Abrir gestão e tocar em salvar sem modificar usuários.
**Esperado:** Aviso “Nenhuma alteração para salvar”.
**Rastreabilidade:** `user_management_page.dart`.

### CT-MOB-USR-009 — Falha parcial/total ao salvar lote
**Pré-condição:** Cenário de falha preparado de forma controlada.
**Passos:** Fazer alterações; salvar.
**Esperado:** Erro apresentado sem declarar sucesso indevido; UI permite recarregar e reconciliar o estado real.
**Rastreabilidade:** RF-USR-004.

---

## 14. Gestão mobile de empresas e relatórios (ADM)

### CT-MOB-ADM-001 — Administrador lista empresas
**Pré-condição:** Administrador autenticado.
**Passos:** Menu > **Gestão administrativa**.
**Esperado:** Tela “Gestão de Empresas” com cartões e ações de usuários/relatórios.
**Rastreabilidade:** RF-PAR-001; `partner_management_page.dart`.

### CT-MOB-ADM-002 — Buscar empresa com debounce
**Passos:** Digitar parte do nome; aguardar; limpar.
**Esperado:** Resultados correspondentes após a espera, sem excesso visível de recargas; lista restaurada ao limpar.
**Rastreabilidade:** RF-PAR-001; `partner_management_page.dart`.

### CT-MOB-ADM-003 — Paginar e atualizar empresas
**Pré-condição:** Mais de uma página.
**Passos:** Rolar; puxar para atualizar.
**Esperado:** Paginação sem duplicação e dados atualizados.
**Rastreabilidade:** RF-PAR-001.

### CT-MOB-ADM-004 — Abrir usuários de uma empresa
**Passos:** Em um cartão, tocar em **Usuários**.
**Esperado:** Gestão de usuários filtrada pelo parceiro selecionado; não mistura usuários de outros parceiros.
**Rastreabilidade:** RF-USR-001; rota `/user-management/partner/:partnerId`.

### CT-MOB-ADM-005 — Abrir relatórios de uma empresa
**Passos:** Em um cartão, tocar em **Relatórios**.
**Esperado:** Lista de vendedores/orçamentos referente ao parceiro selecionado.
**Rastreabilidade:** RF-REL-001/RF-REL-002; rota `/reports/partner/:partnerId`.

### CT-MOB-ADM-006 — Relatório de orçamentos por vendedor com filtros
**Pré-condição:**
- Administrador autenticado.
- Vendedor com orçamentos em diferentes status, datas, cidades/estados e situações de arquivamento.
**Passos:**
1. Abrir relatórios da empresa.
2. Selecionar vendedor.
3. Filtrar por período.
4. Filtrar por status.
5. Filtrar por arquivado/não arquivado.
6. Filtrar por localização disponível no App.
7. Combinar filtros.
8. Limpar os filtros.
**Esperado:**
- Somente orçamentos do vendedor selecionado são exibidos.
- Cada filtro restringe corretamente os resultados.
- A combinação de filtros é coerente.
- Limpar filtros restaura os resultados esperados.
- Totais e contagens correspondem ao conjunto filtrado.
**Rastreabilidade:** RF-REL-002; RN-REL-002.

### CT-MOB-ADM-007 — Validar intervalo de datas do relatório
**Passos:** Definir data inicial posterior à final.
**Esperado:** App bloqueia consulta ou apresenta validação clara; não mostra resultado enganoso.
**Rastreabilidade:** RF-REL-002.

### CT-MOB-ADM-008 — Abrir detalhe de orçamento pelo relatório
**Passos:** Na lista de orçamentos do vendedor, tocar em um registro.
**Esperado:** Detalhe correto aberto, incluindo dados e total do orçamento selecionado.
**Rastreabilidade:** RF-REL-002/RF-REL-003.

### CT-MOB-ADM-009 — Abrir censo pelo detalhe do relatório
**Pré-condição:** Orçamento com censo.
**Passos:** No detalhe, abrir censo.
**Esperado:** Tela de censo corresponde ao orçamento e não permite edição administrativa indevida se a tela for somente leitura.
**Rastreabilidade:** RF-CEN-001; rota `/reports/budget/:id/census`.

---

## 15. Configuração mobile de produtos (CAT)

### CT-MOB-CAT-001 — Acesso exclusivo do administrador pelo menu
**Pré-condição:** Comparar administrador e demais papéis.
**Passos:** Abrir menu.
**Esperado:** **Configurar produtos** disponível somente ao administrador.
**Rastreabilidade:** Matriz de papéis; `profile_modal.dart`.

### CT-MOB-CAT-002 — Listar categorias, subcategorias e produtos
**Pré-condição:** Administrador autenticado e catálogo existente.
**Passos:** Abrir Configurar produtos; entrar em categoria e subcategoria.
**Esperado:** Hierarquia correta e estados vazios adequados quando aplicáveis.
**Rastreabilidade:** Seção 13; `product_management_page.dart`.

### CT-MOB-CAT-003 — Navegar pelo breadcrumb e voltar
**Passos:** Avançar até produtos; tocar na categoria do breadcrumb; usar voltar em cada nível.
**Esperado:** Retorna um nível por vez e depois fecha o módulo, sem perder consistência.
**Rastreabilidade:** `product_management_page.dart`.

### CT-MOB-CAT-004 — Abrir detalhes/configuração de produto
**Passos:** Tocar no ícone de informações de um produto.
**Esperado:** Modal carrega produto, categoria, subcategoria e grupos de indicadores corretos.
**Rastreabilidade:** `ProductEditConfigModal`.

### CT-MOB-CAT-005 — Salvar configuração válida de produto
**Pré-condição:** Produto de teste restaurável.
**Passos:** Alterar campos suportados/indicadores; salvar; reabrir.
**Esperado:** Alterações persistidas e refletidas em novos cálculos de orçamento quando aplicável.
**Rastreabilidade:** Configuração de catálogo no App.

### CT-MOB-CAT-006 — Desativar e reativar produto
**Pré-condição:** Produto de teste.
**Passos:** Desativar; confirmar resultado; verificar ausência em novo orçamento; reativar e verificar retorno.
**Esperado:** Mensagens corretas e status refletido no catálogo de orçamento após recarga.
**Rastreabilidade:** Seção 13.4; `product_management_page.dart`.

### CT-MOB-CAT-007 — Tratar falha ao atualizar produto/status
**Pré-condição:** Falha controlada de rede/servidor.
**Passos:** Salvar configuração ou alternar status.
**Esperado:** Erro apresentado; UI não confirma sucesso nem conserva estado otimista incorreto.
**Rastreabilidade:** `product_management_page.dart`.

---

## 16. Prospecção administrativa no App (PRO)

### CT-MOB-PRO-001 — Acesso exclusivo do administrador
**Pré-condição:** Comparar papéis.
**Passos:** Abrir menu.
**Esperado:** **Prospecção de parceiros** disponível apenas ao administrador.
**Rastreabilidade:** `profile_modal.dart`.

### CT-MOB-PRO-002 — Listar prospecções pendentes
**Pré-condição:** Administrador e prospecções pendentes.
**Passos:** Abrir o módulo.
**Esperado:** Cartões exibem dados e ações previstas; estado vazio aparece quando não há registros.
**Rastreabilidade:** RF-PRO-001; seção 16.2.

### CT-MOB-PRO-003 — Paginar e atualizar prospecções
**Pré-condição:** Mais de uma página.
**Passos:** Rolar até o fim; puxar para atualizar.
**Esperado:** Próxima página sem duplicações e refresh coerente.
**Rastreabilidade:** `prospect_list_page.dart`.

### CT-MOB-PRO-004 — Marcar prospecção como contatada
**Pré-condição:** Prospecção pendente de teste.
**Passos:** Tocar em **Já entrei em contato**.
**Esperado:** Confirmação “Contato registrado”; item deixa os pendentes e aparece em contatados.
**Rastreabilidade:** Seção 16.2; `prospect_list_page.dart`.

### CT-MOB-PRO-005 — Abrir empresas já contatadas
**Passos:** Tocar no banner **Empresas já contactadas**.
**Esperado:** Tela de contatados exibida com os registros correspondentes.
**Rastreabilidade:** Rota `/prospect/contacted`.

### CT-MOB-PRO-006 — Abrir contato externo por WhatsApp/e-mail
**Pré-condição:** Prospecção com contato válido e aplicativo/handler disponível.
**Passos:** Acionar WhatsApp e e-mail separadamente; cancelar o app externo.
**Esperado:** Intent correto aberto com destinatário esperado; retorno ao App sem perda de estado. Se não houver handler, mensagem controlada.
**Rastreabilidade:** Gestão de prospecção no App.

---

## 17. Drive mobile (DRV)

### CT-MOB-DRV-001 — Abrir Drive e listar recentes/categorias
**Pré-condição:** Usuário autenticado.
**Passos:** Menu > **Drive**.
**Esperado:** Tela “Multi Drive”, busca, recentes quando houver, compartilhados comigo e categorias Documentos/Imagens/Vídeos/Pastas.
**Rastreabilidade:** RF-DRV-001; seção 17.2.

### CT-MOB-DRV-002 — Estado vazio por papel
**Pré-condição:** Usuário sem itens.
**Passos:** Abrir Drive como administrador e não administrador.
**Esperado:** Mensagem vazia adequada ao papel; sem erro ou controles indevidos.
**Rastreabilidade:** `new_drive_page.dart`.

### CT-MOB-DRV-003 — “Meus arquivos” somente para administrador
**Pré-condição:** Comparar administrador e vendedor/gestor.
**Passos:** Abrir Drive.
**Esperado:** Botão **Meus arquivos** aparece apenas para administrador; **Compartilhados comigo** aparece aos perfis autenticados.
**Rastreabilidade:** Seção 17.2; `new_drive_page.dart`.

### CT-MOB-DRV-004 — Buscar arquivo
**Pré-condição:** Itens com nomes conhecidos.
**Passos:** Digitar parte do nome; limpar busca.
**Esperado:** Recentes/lista filtrados; estado “Nenhum arquivo recente” quando não há correspondência; restauração ao limpar.
**Rastreabilidade:** `new_drive_page.dart`.

### CT-MOB-DRV-005 — Atualizar Drive por gesto de refresh
**Passos:** Alterar compartilhamento no ambiente; puxar para atualizar.
**Esperado:** Categorias, contagens, tamanhos e itens recentes são atualizados.
**Rastreabilidade:** `new_drive_page.dart`.

### CT-MOB-DRV-006 — Abrir categoria
**Pré-condição:** Categoria com itens.
**Passos:** Tocar em Documentos, Imagens, Vídeos e Pastas, separadamente.
**Esperado:** Cada tela lista somente o tipo correspondente e permite busca/abertura conforme o item.
**Rastreabilidade:** RF-DRV-001; rota `/drive/category`.

### CT-MOB-DRV-007 — Abrir pasta e navegar hierarquia
**Pré-condição:** Três níveis de pastas com nomes e conteúdos distintos.
**Passos:** Entrar por Pastas, Meus arquivos e Compartilhados; descer três níveis; tocar ancestral imediato/distante, pasta atual e raiz; voltar por cabeçalho/sistema; entrar em outra pasta. Repetir com cache e respostas atrasadas.
**Esperado:** ID da página/rota, breadcrumb, pasta ativa e conteúdo coincidem; fecha exatamente as páginas necessárias. Pasta atual não muda contexto. Raiz limpa contexto e respostas antigas não substituem o destino; sem pops duplicados nem permissões adicionais.
**Rastreabilidade:** RF-DRV-001; seção 17.1.

### CT-MOB-DRV-008 — Visualizar imagem
**Pré-condição:** Imagem acessível.
**Passos:** Abrir detalhes; tocar para abrir.
**Esperado:** Visualizador interno mostra a imagem correta e permite voltar.
**Rastreabilidade:** RF-DRV-004; rota `/drive/image-viewer`.

### CT-MOB-DRV-009 — Reproduzir vídeo
**Pré-condição:** Vídeo acessível.
**Passos:** Abrir vídeo; reproduzir, pausar e voltar.
**Esperado:** Player interno usa o arquivo correto, não continua áudio indevidamente ao sair e trata falha de mídia.
**Rastreabilidade:** RF-DRV-004; rota `/drive/video-player`.

### CT-MOB-DRV-010 — Abrir documento suportado
**Pré-condição:** Documento acessível e aplicativo compatível instalado.
**Passos:** Abrir detalhes; abrir documento.
**Esperado:** Progresso de download exibido e arquivo entregue ao aplicativo adequado.
**Rastreabilidade:** RF-DRV-004; `FileOpenerStore`.

### CT-MOB-DRV-011 — Nenhum aplicativo disponível para abrir documento
**Pré-condição:** Tipo sem handler instalado.
**Passos:** Tentar abrir.
**Esperado:** Mensagem controlada; App não encerra nem fica com diálogo de progresso preso.
**Rastreabilidade:** `NoAppToOpenFailure`.

### CT-MOB-DRV-012 — Arquivo removido ou indisponível
**Pré-condição:** Item listado que deixa de existir antes da abertura.
**Passos:** Tentar abrir/baixar.
**Esperado:** Mensagem de arquivo não encontrado; lista pode ser atualizada.
**Rastreabilidade:** `FileNotFoundFailure`.

### CT-MOB-DRV-013 — Falha de conexão durante download
**Passos:** Iniciar download; interromper conexão de forma controlada.
**Esperado:** Progresso encerrado, erro informado e nova tentativa possível.
**Rastreabilidade:** RF-DRV-004; `ConnectionFailure`.

### CT-MOB-DRV-014 — Compartilhar arquivo pelo sistema
**Pré-condição:** Arquivo baixável e folha de compartilhamento disponível.
**Passos:** Nos detalhes, acionar compartilhamento; cancelar o destino externo.
**Esperado:** Arquivo correto enviado à folha do Android e retorno seguro ao App.
**Rastreabilidade:** Comportamento mobile de compartilhamento de sistema.

### CT-MOB-DRV-015 — Garantir ausência de criação/upload mobile para não administradores
**Pré-condição:** Vendedor ou gestor autenticado.
**Passos:** Explorar tela principal, categorias, compartilhados e pastas.
**Esperado:** Nenhum controle de criação de pasta/upload/gerenciamento administrativo disponível.
**Rastreabilidade:** Seção 17.2 do documento funcional.

---

## 18. Wiki e links públicos (WIK)

### CT-MOB-WIK-001 — Abrir Wiki sem autenticação
**Passos:** Na tela de login, tocar em **Wiki**.
**Esperado:** Conteúdo de ajuda abre sem exigir sessão.
**Rastreabilidade:** RF-WIK-001; RN-WIK-001.

### CT-MOB-WIK-002 — Abrir Wiki autenticado
**Pré-condição:** Usuário autenticado.
**Passos:** Menu > **Wiki**.
**Esperado:** Mesmo conteúdo de ajuda exibido e retorno à área autenticada funciona.
**Rastreabilidade:** RF-WIK-001.

### CT-MOB-WIK-003 — Expandir e recolher artigos
**Passos:** Abrir diferentes itens; recolher e reabrir.
**Esperado:** Título/conteúdo corretos, sem depender do backend, e estado visual coerente.
**Rastreabilidade:** RN-WIK-001.

### CT-MOB-WIK-004 — Abrir política de privacidade
**Pré-condição:** Navegador/handler disponível.
**Passos:** No login, tocar em **Privacidade**; voltar ao App.
**Esperado:** Link abre externamente; retorno preserva a tela. Sem handler, App mostra erro controlado.
**Rastreabilidade:** `login_page.dart`.

---

## 19. Compatibilidade, resiliência e exploração (NFR)

### CT-MOB-NFR-001 — Layout em resolução compacta
**Passos:** Executar fluxos principais em 720×1280 com escala padrão.
**Esperado:** Sem overflow, texto inacessível ou controles fora da tela; rolagem alcança todas as ações.
**Rastreabilidade:** RNF de usabilidade/compatibilidade.

### CT-MOB-NFR-002 — Teclado não oculta ações essenciais
**Passos:** Focar o último campo de formulários de login, cadastro, orçamento, perfil e empresa.
**Esperado:** Campo e botão de ação continuam alcançáveis por rolagem; teclado pode ser fechado.
**Rastreabilidade:** RNF de usabilidade.

### CT-MOB-NFR-003 — Rotação e recriação de Activity
**Passos:** Em formulário não destrutivo, girar dispositivo ou recriar Activity.
**Esperado:** Sem crash, tela preta ou envio duplicado; estado preservado ou reiniciado de maneira explícita.
**Rastreabilidade:** Android/iOS; RNF de compatibilidade.

### CT-MOB-NFR-004 — Perda e retorno de rede
**Passos:** Interromper rede durante carregamento; restaurar; tentar novamente/atualizar.
**Esperado:** Erro controlado, sem loop infinito; recuperação sem reiniciar o dispositivo.
**Rastreabilidade:** RNF de disponibilidade.

### CT-MOB-NFR-005 — Toques repetidos em ações assíncronas
**Passos:** Tocar rapidamente em login, salvar, exportar e marcar contato.
**Esperado:** Uma operação efetiva por ação; sem duplicidade ou múltiplas rotas/diálogos.
**Rastreabilidade:** RNF de integridade/usabilidade.

### CT-MOB-NFR-006 — Formatação pt-BR
**Passos:** Verificar datas, moeda, telefone, CPF/CNPJ e textos nos módulos principais.
**Esperado:** Formatos brasileiros consistentes e sem mistura indevida de locale.
**Rastreabilidade:** RNF de usabilidade; App pt-BR.

### CT-MOB-NFR-007 — Persistência isolada entre usuários/emuladores
**Pré-condição:** Dois emuladores com usuários/papéis diferentes.
**Passos:** Autenticar ambos; alterar filtros/navegação/dados; trocar sessões.
**Esperado:** Dados, permissões e estado sensível de um usuário não aparecem para o outro.
**Rastreabilidade:** RNF de segurança; testes multiemulador.

### CT-MOB-NFR-008 — Atualização entre dispositivos
**Pré-condição:** Dois usuários autorizados observando o mesmo orçamento/usuário.
**Passos:** Alterar em um emulador; atualizar no outro.
**Esperado:** Após refresh explícito, segundo dispositivo mostra o estado atual sem manter cache incorreto.
**Rastreabilidade:** RNF de consistência; exploração multiemulador.

### CT-MOB-NFR-009 — Não expor dados sensíveis em mensagens/telas
**Passos:** Provocar erros de login, sessão, perfil, orçamento e Drive.
**Esperado:** UI não exibe token, senha, OTP, stack trace, SQL, caminho interno ou segredo de servidor.
**Rastreabilidade:** RNF de segurança.

### CT-MOB-NFR-010 — Retomada após ir ao background
**Passos:** Durante listas e formulários não destrutivos, enviar App ao background; aguardar; retornar.
**Esperado:** Sessão válida é mantida; sessão expirada é tratada; nenhuma ação é enviada duas vezes.
**Rastreabilidade:** RNF de disponibilidade/compatibilidade.

### CT-MOB-NFR-011 — Exploração de navegação rápida
**Passos:** Alternar rapidamente entre menu, módulos, voltar e abrir novamente durante carregamentos.
**Esperado:** Sem crash, tela sobreposta, diálogo órfão ou conteúdo pertencente à rota anterior.
**Rastreabilidade:** Teste exploratório mobile.

### CT-MOB-NFR-012 — Exploração com dados vazios, longos e caracteres especiais
**Passos:** Em buscas e campos permitidos, testar texto vazio, espaços, acentos, apóstrofo, hífen e texto longo.
**Esperado:** Sem crash/overflow; normalização e validação coerentes; texto é tratado como dado, não como comando.
**Rastreabilidade:** Teste exploratório mobile; RNF de segurança/usabilidade.

---

## 20. Resumo de cobertura mobile

| Domínio | Quantidade |
|---|---:|
| Autenticação e sessão (AUT) | 16 |
| Recuperação de senha (RPS) | 11 |
| Cadastro e parceria (REG) | 15 |
| Navegação e permissões (NAV) | 6 |
| Lista e ações de orçamento (ORC) | 22 |
| Criação/configuração (CRI) | 25 |
| Cálculos e edição (CAL) | 13 |
| Geração/compartilhamento (EXP) | 8 |
| Perfil e conta (PRF) | 10 |
| Empresa (EMP) | 8 |
| Gestão de usuários (USR) | 9 |
| Empresas e relatórios (ADM) | 9 |
| Produtos (CAT) | 7 |
| Prospecção administrativa (PRO) | 6 |
| Drive (DRV) | 15 |
| Wiki e links (WIK) | 4 |
| Compatibilidade e exploração (NFR) | 12 |
| **Total** | **196** |

## 21. Fora do escopo desta suíte

Não pertencem a esta suíte mobile:

- login OTP exclusivo do painel web;
- Gestor/Vendedor bloqueados no painel mesmo com token obtido pelo App;
- middleware de autorização do painel e tema claro/escuro do painel;
- decisão interna de autorização por capacidade `all` (não criar `CT-MOB-*` baseado só em `roleId` ou nome literal);
- preservação de produtos na API ao enviar `produtos: []`, `null` ou omitir o campo, sem ação observável no App;
- histórico de versões incluindo a versão atual, enquanto não existir tela mobile de histórico;
- dashboard com agrupamento diário/mensal (quando a tela não existir no App);
- carta senha / PDF de credenciais sem tela mobile;
- exportação completa do orçamento em Excel/CSV (adiada; ausência não é defeito da versão atual);
- criação/edição de papéis e capacidades sem tela correspondente no App;
- CRUD completo de categorias/subcategorias pelo painel;
- criação de parceiro e geração administrativa de PDF de credenciais/acessos quando não houver tela mobile;
- atualização assíncrona de população IBGE;
- criação de pasta, upload e gerenciamento de compartilhamentos do Drive pelo painel/backend;
- testes feitos somente com `curl`, SQL ou chamada direta de endpoint;
- validações internas do servidor que não possam ser provocadas e observadas pela interface do App.

Esses comportamentos devem possuir suítes próprias de painel web, API, integração ou backend e não devem reutilizar IDs `CT-MOB-*`.
