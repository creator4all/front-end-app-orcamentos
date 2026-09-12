# Casos de Teste — Multimídia: Parceiro

> **Fonte:** `docs/documento-funcional-consolidado.md`
> **Convenção:** `CT-<DOMÍNIO>-NNN` — Domínios: AUT (Autenticação), REG (Cadastro), PRO (Prospecção), USR (Usuários), PAR (Parceiros), ORC (Orçamentos), CEN (Censo), CAT (Catálogo), DRV (Drive), REL (Relatórios), DSH (Dashboard), PRF (Perfil), WIK (Wiki), PER (Permissões).
> **Formato:** Identificador — Título / Pré-condição / Passos / Resultado esperado / (Exceção) quando aplicável.
> **Escopo:** Apenas funcionalidades suficientemente definidas na documentação funcional consolidada. Pontos de divergência (PV-*) não são tratados como casos de teste positivos.

---

## 1. Autenticação (AUT)

### CT-AUT-001 — Login em duas etapas no painel (e-mail + senha + OTP)
**Pré-condição:** Usuário administrador cadastrado, ativo e com e-mail válido.
**Passos:**
1. Informar e-mail e senha válidos.
2. O sistema valida as credenciais.
3. O sistema gera e envia um código OTP (6 dígitos) por e-mail.
4. Informar o código OTP recebido dentro do prazo de validade (5 minutos).
5. O sistema valida o OTP e emite o token de sessão.
**Esperado:** Usuário autenticado com sessão ativa (token JWT válido).
**Rastreabilidade:** RF-AUT-001, RN-AUT-001, RN-AUT-002, CA-AUT-001.

### CT-AUT-002 — Login com credenciais inválidas
**Pré-condição:** Usuário cadastrado e ativo.
**Passos:**
1. Informar e-mail válido e senha incorreta.
2. Solicitar autenticação.
**Esperado:** Sistema rejeita com "Credenciais inválidas" e não emite OTP.
**Rastreabilidade:** RF-AUT-001 (Exceções), CA-AUT-002.

### CT-AUT-003 — Login com usuário inativo
**Pré-condição:** Usuário cadastrado com status inativo.
**Passos:**
1. Informar e-mail e senha corretos.
2. Solicitar autenticação.
**Esperado:** Sistema rejeita o login (usuário inativo).
**Rastreabilidade:** RF-AUT-001 (Exceções).

### CT-AUT-004 — Login com OTP expirado
**Pré-condição:** Usuário validou e-mail e senha e recebeu OTP.
**Passos:**
1. Aguardar mais de 5 minutos após o envio do OTP.
2. Informar o código OTP.
**Esperado:** Sistema rejeita com "Código expirado"; usuário deve solicitar reenvio.
**Rastreabilidade:** RF-AUT-001 (Exceções), RN-AUT-002.

### CT-AUT-005 — Login no App mobile (sem OTP obrigatório)
**Pré-condição:** Vendedor/gestor cadastrado e ativo.
**Passos:**
1. Informar e-mail e senha válidos no App mobile.
2. Solicitar autenticação.
**Esperado:** Sistema autentica apenas com e-mail + senha (sem OTP obrigatório) e emite token.
**Rastreabilidade:** RN-AUT-001.

### CT-AUT-006 — Logout
**Pré-condição:** Usuário autenticado com token ativo.
**Passos:**
1. O usuário solicita logout.
2. O sistema invalida o token no servidor.
3. O cliente limpa o token local.
**Esperado:** Sessão encerrada; chamadas posteriores com o token antigo recebem 401.
**Rastreabilidade:** RF-AUT-002, RN-AUT-005, CA-AUT-003.

### CT-AUT-007 — Logout com token já expirado
**Pré-condição:** Token expirado no servidor.
**Passos:**
1. O usuário solicita logout.
**Esperado:** Sistema trata como sucesso (sessão já encerrada).
**Rastreabilidade:** RF-AUT-002 (Exceções).

### CT-AUT-008 — Recuperação de senha via OTP
**Pré-condição:** Usuário cadastrado com e-mail válido.
**Passos:**
1. Solicitar recuperação informando o e-mail cadastrado.
2. O sistema envia um OTP de recuperação por e-mail.
3. Informar o OTP e a nova senha (com confirmação) que atenda à política.
4. O sistema valida o OTP e atualiza a senha.
**Esperado:** Senha atualizada; usuário consegue logar com a nova senha.
**Rastreabilidade:** RF-AUT-003, RN-AUT-006, CA-AUT-004.

### CT-AUT-009 — Recuperação de senha com nova senha fora da política
**Pré-condição:** Usuário recebeu OTP de recuperação válido.
**Passos:**
1. Informar o OTP correto.
2. Informar nova senha que não atende à política (ex.: "abc" — sem maiúscula, sem especial, curta).
**Esperado:** Sistema rejeita a nova senha.
**Rastreabilidade:** RF-AUT-003 (Exceções), RN-AUT-007.

### CT-AUT-010 — Recuperação de senha com e-mail não cadastrado
**Pré-condição:** E-mail informado não existe no sistema.
**Passos:**
1. Solicitar recuperação informando e-mail inexistente.
**Esperado:** Sistema não envia OTP / rejeita a solicitação.
**Rastreabilidade:** RF-AUT-003 (Exceções).

### CT-AUT-011 — Validação de sessão ativa
**Pré-condição:** Existe um token armazenado no cliente.
**Passos:**
1. O cliente envia o token ao serviço de validação.
2. O servidor verifica assinatura, expiração e revogação.
3. O servidor retorna se a sessão é válida.
**Esperado:** Cliente sabe se deve manter ou encerrar a sessão.
**Rastreabilidade:** RF-AUT-004, RN-AUT-004.

### CT-AUT-012 — Sessão expirada dispara logout automático
**Pré-condição:** Token expira durante o uso.
**Passos:**
1. Próxima chamada autenticada recebe 401.
2. O cliente limpa a sessão e redireciona ao login.
**Esperado:** Cliente deslogado automaticamente.
**Rastreabilidade:** RN-AUT-008.

---

## 2. Cadastro / Registro (REG)

### CT-REG-001 — Verificar empresa parceira ativa por CNPJ
**Pré-condição:** Visitante informa um CNPJ normalizado (apenas dígitos) de empresa ativa.
**Passos:**
1. O visitante informa o documento (CNPJ ou CPF).
2. O sistema normaliza e consulta empresas ativas pelo documento.
3. Empresa encontrada e ativa retorna os dados públicos (nome fantasia, CNPJ).
**Esperado:** Visitante pode prosseguir para o auto-cadastro.
**Rastreabilidade:** RF-REG-001, RN-REG-001, CA-REG-001.

### CT-REG-002 — Verificar empresa parceira inativa
**Pré-condição:** CNPJ informado corresponde a empresa inativa.
**Passos:**
1. O visitante informa o documento.
2. O sistema localiza a empresa, mas o status é inativo.
**Esperado:** Sistema retorna a empresa, mas bloqueia o prosseguimento ao cadastro.
**Rastreabilidade:** RF-REG-001 (Exceções), RN-REG-002, CA-REG-002.

### CT-REG-003 — Verificar empresa não encontrada
**Pré-condição:** Documento informado não corresponde a nenhuma empresa.
**Passos:**
1. O visitante informa o documento.
2. O sistema não localiza empresa ativa.
**Esperado:** Sistema informa "Documento não encontrado"; visitante pode registrar prospecção.
**Rastreabilidade:** RF-REG-001 (Exceções).

### CT-REG-004 — Auto-cadastro de vendedor vinculado a empresa ativa
**Pré-condição:** Empresa foi encontrada e está ativa (CT-REG-001).
**Passos:**
1. O visitante informa nome, e-mail, telefone e senha válidos.
2. O sistema valida os dados (e-mail único, senha na política).
3. O sistema cria o usuário com papel de vendedor, vinculado à empresa, com status pendente.
4. O gestor da empresa aprova posteriormente (ativa o usuário).
**Esperado:** Usuário criado como vendedor pendente; após aprovação do gestor, pode autenticar.
**Rastreabilidade:** RF-REG-002, RN-REG-002, RN-USR-001, RN-USR-006, CA-REG-003.

