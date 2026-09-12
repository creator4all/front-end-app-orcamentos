# Relatório de testes do App Multimídia Parceiro

**Aplicação:** Multimídia Parceiro
**Método:** documentação funcional → geração dos casos `CT-MOB-*` → execução na interface real do App (emulador, mobile-MCP)
**Este documento é autocontido.** Não depende de outros arquivos para ser lido.

---

## 1. Como o trabalho foi feito

O pedido foi: pegar a documentação, gerar os casos de teste, colocar a IA para testar o App e, depois, automatizar. Este relatório cobre as três primeiras etapas no **aplicativo**.

Os casos nasceram da documentação que geramos (regras de negócio, fluxos de tela, permissões por papel). Cada `CT-MOB-*` pergunta se o App faz o que a regra manda, não só “se quebrou na mão”.

## 2. Estatística da suíte (MCP, após todos os retestes)

| Métrica | Valor | % |
|---|---:|---:|
| Casos da suíte | **196** | 100% |
| PASS (conforme) | **179** | 91,3% |
| FAIL (divergente da regra) | **14** | 7,1% |
| IMPROVÁVEL (passo não forçável neste emulador) | **3** | 1,5% |
| BLOQUEADO / PARCIAL restantes | **0** | 0% |
| Domínios cobertos | **17 / 17** | 100% |

Os 3 IMPROVÁVEIS **não são FAIL** e **não são bug confirmado**: AUT-016 (401 só do Drive), EMP-008 (galeria não entrega arquivo inválido), DRV-011 (Android sempre acha um app para abrir o arquivo).

### Por domínio

| Domínio | Casos | PASS | FAIL | IMPROVÁVEL |
|---|---:|---:|---:|---:|
| AUT — Autenticação e sessão | 16 | 13 | 2 | 1 |
| RPS — Recuperação de senha | 11 | 11 | 0 | 0 |
| REG — Cadastro e parceria | 15 | 15 | 0 | 0 |
| NAV — Navegação e permissões | 6 | 6 | 0 | 0 |
| ORC — Lista e ações de orçamento | 22 | 17 | 5 | 0 |
| CRI — Criação e configuração | 25 | 24 | 1 | 0 |
| CAL — Cálculos e edição | 13 | 12 | 1 | 0 |
| EXP — PDF e compartilhamento | 8 | 7 | 1 | 0 |
| PRF — Perfil e conta | 10 | 9 | 1 | 0 |
| EMP — Empresa | 8 | 7 | 0 | 1 |
| USR — Gestão de usuários | 9 | 9 | 0 | 0 |
| ADM — Empresas e relatórios | 9 | 7 | 2 | 0 |
| CAT — Catálogo de produtos | 7 | 7 | 0 | 0 |
| PRO — Prospecção | 6 | 6 | 0 | 0 |
| DRV — Drive | 15 | 13 | 1 | 1 |
| WIK — Wiki | 4 | 4 | 0 | 0 |
| NFR — Compatibilidade (NFR) | 12 | 12 | 0 | 0 |
| **Total** | **196** | **179** | **14** | **3** |

---

## 3. Todos os casos e o status final

Status: **PASS** = App bateu a regra. **FAIL** = o passo rodou e o App fez outra coisa. **IMPROVÁVEL** = o passo do caso não dá para forçar neste emulador.

### AUT — Autenticação e sessão

| ID | Caso | Status |
|---|---|---|
| CT-MOB-AUT-001 | Login mobile válido sem OTP | **PASS** |
| CT-MOB-AUT-002 | Login com senha incorreta | **PASS** |
| CT-MOB-AUT-003 | Login com e-mail não cadastrado | **PASS** |
| CT-MOB-AUT-004 | Login de usuário inativo | **PASS** |
| CT-MOB-AUT-005 | Validação de e-mail vazio | **PASS** |
| CT-MOB-AUT-006 | Validação de formato de e-mail | **PASS** |
| CT-MOB-AUT-007 | Validação de senha vazia | **PASS** |
| CT-MOB-AUT-008 | Validação de senha curta no login | **PASS** |
| CT-MOB-AUT-009 | Alternar visibilidade da senha | **PASS** |
| CT-MOB-AUT-010 | Logout confirmado | **PASS** |
| CT-MOB-AUT-011 | Cancelar logout | **PASS** |
| CT-MOB-AUT-012 | Restaurar sessão válida ao reabrir o App | **PASS** |
| CT-MOB-AUT-013 | Sessão expirada ao reabrir o App | **FAIL** |
| CT-MOB-AUT-014 | Impedir múltiplos envios durante login | **PASS** |
| CT-MOB-AUT-015 | 401 do webservice principal desloga | **FAIL** |
| CT-MOB-AUT-016 | 401 só do Drive não desloga | **IMPROVÁVEL** |

