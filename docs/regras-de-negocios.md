# Especificação Funcional e Regras de Negócio
## Multimídia: Parceiro — Sistema de Orçamentos

> **Leia-me primeiro.** Este documento descreve **o que** o produto faz e **por que / quando** cada regra se aplica, em linguagem de negócio. Não substitui a leitura do código, mas permite entender o sistema sem abri-lo.
>
> **Documento autocontido.** Este arquivo não depende de nenhum outro para ser lido. As divergências entre a regra descrita e o comportamento atual do código estão consolidadas na seção [24. Divergências conhecidas](#24-divergências-conhecidas-entre-regra-e-implementação), com ponteiro para a seção em que cada regra é definida.
>
> **Rodada de validação de 10/09/2026.** Este documento já incorpora as decisões de negócio validadas com Pedro Penha em 10/09/2026. Os pontos decididos deixaram de ser "necessita validação" e passaram a ser regra; quando a implementação atual não segue a regra decidida, o texto identifica explicitamente a divergência.
>
> Convenções de linguagem:
> - **deve** = regra confirmada (especificação + implementação coerentes);
> - **decidido em 10/09/2026** = regra definida na validação de negócio; quando a implementação não a segue, há divergência declarada;
> - **atualmente** = comportamento observado na implementação atual;
> - **intenção original** = descrito na especificação de produto, sem confirmação plena na implementação;
> - **aparentemente / há indícios** = inferência a partir de evidências fragmentadas;
> - **necessita validação** = fontes conflitantes ou lacuna não resolvida;
> - **regra superada** = regra antiga substituída por correção posterior (ex.: arredondamento);
> - **risco técnico aceito** = comportamento conhecido e aceito pelo negócio, a ser reavaliado no futuro.
>
> Nomes técnicos (controllers, stores, DTOs, endpoints) aparecem **apenas** nas seções finais de divergências e rastreabilidade, quando estritamente necessários para justificar uma conclusão.

---

# 1. Visão do Produto

## Propósito

O **Multimídia: Parceiro** é um conjunto de soluções B2B da Multimídia Educacional voltado a parceiros/vendedores que atendem prefeituras e escolas públicas. Seu propósito é permitir que um vendedor visite (ou atenda remotamente) uma prefeitura, colete ou importe os dados do Censo Escolar do município e gere automaticamente uma proposta comercial com quantidades de livros, tecnologias e horas de serviço derivadas dos indicadores escolares, com versões, validade, exportação em PDF e rastreabilidade.

## Problema resolvido

Substituir a montagem manual de propostas educacionais (planilhas, cálculos por município, cópia de dados do QEdu/MEC) por um fluxo guiado que:

- carrega automaticamente os dados demográficos do município selecionado;
- calcula quantidades de livros, tecnologias e horas de serviço a partir de indicadores do Censo Escolar;
- gera um orçamento com identidade visual do parceiro, validade controlada e histórico de versões;
- exporta a proposta em PDF para compartilhamento com a prefeitura.

## Usuários do produto

- **Administradores da Multimídia**: gerenciam parceiros, usuários, catálogo de produtos, censo escolar, cidades/estados, permissões, dashboard e Drive de arquivos.
- **Gestores de empresas parceiras**: gerenciam os vendedores da própria empresa, visualizam orçamentos da empresa e editam dados/identidade visual da empresa.
- **Vendedores de empresas parceiras**: criam, editam e acompanham apenas seus próprios orçamentos.
- **Visitantes (prospecção)**: quem ainda não tem vínculo com o sistema pode pedir para entrar por dois caminhos distintos. Pela **prospecção**, uma pessoa ou empresa pede para ser incluída como nova empresa parceira da Multimídia; o contato posterior é feito pelo administrador. Pelo **cadastro**, uma pessoa que já tem uma empresa parceira cadastrada busca-a pelo CNPJ/CPF e solicita vínculo a ela; esse pedido só vira acesso efetivo depois de aceito pelo **gestor da parceria**.

## Contexto de utilização

O vendedor atua em campo (atendimento a prefeituras) ou remotamente. O App mobile é a ferramenta do vendedor e do gestor; o painel administrativo web é de uso **exclusivo do administrador** (decidido em 10/09/2026) — gestor e vendedor não acessam o painel, nem mesmo de forma limitada, e realizam toda a gestão de empresa e de vendedores pelo App. O Drive é o repositório de materiais comerciais e técnicos compartilhados entre a Multimídia e os parceiros.

## Principais capacidades

- Autenticação em duas etapas **no painel web** (e-mail + senha, seguida de OTP por e-mail); no App, todos os perfis — inclusive o Administrador — entram apenas com e-mail e senha (decidido em 10/09/2026);
- Auto-cadastro de vendedores vinculados a uma empresa parceira existente, sujeito a aprovação do gestor;
- Prospecção de novas parcerias;
- Criação de orçamentos por cidade única e multi-cidade; o fluxo personalizado (sem município) está planejado para uma próxima versão;
- Cálculo automático de quantidades a partir do Censo Escolar;
- Quantidade manual sobrescrevendo o cálculo automático;
- Edição de orçamentos com versionamento e preservação de histórico;
- Controle de validade e expiração;
- Arquivamento e desarquivamento;
- Geração de PDF com identidade visual do parceiro;
- Exportação de censo em CSV;
- Catálogo administrativo de categorias, subcategorias, produtos, indicadores e diferenciais;
- Drive de arquivos com compartilhamento;
- Dashboard e relatórios de vendas.

## Relação entre App, painel e gerenciamento de arquivos

- **App (mobile)**: único ponto de uso do vendedor e do gestor, para orçamentos, perfil, parceiro, gestão de vendedores (gestor), Drive (somente leitura) e wiki.
- **Painel administrativo (web)**: ponto de uso **exclusivo do administrador** para catálogo, censo, cidades/estados, parceiros, usuários, permissões, dashboard, relatórios e Drive (gerenciamento).
- **Drive / File Manager (serviço de arquivos)**: repositório de materiais comerciais e técnicos, acessado pelo App e pelo painel, com compartilhamento entre a Multimídia e os parceiros.

---

# 2. Escopo

## Dentro do escopo

- Autenticação no painel web em duas etapas (e-mail/senha + OTP por e-mail) e autenticação no App em etapa única (e-mail/senha); recuperação de senha via OTP.
- Auto-cadastro de vendedores vinculados a empresa parceira existente e ativa.
- Prospecção de novas parcerias (registro público de interesse).
- Criação, edição, versionamento, arquivamento e desarquivamento de orçamentos.
- Orçamentos de cidade única e multi-cidade. O personalizado está especificado como evolução futura e ainda não integra a versão atual do App.
- Cálculo de quantidades a partir do Censo Escolar (livros, tecnologias, serviços).
- Quantidade manual sobrescrevendo o cálculo automático.
- Geração de PDF de orçamento com identidade visual do parceiro.
- Exportação de censo em CSV.
- Catálogo administrativo (categorias, subcategorias, produtos, indicadores, diferenciais, grupos de censo, índices de etapa).
- Censo Escolar por município, com edição de valores e atualização de população IBGE.
- Gestão de cidades e estados.
- Gestão de parceiros, usuários, papéis e capacidades.
- Drive de arquivos com upload, download, visualização, streaming, compartilhamento e capas de vídeo.
- Dashboard global e relatórios de vendas por parceiro e por vendedor.
- Perfil do usuário (nome, e-mail, telefone, cargo, avatar) e perfil da empresa (gestor).
- Exclusão lógica de conta pelo próprio usuário.

## Fora do escopo

- Funcionalidades offline (o app não funciona sem conexão).
- Login social (não há integração com redes sociais).
- Edição de usuários de um parceiro pelo painel pelo gestor (o gestor gerencia vendedores pelo App, não pelo painel).
- Exclusão física de parceiros (não existe rota de exclusão física; apenas alternância de status).

## Funcionalidades futuras ou adiadas

- **Geração de orçamento em planilha (CSV/Excel completo)**: a especificação original (RF_S2) prevê exportação do orçamento completo em planilha; a implementação atual só exporta o **censo** em CSV. Decidido em 10/09/2026: a exportação completa continua desejável, mas foi **adiada para uma próxima entrega**. A ausência não bloqueia a entrega atual e não deve ser tratada como defeito desta versão.

## Pontos encerrados na validação de 10/09/2026

Os itens abaixo constavam como pendências ou lacunas em versões anteriores deste documento e foram **encerrados** na validação de negócio:

- **Novo layout do PDF do orçamento**: nenhum novo layout foi entregue. Não existe layout alternativo aguardando implementação — o layout presente no código é o layout efetivo. O ponto só deve ser reaberto se um novo artefato de design for entregue.
- **Carta senha de acesso para gestores/vendedores**: a funcionalidade **está implementada**. "Carta senha" e "PDF de credenciais" são o mesmo tipo de artefato, com nomes diferentes conforme o contexto: no cadastro de parceiro, o PDF é consolidado, com uma página por usuário criado; no cadastro individual de usuário, contém apenas o usuário correspondente. A divergência era apenas de terminologia (ver §19.3 e §19.4).

---

# 3. Atores e Perfis

## Administrador

- **Objetivo**: administrar todo o sistema Multimídia: Parceiro.
- **Responsabilidades**: gerenciar parceiros, usuários, catálogo de produtos, censo escolar, cidades/estados, permissões, dashboard, relatórios globais e Drive.
- **Informações que visualiza**: todos os orçamentos (com parceiro e vendedor), todos os parceiros, todos os usuários, dashboard global, relatórios de todos os parceiros e vendedores.
- **Operações que realiza**: criar/editar/desativar parceiros e usuários, gerenciar catálogo, editar censo, atualizar população IBGE, compartilhar conteúdo do Drive, criar orçamentos em nome de outros parceiros (com identidade visual do parceiro destino).
- **Limitações**: não pode se auto-excluir via fluxo de lote; a edição de perfil próprio não permite alterar papel, status, exclusão ou senha.

## Gestor

- **Objetivo**: gerenciar a própria empresa parceira e seus vendedores.
- **Responsabilidades**: aprovar auto-cadastros de vendedores, ativar/desativar vendedores, alterar papel entre vendedor e gestor, editar dados e identidade visual da empresa, visualizar orçamentos da empresa.
- **Informações que visualiza**: orçamentos criados pelos vendedores da própria empresa (com o vendedor responsável, mas sem o parceiro — pois é o seu próprio), usuários vendedores da empresa, contrato da empresa, Drive compartilhado com a empresa.
- **Operações que realiza**: editar dados da empresa e logo, visualizar/baixar contrato, gerenciar vendedores (status e papel), visualizar orçamentos da empresa, criar orçamentos próprios, acessar Drive (somente leitura de itens compartilhados). Todas essas operações são feitas **pelo App**.
- **Limitações**: **não acessa o painel administrativo web** (decidido em 10/09/2026) e, por consequência, não acessa relatórios; não altera o status da própria empresa; não cria parceiros; não gerencia catálogo (apenas leitura); não gerencia censo (apenas leitura do agregado); não cria pastas/arquivos nem gerencia compartilhamentos no Drive.

## Vendedor

- **Objetivo**: criar e acompanhar orçamentos próprios.
- **Responsabilidades**: criar, editar e versionar orçamentos próprios; manter perfil atualizado.
- **Informações que visualiza**: apenas seus próprios orçamentos (sem parceiro nem vendedor adicionais no card — são dados dele próprio), perfil próprio, Drive compartilhado.
- **Operações que realiza**: criar/editar/versionar orçamentos próprios, gerar PDF, exportar censo, editar perfil próprio, excluir a própria conta, acessar Drive (somente leitura de itens compartilhados).
- **Limitações**: **não acessa o painel administrativo web**; não vê orçamentos de outros vendedores; não gerencia usuários; não gerencia empresa; não gerencia catálogo; não cria pastas/arquivos nem gerencia compartilhamentos no Drive.

## Usuário em processo de cadastro (visitante)

- **Objetivo**: vincular-se a uma empresa parceira existente ou registrar interesse em parceria.
- **Responsabilidades**: informar CNPJ/CPF da empresa; se encontrada e ativa, cadastrar-se com nome, e-mail, telefone e senha; se não encontrada, registrar prospecção.
- **Informações que visualiza**: dados públicos da empresa encontrada (nome fantasia, CNPJ).
- **Operações que realiza**: verificar documento, cadastrar-se, solicitar parceria.
- **Limitações**: o cadastro fica pendente de aprovação do gestor da empresa; não tem acesso ao sistema até aprovação.

## Potencial parceiro / prospect

- **Objetivo**: manifestar interesse em tornar-se parceiro da Multimídia.
- **Responsabilidades**: informar nome, e-mail e telefone (obrigatórios); empresa e CNPJ (opcionais); experiência em vendas públicas (opcional).
- **Informações que visualiza**: confirmação de envio da prospecção.
- **Operações que realiza**: registrar prospecção.
- **Limitações**: não tem acesso ao sistema; o contato posterior é feito pelo administrador.

## Parceiro / Empresa

- **Objetivo**: ser a unidade organizacional à qual gestores e vendedores estão vinculados.
- **Responsabilidades**: manter dados cadastrais e identidade visual atualizados (pelo gestor); receber orçamentos destinados (quando criados por admin para a empresa).
- **Informações que visualiza**: dados próprios, contrato, logo.
- **Operações que realiza**: (via gestor) editar dados e logo; (via admin) criar/editar/desativar.
- **Limitações**: parceiros inativos não podem ser selecionados para novos orçamentos; não há exclusão física.

---

# 4. Matriz de Permissões

| Funcionalidade | Administrador | Gestor | Vendedor |
|---|:---:|:---:|:---:|
| Acessar o painel administrativo web | Sim | Não | Não |
| Acessar o App mobile | Sim | Sim | Sim |
| Visualizar próprios orçamentos | Sim | Sim | Sim |
| Visualizar orçamentos dos vendedores da empresa | Sim | Sim | Não |
| Visualizar orçamentos de todos os parceiros | Sim | Não | Não |
| Criar orçamento próprio | Sim | Sim | Sim |
| Criar orçamento em nome de outro parceiro | Sim | Não | Não |
| Editar orçamento próprio | Sim | Sim | Sim |
| Editar orçamento de vendedor da empresa | Sim | Sim | Não |
| Editar qualquer orçamento | Sim | Não | Não |
| Versionar orçamento | Sim | Sim (próprios e da empresa) | Sim (próprios) |
| Arquivar/desarquivar orçamento | Sim | Sim (próprios e da empresa) | Sim (próprios) |
| Gerar PDF de orçamento | Sim | Sim | Sim |
| Exportar censo em CSV | Sim | Sim | Sim |
| Gerir empresa própria (dados/logo) | Sim | Sim | Não |
| Gerir qualquer parceiro | Sim | Não | Não |
| Gerir vendedores da empresa | Sim | Sim | Não |
| Gerir usuários (qualquer parceiro) | Sim | Não | Não |
| Aprovar auto-cadastro de vendedor | Sim | Sim | Não |
| Gerir papéis e capacidades | Sim | Não | Não |
| Gerir catálogo (criar/editar/ativar/desativar) | Sim | Não | Não |
| Visualizar catálogo | Sim | Sim (leitura) | Sim (leitura) |
| Gerir censo escolar (editar valores) | Sim | Não | Não |
| Visualizar censo agregado | Sim | Sim | Sim |
| Atualizar população IBGE | Sim | Não | Não |
| Gerir cidades e estados | Sim | Não | Não |
| Acessar Drive (visualizar/baixar/stream) | Sim | Sim (somente leitura, pelo App) | Sim (somente leitura, pelo App) |
| Criar pastas/arquivos no Drive | Sim | Não | Não |
| Compartilhar conteúdo do Drive | Sim | Não | Não |
| Gerir compartilhamentos | Sim | Não | Não |
| Visualizar dashboard global | Sim | Não | Não |
| Visualizar relatórios de vendas (qualquer parceiro) | Sim | Não | Não |
| Visualizar relatórios de vendas (próprio parceiro) | Sim | Não | Não |
| Visualizar relatórios de orçamentos (qualquer vendedor) | Sim | Não | Não |
| Visualizar relatórios de orçamentos (vendedores da empresa) | Sim | Não | Não |
| Editar perfil próprio | Sim | Sim | Sim |
| Excluir a própria conta | Sim | Sim | Sim |
| Acessar wiki/ajuda | Sim | Sim | Sim |
| Alternar tema escuro/claro (painel) | Sim | — | — |

> **Notas:**
> - **Painel exclusivo do administrador** (decidido em 10/09/2026). Gestor e Vendedor usam apenas o App e devem ser bloqueados no painel **inclusive quando apresentarem um token válido obtido pelo App**. O gestor gerencia a empresa e os vendedores pelo App e **não acessa relatórios**. **Divergência atual:** o painel não possui middleware de bloqueio por papel — qualquer usuário autenticado alcança as páginas. O backend bloqueia o login não-mobile para não-admins, mas esse bloqueio não cobre um token obtido pelo App. O middleware de papel no frontend deve ser implementado (ver §24.2).
> - **Drive é administrado apenas pelo administrador** (decidido em 10/09/2026): somente ele cria pastas, envia arquivos e gerencia compartilhamentos. Gestor e Vendedor têm apenas acesso de leitura, pelo App. **Divergência atual:** a UI do painel exibe os controles de criação para qualquer usuário autenticado na visão "own"; esses controles devem ser bloqueados para não-administradores (ver §24.2).
> - **Administrador é identificado por capacidade, nunca por identificador fixo ou nome de papel** (decidido em 10/09/2026): o papel pode ter qualquer nome, e a capacidade administrativa no modelo atual é `all`. **Divergência atual:** o painel verifica `rol_roleId === 1` e o backend compara o nome literal `Administrador`; ambas as verificações devem ser substituídas por verificação de capacidade (ver §24.2).

---

# 5. Módulos Funcionais

O sistema organiza-se nos seguintes domínios funcionais:

1. **Autenticação** — login em duas etapas no painel web (e-mail/senha + OTP) e em etapa única no App (e-mail/senha); sessão, logout, recuperação de senha via OTP.
2. **Cadastro** — auto-cadastro de vendedores vinculados a empresa parceira existente, aprovado pelo gestor; verificação de CNPJ/CPF.
3. **Usuários** — CRUD de usuários (admin), gestão de vendedores (gestor), atualização em lote, papéis e capacidades.
4. **Parceiros** — cadastro/edição/status de empresas parceiras, logo, contrato, gestor responsável.
5. **Prospecção** — registro público de interesse em parceria; gestão de pendentes e contatados (admin).
6. **Orçamentos** — criação (cidade única, multi-cidade, personalizado), edição, versionamento, status, validade, arquivamento, PDF, exportação de censo.
7. **Censo Escolar** — indicadores de etapa por município, indicadores de professor (sufixo P), grupos de censo, índices de etapa, edição de valores, atualização de população IBGE.
8. **Catálogo de Produtos** — categorias, subcategorias, produtos (livros, tecnologias, serviços), indicadores de etapa, diferenciais, grupos de produtos, ordenação, ativação/inativação, exclusão lógica, restauração.
9. **Drive e Arquivos** — pastas, arquivos, upload (direto e assíncrono em duas fases), download, visualização, streaming, compartilhamento, capas de vídeo.
10. **Relatórios** — vendas por parceiro, orçamentos por vendedor, histórico de versões, PDF de orçamento.
11. **Dashboard** — vendas por período, orçamentos por status, arquivos recentes.
12. **Perfil** — dados do usuário (nome, e-mail, telefone, cargo, avatar), dados da empresa (gestor), tema (painel).
13. **Configurações da Empresa** — edição de dados e logo pelo gestor; contrato.
14. **Wiki/Ajuda** — conteúdo estático de ajuda acessível pelo App.

---

# 6. Requisitos Funcionais

> Identificadores seguem o padrão **RF-\<DOMÍNIO\>-NNN**, onde o domínio é: AUT (Autenticação), USR (Usuários), PAR (Parceiros), ORC (Orçamentos), CEN (Censo Escolar), CAT (Catálogo), DRV (Drive), REL (Relatórios), PRF (Perfil), WIK (Wiki), REG (Cadastro/Registro), PRO (Prospecção), DSH (Dashboard). Cada requisito traz Descrição, Atores, Pré-condições, Fluxo principal, Pós-condições, Exceções e Regras relacionadas.

## RF-AUT-001 — Login (OTP no painel web; e-mail e senha no App)

**Descrição:** O canal define o número de etapas do login (decidido em 10/09/2026). **No painel web**, o usuário informa e-mail e senha e, em seguida, um código OTP enviado por e-mail para concluir a autenticação. **No App mobile**, todos os perfis — inclusive o Administrador — autenticam-se apenas com e-mail e senha, sem OTP.

**Atores:** Administrador (painel e App); Gestor e Vendedor (apenas App).

**Pré-condições:** O usuário está cadastrado, ativo e com e-mail válido.

**Fluxo principal (painel web):**
1. O usuário informa e-mail e senha.
2. O sistema valida as credenciais.
3. O sistema gera e envia um código OTP por e-mail.
4. O usuário informa o código OTP recebido.
5. O sistema valida o OTP e emite um token de sessão.

**Fluxo principal (App mobile):**
1. O usuário informa e-mail e senha.
2. O sistema valida as credenciais e emite um token de sessão diretamente, sem OTP.

**Pós-condições:** O usuário fica autenticado e com sessão ativa.

**Exceções:** Credenciais inválidas; usuário inativo; OTP expirado; OTP inválido (não há bloqueio após tentativas repetidas — regra adotada, ver RN-AUT-003). No painel web, o login de não-administradores é rejeitado.

**Regras relacionadas:** RN-AUT-001, RN-AUT-002, RN-AUT-003, RN-AUT-004.

## RF-AUT-002 — Logout

**Descrição:** O usuário autenticado deve poder encerrar a sessão, invalidando o token no servidor.

**Atores:** Administrador, Gestor, Vendedor.

**Pré-condições:** Usuário autenticado.

**Fluxo principal:**
1. O usuário solicita logout.
2. O sistema invalida o token no servidor.
3. O cliente limpa o token local.

**Pós-condições:** Sessão encerrada; chamadas posteriores com o token antigo são rejeitadas.

**Exceções:** Token já expirado (tratado como sucesso).

**Regras relacionadas:** RN-AUT-005.

## RF-AUT-003 — Recuperação de senha via OTP

**Descrição:** O usuário que esqueceu a senha deve poder redefini-la via OTP enviado por e-mail.

**Atores:** Administrador, Gestor, Vendedor.

**Pré-condições:** O usuário informa um e-mail cadastrado.

**Fluxo principal:**
1. O usuário solicita recuperação informando o e-mail.
2. O sistema envia um OTP de recuperação por e-mail.
3. O usuário informa o OTP e a nova senha (com confirmação).
4. O sistema valida o OTP e atualiza a senha.

**Pós-condições:** A senha é atualizada; o usuário pode logar com a nova senha.

**Exceções:** E-mail não cadastrado; OTP expirado; OTP inválido (não há bloqueio após tentativas repetidas — regra adotada, ver RN-AUT-003); nova senha não atende à política.

**Regras relacionadas:** RN-AUT-006, RN-AUT-007.

## RF-AUT-004 — Validação de sessão

**Descrição:** O cliente deve poder validar se a sessão atual ainda é válida no servidor.

**Atores:** Aplicação cliente (App e painel).

**Pré-condições:** Existe um token armazenado.

**Fluxo principal:**
1. O cliente envia o token ao serviço de validação.
2. O servidor verifica a validade (assinatura, expiração, não revogado).
3. O servidor retorna se a sessão é válida.

**Pós-condições:** O cliente sabe se deve manter ou encerrar a sessão.

**Exceções:** Token expirado ou revogado (sessão inválida).

**Regras relacionadas:** RN-AUT-005, RN-AUT-008.

## RF-REG-001 — Verificar empresa por CNPJ/CPF

**Descrição:** O visitante deve poder buscar uma empresa parceira pelo CNPJ (ou CPF, se pessoa física) para iniciar o auto-cadastro.

**Atores:** Visitante.

**Pré-condições:** O documento informado está normalizado (apenas dígitos).

**Fluxo principal:**
1. O visitante informa o documento.
2. O sistema normaliza e consulta empresas ativas pelo documento.
3. Se encontrada, o sistema retorna os dados públicos da empresa.

**Pós-condições:** O visitante pode prosseguir para o cadastro se a empresa estiver ativa.

**Exceções:** Documento não encontrado; empresa inativa (não pode prosseguir).

**Regras relacionadas:** RN-REG-001, RN-PAR-001.

## RF-REG-002 — Auto-cadastro de vendedor

**Descrição:** O visitante deve poder cadastrar-se como vendedor vinculado a uma empresa parceira ativa.

**Atores:** Visitante.

**Pré-condições:** A empresa foi encontrada e está ativa (RF-REG-001).

**Fluxo principal:**
1. O visitante informa nome, e-mail, telefone e senha.
2. O sistema valida os dados.
3. O sistema cria o usuário com papel de vendedor, vinculado à empresa, com status pendente.
4. O gestor da empresa aprova posteriormente (ativa o usuário).

**Pós-condições:** O usuário é criado, mas permanece inativo até aprovação do gestor.

**Exceções:** E-mail já cadastrado; senha fora da política; empresa inativa.

**Regras relacionadas:** RN-REG-002, RN-USR-001, RN-USR-002.

## RF-PRO-001 — Solicitar parceria (prospecção)

**Descrição:** O visitante deve poder registrar interesse em tornar-se parceiro da Multimídia.

**Atores:** Visitante.

**Pré-condições:** Nenhuma.

**Fluxo principal:**
1. O visitante informa nome, e-mail e telefone (obrigatórios); empresa, CNPJ e experiência em vendas públicas (opcionais).
2. O sistema cria o registro de prospecção.
3. O administrador entra em contato posteriormente.

**Pós-condições:** O registro de prospecção fica disponível para o administrador gerenciar.

**Exceções:** Campos obrigatórios ausentes.

**Regras relacionadas:** RN-PRO-001.

## RF-USR-001 — Listar usuários

**Descrição:** O administrador deve poder listar usuários (com filtros por parceiro, papel e busca); o gestor deve poder listar vendedores da própria empresa.

**Atores:** Administrador, Gestor.

**Pré-condições:** Autenticado.

**Fluxo principal:**
1. O ator acessa a listagem.
2. O sistema retorna usuários paginados (admin: todos; gestor: apenas da própria empresa).
3. O ator pode filtrar por parceiro (admin), papel e busca textual.

**Pós-condições:** O ator visualiza a lista de usuários.

**Exceções:** Sem permissão.

**Regras relacionadas:** RN-USR-003, RN-USR-004.

## RF-USR-002 — Criar usuário

**Descrição:** O administrador deve poder criar um usuário vinculado a um parceiro e papel; o sistema deve poder gerar credenciais temporárias e enviá-las por e-mail ou disponibilizá-las em PDF.

**Atores:** Administrador.

**Pré-condições:** Autenticado como administrador.

**Fluxo principal:**
1. O administrador informa nome, e-mail, telefone, empresa, papel e status.
2. O sistema valida os dados.
3. O sistema cria o usuário.
4. Opcionalmente, o sistema gera senha temporária, envia por e-mail e/ou disponibiliza PDF de credenciais.

**Pós-condições:** O usuário é criado.

**Exceções:** E-mail duplicado; empresa inexistente; papel inválido; telefone inválido.

**Regras relacionadas:** RN-USR-005, RN-USR-006.

## RF-USR-003 — Editar usuário

**Descrição:** O administrador deve poder editar dados de qualquer usuário; o gestor não edita usuários pelo painel (gerencia vendedores pelo App).

**Atores:** Administrador.

**Pré-condições:** Usuário existe.

**Fluxo principal:**
1. O administrador altera nome, e-mail, telefone, empresa, papel ou status.
2. O sistema valida e atualiza.

**Pós-condições:** O usuário é atualizado.

**Exceções:** E-mail duplicado; empresa inexistente; auto-edição bloqueada em lote.

**Regras relacionadas:** RN-USR-007.

## RF-USR-004 — Atualizar usuários em lote

**Descrição:** O gestor deve poder alterar status e papel de múltiplos vendedores da própria empresa em uma única operação.

**Atores:** Gestor.

**Pré-condições:** Autenticado como gestor; usuários pertencem à própria empresa.

**Fluxo principal:**
1. O gestor marca alterações de status e/ou papel para um ou mais vendedores.
2. O sistema envia o lote.
3. O sistema aplica cada alteração individualmente e retorna sucessos e falhas.

**Pós-condições:** Cada alteração bem-sucedida é persistida; falhas são reportadas.

**Exceções:** Auto-edição bloqueada; papel fora do conjunto permitido (vendedor/gestor); usuário não pertence à empresa.

**Regras relacionadas:** RN-USR-008, RN-USR-009, RN-USR-010.

## RF-USR-005 — Gerir papéis e capacidades

**Descrição:** O administrador deve poder criar, editar e excluir papéis, e anexar/desanexar capacidades (permissões) a cada papel.

**Atores:** Administrador.

**Pré-condições:** Autenticado como administrador.

**Fluxo principal:**
1. O administrador acessa a gestão de papéis.
2. Pode criar/editar/excluir papéis e marcar/desmarcar capacidades.
3. O sistema sincroniza as capacidades do papel.

**Pós-condições:** Os papéis e capacidades são atualizados.

**Exceções:** Nome de papel duplicado; capacidade inexistente.

**Regras relacionadas:** RN-USR-011.

## RF-USR-006 — Excluir a própria conta

**Descrição:** Qualquer usuário deve poder excluir (logicamente) a própria conta.

**Atores:** Administrador, Gestor, Vendedor.

**Pré-condições:** Autenticado.

**Fluxo principal:**
1. O usuário solicita a exclusão da conta.
2. O sistema marca o usuário como excluído (exclusão lógica).

**Pós-condições:** O usuário não pode mais autenticar-se.

**Exceções:** Nenhuma.

**Regras relacionadas:** RN-USR-012.

## RF-PAR-001 — Listar parceiros

**Descrição:** O administrador deve poder listar empresas parceiras com filtros e ordenação; o gestor visualiza apenas a própria empresa.

**Atores:** Administrador, Gestor (somente própria).

**Pré-condições:** Autenticado.

**Fluxo principal:**
1. O ator acessa a listagem.
2. O sistema retorna parceiros paginados (admin: todos; gestor: apenas o próprio).
3. O admin pode filtrar por busca textual e ordenar por campos definidos.

**Pós-condições:** O ator visualiza a lista de parceiros.

**Exceções:** Sem permissão.

**Regras relacionadas:** RN-PAR-002.

## RF-PAR-002 — Criar parceiro

**Descrição:** O administrador deve poder criar uma empresa parceira, com gestor responsável e usuários adicionais opcionais.

**Atores:** Administrador.

**Pré-condições:** Autenticado como administrador.

**Fluxo principal:**
1. O administrador informa dados da empresa (nome, nome fantasia, CNPJ, e-mail, telefone, status, URL opcional).
2. O administrador informa o gestor responsável (nome, e-mail, telefone, papel).
3. Opcionalmente, adiciona vendedores adicionais.
4. O sistema cria a empresa e os usuários em transação.
5. Opcionalmente, envia credenciais por e-mail e/ou gera PDF de acessos.
6. Após criação, faz upload de logo e contrato (se fornecidos).

**Pós-condições:** A empresa e os usuários são criados.

**Exceções:** CNPJ duplicado; e-mail de gestor duplicado; falha em uploads de logo/contrato não desfaz a criação.

**Regras relacionadas:** RN-PAR-003, RN-PAR-004, RN-USR-005.

## RF-PAR-003 — Editar parceiro

**Descrição:** O administrador deve poder editar dados de qualquer parceiro; o gestor deve poder editar dados da própria empresa.

**Atores:** Administrador, Gestor (somente própria).

**Pré-condições:** Parceiro existe.

**Fluxo principal:**
1. O ator altera os dados (nome, nome fantasia, CNPJ, e-mail, telefone, URL, status).
2. O sistema valida e atualiza.

**Pós-condições:** O parceiro é atualizado.

**Exceções:** CNPJ duplicado; gestor não pode alterar status da própria empresa.

**Regras relacionadas:** RN-PAR-005, RN-PAR-006.

## RF-PAR-004 — Desativar/ativar parceiro

**Descrição:** O administrador deve poder ativar ou desativar um parceiro (e seus usuários em cascata).

**Atores:** Administrador.

**Pré-condições:** Parceiro existe.

**Fluxo principal:**
1. O administrador alterna o status do parceiro.
2. O sistema inverte o status e propaga para os usuários.

**Pós-condições:** O parceiro (e usuários) mudam de status.

**Exceções:** Não há exclusão física.

**Regras relacionadas:** RN-PAR-007.

## RF-PAR-005 — Upload de logo do parceiro

**Descrição:** O gestor deve poder fazer upload da logo da própria empresa; o administrador pode fazer upload da logo de qualquer parceiro.

**Atores:** Administrador, Gestor.

**Pré-condições:** Parceiro existe.

**Fluxo principal:**
1. O ator seleciona uma imagem.
2. O sistema valida MIME e tamanho.
3. O sistema armazena a logo.

**Pós-condições:** A logo do parceiro é atualizada.

**Exceções:** MIME inválido; tamanho excedido.

**Regras relacionadas:** RN-PAR-008.

## RF-PAR-006 — Visualizar/baixar contrato do parceiro

**Descrição:** O gestor deve poder visualizar e baixar o contrato da própria empresa; o administrador pode gerenciar o contrato de qualquer parceiro.

**Atores:** Administrador, Gestor.

**Pré-condições:** Contrato existe.

**Fluxo principal:**
1. O ator solicita a visualização/download do contrato.
2. O sistema retorna o arquivo PDF.

**Pós-condições:** O ator obtém o contrato.

**Exceções:** Contrato inexistente.

**Regras relacionadas:** RN-PAR-009.

## RF-ORC-001 — Criar orçamento (cidade única)

**Descrição:** O vendedor/gestor deve poder criar um orçamento para uma cidade específica, com base no Censo Escolar do município.

**Atores:** Vendedor, Gestor, Administrador.

**Pré-condições:** Cidade existe e possui censo; usuário autenticado.

**Fluxo principal:**
1. O usuário seleciona a cidade (ou o admin seleciona o parceiro destino e a cidade).
2. O sistema cria um rascunho de orçamento.
3. O sistema copia os valores do Censo Escolar do município para o orçamento (snapshot independente).
4. O usuário seleciona produtos e indicadores.
5. O sistema calcula as quantidades e o total.
6. O usuário define a validade e salva (status passa a pendente).

**Pós-condições:** O orçamento é criado com status pendente, com snapshot do censo e produtos selecionados.

**Exceções:** Validade inválida; total menor ou igual a zero (bloqueado pelo App, mas aceito pela API — ver §9.4); cidade sem censo e nenhum produto selecionado (não enforceados na API — ver §9.4 e §24.3).

**Regras relacionadas:** RN-ORC-001, RN-ORC-002, RN-CEN-001, RN-CEN-002.

## RF-ORC-002 — Criar orçamento multi-cidade

**Descrição:** O vendedor/gestor deve poder criar um orçamento que abranja múltiplas cidades, com censo agregado.

**Atores:** Vendedor, Gestor, Administrador.

**Pré-condições:** Múltiplas cidades selecionadas, cada uma com censo.

**Fluxo principal:**
1. O usuário seleciona múltiplas cidades.
2. O sistema busca o censo de cada cidade.
3. O sistema cria o orçamento multi-cidade com censo agregado (soma por etapa).
4. O usuário seleciona produtos e indicadores.
5. O sistema calcula quantidades com base no censo agregado.

**Pós-condições:** O orçamento multi-cidade é criado com censo agregado.

**Exceções:** Lista de cidades vazia; validade inválida.

**Regras relacionadas:** RN-ORC-003, RN-CEN-003.

## RF-ORC-003 — Criar orçamento personalizado (sem município)

**Status:** Planejado para uma próxima versão; fluxo ainda indisponível no App atual.

**Descrição:** O vendedor/gestor deve poder criar um orçamento personalizado sem vinculação a um município específico, inserindo manualmente os valores do censo.

**Atores:** Vendedor, Gestor, Administrador.

**Pré-condições:** Usuário autenticado.

**Fluxo principal:**
1. O usuário opta por orçamento personalizado.
2. O usuário informa manualmente os valores dos indicadores.
3. O sistema cria o orçamento sem cidade vinculada.
4. O usuário seleciona produtos e indicadores.
5. O sistema calcula as quantidades.

**Pós-condições:** O orçamento personalizado é criado com valores manuais de censo.

**Exceções:** Valores inválidos.

**Regras relacionadas:** RN-ORC-004.

## RF-ORC-004 — Editar orçamento

**Descrição:** O dono, um administrador ou um gestor da mesma empresa deve poder editar um orçamento existente.

**Atores:** Vendedor (próprio), Gestor (empresa), Administrador (qualquer).

**Pré-condições:** Orçamento existe; usuário tem permissão. O status `aprovado` não torna o orçamento somente leitura e não bloqueia a edição.

**Fluxo principal:**
1. O usuário abre o orçamento para edição.
2. Altera produtos, indicadores, quantidades manuais, validade ou status.
3. O sistema recalcula quantidades e total.
4. O sistema persiste as alterações.

**Pós-condições:** O orçamento é atualizado.

**Exceções:** Sem permissão; validade inválida; total negativo.

**Regras relacionadas:** RN-ORC-005, RN-ORC-006.

## RF-ORC-005 — Versionar orçamento

**Descrição:** O usuário deve poder criar uma nova versão de um orçamento, preservando o original arquivado.

**Atores:** Vendedor (próprio), Gestor (empresa), Administrador.

**Pré-condições:** Orçamento existe; usuário tem permissão.

**Fluxo principal:**
1. O usuário solicita o versionamento.
2. O sistema arquiva o original.
3. O sistema cria uma nova versão vinculada ao original (origem).
4. O sistema copia produtos, quantidades, valores e preserva overrides de preço.
5. O sistema recalcula o total da nova versão.

**Pós-condições:** O original fica arquivado; a nova versão fica ativa.

**Exceções:** Sem permissão.

**Regras relacionadas:** RN-ORC-007, RN-ORC-008.

## RF-ORC-006 — Arquivar/desarquivar orçamento

**Descrição:** O usuário deve poder arquivar e desarquivar orçamentos (ação independente do status).

**Atores:** Vendedor (próprio), Gestor (empresa), Administrador.

**Pré-condições:** Orçamento existe; usuário tem permissão.

**Fluxo principal:**
1. O usuário solicita arquivar ou desarquivar.
2. O sistema inverte o flag de arquivamento.

**Pós-condições:** O orçamento muda de estado de arquivamento (sem alterar status).

**Exceções:** Sem permissão.

**Regras relacionadas:** RN-ORC-009.

## RF-ORC-007 — Renomear orçamento

**Descrição:** O usuário deve poder renomear um orçamento próprio (ou da empresa, se gestor/admin).

**Atores:** Vendedor (próprio), Gestor (empresa), Administrador.

**Pré-condições:** Orçamento existe; novo nome com 1 a 255 caracteres. Nomes iguais ao atual **não** são rejeitados — a operação retorna sucesso sem mudança (ver RN-ORC-010).

**Fluxo principal:**
1. O usuário informa o novo nome.
2. O sistema valida e atualiza.

**Pós-condições:** O nome do orçamento é atualizado.

**Exceções:** Nome vazio; nome maior que 255 caracteres.

**Regras relacionadas:** RN-ORC-010.

## RF-ORC-008 — Definir quantidade manual

**Descrição:** O usuário deve poder sobrescrever a quantidade calculada de um produto informando uma quantidade manual.

**Atores:** Vendedor, Gestor, Administrador.

**Pré-condições:** Produto está no orçamento.

**Fluxo principal:**
1. O usuário ativa o modo manual do produto.
2. O usuário informa a quantidade desejada.
3. O sistema ignora o cálculo automático e usa a quantidade manual.
4. Ao desativar o modo manual, o sistema recalcula automaticamente.

**Pós-condições:** A quantidade do produto passa a ser a manual (ou recalculada, se desativado).

**Exceções:** Nenhuma.

**Regras relacionadas:** RN-ORC-011.

## RF-ORC-009 — Gerar PDF do orçamento

**Descrição:** O usuário deve poder gerar um PDF do orçamento com identidade visual do parceiro.

**Atores:** Vendedor, Gestor, Administrador.

**Pré-condições:** Orçamento existe; dados do vendedor (nome, cargo, telefone, e-mail) preenchidos.

**Fluxo principal:**
1. O usuário solicita a geração do PDF.
2. O sistema valida os dados do vendedor.
3. O sistema gera o PDF com logo do parceiro, dados do vendedor, produtos, quantidades, valores e totais.
4. O sistema renova a validade pelo prazo salvo em `orc_dias_validade`, contado a partir da operação; somente `expirado` passa a `pendente` (ver RN-ORC-013).

**Pós-condições:** O PDF é gerado e disponibilizado.

**Exceções:** Dados do vendedor incompletos; orçamento inválido.

**Regras relacionadas:** RN-ORC-012, RN-ORC-013.

## RF-ORC-010 — Exportar censo em CSV

**Descrição:** O usuário deve poder exportar os valores do censo do orçamento em CSV.

**Atores:** Vendedor, Gestor, Administrador.

**Pré-condições:** Orçamento existe com censo.

**Fluxo principal:**
1. O usuário solicita a exportação do censo.
2. O sistema gera um CSV com os indicadores e valores.

**Pós-condições:** O CSV é gerado.

**Exceções:** Orçamento sem censo.

**Regras relacionadas:** RN-ORC-014.

## RF-ORC-011 — Listar orçamentos

**Descrição:** O usuário deve poder listar orçamentos conforme seu perfil (próprios; da empresa; todos).

**Atores:** Vendedor, Gestor, Administrador.

**Pré-condições:** Autenticado.

**Fluxo principal:**
1. O usuário acessa a listagem.
2. O sistema retorna orçamentos paginados conforme perfil.
3. O usuário pode filtrar por status, arquivamento, data e busca.

**Pós-condições:** O usuário visualiza a lista.

**Exceções:** Sem permissão.

**Regras relacionadas:** RN-ORC-015.

## RF-CEN-001 — Visualizar censo de uma cidade

**Descrição:** O usuário deve poder visualizar os indicadores do Censo Escolar de uma cidade.

**Atores:** Vendedor, Gestor, Administrador.

**Pré-condições:** Cidade existe e possui censo.

**Fluxo principal:**
1. O usuário seleciona a cidade.
2. O sistema retorna os indicadores de etapa e seus valores.

**Pós-condições:** O usuário visualiza o censo.

**Exceções:** Cidade sem censo.

**Regras relacionadas:** RN-CEN-001.

## RF-CEN-002 — Editar valores do censo (snapshot do orçamento)

**Descrição:** O usuário deve poder editar os valores do censo dentro de um orçamento, sem alterar o censo oficial da cidade.

**Atores:** Vendedor, Gestor, Administrador.

**Pré-condições:** Orçamento existe com snapshot de censo.

**Fluxo principal:**
1. O usuário abre o censo do orçamento.
2. Altera valores de indicadores.
3. O sistema atualiza apenas o snapshot do orçamento.
4. O sistema recalcula quantidades afetadas.

**Pós-condições:** O snapshot do orçamento é atualizado; o censo oficial da cidade permanece inalterado.

**Exceções:** Nenhuma.

**Regras relacionadas:** RN-CEN-002, RN-ORC-002.

## RF-CEN-003 — Gerir grupos de censo e índices de etapa

**Descrição:** O administrador deve poder criar/editar/excluir grupos de censo e índices de etapa, com ordenação e percentual de população.

**Atores:** Administrador.

**Pré-condições:** Autenticado como administrador.

**Fluxo principal:**
1. O admin acessa a gestão de censo.
2. Cria/edita/exclui grupos e índices.
3. Define ordenação, valor padrão e percentual de população.

**Pós-condições:** Os grupos e índices são atualizados.

**Exceções:** Nome duplicado; exclusão com dependentes.

**Regras relacionadas:** RN-CEN-004, RN-CEN-005.

## RF-CEN-004 — Atualizar população IBGE

**Descrição:** O administrador deve poder disparar a atualização da população IBGE das cidades com base em um índice de etapa e percentual.

**Atores:** Administrador.

**Pré-condições:** Autenticado como administrador; índice e percentual selecionados.

**Fluxo principal:**
1. O admin seleciona um índice de etapa e um percentual.
2. O sistema dispara a atualização assíncrona (stream NDJSON).
3. O sistema reporta progresso por cidade.
4. Ao concluir, o sistema atualiza a população das cidades.

**Pós-condições:** A população IBGE das cidades é atualizada.

**Exceções:** Erro parcial em algumas cidades (reportado, mas não aborta o todo); HTTP 200 não garante sucesso total.

**Regras relacionadas:** RN-CEN-006, RN-CEN-007.

## RF-CAT-001 — Gerir categorias

**Descrição:** O administrador deve poder criar, editar, ativar/desativar e excluir categorias de produtos, com ordenação.

**Atores:** Administrador.

**Pré-condições:** Autenticado como administrador.

**Fluxo principal:**
1. O admin cria/edita a categoria (nome, status, ordenação).
2. O sistema valida e persiste.

**Pós-condições:** A categoria é atualizada.

**Exceções:** Nome duplicado.

**Regras relacionadas:** RN-CAT-001, RN-CAT-002.

## RF-CAT-002 — Gerir subcategorias

**Descrição:** O administrador deve poder criar, editar, ativar/desativar e excluir subcategorias, vinculadas a uma categoria.

**Atores:** Administrador.

**Pré-condições:** Categoria existe.

**Fluxo principal:**
1. O admin cria/edita a subcategoria (nome, categoria, status, ordenação).
2. O sistema valida e persiste.

**Pós-condições:** A subcategoria é atualizada.

**Exceções:** Nome duplicado; categoria inexistente.

**Regras relacionadas:** RN-CAT-003.

## RF-CAT-003 — Gerir produtos

**Descrição:** O administrador deve poder criar, editar, ativar/desativar e excluir produtos (livros, tecnologias, serviços), com indicadores, diferenciais, produtos relacionados (para serviços), valor, percentual e horas fixas.

**Atores:** Administrador.

**Pré-condições:** Subcategoria existe.

**Fluxo principal:**
1. O admin cria/edita o produto (nome, tipo, subcategoria, valor, percentual, horas fixas, ISBN para livros, indicadores, diferenciais, produtos relacionados para serviços).
2. O sistema valida (ISBN obrigatório para livros; serviços exigem produtos relacionados, percentual de 0 a 100, horas fixas ≥ 0).
3. O sistema persiste.

**Pós-condições:** O produto é atualizado.

**Exceções:** ISBN ausente para livro; serviço sem produtos relacionados; percentual inválido.

**Regras relacionadas:** RN-CAT-004, RN-CAT-005, RN-CAT-006.

## RF-CAT-004 — Reordenar catálogo

**Descrição:** O administrador deve poder reordenar categorias, subcategorias e produtos por arrastar e soltar.

**Atores:** Administrador.

**Pré-condições:** Autenticado.

**Fluxo principal:**
1. O admin arrasta um item para nova posição.
2. O sistema calcula a nova ordem (ponto médio entre vizinhos).
3. O sistema persiste a ordenação.

**Pós-condições:** A ordenação é atualizada.

**Exceções:** IDs inválidos.

**Regras relacionadas:** RN-CAT-007.

## RF-CAT-005 — Desativar/ativar produto

**Descrição:** O administrador deve poder ativar ou desativar um produto (sem excluir).

**Atores:** Administrador.

**Pré-condições:** Produto existe.

**Fluxo principal:**
1. O admin alterna o status do produto.
2. O sistema atualiza o status.

**Pós-condições:** O produto muda de status.

**Exceções:** Nenhuma.

**Regras relacionadas:** RN-CAT-008.

## RF-DRV-001 — Listar arquivos do Drive

**Descrição:** O usuário deve poder listar arquivos e pastas do Drive (próprios e compartilhados).

**Atores:** Administrador, Gestor, Vendedor.

**Pré-condições:** Autenticado.

**Fluxo principal:**
1. O usuário acessa o Drive.
2. O sistema retorna itens recentes, próprios e compartilhados.
3. O usuário pode navegar em pastas.

**Pós-condições:** O usuário visualiza os arquivos.

**Exceções:** Sem permissão.

**Regras relacionadas:** RN-DRV-001.

## RF-DRV-002 — Criar pasta/arquivo no Drive

**Descrição:** O administrador deve poder criar pastas e fazer upload de arquivos no Drive.

**Atores:** Administrador.

**Pré-condições:** Autenticado como administrador.

**Fluxo principal:**
1. O admin cria uma pasta ou seleciona um arquivo para upload.
2. O sistema valida MIME e tamanho.
3. O sistema armazena o arquivo (upload direto ou assíncrono em duas fases).

**Pós-condições:** A pasta ou arquivo é criado.

**Exceções:** MIME inválido; tamanho excedido; profundidade máxima excedida.

**Regras relacionadas:** RN-DRV-002, RN-DRV-003.

## RF-DRV-003 — Download/visualizar arquivo

**Descrição:** O usuário deve poder baixar e visualizar arquivos do Drive (com streaming para vídeos e áudio).

**Atores:** Administrador, Gestor, Vendedor.

**Pré-condições:** Tem acesso ao arquivo.

**Fluxo principal:**
1. O usuário solicita download ou visualização.
2. O sistema retorna o arquivo (ou stream, com suporte a Range).

**Pós-condições:** O usuário obtém/visualiza o arquivo.

**Exceções:** Arquivo inexistente; sem permissão; tipo não suportado para visualização.

**Regras relacionadas:** RN-DRV-004.

## RF-DRV-004 — Compartilhar arquivo/pasta

**Descrição:** O dono (ou administrador) deve poder compartilhar um arquivo ou pasta com outro usuário, com permissão de leitura.

**Atores:** Administrador (dono ou admin).

**Pré-condições:** Item existe; destinatário existe e não está excluído; não é o próprio dono.

**Fluxo principal:**
1. O dono seleciona o destinatário.
2. O sistema cria o compartilhamento com permissão de leitura.
3. Para pastas, o compartilhamento é recursivo.

**Pós-condições:** O destinatário passa a ter acesso de leitura ao item.

**Exceções:** Compartilhamento duplicado; destinatário inexistente; auto-compartilhamento.

**Regras relacionadas:** RN-DRV-005.

## RF-DRV-005 — Gerir compartilhamentos

**Descrição:** O dono (ou administrador) deve poder listar e remover compartilhamentos de um item.

**Atores:** Administrador (dono ou admin).

**Pré-condições:** Item existe.

**Fluxo principal:**
1. O dono lista os compartilhamentos do item.
2. Seleciona um ou mais para remover.
3. O sistema remove em lote e reporta sucessos/falhas.

**Pós-condições:** Os compartilhamentos selecionados são removidos.

**Exceções:** Item não compartilhado.

**Regras relacionadas:** RN-DRV-006.

## RF-DRV-006 — Mover/renomear/excluir item

**Descrição:** O dono (ou administrador) deve poder mover, renomear e excluir itens do Drive.

**Atores:** Administrador (dono ou admin).

**Pré-condições:** Item existe; permissão de escrita.

**Fluxo principal:**
1. O dono move/renomea/exclui o item.
2. O sistema valida hierarquia (sem ciclos, profundidade máxima) e permissão.
3. O sistema persiste.

**Pós-condições:** O item é movido/renomeado/excluído.

**Exceções:** Sem permissão; hierarquia inválida; profundidade excedida.

**Regras relacionadas:** RN-DRV-007, RN-DRV-008.

## RF-DRV-007 — Definir capa de vídeo

**Descrição:** O dono (ou administrador) deve poder definir uma imagem de capa para um vídeo.

**Atores:** Administrador (dono ou admin).

**Pré-condições:** Item é um vídeo.

**Fluxo principal:**
1. O dono seleciona uma imagem.
2. O sistema valida MIME e tamanho.
3. O sistema define a capa como padrão.

**Pós-condições:** A capa do vídeo é atualizada.

**Exceções:** Item não é vídeo; MIME inválido.

**Regras relacionadas:** RN-DRV-009.

## RF-REL-001 — Relatório de vendas por parceiro

**Descrição:** O administrador deve poder visualizar vendas por parceiro em um período, com gráfico mensal.

**Atores:** Administrador.

**Pré-condições:** Autenticado.

**Fluxo principal:**
1. O admin seleciona o período.
2. O sistema retorna vendas agregadas por parceiro e por mês.

**Pós-condições:** O admin visualiza o relatório.

**Exceções:** Período inválido.

**Regras relacionadas:** RN-REL-001.

## RF-REL-002 — Relatório de orçamentos por vendedor

**Descrição:** O administrador deve poder visualizar orçamentos por vendedor, com filtros por status, arquivamento, data e localização.

**Atores:** Administrador.

**Pré-condições:** Autenticado.

**Fluxo principal:**
1. O admin seleciona o parceiro e o vendedor.
2. O sistema retorna orçamentos do vendedor.
3. O admin pode filtrar por status, arquivamento, data e localização.

**Pós-condições:** O admin visualiza o relatório.

**Exceções:** Sem permissão.

**Regras relacionadas:** RN-REL-002.

## RF-REL-003 — Histórico de versões de orçamento

**Descrição:** O administrador deve poder visualizar o histórico de versões de um orçamento.

**Atores:** Administrador.

**Pré-condições:** Orçamento existe.

**Fluxo principal:**
1. O admin abre o orçamento.
2. O sistema lista as versões anteriores (arquivadas).

**Pós-condições:** O admin visualiza o histórico.

**Exceções:** Sem versões.

**Regras relacionadas:** RN-REL-003.

## RF-DSH-001 — Visualizar dashboard

**Descrição:** O administrador deve poder visualizar um dashboard com vendas por período, orçamentos por status e arquivos recentes.

**Atores:** Administrador.

**Pré-condições:** Autenticado.

**Fluxo principal:**
1. O admin acessa o dashboard.
2. O sistema retorna vendas por período, contagem por status e arquivos recentes.

**Pós-condições:** O admin visualiza o dashboard.

**Exceções:** Nenhuma.

**Regras relacionadas:** RN-DSH-001.

## RF-PRF-001 — Editar perfil próprio

**Descrição:** O usuário deve poder editar seu perfil (nome, e-mail, telefone, cargo, avatar).

**Atores:** Administrador, Gestor, Vendedor.

**Pré-condições:** Autenticado.

**Fluxo principal:**
1. O usuário altera seus dados.
2. O sistema valida e atualiza.

**Pós-condições:** O perfil é atualizado.

**Exceções:** E-mail duplicado; telefone inválido.

**Regras relacionadas:** RN-PRF-001.

## RF-PRF-002 — Upload de avatar

**Descrição:** O usuário deve poder fazer upload do próprio avatar.

**Atores:** Administrador, Gestor, Vendedor.

**Pré-condições:** Autenticado.

**Fluxo principal:**
1. O usuário seleciona uma imagem.
2. O sistema valida MIME e tamanho.
3. O sistema armazena o avatar.

**Pós-condições:** O avatar é atualizado.

**Exceções:** MIME inválido; tamanho excedido.

**Regras relacionadas:** RN-PRF-002.

## RF-WIK-001 — Acessar wiki/ajuda

**Descrição:** O usuário deve poder acessar conteúdo de ajuda estático no App.

**Atores:** Administrador, Gestor, Vendedor.

**Pré-condições:** Autenticado.

**Fluxo principal:**
1. O usuário acessa a wiki.
2. O sistema exibe conteúdo estático com itens expansíveis.

**Pós-condições:** O usuário visualiza a ajuda.

**Exceções:** Nenhuma.

**Regras relacionadas:** RN-WIK-001.

---

# 7. Regras de Negócio

> Identificadores seguem o padrão **RN-\<DOMÍNIO\>-NNN**. Cada regra traz enunciado, aplicação, exemplo, exceções e requisitos relacionados.

## RN-AUT-001 — OTP de autenticação por e-mail

**Regra:** O OTP é exigido **somente no painel web** (decidido em 10/09/2026). Como o painel é exclusivo do administrador, na prática o OTP de login aplica-se apenas a administradores. **No App, todos os perfis — inclusive o Administrador — autenticam-se apenas com e-mail e senha**, e nenhuma correção no fluxo de OTP deve passar a exigir OTP no App.

**Aplicação:** Painel administrativo (web); o App é explicitamente isento.

**Exemplo:** Um administrador informa e-mail e senha no painel; recebe um código de 6 dígitos por e-mail; digita o código e conclui o login. O mesmo administrador, entrando pelo App, conclui o login apenas com e-mail e senha.

**Exceções:** Falha no envio do e-mail; OTP expirado.

**Risco técnico aceito:** a distinção entre os canais é feita pelo `User-Agent` do App (`App-Orcamentos-V1`). O cabeçalho pode ser imitado, o que permitiria dispensar o OTP em um cliente que se faça passar pelo App. Decidido em 10/09/2026 que isso é aceitável por enquanto; deve ser reavaliado se o modelo de ameaça ou os requisitos de segurança mudarem.

**Requisitos relacionados:** RF-AUT-001.

## RN-AUT-002 — Expiração do OTP

**Regra:** O OTP tem prazo de expiração configurável; após expirar, o usuário deve solicitar reenvio.

**Aplicação:** Autenticação e recuperação de senha.

**Exemplo:** OTP expira em 5 minutos; o usuário digita após esse prazo e recebe "Código expirado".

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-AUT-001, RF-AUT-003.

## RN-AUT-003 — Tentativas máximas de OTP

**Regra:** **Não há limite de tentativas inválidas de OTP** (decidido em 10/09/2026, após confronto com o App). O OTP permanece válido até ser acertado ou expirar em 5 minutos; tentativas inválidas não o invalidam nem bloqueiam o usuário. O único controle existente no App é um **cooldown de 60 segundos para reenviar** o código, que não limita as tentativas de validação. A previsão de "tentativas máximas" da documentação funcional original é uma **regra superada**.

**Aplicação:** Autenticação e recuperação de senha.

**Exemplo:** Um usuário pode tentar códigos inválidos repetidamente até o OTP expirar (5 minutos); não há bloqueio antecipado.

**Risco técnico aceito:** a ausência de limite permite tentativas de força bruta durante a janela de 5 minutos. O risco é conhecido e aceito por enquanto; sua mitigação é decisão futura de negócio.

**Lacuna de implementação:** a coluna `otp_attempts` existe no banco (criada como `integer`), mas é castada como `boolean` no model, inicializada com `true` e nunca incrementada. É um campo não funcional: ou passa a ter uso, ou deve ser removido.

**Requisitos relacionados:** RF-AUT-001, RF-AUT-003.

## RN-AUT-004 — Token de sessão

**Regra:** A sessão é baseada em token JWT com expiração; o token deve ser validado no servidor a cada requisição autenticada.

**Aplicação:** Todas as requisições autenticadas.

**Exemplo:** O cliente envia o token; o servidor valida assinatura, expiração e revogação.

**Exceções:** Token expirado ou revogado.

**Requisitos relacionados:** RF-AUT-001, RF-AUT-004.

## RN-AUT-005 — Logout invalida o token no servidor

**Regra:** O logout deve invalidar o token no servidor (não apenas no cliente), impedindo reuso.

**Aplicação:** Logout.

**Exemplo:** Após logout, chamadas com o token antigo recebem 401.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-AUT-002, RF-AUT-004.

## RN-AUT-006 — Recuperação de senha por OTP

**Regra:** A recuperação de senha exige OTP enviado por e-mail, validação do OTP e nova senha (com confirmação) que atenda à política.

**Aplicação:** Recuperação de senha.

**Exemplo:** Usuário informa e-mail, recebe OTP, digita OTP e nova senha; o sistema atualiza.

**Exceções:** E-mail não cadastrado; OTP inválido; nova senha fora da política.

**Requisitos relacionados:** RF-AUT-003.

## RN-AUT-007 — Política de senha

**Regra:** A nova senha na recuperação deve atender à política (mínimo de caracteres, maiúscula, caractere especial).

**Aplicação:** Recuperação de senha.

**Exemplo:** Senha "abc" é rejeitada; "Abc@1234" é aceita.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-AUT-003.

## RN-AUT-008 — Sessão expirada

**Regra:** Somente uma resposta **401 do webservice principal** encerra a sessão e redireciona ao login (decidido em 10/09/2026). Um 401 vindo do File Manager ou de outro serviço externo **não** deve deslogar o usuário automaticamente. O comportamento atual do interceptor do painel está alinhado com esta regra.

**Aplicação:** Cliente (App e painel).

**Exemplo:** Token expira durante uso; próxima chamada ao webservice principal recebe 401; o cliente desloga. Um 401 do File Manager exibe erro na operação, mas mantém a sessão.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-AUT-004.

## RN-REG-001 — Normalização de documento

**Regra:** O documento (CPF/CNPJ) deve ser normalizado (apenas dígitos) antes da consulta.

**Aplicação:** Verificação de empresa por documento.

**Exemplo:** "12.345.678/0001-90" vira "12345678000190".

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-REG-001.

## RN-REG-002 — Cadastro vinculado a empresa ativa

**Regra:** O auto-cadastro só prossegue se a empresa encontrada estiver ativa.

**Aplicação:** Auto-cadastro de vendedor.

**Exemplo:** Empresa inativa → cadastro bloqueado.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-REG-002, RN-PAR-001.

## RN-USR-001 — Usuário pendente aguarda aprovação

**Regra:** Usuários criados via auto-cadastro nascem com status pendente e não podem autenticar até o gestor aprovar (ativar).

**Aplicação:** Auto-cadastro.

**Exemplo:** Vendedor cadastra-se; fica inativo; gestor ativa; vendedor pode logar.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-REG-002.

## RN-USR-002 — E-mail único

**Regra:** O e-mail do usuário deve ser único no sistema.

**Aplicação:** Criação e edição de usuário.

**Exemplo:** Tentativa de criar usuário com e-mail existente é rejeitada.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-USR-002, RF-USR-003.

## RN-USR-003 — Gestor lista apenas vendedores da própria empresa

**Regra:** O gestor só pode listar usuários da própria empresa; o administrador lista todos.

**Aplicação:** Listagem de usuários.

**Exemplo:** Gestor da empresa A não vê usuários da empresa B.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-USR-001.

## RN-USR-004 — Listagem exclui o próprio usuário

**Regra:** A listagem de usuários não inclui o próprio usuário autenticado.

**Aplicação:** Listagem de usuários (App).

**Exemplo:** O gestor não se vê na lista de vendedores para gerenciar.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-USR-001.

## RN-USR-005 — Senha temporária opcional

**Regra:** Ao criar usuário (admin), a senha pode ser gerada temporariamente, enviada por e-mail ou baixada em PDF.

**Aplicação:** Criação de usuário.

**Exemplo:** Admin cria gestor e marca "enviar e-mail com credenciais"; o sistema envia senha temporária.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-USR-002.

## RN-USR-006 — Papel padrão no auto-cadastro

**Regra:** O auto-cadastro cria o usuário com papel de vendedor.

**Aplicação:** Auto-cadastro.

**Exemplo:** Visitante cadastra-se; vira vendedor pendente.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-REG-002.

## RN-USR-007 — Auto-edição bloqueada em lote

**Regra:** A atualização em lote de usuários não pode incluir o próprio usuário autenticado.

**Aplicação:** Atualização em lote (gestor).

**Exemplo:** Gestor não pode alterar o próprio status ou papel via lote.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-USR-004.

## RN-USR-008 — Lote aplica alterações individualmente

**Regra:** Cada alteração do lote é aplicada individualmente; sucessos e falhas são reportados separadamente.

**Aplicação:** Atualização em lote.

**Exemplo:** Lote com 3 alterações: 2 sucesso, 1 falha; o sistema reporta 2 sucesso e 1 falha.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-USR-004.

## RN-USR-009 — Papel limitado no lote

**Regra:** A alteração de papel em lote é limitada a vendedor ou gestor (não permite promover a administrador).

**Aplicação:** Atualização em lote (gestor).

**Exemplo:** Gestor não pode tornar um vendedor administrador.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-USR-004.

## RN-USR-010 — Usuário deve pertencer à empresa

**Regra:** A atualização em lote só aceita usuários da própria empresa do gestor.

**Aplicação:** Atualização em lote (gestor).

**Exemplo:** Gestor da empresa A não altera usuário da empresa B.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-USR-004.

## RN-USR-011 — Papéis e capacidades

**Regra:** O administrador gerencia papéis (roles) e capacidades (permissions); cada papel tem um conjunto de capacidades.

**Aplicação:** Gestão de papéis.

**Exemplo:** Admin cria papel "Vendedor Sênior" e marca capacidades de criar/editar orçamentos.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-USR-005.

## RN-USR-012 — Exclusão lógica de conta

**Regra:** A exclusão da própria conta é lógica (marca o usuário como excluído); o usuário não pode mais autenticar.

**Aplicação:** Exclusão de conta.

**Exemplo:** Vendedor exclui a conta; não consegue mais logar.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-USR-006.

## RN-PAR-001 — Parceiro ativo para novos orçamentos

**Regra:** Apenas parceiros ativos podem ser selecionados como destino de **novos** orçamentos. Os orçamentos **já existentes** de um parceiro inativo continuam acessíveis conforme as permissões normais (decidido em 10/09/2026): a inativação não oculta nem invalida o histórico. O bloqueio deve ser aplicado pelo backend **no momento da criação**, e não por filtragem do histórico.

**Aplicação:** Criação de orçamento (admin em nome de parceiro).

**Exemplo:** Parceiro inativo não aparece na lista de parceiros destino, mas seus orçamentos anteriores continuam visíveis e podem ser consultados e exportados.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-REG-001, RF-ORC-001.

## RN-PAR-002 — Gestor vê apenas a própria empresa

**Regra:** O gestor só visualiza e edita a própria empresa; o administrador gerencia todos.

**Aplicação:** Listagem e edição de parceiros.

**Exemplo:** Gestor não vê outras empresas na listagem.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-PAR-001, RF-PAR-003.

## RN-PAR-003 — Criação com gestor responsável

**Regra:** A criação de um parceiro exige um gestor responsável (nome, e-mail, telefone).

**Aplicação:** Criação de parceiro.

**Exemplo:** Admin cria empresa "X" e define "João" como gestor responsável.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-PAR-002.

## RN-PAR-004 — Criação em transação

**Regra:** A criação de parceiro e seus usuários (gestor e adicionais) é atômica (transação).

**Aplicação:** Criação de parceiro.

**Exemplo:** Se falha ao criar o gestor, a empresa não é criada.

**Exceções:** Falhas em uploads de logo/contrato não desfazem a criação.

**Requisitos relacionados:** RF-PAR-002.

## RN-PAR-005 — Gestor não altera status da própria empresa

**Regra:** O gestor não pode alterar o status da própria empresa (apenas o administrador).

**Aplicação:** Edição de parceiro.

**Exemplo:** Gestor não desativa a própria empresa.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-PAR-003.

## RN-PAR-006 — CNPJ único

**Regra:** O CNPJ do parceiro deve ser único.

**Aplicação:** Criação e edição.

**Exemplo:** Tentativa de criar parceiro com CNPJ existente é rejeitada.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-PAR-002, RF-PAR-003.

## RN-PAR-007 — Desativação em cascata

**Regra:** A desativação de um parceiro propaga para seus usuários.

**Aplicação:** Desativação de parceiro.

**Exemplo:** Admin desativa empresa; todos os vendedores/gestores ficam inativos.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-PAR-004.

## RN-PAR-008 — Logo: MIME e tamanho

**Regra:** A logo do parceiro deve ser imagem (MIME válido) e respeitar o tamanho máximo (configurável).

**Aplicação:** Upload de logo.

**Exemplo:** Logo em JPG até 5 MiB é aceita; arquivo .txt é rejeitado.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-PAR-005.

## RN-PAR-009 — Contrato em PDF

**Regra:** O contrato do parceiro deve ser um PDF (até 10 MiB).

**Aplicação:** Upload/visualização de contrato.

**Exemplo:** Contrato .pdf até 10 MiB é aceito.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-PAR-006.

## RN-ORC-001 — Snapshot independente do censo

**Regra:** Ao criar um orçamento, o sistema copia os valores do Censo Escolar do município para o orçamento; alterações no censo oficial não afetam orçamentos existentes.

**Aplicação:** Criação de orçamento.

**Exemplo:** Orçamento criado em janeiro; censo oficial atualizado em fevereiro; o orçamento mantém os valores de janeiro.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-ORC-001, RN-CEN-002.

## RN-ORC-002 — Cálculo automático de quantidades

**Regra:** As quantidades de livros, tecnologias e serviços são calculadas automaticamente a partir dos indicadores selecionados e do censo (snapshot) do orçamento.

**Aplicação:** Criação e edição de orçamento.

**Exemplo:** Selecionar indicador "5º ano" soma o valor do censo para "in5ano" à quantidade do livro.

**Exceções:** Quantidade manual sobrescreve o cálculo (RN-ORC-011).

**Requisitos relacionados:** RF-ORC-001, RF-ORC-004.

## RN-ORC-003 — Censo agregado em multi-cidade

**Regra:** Em orçamentos multi-cidade, o censo usado nos cálculos é a soma dos valores por etapa entre todas as cidades.

**Aplicação:** Orçamento multi-cidade.

**Exemplo:** Cidade A tem 100 alunos no 5º ano; cidade B tem 50; o censo agregado é 150.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-ORC-002, RN-CEN-003.

## RN-ORC-004 — Orçamento personalizado sem município

**Status:** Planejado para uma próxima versão; esta regra descreve o comportamento futuro.

**Regra:** O orçamento personalizado não tem município vinculado; o usuário informa manualmente os valores do censo.

**Aplicação:** Orçamento personalizado.

**Exemplo:** Vendedor cria orçamento "Proposta Piloto" sem cidade e digita os valores.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-ORC-003.

## RN-ORC-005 — Autorização por orçamento (escopo por objeto)

**Regra:** O escopo de acesso a um orçamento é determinado pelo perfil e vale **sem exceção**, inclusive nas operações que recebem o identificador do orçamento diretamente (decidido em 10/09/2026):

- **Vendedor**: somente os próprios orçamentos;
- **Gestor**: somente os orçamentos da própria empresa;
- **Administrador**: todos.

A regra deve ser aplicada uniformemente a **visualização, edição, exclusão, geração de PDF, exportação em CSV, censo, arquivamento/desarquivamento e versionamento** — não apenas às listagens.

**Aplicação:** Todas as operações sobre um orçamento.

**Exemplo:** Gestor da empresa A edita orçamento do vendedor X (empresa A), mas recebe erro de autorização ao tentar gerar o PDF de um orçamento da empresa B, mesmo informando o identificador diretamente.

**Exceções:** Nenhuma.

**Divergência atual:** o backend aplica o escopo nas listagens e na edição, mas diversas rotas por identificador verificam apenas capacidades genéricas, sem checar propriedade do objeto. É necessário aplicar autorização por objeto em todos os endpoints.

**Requisitos relacionados:** RF-ORC-004, RF-ORC-005, RF-ORC-006, RF-ORC-009, RF-ORC-010, RF-ORC-011.

## RN-ORC-006 — Total recalculado

**Regra:** O total do orçamento é sempre recalculado pelo servidor, nunca confiado do cliente.

**Aplicação:** Criação e edição.

**Exemplo:** Cliente envia total 1000; servidor recalcula e armazena 980.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-ORC-001, RF-ORC-004.

## RN-ORC-007 — Versionamento arquiva o original

**Regra:** Ao versionar, o original é arquivado (não excluído) e a nova versão é criada vinculada ao original. O orçamento antigo permanece **imutável**: os valores registrados nele não são alterados pela nova versão. A nova versão parte dos dados anteriores e recebe **somente as alterações informadas pelo usuário**.

Esta regra é a mesma para orçamentos de cidade única e **multi-cidade** (decidido em 10/09/2026): não há comportamento de versionamento próprio do multi-cidade. Em ambos os casos, os **dados de censo são mantidos na nova versão**, sem substituição pelo censo atual da cidade.

**Aplicação:** Versionamento (cidade única, multi-cidade e personalizado).

**Exemplo:** Orçamento v1 é arquivado; v2 é criada com origem = v1. Se a quantidade do produto X muda de 200 para 100, v1 continua registrando 200 e apenas v2 registra 100.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-ORC-005.

## RN-ORC-008 — Preservação de overrides no versionamento

**Regra:** Ao versionar, os overrides de preço do original são preservados na nova versão quando a edição não reenvia novos valores.

**Aplicação:** Versionamento.

**Exemplo:** V1 tem override de preço no produto X; v2 preserva o override.

**Exceções:** Se a edição reenvia o valor, o override é substituído.

**Requisitos relacionados:** RF-ORC-005.

## RN-ORC-009 — Arquivamento independente do status

**Regra:** Arquivar/desarquivar é uma ação independente do status (pendente, aprovado, etc.).

**Aplicação:** Arquivamento.

**Exemplo:** Um orçamento aprovado pode ser arquivado sem mudar o status.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-ORC-006.

## RN-ORC-010 — Renomear: validação

**Regra:** Renomear não é uma operação própria: acontece pela atualização geral do orçamento. O nome aceita de **1 a 255 caracteres** e **nomes iguais ao atual não são rejeitados** — nesse caso a operação retorna sucesso sem mudança. A faixa de 3 a 100 caracteres e a obrigatoriedade de nome diferente do atual pertencem à **especificação antiga** e são **regra superada**, não o comportamento vigente (confirmado em 10/09/2026).

**Aplicação:** Renomear.

**Exemplo:** Nome "ab" é aceito (mínimo 1); "Orçamento" é aceito mesmo se igual ao atual.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-ORC-007.

## RN-ORC-011 — Quantidade manual sobrescreve cálculo

**Regra:** Quando o modo manual está ativo, a quantidade informada pelo usuário substitui o cálculo automático; ao desativar, o sistema recalcula.

**Aplicação:** Edição de orçamento.

**Exemplo:** Livro calculado em 50; vendedor ativa manual e digita 60; quantidade vira 60.

**Exceções:** Serviços com quantidade manual retornam a quantidade informada.

**Requisitos relacionados:** RF-ORC-008.

## RN-ORC-012 — PDF exige dados do vendedor

**Regra:** A geração do PDF exige nome, cargo, telefone e e-mail do vendedor preenchidos.

**Aplicação:** Geração de PDF.

**Exemplo:** Vendedor sem telefone não consegue gerar PDF.

**Exceções:** Nenhuma.

**Divergência atual:** o campo `email_vendedor` é **opcional** no schema do PDF; quando ausente, é convertido em string vazia e o PDF é gerado sem o e-mail do vendedor. A validação deve ser alinhada à regra (e-mail obrigatório) ou a regra ajustada para tornar o e-mail opcional.

**Requisitos relacionados:** RF-ORC-009.

## RN-ORC-013 — Compartilhamento renova a validade pelo prazo salvo

**Regra esclarecida em 12/09/2026:** Gerar ou compartilhar o PDF renova a validade como **momento da operação + `orc_dias_validade` salvo**. O padrão de novos orçamentos é 60 dias, mas prazos como 15 e 90 dias são preservados. Somente `expirado` muda para `pendente`; pendente, aprovado e não aprovado mantêm seus status. ID, versões, arquivamento, produtos e valores permanecem intactos.

**Aplicação:** Compartilhamento/PDF.

**Exemplo:** Orçamento expirado há 10 dias, configurado com 15 dias; gerar o PDF define validade para o momento da operação mais 15 dias e status pendente, sem criar versão nem desarquivar.

**Falhas:** Geração negada ou falha não renova; falha na renovação não entrega resposta de sucesso. Cancelar o compartilhamento nativo após gerar não desfaz a renovação já persistida.

**Histórico:** A interpretação de prazo fixo de +60 dias, registrada em 10/09/2026, foi substituída por este esclarecimento. Relatórios daquela execução não representam o resultado dos testes atuais.

**Requisitos relacionados:** RF-ORC-009.

## RN-ORC-014 — Exportação de censo em CSV

**Regra:** A exportação do censo gera um CSV com indicadores e valores do snapshot do orçamento.

**Aplicação:** Exportação de censo.

**Exemplo:** CSV com colunas "Indicador,Valor".

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-ORC-010.

## RN-ORC-015 — Listagem por perfil

**Regra:** A listagem de orçamentos respeita o perfil: vendedor vê apenas os próprios; gestor vê os da empresa; administrador vê todos. Orçamentos em `rascunho` abandonados **não** devem aparecer na listagem como orçamentos recuperáveis (ver §8).

**Aplicação:** Listagem de orçamentos.

**Exemplo:** Vendedor não vê orçamentos de outros vendedores.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-ORC-011.

## RN-CEN-001 — Censo por município

**Regra:** O Censo Escolar é mantido por município, com indicadores de etapa e valores.

**Aplicação:** Visualização e cálculo.

**Exemplo:** Cidade "X" tem indicador "5º ano" com valor 120.

**Exceções:** Cidade sem censo.

**Requisitos relacionados:** RF-CEN-001.

## RN-CEN-002 — Edição afeta apenas o snapshot

**Regra:** A edição de valores do censo dentro de um orçamento altera apenas o snapshot do orçamento, não o censo oficial da cidade.

**Aplicação:** Edição de censo no orçamento.

**Exemplo:** Vendedor ajusta o valor do 5º ano no orçamento; o censo oficial da cidade permanece inalterado.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-CEN-002, RN-ORC-001.

## RN-CEN-003 — Censo agregado soma por etapa

**Regra:** O censo agregado de um orçamento multi-cidade é a soma dos valores por etapa entre as cidades.

**Aplicação:** Multi-cidade.

**Exemplo:** Soma dos valores de "in5ano" entre as cidades selecionadas.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-ORC-002, RN-ORC-003.

## RN-CEN-004 — Grupos de censo

**Regra:** Os indicadores de etapa são organizados em grupos de censo (ex.: "Alunos", "Professores").

**Aplicação:** Gestão de censo.

**Exemplo:** Grupo "Alunos" contém "maternal", "bercario", "in4ano", etc.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-CEN-003.

## RN-CEN-005 — Índices de etapa com ordenação e percentual

**Regra:** Cada índice de etapa tem ordenação (fracionária), valor padrão e percentual de população.

**Aplicação:** Gestão de censo.

**Exemplo:** Índice "5º ano" com ordem 5.0 e percentual 0.10.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-CEN-003.

## RN-CEN-006 — Atualização de população IBGE

**Regra:** A atualização de população IBGE aplica o percentual do índice selecionado à população de cada cidade, sem arredondamento (regra atual).

**Aplicação:** Atualização de população.

**Exemplo:** População 10000, percentual 10% → 1000.

**Exceções:** A implementação atual usa `floor` (divergência — ver §24.1).

**Requisitos relacionados:** RF-CEN-004.

## RN-CEN-007 — Atualização parcial reportada

**Regra:** A atualização de população é assíncrona (stream NDJSON); falhas parciais são reportadas por cidade, mas não abortam o todo; HTTP 200 não garante sucesso total.

**Aplicação:** Atualização de população.

**Exemplo:** 50 cidades; 48 sucesso; 2 falham (timeout IBGE); o sistema reporta as 2 falhas.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-CEN-004.

## RN-CAT-001 — Categorias

**Regra:** Categorias agrupam subcategorias; têm nome, status e ordenação.

**Aplicação:** Catálogo.

**Exemplo:** Categoria "Livros" contém subcategorias "Infantil", "Fundamental".

**Exceções:** Nome duplicado.

**Requisitos relacionados:** RF-CAT-001.

## RN-CAT-002 — Desativação em cascata

**Regra:** A desativação de uma categoria desativa suas subcategorias e produtos; a restauração reativa os que foram desativados em cascata.

**Aplicação:** Desativação de categoria.

**Exemplo:** Desativar "Livros" desativa todas as subcategorias e produtos.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-CAT-001.

## RN-CAT-003 — Subcategorias

**Regra:** Subcategorias pertencem a uma categoria; têm nome, status e ordenação.

**Aplicação:** Catálogo.

**Exemplo:** Subcategoria "Fundamental" na categoria "Livros".

**Exceções:** Nome duplicado.

**Requisitos relacionados:** RF-CAT-002.

## RN-CAT-004 — Tipos de produto

**Regra:** Produtos são de três tipos: livro, tecnologia ou serviço.

**Aplicação:** Catálogo.

**Exemplo:** "Livro do 5º ano" é tipo livro; "Avaliação diagnóstica" é tipo serviço.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-CAT-003.

## RN-CAT-005 — Serviço exige produtos relacionados

**Regra:** Um serviço deve ter pelo menos um produto relacionado (que não seja outro serviço); percentual **de 0 a 100**; horas fixas ≥ 0. O percentual **0% é válido** (decidido em 10/09/2026): permite que a quantidade do serviço seja determinada apenas pelas horas fixas. A validação atual está correta e este ponto não é divergência.

**Aplicação:** Catálogo.

**Exemplo:** Serviço "Implantação" vinculado a "Livro 5º ano" e "Tecnologia 5º ano". Serviço "Treinamento inicial" com percentual 0% e 40 horas fixas resulta em quantidade 40, independentemente do censo.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-CAT-003.

## RN-CAT-006 — Livro exige ISBN

**Regra:** Um produto do tipo livro deve ter ISBN preenchido.

**Aplicação:** Catálogo.

**Exemplo:** "Livro 5º ano" sem ISBN é rejeitado.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-CAT-003.

## RN-CAT-007 — Ordenação fracionária

**Regra:** A ordenação de categorias, subcategorias e produtos usa ordem fracionária, preservando precisão. Quando existem vizinhos anterior e posterior, a nova ordem é o **ponto médio** entre eles. Nas pontas da lista, o algoritmo desloca uma unidade inteira. Se a ordem atual já estiver corretamente posicionada entre os vizinhos, ela é preservada; se não houver espaço representável entre os vizinhos, a operação não produz nova ordem.

**Aplicação:** Reordenação.

**Exemplo:** Mover item entre A (ordem 1.00000000) e B (ordem 2.00000000) → nova ordem 1.50000000.

**Exceções:** Sem espaço representável entre os vizinhos (precisão decimal esgotada).

> A regra está implementada conforme descrito e **não constitui divergência**.

**Requisitos relacionados:** RF-CAT-004.

## RN-CAT-008 — Ativação/desativação de produto

**Regra:** Um produto pode ser ativado ou desativado sem ser excluído. O campo de status enviado ao backend **deve refletir o status real do produto** (decidido em 10/09/2026) — ativo ou inativo — e não pode ser mantido artificialmente verdadeiro.

**Aplicação:** Catálogo.

**Exemplo:** Desativar "Livro 5º ano" antigo; o contrato enviado ao backend deve representá-lo como inativo.

**Exceções:** Nenhuma.

**Divergência atual:** o painel envia `pro_status: true` incondicionalmente na criação e na edição, enquanto o estado ativo/inativo escolhido na tela é refletido apenas em `pro_ativo`. O contrato deve representar corretamente o estado real (ver §24.4).

**Requisitos relacionados:** RF-CAT-005.

## RN-DRV-001 — Acesso ao Drive por perfil

**Regra:** **Somente o Administrador cria pastas, envia arquivos e gerencia compartilhamentos no Drive** (decidido em 10/09/2026). Gestor e Vendedor possuem **apenas acesso de leitura, pelo App** — podem visualizar e baixar os itens compartilhados com eles. Como esses perfis também não acessam o painel, não há nenhum canal em que devam ver controles administrativos do Drive.

**Aplicação:** Drive.

**Exemplo:** Vendedor vê e baixa arquivos compartilhados pelo App, mas não cria pastas nem compartilha.

**Exceções:** Nenhuma.

**Divergência atual:** o painel exibe os controles de criação de pasta e de upload para qualquer usuário autenticado na visão "own". Esses controles devem ser bloqueados para não-administradores (ver §24.2).

**Requisitos relacionados:** RF-DRV-001, RF-DRV-002.

## RN-DRV-002 — Upload: MIME e tamanho

**Regra:** O upload de arquivos valida MIME (perigoso rejeitado) e tamanho máximo (configurável, default 1 GiB no Drive via `FILE_UPLOAD_MAX_BYTES`). **Atualmente** o enforcement do tamanho ocorre apenas no fluxo de upload-intent (`FileUploadJobService::createIntent`); o endpoint direto `POST /api/files/` (`ItemService::createFile` via `FileSchema`) não valida tamanho. O file-manager possui seu próprio fluxo de upload (`FileUploadSchema` + `FileUploadService`) que também não valida tamanho, MIME, extensão ou nome de arquivo no fluxo ativo (ver §24.5).

**Aplicação:** Upload.

**Exemplo:** Arquivo .exe é rejeitado; vídeo .mp4 até 1 GiB é aceito (no fluxo de intent).

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-DRV-002.

## RN-DRV-003 — Profundidade máxima do Drive

**Regra:** A profundidade máxima de pastas no Drive é 100 níveis.

**Aplicação:** Criação/movimentação de pastas.

**Exemplo:** Tentar criar pasta no nível 101 é rejeitado.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-DRV-002, RF-DRV-006.

## RN-DRV-004 — Tipos visualizáveis

**Regra:** A visualização inline suporta imagens (jpg, png, gif, webp, bmp, svg), documentos (pdf, docx, xlsx, pptx), vídeos (mp4, webm, etc.) e áudio (mp3, wav, etc.); outros tipos são apenas baixáveis.

**Aplicação:** Visualização.

**Exemplo:** PDF é visualizado inline; .zip é apenas baixável.

**Exceções:** Tipo não suportado para visualização.

**Requisitos relacionados:** RF-DRV-003.

## RN-DRV-005 — Compartilhamento só leitura

**Regra:** O compartilhamento concede apenas permissão de leitura; pastas compartilhadas propagam recursivamente. **Atualmente** a implementação também propaga compartilhamentos do pai para novos itens criados dentro de uma pasta compartilhada (compartilhamento herdado automático), e re-sincroniza compartilhamentos ao mover itens.

**Aplicação:** Compartilhamento.

**Exemplo:** Dono compartilha pasta "Materiais 2024" com vendedor; vendedor vê todo o conteúdo. Se o dono criar um novo arquivo dentro dessa pasta, o arquivo herda o compartilhamento automaticamente.

**Exceções:** Auto-compartilhamento bloqueado (verificado no item alvo); duplicidade rejeitada no item alvo (409). Em compartilhamento recursivo de pasta, filhos duplicados são atualizados via upsert, não rejeitados.

**Requisitos relacionados:** RF-DRV-004.

## RN-DRV-006 — Gerenciamento de compartilhamentos

**Regra:** O dono (ou admin) pode listar e remover compartilhamentos de um item, individualmente ou em lote.

**Aplicação:** Gerenciamento.

**Exemplo:** Dono remove compartilhamento com 3 usuários de uma vez.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-DRV-005.

## RN-DRV-007 — Mover respeita hierarquia

**Regra:** Mover um item valida a hierarquia (sem ciclos) e a profundidade máxima.

**Aplicação:** Mover.

**Exemplo:** Mover pasta A para dentro de sua subpasta B é rejeitado (ciclo).

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-DRV-006, RN-DRV-003.

## RN-DRV-008 — Exclusão de item

**Regra:** A exclusão de um item exige permissão de dono ou admin; a remoção física no storage é best-effort.

**Aplicação:** Exclusão.

**Exemplo:** Dono exclui arquivo; o registro e o arquivo físico são removidos.

**Exceções:** Falha na remoção física não desfaz a exclusão lógica.

**Requisitos relacionados:** RF-DRV-006.

## RN-DRV-009 — Capa de vídeo

**Regra:** Apenas vídeos podem ter capa; a capa é uma imagem (JPEG, PNG, GIF ou WebP — `ThumbnailSchema` aceita esses quatro MIMEs). **Atualmente** a implementação **não valida tamanho máximo** do upload de capa (não há limite de 10 MiB enforceado no schema ou service).

**Comportamento atual da capa padrão:** **todo novo upload de capa é marcado como padrão e remove o padrão anterior** — ou seja, a capa mais recente sempre se torna a default. Ao excluir a capa padrão, a próxima capa ativa é promovida; se nenhuma estiver marcada, o sistema usa a primeira ativa como fallback. Não há capa padrão pré-gerada. Este é o comportamento existente, registrado antes de qualquer discussão sobre mudança.

**Aplicação:** Capa de vídeo.

**Exemplo:** Dono envia uma segunda capa; ela vira a padrão e a anterior deixa de ser padrão.

**Exceções:** Item não é vídeo.

**Requisitos relacionados:** RF-DRV-007.

## RN-REL-001 — Relatório de vendas por parceiro

**Regra:** O relatório de vendas agrega por parceiro e por mês, dentro do período informado.

**Aplicação:** Relatórios.

**Exemplo:** Período jan-mar; relatório mostra vendas de cada parceiro por mês.

**Exceções:** Período inválido.

**Requisitos relacionados:** RF-REL-001.

## RN-REL-002 — Relatório de orçamentos por vendedor

**Regra:** O relatório de orçamentos lista orçamentos de um vendedor, filtráveis por status, arquivamento, data e localização.

**Aplicação:** Relatórios.

**Exemplo:** Admin seleciona vendedor "X" e filtra por "aprovado" em "jan/2024".

**Exceções:** Sem permissão.

**Requisitos relacionados:** RF-REL-002.

## RN-REL-003 — Histórico de versões

**Regra:** O histórico de versões lista as versões de um orçamento, permitindo comparar a evolução da proposta.

**Comportamento atual:** o histórico retorna **também a versão atual**, e informa o identificador dela separadamente para que o cliente possa distingui-la das anteriores. Este é o comportamento existente, registrado antes de qualquer discussão sobre mudança — versões anteriores deste documento afirmavam que a versão atual era excluída da lista.

**Aplicação:** Relatórios.

**Exemplo:** Orçamento v3 retorna v1, v2 e v3, com o identificador de v3 sinalizado como versão atual.

**Exceções:** Sem versões.

**Requisitos relacionados:** RF-REL-003.

## RN-DSH-001 — Dashboard global

**Regra:** O dashboard exibe vendas por período, contagem de orçamentos por status e arquivos recentes; é visível apenas ao administrador.

**Agregação do gráfico de vendas** (decidido em 10/09/2026): registros com a **mesma chave temporal devem ser somados**, nunca exibidos como categorias repetidas. O agrupamento depende da extensão do período consultado:

- período **inferior a três meses** → agrupamento **diário**;
- período de **três meses ou mais** → agrupamento **mensal**.

**Aplicação:** Dashboard.

**Exemplo:** Admin vê total de vendas do mês e 5 arquivos recentes. Se a API retornar dois registros para 05/03, o gráfico exibe um único ponto em 05/03 com a soma dos dois.

**Exceções:** Nenhuma.

**Divergência atual:** o gráfico de vendas do dashboard mapeia cada registro retornado diretamente para uma categoria, sem agregar chaves repetidas — dias ou meses podem aparecer duplicados. Os relatórios de parceiro/vendedor já agregam, mas o dashboard não usa essa implementação (ver §24.4).

**Requisitos relacionados:** RF-DSH-001.

## RN-PRF-001 — Edição de perfil próprio

**Regra:** O usuário pode editar nome, e-mail, telefone e cargo; não pode alterar papel, status ou senha via este fluxo.

**Aplicação:** Perfil.

**Exemplo:** Vendedor altera telefone; não pode virar gestor por aqui.

**Exceções:** E-mail duplicado.

**Requisitos relacionados:** RF-PRF-001.

## RN-PRF-002 — Avatar: MIME e tamanho

**Regra:** O avatar deve ser imagem (MIME válido) e respeitar o tamanho máximo (5 MiB).

**Aplicação:** Upload de avatar.

**Exemplo:** Avatar .jpg até 5 MiB é aceito.

**Exceções:** MIME inválido; tamanho excedido.

**Requisitos relacionados:** RF-PRF-002.

## RN-WIK-001 — Wiki estática

**Regra:** A wiki é conteúdo estático de ajuda, sem backend; itens são expansíveis.

**Aplicação:** Wiki.

**Exemplo:** Usuário abre "Como criar orçamento" e expande o item.

**Exceções:** Nenhuma.

**Requisitos relacionados:** RF-WIK-001.

## RN-PRO-001 — Prospecção

**Regra:** A prospecção registra interesse em parceria; nome, e-mail e telefone são obrigatórios; empresa, CNPJ e experiência são opcionais.

**Aplicação:** Prospecção.

**Exemplo:** Visitante informa nome, e-mail e telefone; sistema cria prospecção.

**Exceções:** Campos obrigatórios ausentes.

**Requisitos relacionados:** RF-PRO-001.

---

# 8. Ciclo de Vida do Orçamento

## Estados

O orçamento possui dois conceitos ortogonais:

- **Status** (`orc_status`): representa o estado comercial do orçamento. O enum válido na implementação é `rascunho`, `pendente`, `arquivado`, `aprovado`, `expirado`, `nao_aprovado` (6 valores — definidos em `OrcamentosSchema.php`; o model `Orcamento.php` apenas faz cast para `string`, sem definir enum). Os estados comerciais ativos são `pendente`, `aprovado`, `não aprovado` (`nao_aprovado`) e `expirado`.
- **Arquivamento** (`orc_is_archived`): booleano `true`/`false`. Representa se o orçamento está arquivado (fora da listagem ativa, mas preservado). Independente do status.

> **Nota sobre `rascunho`:** `rascunho` é um **estado técnico e transitório**, usado apenas durante a criação (decidido em 10/09/2026). Se o usuário abandonar a criação, o registro permanece no banco com esse status, mas é **considerado descartado para o usuário**: não deve aparecer como orçamento recuperável na listagem nem permitir retomada posterior. O status final salvo pelo fluxo de configuração é `pendente`. Tecnicamente o valor é aceito no enum de `orc_status` e é o padrão ao criar, mas isso não o torna um estado de negócio.

> **Divergência de arquivamento (estado atual):** A implementação possui **dois** mecanismos de arquivamento: a coluna booleana `orc_is_archived` (usada em filtros de listagem/relatório) **e** o valor `arquivado` no enum de `orc_status` (aceito pelos schemas, pela migration, pelo OpenAPI e pelos relatórios). Os fluxos mais recentes de arquivar/desarquivar operam pelo booleano. A regra de negócio (RN-ORC-009) trata o arquivamento como independente do status. Esta é a **descrição do estado atual**, registrada para decisão futura — não uma nova regra de produto (ver §24.3).

## Tabela de transições de status

| Estado atual | Ação | Novo estado | Condições |
|---|---|---|---|
| (novo) | Criar e salvar da configuração | `pendente` | Cidade com censo; ≥1 produto selecionado; validade 1–365 dias; total > 0 |
| (novo) | Criar rascunho (App) | `rascunho` | Estado técnico transitório; cidade selecionada; não exige produtos/validade |
| `rascunho` | Abandonar a criação | `rascunho` (descartado) | O registro permanece no banco, mas não é listado nem recuperável pelo usuário |
| `pendente` | Aprovar manualmente | `aprovado` | Usuário com permissão; orçamento não expirado |
| `pendente` | Reprovar manualmente | `não aprovado` | Usuário com permissão |
| `pendente` | Expirar (automático) | `expirado` | Data de validade passada |
| `aprovado` | Reprovar manualmente | `não aprovado` | Usuário com permissão |
| `aprovado` | Expirar (automático) | `expirado` | Data de validade passada (gerar/compartilhar PDF renova pelo prazo salvo — ver RN-ORC-013) |
| `não aprovado` | Aprovar manualmente | `aprovado` | Usuário com permissão |
| `expirado` | Renovar validade e salvar | `pendente` | Editar/versão: ao definir nova validade, `expirado` → `pendente` |
| `expirado` | Versionar | `pendente` (nova versão) | Versão herda dados; nova validade |
| qualquer status | Arquivar | (status inalterado) | Arquivamento independe do status |
| arquivado | Desarquivar | (status inalterado) | — |
| qualquer status | Versionar | original vira arquivado; nova versão herda status | RN-ORC-007 |

## Distinção entre status, validade e arquivamento

- **Status** é o estado comercial (pendente/aprovado/não aprovado/expirado).
- **Validade** é a data limite do orçamento, calculada como `agora + dias_validade`. Quando a data passa, o orçamento expira (status → `expirado`).
- **Arquivamento** é uma marcação ortogonal que remove o orçamento da listagem ativa sem alterar o status.

## Comportamentos especiais

- **Versionar**: arquiva o original e cria uma nova versão vinculada (origem). O status da nova versão pode ser `pendente` (se o original estava expirado, a nova versão passa a `pendente`).
- **Multi-cidade versionar**: segue a **mesma regra** do orçamento comum, sem comportamento próprio (ver RN-ORC-007).
- **Compartilhar/gerar PDF**: renova pelo prazo salvo a partir da operação; somente expirado passa a pendente, preservando versões e arquivamento (ver RN-ORC-013).
- **Edição preserva status**: a edição pelo App preserva o status selecionado, exceto ao definir nova validade, que reseta `expirado` → `pendente`.

---

# 9. Processo de Criação de Orçamento

## 9.1 Cidade única

1. O usuário acessa a tela de criação e seleciona a cidade (ou o admin seleciona parceiro destino + cidade).
2. O sistema cria um rascunho de orçamento e copia o censo da cidade (snapshot).
3. O usuário é levado à configuração do orçamento.
4. O usuário seleciona categorias/subcategorias/produtos e indicadores.
5. O sistema calcula quantidades e total automaticamente.
6. O usuário define a validade (1–365 dias).
7. O usuário salva (rascunho → pendente).

## 9.2 Multi-cidade

1. O usuário acessa a criação multi-cidade e seleciona múltiplas cidades.
2. O sistema busca o censo de cada cidade.
3. O sistema cria o orçamento multi-cidade com censo agregado (soma por etapa).
4. O usuário seleciona produtos e indicadores.
5. O sistema calcula com base no censo agregado.
6. O usuário define validade e salva.

## 9.3 Personalizado (sem município)

> **Disponibilidade:** fluxo planejado para uma próxima versão e ainda indisponível no App atual. Os passos abaixo descrevem o comportamento futuro.

1. O usuário acessa a criação personalizada.
2. O usuário informa manualmente os valores dos indicadores.
3. O sistema cria o orçamento sem cidade vinculada.
4. O usuário seleciona produtos e indicadores.
5. O sistema calcula com base nos valores manuais.
6. O usuário define validade e salva.

## 9.4 Validações na criação

- Validade entre 1 e 365 dias (schema: `v::intType()->positive()->max(365)`).
- Nome do orçamento informado (multi-cidade exige nome — validação cross-field no schema).

> **Onde cada validação é aplicada hoje.** A cobertura difere entre a interface e a API (confirmado em 10/09/2026):
>
> - **Pelo App (fluxo normal do usuário):** há validação parcial — o App **impede finalizar um orçamento com total ≤ 0** e exige um estado válido da configuração antes de salvar.
> - **Por chamada direta à API:** os três casos abaixo são **aceitos**, porque não há enforcement no schema nem no service (ver §24.3):
>   - **Cidade com censo**: `validarCidadesDisponiveisParaNovosOrcamentos` checa apenas `status`, `excluido` e o status do `estado`; a existência de censo não é confirmada.
>   - **Pelo menos 1 produto selecionado**: `produtos_selecionados` é opcional no schema, e o service cria todos os produtos ativos automaticamente.
>   - **Total > 0**: o schema usa `v::floatVal()->min(0)`, que aceita zero.

---

# 10. Edição e Versionamento

## 10.1 Edição

- Pode editar: dono, admin, ou gestor da mesma empresa (ver RN-ORC-005).
- Orçamentos com status `aprovado` continuam editáveis; aprovação não implica modo somente leitura.
- O total é sempre recalculado pelo servidor.
- Alterações de produtos, indicadores, quantidades manuais, validade e status são suportadas.
- A atualização exige envio completo dos dados; o cliente relê o registro antes para preencher campos não alterados.
- **Lista de produtos vazia preserva os produtos existentes** (decidido em 10/09/2026): enviar `produtos: []` tem exatamente o mesmo efeito de omitir o campo ou enviá-lo como `null`. Lista vazia **não** significa remover todos os produtos. Na implementação atual, o service aceita o array vazio e a preservação ocorre porque o repositório retorna sem sincronizar quando a lista está vazia.

## 10.2 Versionamento

- Arquiva o original (marca como arquivado); o orçamento antigo permanece **imutável**.
- Cria nova versão vinculada à versão original (origem da versão).
- Copia produtos, quantidades e valores; a nova versão recebe **apenas as alterações informadas pelo usuário**, e os valores anteriores continuam registrados na versão antiga.
- Mantém os dados de censo da versão anterior, sem substituí-los pelo censo atual da cidade.
- Preserva overrides de preço do original quando a edição não reenvia `valor`.
- Recalcula o total da nova versão.
- Multi-cidade segue exatamente a mesma regra, sem comportamento próprio (decidido em 10/09/2026).

## 10.3 Renomear

- Renomear ocorre pela atualização geral do orçamento; não há rota dedicada.
- Novo nome: mínimo 1, máximo 255 caracteres. Nome igual ao atual é aceito e retorna sucesso sem mudança. A faixa de 3 a 100 caracteres e a exigência de nome diferente são **regra superada** (especificação antiga).

## 10.4 Arquivamento

- Independente do status.
- Pode ser feito e desfeito.
- Não exclui o orçamento.

---

# 11. Censo Escolar

## 11.1 Indicadores de aluno

Indicadores de etapa representam contagens de alunos por etapa de ensino:

- `maternal`, `bercario` — educação infantil
- `in4ano`, `in5ano` — anos iniciais do fundamental
- `ef1ano` a `ef9ano` — fundamental (1º a 9º ano)
- `em1ano` a `em3ano` — ensino médio
- `efEja`, `emEja` — EJA fundamental e médio
- `cursistas` — cursistas

## 11.2 Indicadores de professor

Indicadores de professor usam o sufixo `P`:

- `maternalP`, `bercarioP`
- `in4anoP`, `in5anoP`
- `ef1anoP` a `ef9anoP`
- `em1anoP` a `em3anoP`
- `efEjaP`, `emEjaP`

> A seleção do indicador "professores" em um produto indica que o cálculo deve somar também os indicadores de professor correspondentes.

## 11.3 Grupos e índices

- Indicadores são organizados em **grupos de censo** (ex.: "Alunos", "Professores").
- Cada **índice de etapa** tem ordenação fracionária, valor padrão e percentual de população.
- O administrador gerencia grupos e índices.

## 11.4 Snapshot no orçamento

- Ao criar um orçamento, o sistema copia os valores do censo do município para o orçamento.
- Alterações no censo oficial não afetam orçamentos existentes.
- O usuário pode editar os valores do snapshot dentro do orçamento.

## 11.5 Censo agregado (multi-cidade)

- Em orçamentos multi-cidade, o censo usado é a soma dos valores por etapa entre as cidades.
- O usuário pode editar valores por cidade; o agregado é recalculado.

## 11.6 Atualização de população IBGE

- O administrador dispara a atualização assíncrona (stream NDJSON).
- Seleciona um índice de etapa e um percentual.
- O sistema aplica `população × percentual` a cada cidade.
- Falhas parciais são reportadas, mas não abortam o todo.
- HTTP 200 não garante sucesso total.

---

# 12. Cálculos

> **REGRA ATUAL (correção do README): "Os cálculos não precisam mais de arredondamento."**
> Regras antigas de `floor`, `ceil` e arredondamento são **regra superada**; os pontos em que a implementação ainda as aplica estão listados em §24.1.
>
> **Comportamento atual registrado (10/09/2026).** A implementação ainda aplica arredondamentos de cálculo em vários pontos: `floor` nas quantidades de serviço e na população proporcional, e `ceil` em `in4ano`/`in5ano`. Isso está registrado como comportamento existente, a ser confrontado com a regra.
>
> **Arredondamento de quantidade e precisão monetária são assuntos distintos.** O `round(..., 2)` do dashboard e os casts monetários `decimal:2` são **formatação e precisão monetária**, e não necessariamente a mesma regra aplicada às quantidades. Ver §12.8 para a regra de precisão monetária.

## 12.1 Conceitos gerais

Os cálculos do orçamento combinam os seguintes conceitos:

- **Indicador**: métrica do Censo Escolar para uma etapa de ensino (ex.: `in5ano` = alunos do 5º ano). Os indicadores de professor usam o sufixo `P` (ex.: `in5anoP`).
- **Quantidade**: número de unidades de um produto no orçamento. Pode ser calculada automaticamente a partir dos indicadores do censo ou informada manualmente pelo usuário.
- **Valor unitário**: preço de uma unidade do produto, conforme cadastro do catálogo. Pode ser sobrescrito (override) em um orçamento específico.
- **Valor total do item**: resultado de `quantidade × valor unitário` para cada produto do orçamento.
- **Produtos relacionados**: produtos vinculados a um serviço, usados como base para o cálculo da quantidade de horas do serviço. Não podem ser outros serviços.
- **Percentual**: fator aplicado à soma das quantidades dos produtos relacionados de um serviço para obter as horas (ex.: 8%). É configurável por serviço, no intervalo de **0 a 100**; 0% é válido e faz a quantidade depender apenas das horas fixas.
- **Horas fixas**: acréscimo fixo de horas somado ao resultado do percentual, configurável por serviço (≥ 0).
- **Quantidade manual**: quantidade informada manualmente pelo usuário que sobrescreve o cálculo automático quando ativada.

## 12.2 Livros para estudantes

**Fórmula:**

```
quantidade = Σ valor_do_censo[indicador] para cada indicador selecionado (exceto "professores")
```

**Exemplo:** Indicadores selecionados: `in5ano` (120), `ef1ano` (80). Quantidade = 120 + 80 = 200.

## 12.3 Livros para professores

Quando o indicador "professores" está selecionado, o cálculo usa os indicadores de professor (sufixo `P`) correspondentes aos indicadores de etapa selecionados.

**Fórmula:**

```
para cada indicador selecionado (exceto "professores"):
  quantidade += valor_do_censo[indicador + "P"]
```

**Exemplo:** Indicadores: `in5ano`, `professores`. Censo: `in5anoP` = 10. Quantidade = 10.

## 12.4 Tecnologias

Para tecnologias, somam-se os indicadores de aluno. Quando "professores" está selecionado, somam-se também os indicadores de professor correspondentes.

**Sem professores:**

```
quantidade = Σ valor_do_censo[indicador] para cada indicador selecionado (exceto "professores")
```

**Com professores:**

```
para cada indicador selecionado (exceto "professores"):
  quantidade += valor_do_censo[indicador]
  quantidade += valor_do_censo[indicador + "P"]
```

**Exemplo (com professores):** Indicadores: `in5ano`, `professores`. Censo: `in5ano` = 120, `in5anoP` = 10. Quantidade = 120 + 10 = 130.

## 12.5 Serviços

A quantidade de um serviço é calculada a partir das quantidades dos produtos relacionados, aplicando um percentual e somando horas fixas.

**Fórmula:**

```
totalCenso = Σ calcularQuantidade(produtosRelacionados selecionados)
quantidade = (totalCenso × percentual) + horasFixas
```

- `totalCenso` é a soma das quantidades calculadas de todos os produtos relacionados do serviço.
- `percentual` é o fator configurado no serviço (ex.: 0,08 para 8%).
- `horasFixas` é o acréscimo fixo configurado no serviço.

**Exemplo:** Serviço vinculado a "Livro 5º ano" (quantidade 200) e "Tecnologia 5º ano" (quantidade 130). Percentual 8%, horas fixas 5. Quantidade = (330 × 0,08) + 5 = 26,4 + 5 = 31,4.

> **Regra atual:** sem arredondamento. **Implementação atual:** aplica `floor` (divergência — ver §24.1).

## 12.6 Quantidade manual

- Quando ativa, substitui o cálculo automático.
- Ao desativar, o sistema recalcula.

## 12.7 Orçamentos multi-cidade

Em orçamentos multi-cidade, o censo usado nos cálculos é o **censo agregado**: a soma dos valores por etapa entre todas as cidades selecionadas.

**Fórmula do censo agregado:**

```
censo_agregado[etapa] = Σ censo[cidade][etapa] para cada cidade selecionada
```

- Todas as fórmulas das seções 12.2 a 12.5 aplicam-se normalmente, substituindo o censo de uma única cidade pelo censo agregado.
- O usuário pode editar os valores por cidade; o agregado é recalculado.
- A edição dos valores dentro do orçamento afeta apenas o snapshot do orçamento, não o censo oficial das cidades.

**Exemplo:** Cidade A tem `in5ano` = 100; cidade B tem `in5ano` = 50. O censo agregado de `in5ano` é 150. Um livro com indicador `in5ano` selecionado terá quantidade 150.

## 12.8 Total do orçamento

**Fórmula:**

```
total = Σ (valor_unitário × quantidade) para cada produto selecionado
```

- O valor unitário considera override de preço se existir.
- O total é sempre recalculado pelo servidor.

**Precisão monetária (decidido em 10/09/2026):** as duas casas decimais são **exclusivamente formatação de apresentação** em tela, PDF e CSV. O valor usado no cálculo deve **preservar sua precisão** e não pode ser alterado por arredondamentos de leitura.

> **Divergência atual:** os casts `decimal:2` (`orc_total`, `op_quantidade`, `op_valor`, `pro_valor`, `pro_horas_fixas`, `opo_valor_override`) arredondam o valor **ao lê-lo do banco**, antes de ser usado em operações subsequentes. Isso influencia o cálculo e, portanto, não é apenas apresentação (ver §24.1).

## 12.9 Regras antigas (superadas)

As seguintes regras eram descritas na documentação antiga de cálculos e **foram superadas** pela correção "sem arredondamento":

- Divisão e `floor` para pré-escola (maternal/bercário).
- Cálculo de professores como 8% dos alunos, arredondado para baixo.
- Arredondamento para baixo de horas de serviço.
- `ceil` em `in4ano`/`in5ano` e seus indicadores de professor.

> Estas regras são **históricas** e não devem ser aplicadas. A implementação atual ainda contém esses arredondamentos (ver §24.1).

---

# 13. Catálogo de Produtos

## 13.1 Estrutura

- **Categorias** → **Subcategorias** → **Produtos**.
- Cada nível tem ordenação fracionária e status (ativo/inativo).
- Produtos têm indicadores de etapa vinculados.
- Produtos podem ter diferenciais.
- Serviços têm produtos relacionados (não podem ser outros serviços).

## 13.2 Tipos de produto

- **Livro**: exige ISBN; quantidade calculada por indicadores de aluno (e professor, se selecionado).
- **Tecnologia**: quantidade calculada por indicadores de aluno + professor (se selecionado).
- **Serviço**: exige produtos relacionados; quantidade calculada por percentual aplicado à soma dos relacionados, mais horas fixas.

## 13.3 Ordenação

- Categorias, subcategorias e produtos suportam reordenação por arrastar e soltar.
- A ordem é fracionária: ponto médio entre vizinhos quando há anterior e posterior; deslocamento de uma unidade inteira nas pontas da lista (ver RN-CAT-007).

## 13.4 Ativação/desativação

- Categorias, subcategorias e produtos podem ser ativados/desativados.
- A desativação de categoria propaga para subcategorias e produtos (cascata).
- A restauração reativa os que foram desativados em cascata.
- O status enviado ao backend deve refletir o estado real do produto; hoje o painel envia `pro_status` sempre verdadeiro (divergência — ver RN-CAT-008).

## 13.5 Exclusão

- A exclusão é lógica (marca como excluído).
- Produtos excluídos por cascata podem ser restaurados.

## 13.6 Indicadores de etapa

- Cada produto pode ter indicadores de etapa vinculados (quais etapas ele atende).
- Ao criar um indicador de etapa, ele é vinculado a todos os produtos (regra do backend).

## 13.7 Diferenciais

- Produtos podem ter diferenciais (características diferenciais).
- Diferenciais podem ser vinculados a categorias, subcategorias e produtos.

---

# 14. Parceiros

## 14.1 Cadastro

- O administrador cria parceiros com gestor responsável e usuários adicionais opcionais.
- A criação é atômica (transação): empresa + usuários.
- Após a criação, logo e contrato podem ser enviados separadamente; falhas nesses uploads não desfazem a criação.
- Opcionalmente, envia credenciais por e-mail e/ou gera PDF de acessos.

## 14.2 Edição

- O administrador edita qualquer parceiro.
- O gestor edita apenas a própria empresa (dados e logo).
- O gestor não altera o status da própria empresa.

## 14.3 Status

- Parceiros podem ser ativados/desativados pelo administrador.
- A desativação propaga para os usuários.
- Não há exclusão física.

## 14.4 Contrato

- O gestor pode visualizar e baixar o contrato da própria empresa.
- O contrato é um PDF (até 10 MiB).

## 14.5 Logo

- O gestor pode fazer upload da logo da própria empresa.
- O administrador pode fazer upload da logo de qualquer parceiro.
- MIME e tamanho são validados.

---

# 15. Usuários

## 15.1 Papéis

- **Administrador**: acesso total (capacidade `all`); único perfil com acesso ao painel web.
- **Gestor**: gerencia a própria empresa e seus vendedores, pelo App.
- **Vendedor**: cria e acompanha orçamentos próprios, pelo App.

> Os identificadores numéricos de papel existem no banco, mas **não devem ser usados como critério de autorização** (ver §15.2).

## 15.2 Capacidades

- O administrador gerencia papéis e capacidades (permissões).
- Cada papel tem um conjunto de capacidades.
- A capacidade administrativa é `all`.
- **A autorização administrativa deve ser validada somente por capacidade** (decidido em 10/09/2026). O papel pode ter qualquer nome, e o identificador numérico pode mudar; portanto, nenhuma verificação deve depender de `rol_roleId === 1` nem do nome literal `Administrador`. As verificações atuais por identificador (painel) e por nome (backend) são divergências e devem ser substituídas por verificação de capacidade (ver §24.2).

## 15.3 Criação

- O administrador cria usuários vinculados a um parceiro e papel.
- Pode gerar senha temporária e enviar por e-mail ou PDF.
- O auto-cadastro cria vendedores pendentes (aguardam aprovação do gestor).

## 15.4 Edição

- O administrador edita qualquer usuário.
- O gestor não edita usuários pelo painel (gerencia vendedores pelo App).
- A atualização em lote (gestor) não pode incluir o próprio usuário.
- A alteração de papel em lote é limitada a vendedor/gestor.

## 15.5 Exclusão

- O usuário pode excluir a própria conta (exclusão lógica).
- O administrador pode desativar usuários.

---

# 16. Prospecção

## 16.1 Registro

- Visitantes registram interesse em parceria.
- Nome, e-mail e telefone são obrigatórios; empresa, CNPJ e experiência são opcionais.

## 16.2 Gestão

- O administrador gerencia prospecções (pendentes e contatados).
- Pode marcar como contatado.
- Paginação dupla (pendentes e contatados independentes).

---

# 17. Drive e Arquivos

## 17.1 Estrutura

- Pastas e arquivos hierárquicos.
- Profundidade máxima: 100 níveis.
- Cada item tem dono, tipo, MIME, tamanho, etc.

## 17.2 Acesso

- Todos os perfis visualizam e baixam arquivos compartilhados.
- **Regra:** somente o Administrador cria pastas, envia arquivos e gerencia compartilhamentos; Gestor e Vendedor têm acesso de **leitura apenas, pelo App** (ver RN-DRV-001).
- **Painel (divergência):** a UI exibe controles de criação de pastas/arquivos para qualquer usuário autenticado na visão "own" — o composable `useFilePermissions` define permissões admin-only mas **não é utilizado** no componente. Como o painel deve ser exclusivo do administrador, esses controles precisam ser bloqueados (ver §24.2).
- **App mobile:** a tela "Meus Arquivos" é restrita a administradores; não há UI de criação de pastas/arquivos no mobile. O botão "Compartilhar" no mobile usa compartilhamento de sistema (Share API), não o compartilhamento do Drive.
- Itens compartilhados têm menu de contexto reduzido (apenas ver detalhes, baixar, visualizar).
- Itens próprios têm menu completo (detalhes, compartilhar, gerenciar compartilhamentos, mover, renomear, excluir).

## 17.3 Upload

- Upload direto (síncrono) e assíncrono em duas fases (conteúdo + armazenamento).
- MIME perigoso rejeitado.
- Tamanho máximo configurável (default 1 GiB no Drive — enforcement apenas no fluxo de upload-intent `FileUploadJobService`; o endpoint direto `POST /api/files/` via `ItemService::createFile` não valida tamanho). O file-manager também não valida tamanho, MIME ou extensão no seu fluxo ativo (`FileUploadSchema`) — ver §24.5.
- O upload assíncrono é persistente (retoma após recarregar a página).
- Status terminais: `done`, `error`, `cancelled`, `interrupted`.

## 17.4 Download e visualização

- Download com Content-Disposition attachment.
- Visualização inline para tipos suportados (imagens, PDFs, documentos, vídeos, áudio).
- Streaming com suporte a Range para vídeos e áudio.

## 17.5 Compartilhamento

- Apenas leitura.
- Pastas compartilhadas propagam recursivamente.
- Não permite auto-compartilhamento (verificado no item alvo).
- Não permite duplicidade no item alvo (409); em compartilhamento recursivo, filhos duplicados são atualizados via upsert.
- **Compartilhamento herdado:** novos itens criados dentro de uma pasta compartilhada herdam automaticamente os compartilhamentos do pai; ao mover itens, os compartilhamentos são re-sincronizados.

## 17.6 Capa de vídeo

- Apenas vídeos podem ter capa.
- A capa é uma imagem (JPEG, PNG, GIF ou WebP). **Atualmente** não há validação de tamanho máximo no schema ou service.
- O primeiro upload torna-se a capa padrão; ao excluir a padrão, a próxima ativa é promovida; fallback para a primeira ativa se nenhuma marcada. Não há capa padrão pré-gerada.

## 17.7 Exclusão

- Exige permissão de dono ou admin.
- Remoção física no storage é best-effort.

---

# 18. Relatórios

## 18.1 Vendas por parceiro

- O administrador visualiza vendas por parceiro em um período.
- Gráfico mensal (agrupado por `YYYY-MM`).
- Períodos de três meses ou mais são agrupados mensalmente; períodos menores, diariamente. Em ambos os casos, registros com a mesma chave temporal são somados.

## 18.2 Orçamentos por vendedor

- O administrador visualiza orçamentos de um vendedor.
- Filtros: status, arquivamento, data, localização (cidade/estado, no cliente).
- Orçamentos ordenados por criação descendente.
- Apenas orçamentos principais (exclui versões anteriores).

## 18.3 Histórico de versões

- O administrador visualiza o histórico de versões de um orçamento.
- **Inclui a versão atual**, cujo identificador é informado separadamente para que possa ser distinguida das anteriores (ver RN-REL-003).

## 18.4 Dashboard

- Vendas por período, orçamentos por status, arquivos recentes.
- Apenas administrador.
- O gráfico de vendas soma os registros com a mesma chave temporal; períodos com menos de três meses são agrupados por dia e períodos de três meses ou mais, por mês (ver RN-DSH-001).

---

# 19. Geração e Exportação

## 19.1 PDF do orçamento

- Gera PDF com identidade visual do parceiro (logo).
- Dados do vendedor (nome, cargo, telefone, e-mail) são obrigatórios.
- Contém produtos, quantidades, valores unitários, totais por subcategoria/categoria/geral.
- Renova a validade pelo prazo salvo a partir da operação; somente expirado passa a pendente (ver RN-ORC-013).
- O conteúdo é escapado para segurança.

## 19.2 Exportação de censo (CSV)

- Exporta os indicadores e valores do snapshot do orçamento em CSV.
- Formatação com 2 casas decimais — apresentação apenas, sem efeito sobre o valor de cálculo (ver §12.8).

## 19.3 PDF de credenciais (carta senha individual)

- Ao criar usuário (admin), o sistema pode gerar PDF de credenciais contendo **apenas o usuário correspondente**.
- Baixado com nome `credenciais_<email>.pdf`.

## 19.4 PDF de acessos do parceiro (carta senha consolidada)

- Ao criar parceiro, o sistema pode gerar PDF de acessos **consolidado, com uma página para cada usuário criado** no cadastro da empresa.
- Baixado com nome `Acessos_<nome>.pdf`.

> **Terminologia.** "Carta senha" e "PDF de credenciais" designam o **mesmo tipo de artefato**; a diferença entre §19.3 e §19.4 é apenas o contexto (usuário individual ou cadastro de parceiro). O termo "carta senha" é o nome de negócio e aparece, por exemplo, no assunto do e-mail. Ponto encerrado em 10/09/2026.

---

# 20. Validações

## 20.1 Autenticação

- E-mail e senha obrigatórios.
- OTP obrigatório **apenas no painel web**; 6 dígitos. No App, nenhum perfil usa OTP.
- OTP expira em 5 minutos; **não há** limite de tentativas inválidas (regra adotada — ver RN-AUT-003).

## 20.2 Usuários

- Nome, e-mail, telefone, empresa e papel obrigatórios (criação).
- E-mail único.
- Telefone normalizado (apenas dígitos).
- Avatar: MIME e tamanho validados.

## 20.3 Parceiros

- Nome, nome fantasia, CNPJ, e-mail, telefone obrigatórios (criação).
- CNPJ único.
- URL opcional (mas se preenchida, deve ser válida).
- Logo: MIME e tamanho.
- Contrato: PDF até 10 MiB.

## 20.4 Orçamentos

- Validade 1–365 dias (schema: `v::intType()->positive()->max(365)`).
- Nome (multi-cidade): obrigatório (validação cross-field no schema).
- **Validação parcial: App bloqueia, API aceita** (ver §9.4):
  - Cidade com censo (exceto personalizado): **não verificado na API** — apenas status/excluido/estado são checados.
  - Pelo menos 1 produto selecionado: **não verificado na API** — `produtos_selecionados` é opcional; o service cria produtos ativos automaticamente.
  - Total > 0: **bloqueado pelo App**, que impede finalizar com total ≤ 0; na API, criação e edição usam `v::floatVal()->min(0)` e ambas aceitam zero (ver §24.3).

## 20.5 Catálogo

- Categoria: nome único.
- Subcategoria: nome único; categoria existente.
- Produto: ISBN obrigatório (livro); produtos relacionados (serviço); percentual de 0 a 100 (0 é válido); horas fixas ≥ 0.

## 20.6 Drive

- MIME perigoso rejeitado.
- Tamanho máximo (1 GiB default — enforcement apenas no fluxo de upload-intent; o endpoint direto `POST /api/files/` não valida tamanho). O file-manager também não valida tamanho, MIME ou extensão no seu fluxo ativo (ver §24.5).
- Profundidade máxima 100 (webservice: `DriveHierarchyPolicy::MAX_DEPTH = 100`).
- Nome: obrigatório, máx. 255 (apenas no upload-intent). **Atualmente** apenas `/`, `\`, `\0` e extensões perigosas são rejeitados — o conjunto completo `< > : " | ? *` **não é validado** (ver §24.5). Schemas genéricos (`FolderSchema`, `ItemSchema`) apenas exigem `notEmpty`, sem limite de tamanho ou caracteres.

> **Nota.** O File Manager é restrito por `.htaccess` ao webservice/rede local (ver §21.1), mas isso é uma restrição de **acesso**, não uma validação do arquivo. A cobertura de limite máximo, MIME, extensão e nome de arquivo continua incompleta no fluxo ativo do File Manager e no endpoint direto `POST /api/files/` do webservice.
- Compartilhamento: destinatário existe, não é o dono, não duplicado (verificado no item alvo; em compartilhamento recursivo de pasta, filhos duplicados são atualizados via upsert, não rejeitados).

## 20.7 Censo

- Grupo: nome obrigatório.
- Índice: ordenação, valor padrão, percentual de população.
- Percentual > 0 e ≤ 100 (atualização de população).

## 20.8 Prospecção

- Nome, e-mail, telefone obrigatórios.

## 20.9 Recuperação de senha

- OTP 6 dígitos.
- Nova senha: maiúscula, caractere especial, mínimo de caracteres.

---

# 21. Requisitos Não Funcionais

## 21.1 Segurança

**Regras confirmadas**

- Autenticação JWT com expiração e validação server-side.
- Logout invalida o token no servidor.
- OTP por e-mail **apenas no painel web** e na recuperação de senha; o App autentica com e-mail e senha (ver RN-AUT-001).
- OTP expira em 5 minutos e **não** possui limite de tentativas inválidas — regra adotada, com o risco de força bruta aceito (ver RN-AUT-003).
- Senha temporária para novos usuários (opcional).
- **Autorização administrativa por capacidade**, nunca por identificador fixo ou nome de papel (ver §15.2).
- **Autorização por objeto** em todas as operações sobre orçamento, inclusive as que recebem o identificador diretamente (ver RN-ORC-005).
- Verificação de propriedade (parceiro, orçamento, item do Drive).
- Prevenção de auto-edição em lote.
- MIME e tamanho validados em uploads.
- Caminhos de storage sanitizados (sem path traversal).
- Conteúdo do PDF escapado.
- Transações em operações críticas.
- Escrita atômica de metadados.
- Remoção segura de diretórios (validação de root).

**Tratamento de erros e logs (decidido em 10/09/2026)**

- **Em produção, todas as respostas de erro devem ser sanitizadas.** Nenhuma resposta pode expor stack trace, caminhos internos, nomes de arquivo, números de linha, cabeçalhos ou corpo da requisição. `displayErrorDetails` deve ser `false` em produção e **controlado por variável de ambiente**.
- **Logs internos podem registrar informações técnicas para diagnóstico**, mas devem **ocultar ou redigir** tokens, senhas, OTPs, cookies, cabeçalhos de autorização e demais dados sensíveis ou pessoais. Não devem persistir corpo e cabeçalhos completos sem sanitização. A política de retenção e redação dos logs é tratada separadamente da sanitização das respostas.
- **Divergência atual:** no File Manager, `displayErrorDetails` está fixo em `true`, sem override por ambiente. O middleware customizado sanitiza as exceções lançadas dentro de rotas `/api` já correspondidas, mas rotas fora de `/api` e erros 404 de qualquer rota (inclusive `/api/*` inexistentes) expõem stack traces. Os logs gravam corpo e cabeçalhos completos (ver §24.6).

**Isolamento do File Manager (premissa arquitetural de implantação)**

- O File Manager é acessado **exclusivamente pelo webservice** (confirmado em 10/09/2026). O `.htaccess` versionado restringe o acesso aos IPs `10.1.0.1`, `127.0.0.1` e `::1`.
- Sob essa fronteira, confiar no `userId` encaminhado pelo webservice é uma **decisão arquitetural aceita**.
- Esta premissa é um **requisito de implantação** e deve ser verificada no ambiente: o Apache precisa honrar o `.htaccess` e a porta do File Manager **não pode ficar exposta externamente**.
- Se essa fronteira deixar de existir, o File Manager passará a ter de **validar propriedade e compartilhamento por conta própria**.
- Atenção: a restrição por `.htaccess` é um controle de **acesso**, não uma validação do conteúdo dos arquivos enviados (ver §20.6).

**Riscos técnicos aceitos e pendências conhecidas**

- Identificação do App pelo cabeçalho `User-Agent: App-Orcamentos-V1` para dispensar o OTP: o cabeçalho pode ser imitado. Aceito por ora; reavaliar se o modelo de ameaça mudar (ver RN-AUT-001).
- Ausência de limite de tentativas de OTP: risco de força bruta na janela de 5 minutos, aceito por ora (ver RN-AUT-003).
- Coluna `otp_attempts` presente mas não funcional (inicializada como `true`, nunca incrementada — ver RN-AUT-003).
- **Painel sem middleware de bloqueio por papel**: qualquer usuário autenticado alcança as páginas, inclusive com token obtido pelo App. O middleware de papel deve ser implementado (ver §24.2).
- Enforcement de tamanho de upload incompleto fora do fluxo de upload-intent (ver §20.6 e §24.5).
- Compartilhamento herdado automático: itens novos em pasta compartilhada herdam os compartilhamentos do pai (ver RN-DRV-005).

## 21.2 Desempenho

- Paginação em listagens.
- Upload assíncrono em duas fases com retomada.
- Streaming com Range para vídeos/áudio.
- Cache de pastas no Drive (App).
- Deduplicação de respostas stale (painel).

## 21.3 Disponibilidade

- O sistema não funciona offline.
- Falhas parciais na atualização de população não abortam o todo.

## 21.4 Usabilidade

- App mobile em português (pt-BR).
- Painel web em português.
- Tema escuro/claro no painel: ao abrir, o tema efetivo **deve seguir a preferência do sistema operacional** (`prefers-color-scheme`). Decidido em 10/09/2026 que **não há requisito de persistir uma escolha manual entre sessões** — ao reabrir o painel, a configuração do sistema operacional volta a prevalecer. O comportamento atual está alinhado com a regra.
- Wiki/ajuda estática no App.

## 21.5 Compatibilidade

- App: Android e iOS.
- Painel: aplicação web de página única, servida estaticamente.
- Backend: serviço web em PHP.
- File Manager: serviço web em PHP.

## 21.6 Manutenibilidade

- Código organizado em domínios (App, painel e backend separados).
- Regras de negócio isoladas em camada própria.
- Políticas para invariantes (ex.: profundidade do Drive).

---

# 22. Critérios de Aceite

> Formato **Dado que / Quando / Então**. Agrupados por domínio.

## Autenticação

### CA-AUT-001 — Login com OTP (painel)

**Dado que** o administrador informou e-mail e senha válidos
**Quando** o sistema enviar o OTP e o administrador digitar o código correto
**Então** o sistema deve autenticar e emitir o token de sessão.

### CA-AUT-002 — Login com senha inválida

**Dado que** o usuário informou e-mail válido e senha inválida
**Quando** tentar autenticar
**Então** o sistema deve rejeitar com "Credenciais inválidas".

### CA-AUT-003 — Logout

**Dado que** o usuário está autenticado
**Quando** solicitar logout
**Então** o sistema deve invalidar o token no servidor e o cliente deve limpar a sessão.

### CA-AUT-004 — Recuperação de senha

**Dado que** o usuário informou e-mail cadastrado
**Quando** receber o OTP e informar nova senha válida
**Então** o sistema deve atualizar a senha e permitir o login.

### CA-AUT-005 — Login no App sem OTP

**Dado que** qualquer perfil — inclusive o Administrador — está autenticando pelo App
**Quando** informar e-mail e senha válidos
**Então** o sistema deve emitir o token de sessão diretamente, sem solicitar OTP.

## Cadastro

### CA-REG-001 — Verificar empresa ativa

**Dado que** o visitante informou CNPJ de empresa parceira ativa
**Quando** consultar
**Então** o sistema deve retornar os dados públicos da empresa e habilitar o cadastro.

### CA-REG-002 — Verificar empresa inativa

**Dado que** o visitante informou CNPJ de empresa parceira inativa
**Quando** consultar
**Então** o sistema deve retornar a empresa, mas bloquear o prosseguimento ao cadastro.

### CA-REG-003 — Auto-cadastro

**Dado que** o visitante encontrou empresa ativa
**Quando** informar nome, e-mail, telefone e senha válidos
**Então** o sistema deve criar o usuário como vendedor pendente, vinculado à empresa.

## Usuários

### CA-USR-001 — Criar usuário (admin)

**Dado que** o administrador informou dados válidos
**Quando** confirmar a criação do usuário
**Então** o sistema deve criar o usuário e, opcionalmente, enviar credenciais por e-mail ou gerar o PDF de credenciais (carta senha).

### CA-USR-002 — Atualizar em lote (gestor)

**Dado que** o gestor marcou alterações para 3 vendedores da própria empresa
**Quando** salvar o lote
**Então** o sistema deve aplicar cada alteração individualmente e reportar sucessos e falhas.

### CA-USR-003 — Auto-edição bloqueada em lote

**Dado que** o gestor marcou alteração para o próprio usuário
**Quando** salvar o lote
**Então** o sistema deve rejeitar a alteração do próprio usuário.

## Parceiros

### CA-PAR-001 — Criar parceiro

**Dado que** o administrador informou dados da empresa e do gestor responsável
**Quando** confirmar a criação
**Então** o sistema deve criar a empresa e o gestor em transação.

### CA-PAR-002 — Desativar parceiro

**Dado que** o administrador desativou um parceiro
**Quando** confirmar
**Então** o sistema deve desativar o parceiro e seus usuários em cascata.

## Orçamentos

### CA-ORC-001 — Criar orçamento com Censo

**Dado que** o usuário possui acesso e selecionou uma cidade com censo
**Quando** confirmar a criação do orçamento
**Então** o sistema deve criar uma cópia independente do Censo e calcular os produtos selecionados.

### CA-ORC-002 — Criar multi-cidade

**Dado que** o usuário selecionou múltiplas cidades com censo
**Quando** confirmar a criação
**Então** o sistema deve criar o orçamento com censo agregado (soma por etapa).

### CA-ORC-003 — Criar personalizado

**Status:** Planejado para uma próxima versão; não aplicável ao App atual.

**Dado que** o usuário optou por orçamento personalizado
**Quando** informar valores manuais e salvar
**Então** o sistema deve criar o orçamento sem cidade vinculada, com os valores informados.

### CA-ORC-004 — Editar orçamento

**Dado que** o usuário tem permissão (dono, admin ou gestor da empresa)
**Quando** editar produtos, indicadores, validade ou status
**Então** o sistema deve recalcular quantidades e total e persistir.

### CA-ORC-005 — Versionar orçamento

**Dado que** o usuário tem permissão
**Quando** solicitar versionamento
**Então** o sistema deve arquivar o original e criar uma nova versão com produtos, quantidades e overrides preservados.

### CA-ORC-006 — Arquivar/desarquivar

**Dado que** o orçamento existe
**Quando** arquivar ou desarquivar
**Então** o sistema deve inverter o flag de arquivamento sem alterar o status.

### CA-ORC-007 — Quantidade manual

**Dado que** o produto está no orçamento
**Quando** o usuário ativar modo manual e informar quantidade
**Então** o sistema deve usar a quantidade manual, ignorando o cálculo automático.

### CA-ORC-008 — Gerar PDF

**Dado que** o orçamento existe e o vendedor tem dados preenchidos
**Quando** solicitar o PDF
**Então** o sistema deve gerar o PDF com identidade visual do parceiro.

### CA-ORC-009 — Exportar censo

**Dado que** o orçamento tem censo
**Quando** solicitar exportação
**Então** o sistema deve gerar o CSV com indicadores e valores.

### CA-ORC-010 — PDF renova a validade pelo prazo salvo

**Dado que** o orçamento está expirado
**Quando** o usuário gerar ou compartilhar o PDF
**Então** o sistema deve renovar a validade pelo prazo salvo em `orc_dias_validade`, contado da operação, e passar somente o status expirado para pendente, sem criar versão ou alterar arquivamento.

### CA-ORC-011 — Edição com lista de produtos vazia

**Dado que** o orçamento possui produtos
**Quando** a atualização enviar `produtos` como lista vazia, nulo ou omitir o campo
**Então** o sistema deve preservar os produtos existentes, em qualquer um dos três casos.

### CA-ORC-012 — Versionar preserva a versão anterior

**Dado que** o produto X tem quantidade 200 na versão atual
**Quando** o usuário versionar e alterar a quantidade de X para 100
**Então** a versão anterior deve continuar registrando 200, a nova versão deve registrar 100 e o censo da versão anterior deve ser mantido na nova versão, sem substituição pelo censo atual da cidade.

## Cálculos

### CA-CAL-001 — Livro sem professores

**Dado que** o livro tem indicadores `in5ano` (120) e `ef1ano` (80) selecionados, sem "professores"
**Quando** calcular
**Então** a quantidade deve ser 200.

### CA-CAL-002 — Livro com professores

**Dado que** o livro tem indicadores `in5ano` e `professores` selecionados; `in5anoP` = 10
**Quando** calcular
**Então** a quantidade deve ser 10.

### CA-CAL-003 — Tecnologia com professores

**Dado que** a tecnologia tem indicadores `in5ano` e `professores`; `in5ano` = 120, `in5anoP` = 10
**Quando** calcular
**Então** a quantidade deve ser 130.

### CA-CAL-004 — Serviço

**Dado que** o serviço tem produtos relacionados com quantidades 200 e 130; percentual 8%; horas fixas 5
**Quando** calcular
**Então** a quantidade deve ser (330 × 0.08) + 5 = 31.4 (sem arredondamento).

### CA-CAL-005 — Sem arredondamento

**Dado que** a regra atual é "sem arredondamento"
**Quando** calcular qualquer quantidade
**Então** o resultado não deve ser arredondado (a implementação atual diverge — ver §24.1).

## Censo

### CA-CEN-001 — Snapshot independente

**Dado que** o orçamento foi criado em janeiro
**Quando** o censo oficial da cidade é atualizado em fevereiro
**Então** o orçamento deve manter os valores de janeiro.

### CA-CEN-002 — Atualização parcial de população

**Dado que** a atualização de população é disparada para 50 cidades
**Quando** 2 cidades falham (timeout IBGE)
**Então** o sistema deve reportar as 2 falhas, mas concluir as 48 com sucesso.

## Catálogo

### CA-CAT-001 — Criar serviço sem produtos relacionados

**Dado que** o administrador tenta criar serviço sem produtos relacionados
**Quando** salvar
**Então** o sistema deve rejeitar.

### CA-CAT-002 — Reordenar

**Dado que** o administrador arrasta um item para nova posição
**Quando** soltar
**Então** o sistema deve calcular a nova ordem (ponto médio) e persistir.

## Drive

### CA-DRV-001 — Upload

**Dado que** o administrador seleciona um arquivo válido
**Quando** confirmar o upload
**Então** o sistema deve armazenar o arquivo e disponibilizá-lo.

### CA-DRV-002 — Compartilhar

**Dado que** o dono seleciona um destinatário válido
**Quando** compartilhar
**Então** o sistema deve conceder acesso de leitura ao destinatário.

### CA-DRV-003 — Compartilhar pasta recursivamente

**Dado que** o dono compartilha uma pasta
**Quando** confirmar
**Então** o sistema deve conceder acesso a todo o conteúdo da pasta.

## Relatórios

### CA-REL-001 — Vendas por parceiro

**Dado que** o administrador seleciona um período
**Quando** solicitar o relatório
**Então** o sistema deve retornar vendas agregadas por parceiro e por mês.

## Permissões

### CA-PER-001 — Vendedor não vê orçamentos de outros

**Dado que** o vendedor está autenticado
**Quando** listar orçamentos
**Então** o sistema deve retornar apenas os próprios orçamentos.

### CA-PER-002 — Gestor vê orçamentos da empresa

**Dado que** o gestor está autenticado
**Quando** listar orçamentos
**Então** o sistema deve retornar orçamentos de todos os vendedores da própria empresa.

### CA-PER-003 — Autorização por objeto em operação por identificador

**Dado que** o vendedor está autenticado e conhece o identificador de um orçamento de outro vendedor
**Quando** solicitar visualização, edição, exclusão, PDF, CSV, censo, arquivamento ou versionamento desse orçamento
**Então** o sistema deve negar a operação em todos os casos, e não apenas ocultá-lo da listagem.

### CA-PER-004 — Gestor e vendedor bloqueados no painel

**Dado que** um gestor ou vendedor obteve um token válido pelo App
**Quando** tentar acessar qualquer página do painel administrativo web com esse token
**Então** o painel deve bloquear o acesso e redirecioná-lo, sem depender apenas do bloqueio de login do backend.

---

# 23. Glossário

- **Censo Escolar**: Conjunto de indicadores demográficos escolares por município (alunos e professores por etapa).
- **Indicador**: Métrica do Censo Escolar para uma etapa de ensino (ex.: `in5ano` = alunos do 5º ano).
- **Indicador de aluno**: Indicador que conta alunos (sem sufixo `P`).
- **Indicador de professor**: Indicador que conta professores (com sufixo `P`).
- **Etapa**: Nível de ensino (ex.: maternal, berçário, 5º ano, 1º ano EM, EJA).
- **Livro do estudante**: Produto do tipo livro, cuja quantidade é calculada pelos indicadores de aluno (e professor, se selecionado).
- **Livro do professor**: Quantidade de livro calculada quando "professores" está selecionado, somando os indicadores de professor correspondentes.
- **Tecnologia**: Produto do tipo tecnologia, cuja quantidade soma indicadores de aluno e professor (se selecionado).
- **Serviço**: Produto do tipo serviço, cuja quantidade é calculada como (soma dos produtos relacionados × percentual) + horas fixas.
- **Quantidade manual**: Quantidade informada manualmente pelo usuário que sobrescreve o cálculo automático.
- **Override**: Sobrescrita de preço de um produto em um orçamento específico.
- **Orçamento multi-cidade**: Orçamento que abrange múltiplas cidades, com censo agregado (soma por etapa).
- **Versão**: Cópia de um orçamento criada ao versionar; o original é arquivado e a nova versão é vinculada a ele.
- **Validade**: Data limite do orçamento (`agora + dias_validade`); ao expirar, o status muda para `expirado`.
- **Arquivamento**: Marcação ortogonal ao status que remove o orçamento da listagem ativa sem excluí-lo.
- **Parceiro**: Empresa parceira da Multimídia, à qual gestores e vendedores estão vinculados.
- **Gestor**: Perfil que gerencia a própria empresa e seus vendedores.
- **Vendedor**: Perfil que cria e acompanha orçamentos próprios.
- **Drive**: Repositório de arquivos comerciais e técnicos compartilhados entre a Multimídia e os parceiros.
- **Snapshot**: Cópia independente do censo feita ao criar o orçamento; não é afetada por atualizações do censo oficial.
- **Censo agregado**: Soma dos valores por etapa entre as cidades de um orçamento multi-cidade.
- **OTP**: Código de uso único (one-time password) enviado por e-mail para autenticação ou recuperação de senha.
- **Prospecção**: Registro de interesse em parceria feito por um visitante.
- **Diferencial**: Característica diferencial vinculada a categorias, subcategorias ou produtos.
- **Produto relacionado**: Produto vinculado a um serviço para cálculo de horas (não pode ser outro serviço).
- **Divergência**: Ponto em que o comportamento atual do código não corresponde à regra descrita neste documento; todas estão consolidadas na seção 24.
- **Carta senha**: Nome de negócio do PDF com as credenciais de acesso de um usuário; o mesmo artefato aparece no código como "PDF de credenciais" (individual) ou "PDF de acessos" (consolidado por parceiro).

---

# 24. Divergências conhecidas entre regra e implementação

> Lista consolidada dos pontos em que o **comportamento atual do código não corresponde à regra** descrita neste documento. Cada item aponta a seção em que a regra está definida, para que a correção possa ser planejada sem releitura completa.
>
> Todos os itens foram verificados contra o código-fonte dos quatro repositórios (webservice de orçamentos, file manager, painel web e App); parte deles foi adicionalmente comprovada em ambiente local. Itens já **decididos e alinhados** com a implementação não aparecem aqui — eles estão descritos como regra no corpo do documento.

## 24.1 Arredondamento e precisão numérica

Regra aplicável: §12 (cálculos sem arredondamento) e §12.8 (duas casas decimais são apresentação, não cálculo).

| Onde | Regra | Comportamento atual |
|---|---|---|
| Quantidade de serviço | Sem arredondamento | `floor($quantidade)` em `OrcamentoService.php:525` e `:594` |
| Horas de serviço (repositório) | Sem arredondamento | `floor($horasCalculadas)` em `ProdutoRepository.php:737` |
| Horas de serviço (utilitário) | Sem arredondamento | `floor($quantidade * $percentual) + $horasFixas` em `CalculosProdutos.php:57` |
| `in4ano` / `in5ano` | Sem arredondamento | `ceil($valor)` em `OrcamentoService.php:692`, `CalculosProdutos.php:64` e `CensoValueNormalizer.php:19` |
| População IBGE | Sem arredondamento | `floor(populacao * fracao)` em `CidadesPopulacaoService.php:354` |
| Total do dashboard | Precisão preservada no cálculo | `round($totalGeral, 2)` em `DashboardService.php:49` |
| Casts monetários | Duas casas são apresentação | `decimal:2` em `orc_total`, `op_quantidade`, `op_valor`, `pro_valor`, `pro_horas_fixas` e `opo_valor_override` arredonda **ao ler do banco**, antes do uso em operações subsequentes |

> **Sem impacto de negócio:** `floor`/`round` em indicadores de progresso (técnico) e `number_format` no PDF e no CSV (apresentação). Conforme §12, arredondamento de **quantidade** e precisão **monetária** são assuntos distintos e devem ser corrigidos separadamente.

## 24.2 Autorização e acesso

| Item | Regra | Comportamento atual |
|---|---|---|
| Painel exclusivo do administrador | §4, §21.1 | O painel usa apenas o middleware de autenticação; não há bloqueio por papel. Um gestor ou vendedor com token obtido pelo App navega pelas páginas. O backend bloqueia o login não-mobile para não-admins, mas esse bloqueio não cobre o token vindo do App. |
| Administrador por capacidade | §15.2 | O painel verifica `rol_roleId === 1` (`useFilePermissions.js`) e o backend compara o nome literal `'Administrador'` (`OrcamentoService.php:270-272`). A capacidade `all` existe no seed, mas não é usada na verificação. |
| Autorização por objeto | RN-ORC-005 | O escopo é aplicado nas listagens e na edição, mas diversas rotas por identificador verificam apenas capacidades genéricas, sem checar propriedade do orçamento. |
| Drive administrado só pelo administrador | RN-DRV-001, §17.2 | A UI do painel exibe "Criar Pasta" e "Upload Arquivo" para qualquer usuário autenticado na visão "own"; o composable define as permissões como admin-only, mas não é utilizado pelo componente. |

## 24.3 Orçamento

| Item | Regra | Comportamento atual |
|---|---|---|
| Renovação da validade por PDF | RN-ORC-013 | Prazo salvo confirmado em 12/09/2026; corrigida transição somente de expirado para pendente. Evidências e limites de aceitação constam no relatório dos Itens 7/8/10/11, sem substituir resultados históricos. |
| E-mail do vendedor no PDF | RN-ORC-012 | `email_vendedor` é **opcional** no schema; quando ausente, vira string vazia e o PDF é gerado sem o e-mail. |
| Validações de criação | §9.4, §20.4 | Pela API, são aceitos `orc_total: 0`, ausência de `produtos_selecionados` (o service cria todos os ativos) e cidade sem confirmação de censo. O App bloqueia total ≤ 0; a API não. |
| Arquivamento duplo | RN-ORC-009, §8 | Coexistem o booleano `orc_is_archived` e o valor `arquivado` no enum de `orc_status`, aceito por schemas, migration, OpenAPI e relatórios. Registrado como estado atual, para decisão futura. |
| Renomear | RN-ORC-010 | Alinhado à regra vigente: 1 a 255 caracteres, sem rejeição de nome igual. A faixa de 3 a 100 e a exigência de nome diferente são regra superada, não divergência. |

## 24.4 Catálogo, relatórios e dashboard

| Item | Regra | Comportamento atual |
|---|---|---|
| Status do produto | RN-CAT-008 | O painel envia `pro_status: true` de forma incondicional na criação e na edição; o estado escolhido na tela aparece apenas em `pro_ativo`. |
| Agregação do gráfico de vendas | RN-DSH-001 | O dashboard mapeia cada registro diretamente para uma categoria, sem somar chaves repetidas; dias ou meses podem aparecer duplicados. Os relatórios de parceiro/vendedor já agregam, mas o dashboard não usa essa implementação. |

## 24.5 Drive e File Manager

| Item | Regra | Comportamento atual |
|---|---|---|
| Limite de 1 GiB no upload | RN-DRV-002, §20.6 | O limite é aplicado apenas no fluxo de upload-intent do webservice. O endpoint direto `POST /api/files/` não valida tamanho. |
| MIME, extensão e tamanho no File Manager | §20.6 | O schema ativo (`FileUploadSchema`) valida apenas que o arquivo foi recebido sem erro. O schema completo (`FileSchema`) existe, mas é **código morto** — não é referenciado por nenhuma rota. |
| Caracteres proibidos no nome de arquivo | §20.6 | Apenas `/`, `\`, `\0` e extensões perigosas são rejeitados; `< > : " \| ? *` não são validados. Schemas genéricos exigem apenas `notEmpty`. |
| Tamanho da capa de vídeo | RN-DRV-009 | Não há limite máximo enforceado no schema nem no service. |

> A restrição do File Manager por `.htaccess` (§21.1) é um controle de **acesso** e não substitui nenhuma destas validações de conteúdo.

## 24.6 Segurança operacional

| Item | Regra | Comportamento atual |
|---|---|---|
| Sanitização de erros em produção | §21.1 | `displayErrorDetails` está fixo em `true` no File Manager, sem override por ambiente. O middleware customizado sanitiza apenas exceções lançadas dentro de rotas `/api` já correspondidas; rotas fora de `/api` e erros 404 de qualquer rota (inclusive `/api/*` inexistentes) expõem stack trace, caminho e linha. |
| Redação de logs | §21.1 | Os logs persistem corpo da requisição e cabeçalhos completos, sem redação de dados sensíveis. |
| Campo `otp_attempts` | RN-AUT-003 | Criado como `integer` na migration, castado como `boolean` no model, inicializado com `true` e nunca incrementado. Campo não funcional: deve passar a ter uso ou ser removido. |

## 24.7 Pendência de rastreabilidade

A **matriz de rastreabilidade** que vincula requisito ↔ regra ↔ critério de aceite ↔ código, incluindo a definição das fontes documentais originais (`F1` a `F7`), **nunca foi produzida**. Esta é uma lacuna do conjunto documental que não pode ser resolvida a partir do código: depende dos documentos de especificação originais. Ela não afeta a leitura desta especificação, que é autocontida, mas impede auditar a origem de cada regra.

---