### CT-REG-005 — Auto-cadastro com e-mail já cadastrado
**Pré-condição:** E-mail informado já existe no sistema.
**Passos:**
1. O visitante informa e-mail duplicado.
2. O sistema valida os dados.
**Esperado:** Sistema rejeita o cadastro (e-mail único).
**Rastreabilidade:** RF-REG-002 (Exceções), RN-USR-002.

### CT-REG-006 — Usuário pendente não autentica antes da aprovação
**Pré-condição:** Vendedor recém-cadastrado (status pendente).
**Passos:**
1. O vendedor tenta autenticar antes da aprovação do gestor.
**Esperado:** Sistema rejeita o login (usuário inativo/pendente).
**Rastreabilidade:** RN-USR-001.

---

## 3. Prospecção (PRO)

### CT-PRO-001 — Solicitar parceria (prospecção) com campos obrigatórios
**Pré-condição:** Visitante sem cadastro.
**Passos:**
1. O visitante informa nome, e-mail e telefone (obrigatórios); empresa, CNPJ e experiência em vendas públicas (opcionais).
2. O sistema cria o registro de prospecção.
3. O administrador entra em contato posteriormente.
**Esperado:** Registro de prospecção criado e disponível para o administrador gerenciar.
**Rastreabilidade:** RF-PRO-001, RN-PRO-001.

### CT-PRO-002 — Solicitar parceria sem campos obrigatórios
**Pré-condição:** Visitante sem cadastro.
**Passos:**
1. O visitante omite nome, e-mail ou telefone.
2. O sistema valida os campos.
**Esperado:** Sistema rejeita a prospecção (campos obrigatórios ausentes).
**Rastreabilidade:** RF-PRO-001 (Exceções), RN-PRO-001.

---

## 4. Usuários (USR)

### CT-USR-001 — Administrador lista todos os usuários com filtros
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin acessa a listagem de usuários.
2. O sistema retorna usuários paginados (todos).
3. O admin filtra por parceiro, papel e busca textual.
**Esperado:** Admin visualiza a lista de todos os usuários conforme filtros.
**Rastreabilidade:** RF-USR-001, RN-USR-003.

### CT-USR-002 — Gestor lista apenas vendedores da própria empresa
**Pré-condição:** Gestor autenticado.
**Passos:**
1. O gestor acessa a listagem de usuários.
2. O sistema retorna apenas usuários da própria empresa, excluindo o próprio gestor.
**Esperado:** Gestor visualiza apenas vendedores da própria empresa (sem se ver na lista).
**Rastreabilidade:** RF-USR-001, RN-USR-003, RN-USR-004.

### CT-USR-003 — Administrador cria usuário com credenciais por e-mail
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin informa nome, e-mail, telefone, empresa, papel e status.
2. O sistema valida os dados (e-mail único, empresa existente, papel válido).
3. O sistema cria o usuário.
4. O sistema gera senha temporária e envia por e-mail (e/ou gera PDF de credenciais).
**Esperado:** Usuário criado; credenciais enviadas por e-mail e/ou PDF disponibilizado.
**Rastreabilidade:** RF-USR-002, RN-USR-005, CA-USR-001.

### CT-USR-004 — Criar usuário com e-mail duplicado
**Pré-condição:** Administrador autenticado; e-mail já existe.
**Passos:**
1. O admin informa e-mail já cadastrado.
2. O sistema valida os dados.
**Esperado:** Sistema rejeita a criação (e-mail único).
**Rastreabilidade:** RF-USR-002 (Exceções), RN-USR-002.

### CT-USR-005 — Administrador edita usuário
**Pré-condição:** Administrador autenticado; usuário existe.
**Passos:**
1. O admin altera nome, e-mail, telefone, empresa, papel ou status.
2. O sistema valida e atualiza.
**Esperado:** Usuário atualizado.
**Rastreabilidade:** RF-USR-003.

### CT-USR-006 — Gestor atualiza vendedores em lote
**Pré-condição:** Gestor autenticado; usuários pertencem à própria empresa.
**Passos:**
1. O gestor marca alterações de status e/ou papel para um ou mais vendedores.
2. O sistema envia o lote.
3. O sistema aplica cada alteração individualmente e retorna sucessos e falhas.
**Esperado:** Cada alteração bem-sucedida persistida; falhas reportadas separadamente.
**Rastreabilidade:** RF-USR-004, RN-USR-008, CA-USR-002.

### CT-USR-007 — Lote bloqueia auto-edição do gestor
**Pré-condição:** Gestor autenticado.
**Passos:**
1. O gestor marca alteração para o próprio usuário.
2. O sistema envia o lote.
**Esperado:** Sistema rejeita a alteração do próprio usuário.
**Rastreabilidade:** RF-USR-004 (Exceções), RN-USR-007, CA-USR-003.

### CT-USR-008 — Lote restringe papel a vendedor/gestor
**Pré-condição:** Gestor autenticado.
**Passos:**
1. O gestor tenta promover um vendedor a administrador em lote.
2. O sistema envia o lote.
**Esperado:** Sistema rejeita a alteração de papel (não permite promover a administrador).
**Rastreabilidade:** RN-USR-009.

### CT-USR-009 — Lote rejeita usuário de outra empresa
**Pré-condição:** Gestor da empresa A tenta alterar usuário da empresa B.
**Passos:**
1. O gestor marca alteração para usuário de outra empresa.
2. O sistema envia o lote.
**Esperado:** Sistema rejeita a alteração (usuário deve pertencer à empresa do gestor).
**Rastreabilidade:** RN-USR-010.

### CT-USR-010 — Administrador gerencia papéis e capacidades
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin acessa a gestão de papéis.
2. Cria/edita/exclui papéis e marca/desmarca capacidades.
3. O sistema sincroniza as capacidades do papel.
**Esperado:** Papéis e capacidades atualizados.
**Rastreabilidade:** RF-USR-005, RN-USR-011.

### CT-USR-011 — Excluir a própria conta (exclusão lógica)
**Pré-condição:** Usuário autenticado (qualquer perfil).
**Passos:**
1. O usuário solicita a exclusão da conta.
2. O sistema marca o usuário como excluído (exclusão lógica).
**Esperado:** Usuário não consegue mais autenticar-se.
**Rastreabilidade:** RF-USR-006, RN-USR-012.

---

## 5. Parceiros (PAR)

### CT-PAR-001 — Administrador lista parceiros com filtros e ordenação
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin acessa a listagem de parceiros.
2. O sistema retorna parceiros paginados (todos).
3. O admin filtra por busca textual e ordena por campos definidos.
**Esperado:** Admin visualiza a lista de todos os parceiros.
**Rastreabilidade:** RF-PAR-001.

### CT-PAR-002 — Gestor visualiza apenas a própria empresa
**Pré-condição:** Gestor autenticado.
**Passos:**
1. O gestor acessa a listagem de parceiros.
2. O sistema retorna apenas a própria empresa.
**Esperado:** Gestor visualiza apenas a própria empresa.
**Rastreabilidade:** RF-PAR-001, RN-PAR-002.

### CT-PAR-003 — Administrador cria parceiro com gestor responsável
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin informa dados da empresa (nome, nome fantasia, CNPJ, e-mail, telefone, status, URL opcional).
2. O admin informa o gestor responsável (nome, e-mail, telefone, papel).
3. Opcionalmente, adiciona vendedores adicionais.
4. O sistema cria a empresa e os usuários em transação.
5. Opcionalmente, envia credenciais por e-mail e/ou gera PDF de acessos.
6. Após criação, faz upload de logo e contrato (se fornecidos).
**Esperado:** Empresa e usuários criados em transação atômica; logo/contrato opcionais.
**Rastreabilidade:** RF-PAR-002, RN-PAR-003, RN-PAR-004, CA-PAR-001.