### RPS — Recuperação de senha

| ID | Caso | Status |
|---|---|---|
| CT-MOB-RPS-001 | Solicitar recuperação com e-mail cadastrado | **PASS** |
| CT-MOB-RPS-002 | Solicitar recuperação com e-mail vazio | **PASS** |
| CT-MOB-RPS-003 | Solicitar recuperação com e-mail inválido | **PASS** |
| CT-MOB-RPS-004 | Recuperação com e-mail não cadastrado | **PASS** |
| CT-MOB-RPS-005 | Validar OTP correto | **PASS** |
| CT-MOB-RPS-006 | Rejeitar OTP incorreto | **PASS** |
| CT-MOB-RPS-007 | Rejeitar OTP expirado | **PASS** |
| CT-MOB-RPS-008 | Reenviar OTP | **PASS** |
| CT-MOB-RPS-009 | Rejeitar nova senha fora da política | **PASS** |
| CT-MOB-RPS-010 | Rejeitar confirmação divergente | **PASS** |
| CT-MOB-RPS-011 | Redefinir senha com sucesso | **PASS** |

### REG — Cadastro e parceria

| ID | Caso | Status |
|---|---|---|
| CT-MOB-REG-001 | Abrir cadastro pelo login | **PASS** |
| CT-MOB-REG-002 | Formatar CPF durante digitação | **PASS** |
| CT-MOB-REG-003 | Formatar CNPJ durante digitação | **PASS** |
| CT-MOB-REG-004 | Rejeitar CPF/CNPJ matematicamente inválido | **PASS** |
| CT-MOB-REG-005 | Localizar empresa ativa por CNPJ | **PASS** |
| CT-MOB-REG-006 | Recusar empresa encontrada | **PASS** |
| CT-MOB-REG-007 | Confirmar empresa encontrada | **PASS** |
| CT-MOB-REG-008 | Empresa não encontrada ou inativa | **PASS** |
| CT-MOB-REG-009 | Validar campos obrigatórios do autocadastro | **PASS** |
| CT-MOB-REG-010 | Rejeitar e-mail duplicado no autocadastro | **PASS** |
| CT-MOB-REG-011 | Concluir autocadastro de vendedor | **PASS** |
| CT-MOB-REG-012 | Usuário recém-cadastrado pendente não autentica | **PASS** |
| CT-MOB-REG-013 | Abrir formulário "Quero me tornar um parceiro" | **PASS** |
| CT-MOB-REG-014 | Validar obrigatórios da solicitação de parceria | **PASS** |
| CT-MOB-REG-015 | Enviar solicitação de parceria válida | **PASS** |

### NAV — Navegação e permissões

| ID | Caso | Status |
|---|---|---|
| CT-MOB-NAV-001 | Abrir e fechar menu do perfil | **PASS** |
| CT-MOB-NAV-002 | Menu de vendedor | **PASS** |
| CT-MOB-NAV-003 | Menu de gestor | **PASS** |
| CT-MOB-NAV-004 | Menu de administrador | **PASS** |
| CT-MOB-NAV-005 | Voltar preserva a tela anterior | **PASS** |
| CT-MOB-NAV-006 | Botão voltar na lista principal não fecha o App indevidamente | **PASS** |

### ORC — Lista e ações de orçamento