### CT-PAR-004 — Criar parceiro com CNPJ duplicado
**Pré-condição:** Administrador autenticado; CNPJ já existe.
**Passos:**
1. O admin informa CNPJ já cadastrado.
2. O sistema valida os dados.
**Esperado:** Sistema rejeita a criação (CNPJ único).
**Rastreabilidade:** RF-PAR-002 (Exceções), RN-PAR-006.

### CT-PAR-005 — Falha em upload de logo/contrato não desfaz a criação
**Pré-condição:** Administrador criando parceiro.
**Passos:**
1. O admin cria a empresa e o gestor com sucesso.
2. O upload de logo ou contrato falha.
**Esperado:** A empresa e os usuários permanecem criados (falhas em uploads não desfazem a criação).
**Rastreabilidade:** RF-PAR-002 (Exceções), RN-PAR-004.

### CT-PAR-006 — Administrador edita parceiro
**Pré-condição:** Administrador autenticado; parceiro existe.
**Passos:**
1. O admin altera os dados (nome, nome fantasia, CNPJ, e-mail, telefone, URL, status).
2. O sistema valida e atualiza.
**Esperado:** Parceiro atualizado.
**Rastreabilidade:** RF-PAR-003.

### CT-PAR-007 — Gestor edita apenas a própria empresa
**Pré-condição:** Gestor autenticado.
**Passos:**
1. O gestor altera os dados da própria empresa.
2. O sistema valida e atualiza.
**Esperado:** Empresa atualizada.
**Rastreabilidade:** RF-PAR-003, RN-PAR-002.

### CT-PAR-008 — Gestor não altera status da própria empresa
**Pré-condição:** Gestor autenticado.
**Passos:**
1. O gestor tenta alterar o status da própria empresa.
2. O sistema valida a operação.
**Esperado:** Sistema rejeita a alteração de status (apenas admin altera status).
**Rastreabilidade:** RF-PAR-003 (Exceções), RN-PAR-005.

### CT-PAR-009 — Administrador desativa parceiro em cascata
**Pré-condição:** Administrador autenticado; parceiro ativo com usuários.
**Passos:**
1. O admin alterna o status do parceiro para inativo.
2. O sistema inverte o status e propaga para os usuários.
**Esperado:** Parceiro e todos os seus usuários ficam inativos.
**Rastreabilidade:** RF-PAR-004, RN-PAR-007, CA-PAR-002.

### CT-PAR-010 — Administrador reativa parceiro
**Pré-condição:** Administrador autenticado; parceiro inativo.
**Passos:**
1. O admin alterna o status do parceiro para ativo.
2. O sistema propaga para os usuários.
**Esperado:** Parceiro e usuários reativados.
**Rastreabilidade:** RF-PAR-004, RN-PAR-007.

### CT-PAR-011 — Upload de logo do parceiro (gestor)
**Pré-condição:** Gestor autenticado; imagem válida (MIME e tamanho).
**Passos:**
1. O gestor seleciona uma imagem.
2. O sistema valida MIME e tamanho.
3. O sistema armazena a logo.
**Esperado:** Logo do parceiro atualizada.
**Rastreabilidade:** RF-PAR-005, RN-PAR-008.

### CT-PAR-012 — Upload de logo com MIME inválido
**Pré-condição:** Gestor ou admin; arquivo .txt selecionado.
**Passos:**
1. O ator seleciona arquivo não-imagem.
2. O sistema valida MIME.
**Esperado:** Sistema rejeita o upload (MIME inválido).
**Rastreabilidade:** RF-PAR-005 (Exceções), RN-PAR-008.

### CT-PAR-013 — Gestor visualiza/baixa contrato da própria empresa
**Pré-condição:** Gestor autenticado; contrato existe.
**Passos:**
1. O gestor solicita a visualização/download do contrato.
2. O sistema retorna o arquivo PDF.
**Esperado:** Gestor obtém o contrato em PDF.
**Rastreabilidade:** RF-PAR-006, RN-PAR-009.

### CT-PAR-014 — Contrato inexistente
**Pré-condição:** Parceiro sem contrato cadastrado.
**Passos:**
1. O ator solicita a visualização do contrato.
**Esperado:** Sistema informa que o contrato não existe.
**Rastreabilidade:** RF-PAR-006 (Exceções).

---

## 6. Orçamentos (ORC)

### CT-ORC-001 — Criar orçamento de cidade única
**Pré-condição:** Usuário autenticado (vendedor/gestor/admin); cidade existe e possui censo.
**Passos:**
1. O usuário seleciona a cidade (ou o admin seleciona parceiro destino + cidade).
2. O sistema cria um rascunho de orçamento.
3. O sistema copia os valores do Censo Escolar do município (snapshot independente).
4. O usuário seleciona produtos e indicadores.
5. O sistema calcula as quantidades e o total.
6. O usuário define a validade (1–365 dias) e salva (status passa a pendente).
**Esperado:** Orçamento criado com status pendente, com snapshot do censo e produtos selecionados.
**Rastreabilidade:** RF-ORC-001, RN-ORC-001, RN-ORC-002, CA-ORC-001.

### CT-ORC-002 — Snapshot do censo independe do censo oficial
**Pré-condição:** Orçamento criado em janeiro com snapshot do censo.
**Passos:**
1. O censo oficial da cidade é atualizado em fevereiro.
2. O usuário abre o orçamento criado em janeiro.
**Esperado:** O orçamento mantém os valores de janeiro (snapshot independente).
**Rastreabilidade:** RN-ORC-001, CA-CEN-001.

### CT-ORC-003 — Criar orçamento multi-cidade com censo agregado
**Pré-condição:** Usuário autenticado; múltiplas cidades selecionadas, cada uma com censo.
**Passos:**
1. O usuário seleciona múltiplas cidades.
2. O sistema busca o censo de cada cidade.
3. O sistema cria o orçamento multi-cidade com censo agregado (soma por etapa).
4. O usuário seleciona produtos e indicadores.
5. O sistema calcula quantidades com base no censo agregado.
6. O usuário define validade e salva.
**Esperado:** Orçamento multi-cidade criado com censo agregado (soma por etapa).
**Rastreabilidade:** RF-ORC-002, RN-ORC-003, RN-CEN-003, CA-ORC-002.

### CT-ORC-004 — Criar orçamento personalizado (sem município)
**Pré-condição:** Usuário autenticado.
**Passos:**
1. O usuário opta por orçamento personalizado.
2. O usuário informa manualmente os valores dos indicadores.
3. O sistema cria o orçamento sem cidade vinculada.
4. O usuário seleciona produtos e indicadores.
5. O sistema calcula as quantidades com base nos valores manuais.
6. O usuário define validade e salva.
**Esperado:** Orçamento personalizado criado sem cidade vinculada, com valores manuais de censo.
**Rastreabilidade:** RF-ORC-003, RN-ORC-004, CA-ORC-003.

### CT-ORC-005 — Validade fora do intervalo permitido
**Pré-condição:** Usuário criando/editando orçamento.
**Passos:**
1. O usuário informa validade de 0 ou superior a 365 dias.
2. O sistema valida o campo.
**Esperado:** Sistema rejeita a validade (deve ser 1–365 dias).
**Rastreabilidade:** RF-ORC-001 (Exceções), seção 20.4.

### CT-ORC-006 — Editar orçamento (recálculo pelo servidor)
**Pré-condição:** Orçamento existe; usuário tem permissão (dono, admin ou gestor da mesma empresa).
**Passos:**
1. O usuário abre o orçamento para edição.
2. Altera produtos, indicadores, quantidades manuais, validade ou status.
3. O sistema recalcula quantidades e total (sempre pelo servidor).
4. O sistema persiste as alterações.
**Esperado:** Orçamento atualizado com total recalculado pelo servidor.
**Rastreabilidade:** RF-ORC-004, RN-ORC-005, RN-ORC-006, CA-ORC-004.

### CT-ORC-007 — Vendedor não edita orçamento de outro vendedor
**Pré-condição:** Vendedor autenticado; orçamento pertence a outro vendedor de empresa diferente.
**Passos:**
1. O vendedor tenta editar o orçamento alheio.
2. O sistema valida a permissão.
**Esperado:** Sistema rejeita a edição (sem permissão).
**Rastreabilidade:** RF-ORC-004 (Exceções), RN-ORC-005.

### CT-ORC-008 — Versionar orçamento (arquiva original e cria nova versão)
**Pré-condição:** Orçamento existe; usuário tem permissão.
**Passos:**
1. O usuário solicita o versionamento.
2. O sistema arquiva o original.
3. O sistema cria uma nova versão vinculada ao original (origem).
4. O sistema copia produtos, quantidades, valores e preserva overrides de preço.
5. O sistema recalcula o total da nova versão.
**Esperado:** Original arquivado; nova versão ativa com dados e overrides preservados.
**Rastreabilidade:** RF-ORC-005, RN-ORC-007, RN-ORC-008, CA-ORC-005.

### CT-ORC-009 — Versionar orçamento expirado (nova versão fica pendente)
**Pré-condição:** Orçamento com status expirado.
**Passos:**
1. O usuário solicita o versionamento.
2. O sistema arquiva o original expirado.
3. O sistema cria nova versão com nova validade.
**Esperado:** Nova versão criada com status pendente.
**Rastreabilidade:** Seção 8 (tabela de transições).

### CT-ORC-010 — Arquivar orçamento (sem alterar status)
**Pré-condição:** Orçamento existe; usuário tem permissão.
**Passos:**
1. O usuário solicita arquivar.
2. O sistema inverte o flag de arquivamento.
**Esperado:** Orçamento arquivado (status comercial inalterado).
**Rastreabilidade:** RF-ORC-006, RN-ORC-009, CA-ORC-006.

### CT-ORC-011 — Desarquivar orçamento
**Pré-condição:** Orçamento arquivado; usuário tem permissão.
**Passos:**
1. O usuário solicita desarquivar.
2. O sistema inverte o flag de arquivamento.
**Esperado:** Orçamento desarquivado (status comercial inalterado).
**Rastreabilidade:** RF-ORC-006, RN-ORC-009.

### CT-ORC-012 — Renomear orçamento com nome válido
**Pré-condição:** Orçamento existe; usuário tem permissão; novo nome entre 1 e 255 caracteres.
**Passos:**
1. O usuário informa o novo nome.
2. O sistema valida e atualiza.
**Esperado:** Nome do orçamento atualizado.
**Rastreabilidade:** RF-ORC-007, RN-ORC-010.

### CT-ORC-013 — Renomear orçamento com nome vazio
**Pré-condição:** Orçamento existe; usuário tem permissão.
**Passos:**
1. O usuário informa nome vazio.
2. O sistema valida o formato.
**Esperado:** Sistema rejeita (mínimo 1 caractere).
**Rastreabilidade:** RF-ORC-007 (Exceções), RN-ORC-010.

### CT-ORC-014 — Renomear orçamento com nome maior que 255 caracteres
**Pré-condição:** Orçamento existe; usuário tem permissão.
**Passos:**
1. O usuário informa nome com mais de 255 caracteres.
2. O sistema valida o formato.
**Esperado:** Sistema rejeita (máximo 255 caracteres).
**Rastreabilidade:** RF-ORC-007 (Exceções), RN-ORC-010.

### CT-ORC-015 — Definir quantidade manual sobrescrevendo cálculo
**Pré-condição:** Produto está no orçamento com quantidade calculada.
**Passos:**
1. O usuário ativa o modo manual do produto.
2. O usuário informa a quantidade desejada.
3. O sistema ignora o cálculo automático e usa a quantidade manual.
**Esperado:** Quantidade do produto passa a ser a manual.
**Rastreabilidade:** RF-ORC-008, RN-ORC-011, CA-ORC-007.

### CT-ORC-016 — Desativar modo manual recalcula automaticamente
**Pré-condição:** Produto com modo manual ativo.
**Passos:**
1. O usuário desativa o modo manual do produto.
2. O sistema recalcula automaticamente com base no censo.
**Esperado:** Quantidade do produto volta a ser a calculada automaticamente.
**Rastreabilidade:** RF-ORC-008, RN-ORC-011.

### CT-ORC-017 — Gerar PDF do orçamento com dados completos do vendedor
**Pré-condição:** Orçamento existe; vendedor com nome, cargo, telefone e e-mail preenchidos.
**Passos:**
1. O usuário solicita a geração do PDF.
2. O sistema valida os dados do vendedor.
3. O sistema gera o PDF com logo do parceiro, dados do vendedor, produtos, quantidades, valores e totais.
**Esperado:** PDF gerado e disponibilizado com identidade visual do parceiro.
**Rastreabilidade:** RF-ORC-009, RN-ORC-012, CA-ORC-008.

### CT-ORC-018 — Gerar PDF com dados do vendedor incompletos
**Pré-condição:** Orçamento existe; vendedor sem telefone (ou outro dado obrigatório).
**Passos:**
1. O usuário solicita a geração do PDF.
2. O sistema valida os dados do vendedor.
**Esperado:** Sistema rejeita a geração (dados do vendedor incompletos).
**Rastreabilidade:** RF-ORC-009 (Exceções), RN-ORC-012.

### CT-ORC-019 — Exportar censo do orçamento em CSV
**Pré-condição:** Orçamento existe com censo (snapshot).
**Passos:**
1. O usuário solicita a exportação do censo.
2. O sistema gera um CSV com os indicadores e valores do snapshot.
**Esperado:** CSV gerado com colunas de indicadores e valores.
**Rastreabilidade:** RF-ORC-010, RN-ORC-014, CA-ORC-009.

### CT-ORC-020 — Listar orçamentos por perfil (vendedor)
**Pré-condição:** Vendedor autenticado.
**Passos:**
1. O vendedor acessa a listagem.
2. O sistema retorna apenas os orçamentos próprios, paginados.
3. O vendedor pode filtrar por status, arquivamento, data e busca.
**Esperado:** Vendedor visualiza apenas seus próprios orçamentos.
**Rastreabilidade:** RF-ORC-011, RN-ORC-015, CA-PER-001.

### CT-ORC-021 — Listar orçamentos por perfil (gestor)
**Pré-condição:** Gestor autenticado.
**Passos:**
1. O gestor acessa a listagem.
2. O sistema retorna orçamentos de todos os vendedores da própria empresa, paginados.
3. O gestor pode filtrar por status, arquivamento, data e busca.
**Esperado:** Gestor visualiza orçamentos de todos os vendedores da empresa.
**Rastreabilidade:** RF-ORC-011, RN-ORC-015, CA-PER-002.

### CT-ORC-022 — Listar orçamentos por perfil (administrador)
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin acessa a listagem.
2. O sistema retorna todos os orçamentos (com parceiro e vendedor), paginados.
3. O admin pode filtrar por status, arquivamento, data e busca.
**Esperado:** Admin visualiza todos os orçamentos.
**Rastreabilidade:** RF-ORC-011, RN-ORC-015.

### CT-ORC-023 — Aprovar orçamento pendente
**Pré-condição:** Orçamento com status pendente; usuário com permissão; orçamento não expirado.
**Passos:**
1. O usuário aprova manualmente o orçamento.
2. O sistema altera o status para aprovado.
**Esperado:** Status do orçamento passa a aprovado.
**Rastreabilidade:** Seção 8 (tabela de transições).

### CT-ORC-024 — Reprovar orçamento pendente
**Pré-condição:** Orçamento com status pendente; usuário com permissão.
**Passos:**
1. O usuário reprova manualmente o orçamento.
2. O sistema altera o status para não aprovado.
**Esperado:** Status do orçamento passa a não aprovado.
**Rastreabilidade:** Seção 8 (tabela de transições).