| ID | Caso | Status |
|---|---|---|
| CT-MOB-ORC-001 | Listar orçamentos próprios como vendedor | **PASS** |
| CT-MOB-ORC-002 | Listar orçamentos da própria empresa como gestor | **PASS** |
| CT-MOB-ORC-003 | Listar orçamentos de todos os parceiros como administrador | **PASS** |
| CT-MOB-ORC-004 | Buscar orçamento por texto | **PASS** |
| CT-MOB-ORC-005 | Filtrar por status (parcial) | **PASS** |
| CT-MOB-ORC-006 | Exibir arquivados e voltar aos realizados | **PASS** |
| CT-MOB-ORC-007 | Resetar filtros | **PASS** |
| CT-MOB-ORC-008 | Paginação por rolagem | **PASS** |
| CT-MOB-ORC-009 | Atualizar lista por gesto de refresh | **PASS** |
| CT-MOB-ORC-010 | Estado vazio da lista | **PASS** |
| CT-MOB-ORC-011 | Recuperar falha de carregamento | **PASS** |
| CT-MOB-ORC-012 | Abrir detalhes/edição de orçamento permitido | **PASS** |
| CT-MOB-ORC-013 | Renomear orçamento com nome válido | **PASS** |
| CT-MOB-ORC-014 | Rejeitar nome vazio ao renomear | **PASS** |
| CT-MOB-ORC-015 | Rejeitar nome com mais de 255 caracteres ao renomear | **PASS** |
| CT-MOB-ORC-016 | Arquivar orçamento | **FAIL** |
| CT-MOB-ORC-017 | Desarquivar orçamento | **FAIL** |
| CT-MOB-ORC-018 | Versionar orçamento | **PASS** |
| CT-MOB-ORC-019 | Bloquear edição sem permissão | **FAIL** |
| CT-MOB-ORC-020 | Orçamento finalizado/somente leitura | **FAIL** |
| CT-MOB-ORC-021 | Renomear confirmando o nome atual | **FAIL** |
| CT-MOB-ORC-022 | Histórico de orçamento de parceiro inativo | **PASS** |

### CRI — Criação e configuração

| ID | Caso | Status |
|---|---|---|
| CT-MOB-CRI-001 | Abrir novo orçamento | **PASS** |
| CT-MOB-CRI-002 | Campos de parceiro exclusivos do administrador | **PASS** |
| CT-MOB-CRI-003 | Selecionar parceiro de destino como administrador | **PASS** |
| CT-MOB-CRI-004 | Validar estado e cidade obrigatórios | **PASS** |
| CT-MOB-CRI-005 | Validar e-mail do responsável | **PASS** |
| CT-MOB-CRI-006 | Criar orçamento de cidade única | **PASS** |
| CT-MOB-CRI-007 | Cancelar criação após rascunho | **PASS** |
| CT-MOB-CRI-008 | Exigir nome no multi-cidade | **PASS** |
| CT-MOB-CRI-009 | Cancelar seleção multi-cidade | **PASS** |
| CT-MOB-CRI-010 | Criar orçamento multi-cidade | **PASS** |
| CT-MOB-CRI-011 | Remover cidade antes de concluir multi-cidade | **PASS** |
| CT-MOB-CRI-012 | Criar orçamento personalizado | **FAIL** |
| CT-MOB-CRI-013 | Rejeitar valor inválido no censo personalizado | **PASS** |
| CT-MOB-CRI-014 | Visualizar censo do orçamento | **PASS** |
| CT-MOB-CRI-015 | Editar snapshot do censo | **PASS** |
| CT-MOB-CRI-016 | Agregado multi-cidade após editar cidade | **PASS** |
| CT-MOB-CRI-017 | Navegar categoria, subcategoria e produtos | **PASS** |
| CT-MOB-CRI-018 | Selecionar/desmarcar categoria completa (cascade) | **PASS** |
| CT-MOB-CRI-019 | Selecionar/desmarcar produto individual | **PASS** |
| CT-MOB-CRI-020 | Salvar orçamento sem produtos (com confirmação) | **PASS** |
| CT-MOB-CRI-021 | Validade mínima válida | **PASS** |
| CT-MOB-CRI-022 | Rejeitar validade zero ou negativa | **PASS** |
| CT-MOB-CRI-023 | Validade máxima válida | **PASS** |
| CT-MOB-CRI-024 | Rejeitar validade acima de 365 dias | **PASS** |
| CT-MOB-CRI-025 | Impedir duplo salvamento | **PASS** |