### CT-ORC-025 — Expiração automática de orçamento pendente
**Pré-condição:** Orçamento pendente com data de validade passada.
**Passos:**
1. O sistema verifica a validade.
2. O status muda automaticamente para expirado.
**Esperado:** Status do orçamento passa a expirado.
**Rastreabilidade:** Seção 8 (tabela de transições).

### CT-ORC-026 — Editar orçamento expirado redefine status para pendente
**Pré-condição:** Orçamento com status expirado; usuário com permissão.
**Passos:**
1. O usuário edita o orçamento e define nova validade.
2. O sistema salva e redefine o status para pendente.
**Esperado:** Status do orçamento passa de expirado para pendente.
**Rastreabilidade:** Seção 8 (tabela de transições).

### CT-ORC-027 — Administrador cria orçamento em nome de outro parceiro
**Pré-condição:** Administrador autenticado; parceiro destino ativo.
**Passos:**
1. O admin seleciona o parceiro destino (ativo) e a cidade.
2. O sistema cria o orçamento com identidade visual do parceiro destino.
3. O admin configura produtos, indicadores e validade.
4. O admin salva.
**Esperado:** Orçamento criado vinculado ao parceiro destino, com identidade visual dele.
**Rastreabilidade:** RN-PAR-001, seção 3 (Administrador).

### CT-ORC-028 — Parceiro inativo não é selecionável para novo orçamento
**Pré-condição:** Administrador criando orçamento; parceiro destino inativo.
**Passos:**
1. O admin tenta selecionar parceiro inativo como destino.
**Esperado:** Parceiro inativo não aparece na lista de parceiros destino.
**Rastreabilidade:** RN-PAR-001.

---

## 7. Cálculos (CAL)

### CT-CAL-001 — Livro para estudantes (sem professores)
**Pré-condição:** Livro com indicadores `in5ano` (120) e `ef1ano` (80) selecionados, sem "professores".
**Passos:**
1. O sistema calcula a quantidade somando os valores do censo dos indicadores selecionados (exceto "professores").
**Esperado:** Quantidade = 120 + 80 = 200.
**Rastreabilidade:** Seção 12.2, CA-CAL-001.

### CT-CAL-002 — Livro para professores
**Pré-condição:** Livro com indicadores `in5ano` e "professores" selecionados; `in5anoP` = 10.
**Passos:**
1. O sistema calcula a quantidade somando os indicadores de professor correspondentes.
**Esperado:** Quantidade = 10.
**Rastreabilidade:** Seção 12.3, CA-CAL-002.

### CT-CAL-003 — Tecnologia sem professores
**Pré-condição:** Tecnologia com indicadores `in5ano` (120) e `ef1ano` (80) selecionados, sem "professores".
**Passos:**
1. O sistema calcula a quantidade somando os indicadores de aluno.
**Esperado:** Quantidade = 120 + 80 = 200.
**Rastreabilidade:** Seção 12.4.

### CT-CAL-004 — Tecnologia com professores
**Pré-condição:** Tecnologia com indicadores `in5ano` e "professores"; `in5ano` = 120, `in5anoP` = 10.
**Passos:**
1. O sistema calcula somando indicadores de aluno e professor correspondentes.
**Esperado:** Quantidade = 120 + 10 = 130.
**Rastreabilidade:** Seção 12.4, CA-CAL-003.

### CT-CAL-005 — Serviço (percentual + horas fixas)
**Pré-condição:** Serviço vinculado a "Livro 5º ano" (quantidade 200) e "Tecnologia 5º ano" (quantidade 130); percentual 8%; horas fixas 5.
**Passos:**
1. O sistema soma as quantidades dos produtos relacionados (totalCenso = 330).
2. O sistema aplica o percentual (330 × 0,08 = 26,4).
3. O sistema soma as horas fixas (26,4 + 5 = 31,4).
**Esperado:** Quantidade = 31,4 (sem arredondamento).
**Rastreabilidade:** Seção 12.5, CA-CAL-004.

### CT-CAL-006 — Cálculo sem arredondamento
**Pré-condição:** Qualquer cálculo de quantidade com resultado fracionado.
**Passos:**
1. O sistema calcula a quantidade.
**Esperado:** Resultado não arredondado (regra atual: sem arredondamento).
**Rastreabilidade:** Seção 12.9, CA-CAL-005.

### CT-CAL-007 — Total do orçamento recalculado pelo servidor
**Pré-condição:** Orçamento com produtos selecionados e quantidades calculadas.
**Passos:**
1. O cliente envia o total.
2. O servidor recalcula o total como Σ (valor_unitário × quantidade) considerando overrides.
**Esperado:** Total armazenado é o recalculado pelo servidor (não o enviado pelo cliente).
**Rastreabilidade:** Seção 12.8, RN-ORC-006.

### CT-CAL-008 — Cálculo em orçamento multi-cidade usa censo agregado
**Pré-condição:** Orçamento multi-cidade; cidade A com `in5ano` = 100; cidade B com `in5ano` = 50.
**Passos:**
1. O sistema soma os valores por etapa entre as cidades (censo agregado = 150).
2. O sistema calcula as quantidades com base no censo agregado.
**Esperado:** Livro com indicador `in5ano` terá quantidade 150.
**Rastreabilidade:** Seção 12.7, RN-ORC-003.

---

## 8. Censo Escolar (CEN)

### CT-CEN-001 — Visualizar censo de uma cidade
**Pré-condição:** Cidade existe e possui censo; usuário autenticado.
**Passos:**
1. O usuário seleciona a cidade.
2. O sistema retorna os indicadores de etapa e seus valores.
**Esperado:** Usuário visualiza o censo da cidade.
**Rastreabilidade:** RF-CEN-001, RN-CEN-001.

### CT-CEN-002 — Visualizar censo de cidade sem censo
**Pré-condição:** Cidade existe, mas sem censo cadastrado.
**Passos:**
1. O usuário seleciona a cidade.
2. O sistema tenta retornar o censo.
**Esperado:** Sistema informa que a cidade não possui censo.
**Rastreabilidade:** RF-CEN-001 (Exceções), RN-CEN-001.

### CT-CEN-003 — Editar valores do censo no snapshot do orçamento
**Pré-condição:** Orçamento existe com snapshot de censo.
**Passos:**
1. O usuário abre o censo do orçamento.
2. Altera valores de indicadores.
3. O sistema atualiza apenas o snapshot do orçamento.
4. O sistema recalcula as quantidades afetadas.
**Esperado:** Snapshot do orçamento atualizado; censo oficial da cidade permanece inalterado.
**Rastreabilidade:** RF-CEN-002, RN-CEN-002, RN-ORC-001.

### CT-CEN-004 — Administrador gerencia grupos de censo e índices de etapa
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin acessa a gestão de censo.
2. Cria/edita/exclui grupos e índices.
3. Define ordenação, valor padrão e percentual de população.
**Esperado:** Grupos e índices atualizados.
**Rastreabilidade:** RF-CEN-003, RN-CEN-004, RN-CEN-005.

### CT-CEN-005 — Criar grupo de censo com nome duplicado
**Pré-condição:** Administrador autenticado; nome já existe.
**Passos:**
1. O admin cria grupo com nome já existente.
2. O sistema valida.
**Esperado:** Sistema rejeita (nome duplicado).
**Rastreabilidade:** RF-CEN-003 (Exceções).

### CT-CEN-006 — Atualizar população IBGE (assíncrona)
**Pré-condição:** Administrador autenticado; índice de etapa e percentual selecionados.
**Passos:**
1. O admin seleciona um índice de etapa e um percentual.
2. O sistema dispara a atualização assíncrona (stream NDJSON).
3. O sistema reporta progresso por cidade.
4. Ao concluir, a população das cidades é atualizada.
**Esperado:** População IBGE das cidades atualizada conforme percentual aplicado.
**Rastreabilidade:** RF-CEN-004, RN-CEN-006.