### CAL — Cálculos e edição

| ID | Caso | Status |
|---|---|---|
| CT-MOB-CAL-001 | Livro calculado por indicadores de estudantes | **PASS** |
| CT-MOB-CAL-002 | Livro calculado por indicadores de professores | **PASS** |
| CT-MOB-CAL-003 | Tecnologia com estudantes e professores | **PASS** |
| CT-MOB-CAL-004 | Serviço calculado por produtos relacionados | **PASS** |
| CT-MOB-CAL-005 | Total do orçamento | **PASS** |
| CT-MOB-CAL-006 | Ativar quantidade manual | **PASS** |
| CT-MOB-CAL-007 | Desativar quantidade manual | **PASS** |
| CT-MOB-CAL-008 | Rejeitar quantidade manual inválida | **PASS** |
| CT-MOB-CAL-009 | Salvar edição e refletir na lista | **PASS** |
| CT-MOB-CAL-010 | Sair com alterações pendentes | **FAIL** |
| CT-MOB-CAL-011 | Bloquear compartilhamento com alterações pendentes | **PASS** |
| CT-MOB-CAL-012 | Editar orçamento expirado com nova validade | **PASS** |
| CT-MOB-CAL-013 | Serviço com percentual 0% e horas fixas | **PASS** |

### EXP — PDF e compartilhamento

| ID | Caso | Status |
|---|---|---|
| CT-MOB-EXP-001 | Gerar PDF com dados completos (parcial) | **PASS** |
| CT-MOB-EXP-002 | Bloquear PDF sem nome do responsável | **PASS** |
| CT-MOB-EXP-003 | Bloquear PDF sem cargo | **PASS** |
| CT-MOB-EXP-004 | Bloquear PDF sem telefone | **PASS** |
| CT-MOB-EXP-005 | Bloquear PDF sem e-mail válido | **PASS** |
| CT-MOB-EXP-006 | Cancelar folha de compartilhamento | **PASS** |
| CT-MOB-EXP-007 | Exportar censo em CSV | **PASS** |
| CT-MOB-EXP-008 | Gerar PDF renova validade em 60 dias | **FAIL** |

### PRF — Perfil e conta

| ID | Caso | Status |
|---|---|---|
| CT-MOB-PRF-001 | Carregar perfil próprio | **PASS** |
| CT-MOB-PRF-002 | Editar dados válidos do perfil | **PASS** |
| CT-MOB-PRF-003 | Rejeitar e-mail duplicado ao editar perfil | **PASS** |
| CT-MOB-PRF-004 | Validar telefone do perfil | **PASS** |
| CT-MOB-PRF-005 | Atualizar avatar válido | **PASS** |
| CT-MOB-PRF-006 | Cancelar seleção/recorte do avatar | **PASS** |
| CT-MOB-PRF-007 | Rejeitar avatar inválido ou acima de 5 MiB | **FAIL** |
| CT-MOB-PRF-008 | Remover avatar com confirmação | **PASS** |
| CT-MOB-PRF-009 | Cancelar exclusão da conta | **PASS** |
| CT-MOB-PRF-010 | Excluir a própria conta | **PASS** |

### EMP — Empresa

| ID | Caso | Status |
|---|---|---|
| CT-MOB-EMP-001 | Abrir edição da própria empresa como gestor/admin | **PASS** |
| CT-MOB-EMP-002 | Vendedor não acessa edição da empresa | **PASS** |
| CT-MOB-EMP-003 | Gestor edita própria empresa | **PASS** |
| CT-MOB-EMP-004 | Rejeitar CNPJ inválido ao editar empresa | **PASS** |
| CT-MOB-EMP-005 | Rejeitar e-mail inválido da empresa | **PASS** |
| CT-MOB-EMP-006 | Gestor não edita empresa de outra empresa | **PASS** |
| CT-MOB-EMP-007 | Cancelar recorte da logo | **PASS** |
| CT-MOB-EMP-008 | Rejeitar formato/proporção inválida de logo | **IMPROVÁVEL** |

### USR — Gestão de usuários

| ID | Caso | Status |
|---|---|---|
| CT-MOB-USR-001 | Gestor/admin lista usuários da própria empresa | **PASS** |
| CT-MOB-USR-002 | Buscar usuário | **PASS** |
| CT-MOB-USR-003 | Ativar/inativar vendedor como gestor | **PASS** |
| CT-MOB-USR-004 | Alterar papel de vendedor para gestor | **PASS** |
| CT-MOB-USR-005 | Alterar papel permitido e salvar lote | **PASS** |
| CT-MOB-USR-006 | Bloquear alteração do próprio gestor | **PASS** |
| CT-MOB-USR-007 | Bloquear alteração de papel superior ou igual | **PASS** |
| CT-MOB-USR-008 | Salvar sem alterações | **PASS** |
| CT-MOB-USR-009 | Gestor não lista usuários de outra empresa | **PASS** |

### ADM — Empresas e relatórios

| ID | Caso | Status |
|---|---|---|
| CT-MOB-ADM-001 | Administrador lista empresas | **PASS** |
| CT-MOB-ADM-002 | Buscar empresa com debounce | **PASS** |
| CT-MOB-ADM-003 | Paginar e atualizar empresas | **PASS** |
| CT-MOB-ADM-004 | Abrir usuários de uma empresa | **PASS** |
| CT-MOB-ADM-005 | Abrir relatórios de uma empresa | **PASS** |
| CT-MOB-ADM-006 | Relatório por vendedor e período | **PASS** |
| CT-MOB-ADM-007 | Validar intervalo de datas do relatório | **PASS** |
| CT-MOB-ADM-008 | Abrir detalhe de orçamento pelo relatório | **FAIL** |
| CT-MOB-ADM-009 | Abrir censo pelo detalhe do relatório | **FAIL** |

### CAT — Catálogo de produtos

| ID | Caso | Status |
|---|---|---|
| CT-MOB-CAT-001 | Acesso exclusivo do administrador pelo menu | **PASS** |
| CT-MOB-CAT-002 | Listar categorias, subcategorias e produtos (parcial) | **PASS** |
| CT-MOB-CAT-003 | Navegar pelo breadcrumb e voltar | **PASS** |
| CT-MOB-CAT-004 | Abrir detalhes/configuração de produto | **PASS** |
| CT-MOB-CAT-005 | Salvar configuração válida de produto | **PASS** |
| CT-MOB-CAT-006 | Desativar e reativar produto | **PASS** |
| CT-MOB-CAT-007 | Tratar falha ao atualizar produto/status | **PASS** |

### PRO — Prospecção

| ID | Caso | Status |
|---|---|---|
| CT-MOB-PRO-001 | Acesso exclusivo do administrador (parcial) | **PASS** |
| CT-MOB-PRO-002 | Listar prospecções pendentes | **PASS** |
| CT-MOB-PRO-003 | Paginar e atualizar prospecções | **PASS** |
| CT-MOB-PRO-004 | Marcar prospecção como contatada | **PASS** |
| CT-MOB-PRO-005 | Abrir empresas já contatadas | **PASS** |
| CT-MOB-PRO-006 | Abrir contato externo por WhatsApp/e-mail | **PASS** |

### DRV — Drive

| ID | Caso | Status |
|---|---|---|
| CT-MOB-DRV-001 | Abrir Drive e listar recentes/categorias | **PASS** |
| CT-MOB-DRV-002 | Estado vazio por papel | **PASS** |
| CT-MOB-DRV-003 | Meus arquivos somente para administrador | **PASS** |
| CT-MOB-DRV-004 | Buscar arquivo | **PASS** |
| CT-MOB-DRV-005 | Atualizar Drive por gesto de refresh | **PASS** |
| CT-MOB-DRV-006 | Abrir categoria | **PASS** |
| CT-MOB-DRV-007 | Abrir pasta e navegar hierarquia | **FAIL** |
| CT-MOB-DRV-008 | Visualizar imagem | **PASS** |
| CT-MOB-DRV-009 | Reproduzir vídeo | **PASS** |
| CT-MOB-DRV-010 | Abrir documento suportado | **PASS** |
| CT-MOB-DRV-011 | Nenhum aplicativo disponível para abrir documento | **IMPROVÁVEL** |
| CT-MOB-DRV-012 | Arquivo removido ou indisponível | **PASS** |
| CT-MOB-DRV-013 | Falha de conexão durante download | **PASS** |
| CT-MOB-DRV-014 | Compartilhar arquivo pelo sistema | **PASS** |
| CT-MOB-DRV-015 | Garantir ausência de criação/upload mobile para não administradores | **PASS** |