### CT-CEN-007 — Atualização de população com falhas parciais
**Pré-condição:** Atualização disparada para 50 cidades.
**Passos:**
1. O sistema processa as cidades.
2. 2 cidades falham (timeout IBGE); 48 concluem com sucesso.
3. O sistema reporta as 2 falhas sem abortar o todo.
**Esperado:** 48 cidades atualizadas; 2 falhas reportadas; HTTP 200 não garante sucesso total.
**Rastreabilidade:** RF-CEN-004 (Exceções), RN-CEN-007, CA-CEN-002.

---

## 9. Catálogo de Produtos (CAT)

### CT-CAT-001 — Administrador cria categoria
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin cria a categoria (nome, status, ordenação).
2. O sistema valida e persiste.
**Esperado:** Categoria criada.
**Rastreabilidade:** RF-CAT-001, RN-CAT-001.

### CT-CAT-002 — Criar categoria com nome duplicado
**Pré-condição:** Administrador autenticado; nome já existe.
**Passos:**
1. O admin cria categoria com nome já existente.
2. O sistema valida.
**Esperado:** Sistema rejeita (nome duplicado).
**Rastreabilidade:** RF-CAT-001 (Exceções), RN-CAT-001.

### CT-CAT-003 — Desativar categoria em cascata
**Pré-condição:** Administrador autenticado; categoria ativa com subcategorias e produtos.
**Passos:**
1. O admin desativa a categoria.
2. O sistema desativa em cascata as subcategorias e produtos.
**Esperado:** Categoria, subcategorias e produtos desativados.
**Rastreabilidade:** RN-CAT-002.

### CT-CAT-004 — Restaurar categoria reativa em cascata
**Pré-condição:** Categoria desativada em cascata.
**Passos:**
1. O admin reativa a categoria.
2. O sistema reativa os itens que foram desativados em cascata.
**Esperado:** Categoria, subcategorias e produtos reativados.
**Rastreabilidade:** RN-CAT-002.

### CT-CAT-005 — Administrador cria subcategoria
**Pré-condição:** Administrador autenticado; categoria existe.
**Passos:**
1. O admin cria a subcategoria (nome, categoria, status, ordenação).
2. O sistema valida e persiste.
**Esperado:** Subcategoria criada vinculada à categoria.
**Rastreabilidade:** RF-CAT-002, RN-CAT-003.

### CT-CAT-006 — Criar subcategoria com categoria inexistente
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin cria subcategoria vinculada a categoria inexistente.
2. O sistema valida.
**Esperado:** Sistema rejeita (categoria inexistente).
**Rastreabilidade:** RF-CAT-002 (Exceções).

### CT-CAT-007 — Administrador cria produto do tipo livro com ISBN
**Pré-condição:** Administrador autenticado; subcategoria existe.
**Passos:**
1. O admin cria o produto (nome, tipo livro, subcategoria, valor, ISBN, indicadores, diferenciais).
2. O sistema valida (ISBN obrigatório para livros).
3. O sistema persiste.
**Esperado:** Produto livro criado.
**Rastreabilidade:** RF-CAT-003, RN-CAT-004, RN-CAT-006.

### CT-CAT-008 — Criar livro sem ISBN
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin cria produto do tipo livro sem ISBN.
2. O sistema valida.
**Esperado:** Sistema rejeita (ISBN obrigatório para livros).
**Rastreabilidade:** RF-CAT-003 (Exceções), RN-CAT-006.

### CT-CAT-009 — Administrador cria serviço com produtos relacionados
**Pré-condição:** Administrador autenticado; subcategoria existe.
**Passos:**
1. O admin cria o serviço (nome, tipo serviço, subcategoria, valor, percentual, horas fixas, produtos relacionados).
2. O sistema valida (produtos relacionados existem e não são outros serviços; percentual ≥ 0 e ≤ 100; horas fixas ≥ 0).
3. O sistema persiste.
**Esperado:** Serviço criado com produtos relacionados.
**Rastreabilidade:** RF-CAT-003, RN-CAT-005.

### CT-CAT-010 — Criar serviço sem produtos relacionados
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin tenta criar serviço sem produtos relacionados.
2. O sistema valida.
**Esperado:** Sistema rejeita (serviço exige produtos relacionados).
**Rastreabilidade:** RF-CAT-003 (Exceções), RN-CAT-005, CA-CAT-001.

### CT-CAT-011 — Reordenar catálogo por arrastar e soltar
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin arrasta um item para nova posição.
2. O sistema calcula a nova ordem (ponto médio entre vizinhos).
3. O sistema persiste a ordenação.
**Esperado:** Ordenação atualizada com ordem fracionária.
**Rastreabilidade:** RF-CAT-004, RN-CAT-007, CA-CAT-002.

### CT-CAT-012 — Ativar/desativar produto
**Pré-condição:** Administrador autenticado; produto existe.
**Passos:**
1. O admin alterna o status do produto.
2. O sistema atualiza o status.
**Esperado:** Produto muda de status (ativo/inativo) sem ser excluído.
**Rastreabilidade:** RF-CAT-005, RN-CAT-008.

---

## 10. Drive e Arquivos (DRV)

### CT-DRV-001 — Listar arquivos do Drive (próprios e compartilhados)
**Pré-condição:** Usuário autenticado (qualquer perfil).
**Passos:**
1. O usuário acessa o Drive.
2. O sistema retorna itens recentes, próprios e compartilhados.
3. O usuário pode navegar em pastas.
**Esperado:** Usuário visualiza os arquivos próprios e compartilhados.
**Rastreabilidade:** RF-DRV-001, RN-DRV-001.

### CT-DRV-002 — Administrador cria pasta no Drive
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin cria uma pasta.
2. O sistema valida e armazena.
**Esperado:** Pasta criada no Drive.
**Rastreabilidade:** RF-DRV-002.

### CT-DRV-003 — Administrador faz upload de arquivo válido
**Pré-condição:** Administrador autenticado; arquivo com MIME válido e tamanho dentro do limite.
**Passos:**
1. O admin seleciona um arquivo para upload.
2. O sistema valida MIME e tamanho.
3. O sistema armazena o arquivo (upload direto ou assíncrono em duas fases).
**Esperado:** Arquivo armazenado e disponibilizado.
**Rastreabilidade:** RF-DRV-002, RN-DRV-002, CA-DRV-001.

### CT-DRV-004 — Upload de arquivo com MIME perigoso
**Pré-condição:** Administrador autenticado; arquivo .exe selecionado.
**Passos:**
1. O admin seleciona arquivo com MIME perigoso.
2. O sistema valida MIME.
**Esperado:** Sistema rejeita o upload (MIME perigoso).
**Rastreabilidade:** RF-DRV-002 (Exceções), RN-DRV-002.

### CT-DRV-005 — Criar pasta excedendo profundidade máxima
**Pré-condição:** Administrador autenticado; hierarquia já no nível 100.
**Passos:**
1. O admin tenta criar pasta no nível 101.
2. O sistema valida a profundidade.
**Esperado:** Sistema rejeita (profundidade máxima 100 excedida).
**Rastreabilidade:** RF-DRV-002 (Exceções), RN-DRV-003.

### CT-DRV-006 — Download/visualização de arquivo
**Pré-condição:** Usuário tem acesso ao arquivo.
**Passos:**
1. O usuário solicita download ou visualização.
2. O sistema retorna o arquivo (ou stream com suporte a Range para vídeos/áudio).
**Esperado:** Usuário obtém/visualiza o arquivo.
**Rastreabilidade:** RF-DRV-003, RN-DRV-004.

### CT-DRV-007 — Visualização de tipo não suportado
**Pré-condição:** Usuário solicita visualização inline de arquivo .zip.
**Passos:**
1. O usuário solicita visualização.
2. O sistema verifica o tipo suportado.
**Esperado:** Sistema oferece apenas download (tipo não suportado para visualização inline).
**Rastreabilidade:** RF-DRV-003 (Exceções), RN-DRV-004.