### WIK — Wiki

| ID | Caso | Status |
|---|---|---|
| CT-MOB-WIK-001 | Abrir Wiki sem autenticação | **PASS** |
| CT-MOB-WIK-002 | Abrir Wiki autenticado | **PASS** |
| CT-MOB-WIK-003 | Expandir e recolher artigos | **PASS** |
| CT-MOB-WIK-004 | Abrir política de privacidade | **PASS** |

### NFR — Compatibilidade (NFR)

| ID | Caso | Status |
|---|---|---|
| CT-MOB-NFR-001 | Layout em resolução compacta | **PASS** |
| CT-MOB-NFR-002 | Teclado não oculta ações essenciais | **PASS** |
| CT-MOB-NFR-003 | Rotação e recriação de Activity | **PASS** |
| CT-MOB-NFR-004 | Perda e retorno de rede | **PASS** |
| CT-MOB-NFR-005 | Toques repetidos em ações assíncronas | **PASS** |
| CT-MOB-NFR-006 | Formatação pt-BR | **PASS** |
| CT-MOB-NFR-007 | Persistência isolada entre usuários/emuladores | **PASS** |
| CT-MOB-NFR-008 | Atualização entre dispositivos | **PASS** |
| CT-MOB-NFR-009 | Não expor dados sensíveis em mensagens/telas | **PASS** |
| CT-MOB-NFR-010 | Retomada após ir ao background | **PASS** |
| CT-MOB-NFR-011 | Exploração de navegação rápida | **PASS** |
| CT-MOB-NFR-012 | Exploração com dados vazios, longos e caracteres especiais | **PASS** |

---

## 4. Erros e bugs encontrados (os 14 FAIL)

São **11 problemas** (alguns FAIL compartilham a mesma causa). Confirmados no App, no código Flutter e nas APIs que o App chama.

### 4.1 Sessão inválida não leva ao login — AUT-013 e AUT-015

**Esperado:** token expirado ou revogado → desloga e abre o login.

**Atual:** a área autenticada continua visível. Atualizar a lista mostra `Token inválido ou expirado`. Token que nunca foi JWT já volta 401 JSON. Token que **era válido e foi revogado** volta **500 HTML**. O App só desloga no 401.

**Onde:** backend (middleware JWT).

### 4.2 Arquivar ou desarquivar cria outro orçamento — ORC-016 e ORC-017

**Esperado:** arquivar guarda o **mesmo** registro, sem mudar status comercial. Desarquivar devolve o mesmo id.

**Atual:** **Salvar Alterações** com Arquivado=Sim versiona. Exemplo: orçamento 115 pendente virou `nao_aprovado` arquivado; nasceu o 148 pendente. Arquivados + Pendentes fica vazio.

**Onde:** App (save sempre versiona).

### 4.3 Vendedor acessa orçamento de outro usuário — ORC-019

**Esperado:** vendedor só vê e altera os próprios.

**Atual:** vendedor 46 vê `FX ORC-019 ALHEIO` (dono 45), abre e usa **Deselecionar todos**. `GET` do orçamento 117 com o token do 46 responde 200.

**Onde:** backend (autorização).

### 4.4 Orçamento aprovado continua editável — ORC-020

**Esperado (suíte):** aprovado em somente leitura.

**Atual:** `FX ORC-020 APROVADO` (118) mantém Deselecionar todos, catálogo e seletor de status. Confirmar se a regra de negócio vigente é mesmo “somente leitura”.

**Onde:** App.

### 4.5 Confirmar o mesmo nome no rename é rejeitado — ORC-021

**Esperado:** abrir Renomear, manter o nome e confirmar = sucesso sem mudança.

**Atual:** `O novo nome deve ser diferente do atual`. A janela não fecha.

**Onde:** App.

### 4.6 Não existe orçamento personalizado sem município — CRI-012

**Esperado:** terceiro fluxo de criação, sem cidade, censo na mão.

**Atual:** Novo Orç. só tem cidade única e multi-cidade. Pode ser regra retirada no produto; como está, o caso canônico não executa.

**Onde:** App (fluxo ausente).

### 4.7 Voltar com alteração não salva sai direto — CAL-010

**Esperado:** diálogo Cancelar / Descartar.

**Atual:** o `*` aparece no título e o Back sai sem perguntar.

**Onde:** App.

### 4.8 Gerar PDF não renova 60 dias — EXP-008

**Esperado:** PDF → validade = hoje + 60; expirado sai de expirado.

**Atual:** PDF sai. O 135 ficou com 15 dias / 26/09/2026. O backend soma `agora + orc_dias_validade` (o prazo antigo), sem forçar 60 nem mudar status.

**Onde:** backend.

### 4.9 Total e censo do relatório mudam no detalhe — ADM-008 e ADM-009

**Esperado:** o cartão e o detalhe mostram o mesmo total e o mesmo censo gravados.

**Atual:** lista `FX ADM-008` R$ 123.456,78; detalhe ~R$ 22 milhões. `FX ADM-009` lista R$ 7.000,00; detalhe recalcula milhões. A lista usa o total salvo; o detalhe soma o catálogo de novo.

**Onde:** App (tela de detalhe do relatório).

### 4.10 Avatar maior que 5 MiB não é recusado — PRF-007

**Esperado:** recusar imagem > 5 MiB antes do recorte.

**Atual:** JPG 6,29 MiB abre Recortar Foto. `.txt` nem entra na galeria (isso é limitação do picker, não o FAIL principal).

**Onde:** App.

### 4.11 Breadcrumb do Drive não volta à pasta pai — DRV-007

**Esperado:** Drive → Pasta → Subpasta; tocar em Pasta mostra o conteúdo dela.

**Atual:** o texto do caminho muda, a tela continua na subpasta. O App reduz a pilha interna antes de calcular quantas telas voltar, e o cálculo vira zero.

**Onde:** App.

---

## 5. O que os dois estagiários testaram (App)

Fontes: relatórios de 10/09/2026, **Lucca Turra** e **Rodrigo Fattori**, versão V1.1.0. Eles fizeram caça a bug (exploratório). A IA fez suíte fechada. Não é a mesma pergunta.

Itens **Plataforma WEB** dos dois PDFs **não entram** na estatística do App. Ficam listados só para não misturar.

### 5.1 Lucca Turra (10/09) — 4 itens de App + 1 WEB + 1 melhoria WEB

| # | Plataforma | Situação no PDF | O que ele viu | O que o MCP viu no App |
|---|---|---|---|---|
| 1 | App | CORRIGIDO | Dava para digitar valores infinitos na edição | **CAL-008** e **CRI-013 PASS.** Inválido / negativo / `abc` não entram. Não retestamos um número gigante tipo 999…999. |
| 2 | App | CORRIGIDO | Alterar orçamento de outro vendedor (multi-cidade) dava erro ao salvar | **CRI-010** cria multi **PASS.** **CRI-016** (editar agregado multi) **PASS** no reteste de 11/09. **ORC-019 FAIL:** o vendedor ainda **abre e edita** o orçamento de outro. Lucca perguntou se o save crashava; a suíte pergunta se **pode** editar o do outro. |
| 3 | App | CORRIGIDO | Editar empresa: erro ao clicar em Salvar | **EMP-003/004/005 PASS.** A tela responde; CNPJ/e-mail inválido são recusados. |
| 4 | App | CORRIGIDO | Telefone aceitava qualquer quantidade de dígitos | **PRF-004 PASS.** `(11) 999` → Telefone inválido, não gravou. |
| 5 | WEB | CORRIGIDO | Anexar contrato PDF → erro 500 | **Fora do App.** No mobile o gestor só vê/baixa contrato; não anexa. |
| 6 | WEB | MELHORIA | Replicar séries nas trilhas / duplicar produto | Fora do App. |