### CT-DRV-008 — Compartilhar arquivo com destinatário válido
**Pré-condição:** Dono (ou admin); destinatário existe, não está excluído e não é o próprio dono.
**Passos:**
1. O dono seleciona o destinatário.
2. O sistema cria o compartilhamento com permissão de leitura.
**Esperado:** Destinatário passa a ter acesso de leitura ao item.
**Rastreabilidade:** RF-DRV-004, RN-DRV-005, CA-DRV-002.

### CT-DRV-009 — Compartilhar pasta recursivamente
**Pré-condição:** Dono compartilha uma pasta com destinatário válido.
**Passos:**
1. O dono seleciona a pasta e o destinatário.
2. O sistema cria o compartilhamento recursivo para todo o conteúdo.
**Esperado:** Destinatário passa a ter acesso de leitura a todo o conteúdo da pasta.
**Rastreabilidade:** RF-DRV-004, RN-DRV-005, CA-DRV-003.

### CT-DRV-010 — Auto-compartilhamento bloqueado
**Pré-condição:** Dono tenta compartilhar item consigo mesmo.
**Passos:**
1. O dono seleciona a si mesmo como destinatário.
2. O sistema valida.
**Esperado:** Sistema rejeita (auto-compartilhamento bloqueado).
**Rastreabilidade:** RF-DRV-004 (Exceções), RN-DRV-005.

### CT-DRV-011 — Compartilhamento duplicado rejeitado
**Pré-condição:** Item já compartilhado com o destinatário.
**Passos:**
1. O dono tenta compartilhar novamente o mesmo item com o mesmo destinatário.
2. O sistema valida.
**Esperado:** Sistema rejeita com 409 (duplicidade no item alvo).
**Rastreabilidade:** RF-DRV-004 (Exceções), RN-DRV-005.

### CT-DRV-012 — Compartilhamento herdado em pasta compartilhada
**Pré-condição:** Pasta compartilhada com destinatário.
**Passos:**
1. O dono cria um novo arquivo dentro da pasta compartilhada.
2. O sistema propaga o compartilhamento do pai para o novo item.
**Esperado:** Novo item herda automaticamente os compartilhamentos do pai.
**Rastreabilidade:** RN-DRV-005.

### CT-DRV-013 — Gerenciar compartilhamentos (listar e remover em lote)
**Pré-condição:** Dono (ou admin); item compartilhado.
**Passos:**
1. O dono lista os compartilhamentos do item.
2. Seleciona um ou mais para remover.
3. O sistema remove em lote e reporta sucessos/falhas.
**Esperado:** Compartilhamentos selecionados removidos.
**Rastreabilidade:** RF-DRV-005, RN-DRV-006.

### CT-DRV-014 — Mover item respeitando hierarquia (sem ciclos)
**Pré-condição:** Dono (ou admin); item existe.
**Passos:**
1. O dono move o item para nova pasta.
2. O sistema valida hierarquia (sem ciclos) e profundidade máxima.
3. O sistema persiste.
**Esperado:** Item movido com compartilhamentos re-sincronizados.
**Rastreabilidade:** RF-DRV-006, RN-DRV-007.

### CT-DRV-015 — Mover pasta para dentro de sua subpasta (ciclo)
**Pré-condição:** Dono tenta mover pasta A para dentro de sua subpasta B.
**Passos:**
1. O dono solicita a movimentação.
2. O sistema valida a hierarquia.
**Esperado:** Sistema rejeita (ciclo detectado).
**Rastreabilidade:** RF-DRV-006 (Exceções), RN-DRV-007.

### CT-DRV-016 — Renomear item do Drive
**Pré-condição:** Dono (ou admin); item existe.
**Passos:**
1. O dono informa o novo nome.
2. O sistema valida e persiste.
**Esperado:** Item renomeado.
**Rastreabilidade:** RF-DRV-006.

### CT-DRV-017 — Excluir item do Drive
**Pré-condição:** Dono (ou admin); item existe.
**Passos:**
1. O dono solicita a exclusão.
2. O sistema valida permissão (dono ou admin).
3. O sistema remove o registro (remoção física no storage é best-effort).
**Esperado:** Item excluído (lógico); falha na remoção física não desfaz a exclusão.
**Rastreabilidade:** RF-DRV-006, RN-DRV-008.

### CT-DRV-018 — Definir capa de vídeo
**Pré-condição:** Dono (ou admin); item é um vídeo; imagem JPEG/PNG/GIF/WebP.
**Passos:**
1. O dono seleciona uma imagem.
2. O sistema valida MIME.
3. O sistema define a capa como padrão.
**Esperado:** Capa do vídeo atualizada (a anterior deixa de ser padrão).
**Rastreabilidade:** RF-DRV-007, RN-DRV-009.

### CT-DRV-019 — Definir capa em item não-vídeo
**Pré-condição:** Dono tenta definir capa em um arquivo PDF.
**Passos:**
1. O dono seleciona uma imagem para item não-vídeo.
2. O sistema valida o tipo do item.
**Esperado:** Sistema rejeita (apenas vídeos podem ter capa).
**Rastreabilidade:** RF-DRV-007 (Exceções), RN-DRV-009.

### CT-DRV-020 — Excluir capa padrão promove próxima ativa
**Pré-condição:** Vídeo com capa padrão e outras capas ativas.
**Passos:**
1. O dono exclui a capa padrão.
2. O sistema promove a próxima capa ativa como padrão (ou fallback para a primeira ativa).
**Esperado:** Vídeo permanece com uma capa padrão.
**Rastreabilidade:** RN-DRV-009.

### CT-DRV-021 — Vendedor não cria pastas/arquivos no Drive
**Pré-condição:** Vendedor autenticado.
**Passos:**
1. O vendedor acessa o Drive.
2. O vendedor visualiza apenas itens compartilhados (somente leitura).
**Esperado:** Vendedor não tem opção de criar pastas/arquivos; apenas visualiza/baixa itens compartilhados.
**Rastreabilidade:** RN-DRV-001, seção 17.2.

---

## 11. Relatórios (REL)

### CT-REL-001 — Relatório de vendas por parceiro
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin seleciona o período.
2. O sistema retorna vendas agregadas por parceiro e por mês.
3. Períodos longos (3 meses, ano) agrupados mensalmente; demais diariamente.
**Esperado:** Admin visualiza o relatório de vendas por parceiro no período.
**Rastreabilidade:** RF-REL-001, RN-REL-001, CA-REL-001.

### CT-REL-002 — Relatório de orçamentos por vendedor
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin seleciona o parceiro e o vendedor.
2. O sistema retorna orçamentos do vendedor (apenas principais, excluindo versões anteriores).
3. O admin pode filtrar por status, arquivamento, data e localização.
**Esperado:** Admin visualiza os orçamentos do vendedor conforme filtros.
**Rastreabilidade:** RF-REL-002, RN-REL-002.

### CT-REL-003 — Histórico de versões de orçamento
**Pré-condição:** Administrador autenticado; orçamento existe com versões anteriores.
**Passos:**
1. O admin abre o orçamento.
2. O sistema lista as versões anteriores (arquivadas), excluindo a versão atual.
**Esperado:** Admin visualiza o histórico de versões.
**Rastreabilidade:** RF-REL-003, RN-REL-003.

### CT-REL-004 — Histórico de versões sem versões anteriores
**Pré-condição:** Orçamento sem versões anteriores.
**Passos:**
1. O admin abre o orçamento.
2. O sistema tenta listar as versões anteriores.
**Esperado:** Sistema informa que não há versões anteriores.
**Rastreabilidade:** RF-REL-003 (Exceções), RN-REL-003.

---

## 12. Dashboard (DSH)

### CT-DSH-001 — Visualizar dashboard global
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin acessa o dashboard.
2. O sistema retorna vendas por período, contagem de orçamentos por status e arquivos recentes.
**Esperado:** Admin visualiza o dashboard global.
**Rastreabilidade:** RF-DSH-001, RN-DSH-001.