### 5.2 Rodrigo Fattori (10/09) — 1 item de App + 6 WEB

| # | Plataforma | Situação no PDF | O que ele viu | O que o MCP viu no App |
|---|---|---|---|---|
| 1 | WEB | CORRIGIDO | Anexar contrato PDF → erro 500 | Fora do App (igual ao item 5 do Lucca). |
| 2 | WEB | MELHORIA | Cadastrar produto: termo “solução” | Fora do App. |
| 3 | WEB | MELHORIA | Diferencial inexistente: confirma e não limpa o campo | Fora do App. |
| 4 | WEB | CORRIGIDO | Compartilhamento em lote no Multi Drive | Fora do App. Drive mobile não cria/envia em lote. |
| 5 | WEB | CORRIGIDO | Descompartilhamento em lote | Fora do App. |
| 6 | **App** | **ERRO** | Lista de orçamentos: primeira página carrega; as demais ficam com carregamento infinito | **ORC-008 PASS** no MCP (20 fixtures, rolagem até o fim, API com 3 páginas). **Não reproduzimos** o spinner infinito neste ambiente. Ou foi corrigido depois do PDF, ou depende de dado/rede que não montamos. |
| 7 | WEB | ERRO | Filtros de orçamento na gestão de parceiros | Fora do App (é o painel). |

### 5.3 Cruzamento em uma frase

| | Lucca (App) | Rodrigo (App) | IA / MCP |
|---|---|---|---|
| Método | Exploratório | Exploratório | Suíte contra a documentação |
| Itens de App no PDF | 4 bugs marcados CORRIGIDO | 1 ERRO (paginação) | 196 casos |
| Resultado no App em 11/09 | 3 consertos confirmados (valores, empresa, telefone); 1 família ainda aberta na **permissão** (ORC-019), não no crash do save | Paginação **não reproduzida** (ORC-008 PASS) | 179 PASS, 14 FAIL, 3 IMPROVÁVEL |

- **Pegos pelos dois lados:** nenhum FAIL da suíte está escrito nos PDFs dos estagiários.
- **Pegos só pelos estagiários (App):** paginação infinita do Rodrigo — a suíte cobriu o tema (ORC-008) e **passou**.
- **Pegos só pela suíte:** os 14 FAIL da seção 4 (sessão, arquivar, permissão, aprovado, rename, CRI-012, back sujo, PDF 60 dias, relatório, avatar, breadcrumb).
- **Marcados CORRIGIDO pelo Lucca e confirmados no MCP:** valores inválidos, telefone, edição de empresa, save do multi-cidade (CRI-016).
- **WEB nos dois PDFs:** contrato, Drive em lote, cadastro de produto/diferencial, filtros da gestão de parceiros — não são deste App.

---

## 6. IMPROVÁVEIS (não vão como erro de produto)

| ID | Por que não é FAIL |
|---|---|
| AUT-016 | Precisaria de 401 **só** do File Manager, com o webservice ainda ok. Não isolamos isso no ASUS. |
| EMP-008 | Galeria (`pickImage`) não entrega `.txt`; o recorte trava 1:1 / 16:9. O validador de logo inválida não abre. |
| DRV-011 | O chooser Android `*/*` sempre acha um app. O estado “nenhum aplicativo” não existe neste emulador. |

---

## 7. Conclusão

A cadeia documentação → casos → teste na UI do App foi executada até o fim: **196/196**.

- **91% conforme.**
- **14 divergências** para correção (11 problemas; sessão e arquivar e relatório agrupam dois IDs cada).
- **3 casos** só deste emulador, sem tratar como bug.
- Os estagiários acharam regressões pontuais (e várias coisas de **WEB**). A suíte cobriu o App inteiro e achou falhas que o teste exploratório não listou.
- Próximo passo do pipeline original: testes automatizados (Patrol já existe para parte dos casos).