### CT-DSH-002 — Gestor/vendedor não acessa dashboard
**Pré-condição:** Gestor ou vendedor autenticado.
**Passos:**
1. O gestor/vendedor tenta acessar o dashboard.
**Esperado:** Dashboard não disponível (visível apenas ao administrador).
**Rastreabilidade:** RN-DSH-001, matriz de permissões.

---

## 13. Perfil (PRF)

### CT-PRF-001 — Editar perfil próprio
**Pré-condição:** Usuário autenticado (qualquer perfil).
**Passos:**
1. O usuário altera nome, e-mail, telefone e cargo.
2. O sistema valida e atualiza.
**Esperado:** Perfil atualizado.
**Rastreabilidade:** RF-PRF-001, RN-PRF-001.

### CT-PRF-002 — Editar perfil não permite alterar papel/status/senha
**Pré-condição:** Usuário autenticado.
**Passos:**
1. O usuário tenta alterar papel, status ou senha via edição de perfil.
2. O sistema valida.
**Esperado:** Sistema não permite alterar papel, status ou senha por este fluxo.
**Rastreabilidade:** RN-PRF-001.

### CT-PRF-003 — Editar perfil com e-mail duplicado
**Pré-condição:** Usuário autenticado; novo e-mail já existe.
**Passos:**
1. O usuário altera o e-mail para um já cadastrado.
2. O sistema valida.
**Esperado:** Sistema rejeita (e-mail único).
**Rastreabilidade:** RF-PRF-001 (Exceções), RN-PRF-001.

### CT-PRF-004 — Upload de avatar válido
**Pré-condição:** Usuário autenticado; imagem válida (MIME e até 5 MiB).
**Passos:**
1. O usuário seleciona uma imagem.
2. O sistema valida MIME e tamanho.
3. O sistema armazena o avatar.
**Esperado:** Avatar atualizado.
**Rastreabilidade:** RF-PRF-002, RN-PRF-002.

### CT-PRF-005 — Upload de avatar com tamanho excedido
**Pré-condição:** Usuário autenticado; imagem maior que 5 MiB.
**Passos:**
1. O usuário seleciona imagem maior que 5 MiB.
2. O sistema valida o tamanho.
**Esperado:** Sistema rejeita (tamanho excedido).
**Rastreabilidade:** RF-PRF-002 (Exceções), RN-PRF-002.

---

## 14. Wiki / Ajuda (WIK)

### CT-WIK-001 — Acessar wiki/ajuda
**Pré-condição:** Usuário autenticado (qualquer perfil).
**Passos:**
1. O usuário acessa a wiki.
2. O sistema exibe conteúdo estático com itens expansíveis.
**Esperado:** Usuário visualiza a ajuda e pode expandir itens.
**Rastreabilidade:** RF-WIK-001, RN-WIK-001.

---

## 15. Permissões (PER)

### CT-PER-001 — Vendedor não visualiza orçamentos de outros vendedores
**Pré-condição:** Vendedor autenticado.
**Passos:**
1. O vendedor lista orçamentos.
2. O sistema retorna apenas os próprios.
**Esperado:** Vendedor não vê orçamentos de outros vendedores.
**Rastreabilidade:** RN-ORC-015, CA-PER-001.

### CT-PER-002 — Gestor visualiza orçamentos da própria empresa
**Pré-condição:** Gestor autenticado.
**Passos:**
1. O gestor lista orçamentos.
2. O sistema retorna orçamentos de todos os vendedores da própria empresa.
**Esperado:** Gestor visualiza orçamentos da empresa (sem o parceiro no card, pois é o seu próprio).
**Rastreabilidade:** RN-ORC-015, CA-PER-002.

### CT-PER-003 — Administrador visualiza orçamentos de todos os parceiros
**Pré-condição:** Administrador autenticado.
**Passos:**
1. O admin lista orçamentos.
2. O sistema retorna todos os orçamentos (com parceiro e vendedor).
**Esperado:** Admin visualiza orçamentos de todos os parceiros.
**Rastreabilidade:** RN-ORC-015.

### CT-PER-004 — Gestor não gerencia catálogo (apenas leitura)
**Pré-condição:** Gestor autenticado.
**Passos:**
1. O gestor acessa o catálogo.
2. O sistema apresenta apenas leitura.
**Esperado:** Gestor visualiza o catálogo sem opções de criação/edição.
**Rastreabilidade:** Matriz de permissões (seção 4).

### CT-PER-005 — Vendedor não gerencia usuários
**Pré-condição:** Vendedor autenticado.
**Passos:**
1. O vendedor tenta acessar a gestão de usuários.
**Esperado:** Vendedor não tem permissão de gerenciar usuários.
**Rastreabilidade:** Matriz de permissões (seção 4).

### CT-PER-006 — Gestor não cria parceiros
**Pré-condição:** Gestor autenticado.
**Passos:**
1. O gestor tenta criar um parceiro.
**Esperado:** Operação não permitida (apenas admin cria parceiros).
**Rastreabilidade:** Matriz de permissões (seção 4).

### CT-PER-007 — Gestor não atualiza população IBGE
**Pré-condição:** Gestor autenticado.
**Passos:**
1. O gestor tenta disparar a atualização de população IBGE.
**Esperado:** Operação não permitida (apenas admin).
**Rastreabilidade:** Matriz de permissões (seção 4).

---

## 16. Geração e Exportação (EXP)

### CT-EXP-001 — PDF de credenciais ao criar usuário
**Pré-condição:** Administrador criando usuário.
**Passos:**
1. O admin cria o usuário e marca a geração de PDF de credenciais.
2. O sistema gera o PDF.
3. O PDF é baixado com nome `credenciais_<email>.pdf`.
**Esperado:** PDF de credenciais gerado e disponibilizado.
**Rastreabilidade:** Seção 19.3.

### CT-EXP-002 — PDF de acessos ao criar parceiro
**Pré-condição:** Administrador criando parceiro.
**Passos:**
1. O admin cria o parceiro e marca a geração de PDF de acessos.
2. O sistema gera o PDF.
3. O PDF é baixado com nome `Acessos_<nome>.pdf`.
**Esperado:** PDF de acessos gerado e disponibilizado.
**Rastreabilidade:** Seção 19.4.

### CT-EXP-003 — Exportação de censo com formatação de 2 casas decimais
**Pré-condição:** Orçamento com censo.
**Passos:**
1. O usuário solicita a exportação do censo.
2. O sistema gera o CSV com indicadores e valores formatados com 2 casas decimais (apresentação).
**Esperado:** CSV gerado com formatação de apresentação.
**Rastreabilidade:** Seção 19.2.

---

## Resumo de Cobertura

| Domínio | Casos de teste | Faixa de IDs |
|---|---:|---|
| Autenticação (AUT) | 12 | CT-AUT-001 a CT-AUT-012 |
| Cadastro (REG) | 6 | CT-REG-001 a CT-REG-006 |
| Prospecção (PRO) | 2 | CT-PRO-001 a CT-PRO-002 |
| Usuários (USR) | 11 | CT-USR-001 a CT-USR-011 |
| Parceiros (PAR) | 14 | CT-PAR-001 a CT-PAR-014 |
| Orçamentos (ORC) | 28 | CT-ORC-001 a CT-ORC-028 |
| Cálculos (CAL) | 8 | CT-CAL-001 a CT-CAL-008 |
| Censo (CEN) | 7 | CT-CEN-001 a CT-CEN-007 |
| Catálogo (CAT) | 12 | CT-CAT-001 a CT-CAT-012 |
| Drive (DRV) | 21 | CT-DRV-001 a CT-DRV-021 |
| Relatórios (REL) | 4 | CT-REL-001 a CT-REL-004 |
| Dashboard (DSH) | 2 | CT-DSH-001 a CT-DSH-002 |
| Perfil (PRF) | 5 | CT-PRF-001 a CT-PRF-005 |
| Wiki (WIK) | 1 | CT-WIK-001 |
| Permissões (PER) | 7 | CT-PER-001 a CT-PER-007 |
| Geração/Exportação (EXP) | 3 | CT-EXP-001 a CT-EXP-003 |
| **Total** | **143** | — |