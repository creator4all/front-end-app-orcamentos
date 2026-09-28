# Casos de Teste — Atualização do Aplicativo

> **Fonte funcional:** `ATUALIZACAO_APLICATIVO.md`.
> **Fonte técnica mobile:** `lib/main.dart`, `lib/app_module.dart`, `lib/app/shared/core/update/app_update_coordinator.dart`, `lib/app/shared/core/http/interceptors/version_checker_interceptor.dart`, `lib/app/shared/core/navigation/app_route_observer.dart` e `lib/app/shared/widgets/custom_info_dialog.dart`.
> **Fonte técnica backend:** `webservice-app-orcamentos/app/Middleware/AppVersionMiddleware.php` e configuração `mobile_app_update` do backend.
> **Escopo:** atualização obrigatória determinada pelo backend, atualização opcional consultada na loja, prioridade entre os fluxos e implantação compatível com versões legadas.
> **Convenção:** `CT-MOB-UPD-NNN` para casos executados pela interface e `VER-UPD-NNN` para verificações técnicas de contrato.
> **Execução:** interação real pela interface via Mobile MCP em emulador Android. As verificações `VER-UPD-*` não substituem os casos mobile.
> **Relação com a suíte principal:** documento complementar a `docs/testes/casos-de-teste.md`; não altera os IDs nem a contagem da suíte principal.

## 1. Regras da execução

Para cada execução, registrar: **resultado esperado**, **resultado obtido**, **status** (`Passou`, `Falhou`, `Parcial` ou `Bloqueado`), **dispositivo**, **usuário/papel**, **data** e **evidência**.

- Não considerar uma chamada direta de API como execução de um caso `CT-MOB-UPD-*`.
- As chamadas diretas ao backend são permitidas somente para os casos `VER-UPD-*`.
- Não registrar tokens, senhas, cookies, chaves ou outros segredos nas evidências.
- Usar um backend controlado para alterar o build mínimo sem afetar ambientes compartilhados.
- Restaurar proxy, `adb reverse`, containers temporários e demais recursos após a execução.
- A flag `FORCE_OPTIONAL_UPDATE=true` é permitida somente em build de debug para validar o fluxo opcional sem depender de uma publicação real na loja.
- Um teste forçado comprova apresentação, ações e controle por processo, mas não comprova que a Play Store ou App Store informou corretamente uma nova versão.
- A instalação efetiva da atualização pela loja não faz parte desta suíte.

## 2. Dados e ambientes de referência

| Item | Valor de referência |
|---|---|
| Identificador mobile | `br.com.multimidiaeducacional.parceiro` |
| Versão instalada usada na execução | `1.1.0` |
| Build instalado usado na execução | `33` |
| Build mínimo Android para forçar bloqueio | `34` |
| Build mínimo desativado | `0` |
| Plataforma principal | Android 15 em emulador |
| Loja Android | Google Play |
| Loja iOS | App Store |

### 2.1 Ambientes

| Perfil | Configuração | Finalidade |
|---|---|---|
| **A — Backend normal** | Build mínimo Android/iOS igual a `0` | Validar operação sem bloqueio e atualização opcional |
| **B — Backend forçado** | Build mínimo Android `34` para app build `33` | Validar resposta `426` e atualização obrigatória |
| **C — Backend indisponível** | Conexão recusada, timeout ou ausência de rede | Confirmar que erro de rede não ativa atualização obrigatória |
| **D — Loja com versão mais nova** | Versão real publicada acima da instalada | Validar consulta real da loja sem flag de força |

---

## 3. Verificações do contrato de backend (VER)

### VER-UPD-001 — Cliente legado sem headers não é bloqueado
**Pré-condição:** Backend com política de atualização carregada.
**Passos:** Enviar uma requisição protegida sem `App-Identifier`, `App-Build`, `App-Platform` e `App-Version`.
**Esperado:** A requisição não recebe `426`; segue para a autenticação ou controller correspondente.
**Rastreabilidade:** implantação segura; compatibilidade com aplicativo legado e painel web.

### VER-UPD-002 — Build mínimo zero mantém bloqueio desativado
**Pré-condição:** `APP_MINIMUM_BUILD_ANDROID=0`.
**Passos:** Enviar requisição identificada como aplicativo Android com build inferior ao publicado.
**Esperado:** A requisição não recebe `426`; valor `0` funciona como bloqueio desativado.
**Rastreabilidade:** configuração `mobile_app_update.platforms.android.minimum_build`.

### VER-UPD-003 — Android abaixo do mínimo recebe 426
**Pré-condição:** Build Android instalado `33`; mínimo configurado `34`.
**Passos:** Enviar requisição com os quatro headers do aplicativo.
**Esperado:**
- Status `426 Upgrade Required`.
- `Content-Type: application/json; charset=utf-8`.
- Corpo com `code: APP_UPDATE_REQUIRED`, mensagem controlada e URL da Google Play.
**Rastreabilidade:** `AppVersionMiddleware`.

### VER-UPD-004 — Build igual ao mínimo continua normalmente
**Pré-condição:** Build Android instalado e mínimo configurado iguais a `34`.
**Passos:** Enviar requisição identificada sem JWT para uma rota protegida.
**Esperado:** Não recebe `426`; chega à autenticação e recebe o resultado normal do JWT.
**Rastreabilidade:** comparação por build em `AppVersionMiddleware`.

### VER-UPD-005 — Android e iOS possuem políticas independentes
**Pré-condição:** Mínimos Android e iOS configurados com valores diferentes.
**Passos:** Repetir a requisição com `App-Platform: android` e `App-Platform: ios`.
**Esperado:** Cada plataforma usa seu próprio build mínimo e sua própria URL de loja.
**Rastreabilidade:** `mobile_app_update.platforms`.

### VER-UPD-006 — App identificado com build ausente ou inválido é bloqueado
**Pré-condição:** Build mínimo da plataforma maior que zero.
**Passos:** Repetir a requisição sem `App-Build` e com `App-Build` não numérico.
**Esperado:** As duas requisições recebem `426`.
**Rastreabilidade:** validação `FILTER_VALIDATE_INT`.

### VER-UPD-007 — Plataforma não suportada fica fora da política mobile
**Pré-condição:** Identifier correto e plataforma diferente de Android/iOS.
**Passos:** Enviar `App-Platform: windows` com build baixo.
**Esperado:** Não recebe `426`; segue para a autenticação ou controller.
**Rastreabilidade:** validação explícita por `array_key_exists`.

---

## 4. Atualização obrigatória (OBR)

### CT-MOB-UPD-001 — Exibir atualização obrigatória após 426
**Pré-condição:** App build `33` conectado ao perfil B, cujo mínimo Android é `34`.
**Passos:**
1. Iniciar o aplicativo.
2. Executar uma operação normal que consulte o backend, como restaurar sessão ou autenticar.
3. Aguardar a resposta.
**Esperado:** A modal **Atualização necessária** é apresentada e impede a continuidade no App.
**Rastreabilidade:** resposta `426`; `VersionCheckerInterceptor`; `AppUpdateCoordinator.requireUpdate`.

### CT-MOB-UPD-002 — Conteúdo e ações da modal obrigatória
**Pré-condição:** Modal obrigatória aberta.
**Passos:** Inspecionar título, mensagem e ações disponíveis.
**Esperado:**
- Título **Atualização necessária**.
- Mensagem orientando a instalar a versão mais recente.
- Somente o botão **Atualizar aplicativo**.
- Ausência de botão `X`, **Mais tarde** ou qualquer ação de continuidade.
**Rastreabilidade:** `AppUpdateCoordinator._showRequiredUpdate`; `CustomInfoDialog`.

### CT-MOB-UPD-003 — Impedir fechamento pelo voltar e pelo toque externo
**Pré-condição:** Modal obrigatória aberta.
**Passos:**
1. Pressionar o botão voltar do Android.
2. Tocar fora da área visual da modal.
**Esperado:** A modal permanece aberta nas duas tentativas e o conteúdo do aplicativo continua inacessível.
**Rastreabilidade:** `barrierDismissible: false`; `PopScope(canPop: false)`.

### CT-MOB-UPD-004 — Não duplicar modal com múltiplos 426
**Pré-condição:** Tela que dispara duas ou mais requisições concorrentes; todas respondem `426`.
**Passos:** Abrir a tela e aguardar todas as respostas.
**Esperado:** Apenas uma modal obrigatória é visível; não existem modais empilhadas.
**Rastreabilidade:** `_updateRequired`; `_requiredDialogVisible`.

### CT-MOB-UPD-005 — Abrir a loja correta pela modal obrigatória
**Pré-condição:** Modal obrigatória aberta em Android ou iOS.
**Passos:** Tocar em **Atualizar aplicativo**.
**Esperado:**
- Android abre a página do aplicativo na Google Play.
- iOS abre a página do aplicativo na App Store.
- A navegação ocorre fora do aplicativo.
**Rastreabilidade:** URLs de loja da política e `LaunchMode.externalApplication`.

### CT-MOB-UPD-006 — Continuar bloqueado ao voltar da loja
**Pré-condição:** Loja aberta pelo botão da modal obrigatória; atualização não instalada.
**Passos:** Voltar ao aplicativo sem atualizar.
**Esperado:** A modal obrigatória continua aberta e o aplicativo permanece bloqueado.
**Rastreabilidade:** `closeOnButtonPressed: false`.

### CT-MOB-UPD-007 — Bloquear novamente em novo processo
**Pré-condição:** Aplicativo ainda abaixo do build mínimo.
**Passos:**
1. Encerrar completamente o processo.
2. Iniciar o aplicativo novamente.
3. Provocar uma requisição normal.
**Esperado:** O backend retorna `426` novamente e a modal obrigatória reaparece.
**Rastreabilidade:** política do backend; estado obrigatório apenas em memória no App.

### CT-MOB-UPD-008 — Erro de rede não ativa atualização obrigatória
**Pré-condição:** Perfil C, sem resposta HTTP `426`.
**Passos:**
1. Iniciar uma operação com backend indisponível ou rede interrompida.
2. Aguardar timeout ou erro de conexão.
**Esperado:** Tratamento normal de erro de rede; modal **Atualização necessária** não é exibida.
**Rastreabilidade:** `VersionCheckerInterceptor` reage somente ao status `426`.

---

## 5. Atualização opcional (OPC)

### CT-MOB-UPD-009 — Exibir atualização opcional quando há versão mais nova
**Pré-condição:** Novo processo; perfil D ou build debug com `FORCE_OPTIONAL_UPDATE=true`; backend sem `426`.
**Passos:** Iniciar o aplicativo e aguardar a rota inicial estabilizar.
**Esperado:** Modal **Nova atualização disponível** é exibida sem bloquear permanentemente o aplicativo.
**Rastreabilidade:** `AppRouteObserver`; `checkOptionalUpdateOnce`.

### CT-MOB-UPD-010 — Conteúdo e ações da modal opcional
**Pré-condição:** Modal opcional aberta.
**Passos:** Inspecionar título, mensagem e botões.
**Esperado:** Exibe **Mais tarde** e **Atualizar agora**, sem ações adicionais.
**Rastreabilidade:** `AppUpdateCoordinator._showOptionalUpdate`; `CustomInfoDialog`.

### CT-MOB-UPD-011 — Mais tarde permite continuar e não reaparece no processo
**Pré-condição:** Modal opcional aberta.
**Passos:**
1. Tocar em **Mais tarde**.
2. Navegar entre telas do aplicativo.
**Esperado:** Modal fecha, aplicativo permanece utilizável e o aviso não reaparece durante o mesmo processo.
**Rastreabilidade:** `_checkedInCurrentProcess`.

### CT-MOB-UPD-012 — Não consultar novamente ao minimizar e retornar
**Pré-condição:** Verificação opcional já executada no processo atual.
**Passos:**
1. Enviar o aplicativo para o background.
2. Abrir outro aplicativo.
3. Retornar ao aplicativo.
**Esperado:** A consulta não é repetida e a modal opcional não reaparece.
**Rastreabilidade:** ausência de verificação em `AppLifecycleState.resumed`.

### CT-MOB-UPD-013 — Novo processo consulta novamente
**Pré-condição:** Verificação opcional já executada e modal dispensada.
**Passos:**
1. Encerrar completamente o processo.
2. Iniciar o aplicativo novamente.
**Esperado:** A verificação é executada novamente e, se a atualização continuar disponível, a modal reaparece.
**Rastreabilidade:** guard somente em memória.

### CT-MOB-UPD-014 — Atualizar agora abre loja e não reaparece ao voltar
**Pré-condição:** Modal opcional aberta.
**Passos:**
1. Tocar em **Atualizar agora**.
2. Voltar ao aplicativo sem instalar a atualização.
**Esperado:** A loja correta abre; ao retornar, a modal não reaparece durante o mesmo processo e o App continua utilizável.
**Rastreabilidade:** `_checkedInCurrentProcess`; `launchUrl`.

### CT-MOB-UPD-015 — Não exibir modal quando a loja não possui versão mais nova
**Pré-condição:** Novo processo; versão instalada igual ou superior à versão informada pela loja; flag de força desativada.
**Passos:** Iniciar o aplicativo e aguardar a consulta.
**Esperado:** Nenhuma modal opcional é apresentada e o aplicativo continua normalmente.
**Rastreabilidade:** `VersionStatus.canUpdate`.

### CT-MOB-UPD-016 — Falha na consulta da loja não bloqueia o aplicativo
**Pré-condição:** Novo processo; backend funcional; consulta à loja indisponível ou inválida.
**Passos:** Iniciar o aplicativo e aguardar a falha da consulta externa.
**Esperado:** Falha é reportada tecnicamente sem apresentar atualização obrigatória e sem impedir o uso do App.
**Rastreabilidade:** tratamento de exceção em `checkOptionalUpdateOnce`.

---

## 6. Prioridade entre os fluxos

### CT-MOB-UPD-017 — Atualização obrigatória prevalece sobre a opcional
**Pré-condição:** Atualização opcional disponível e backend configurado para responder `426` ao build instalado.
**Passos:**
1. Iniciar um novo processo.
2. Permitir o início da verificação opcional.
3. Fazer uma requisição normal receber `426` durante a inicialização.
**Esperado:**
- A modal obrigatória é a única modal visível.
- Se a opcional já estiver aberta, ela é fechada/substituída.
- O usuário não consegue continuar no App.
**Rastreabilidade:** `_required`; `_dismissOptionalUpdate`; `AppRouteObserver`.

### CT-MOB-UPD-018 — Vários eventos de navegação não repetem a consulta opcional
**Pré-condição:** Verificação opcional já iniciada ou concluída.
**Passos:** Navegar por várias rotas que disparem `didPush` ou `didReplace`.
**Esperado:** O observer pode solicitar a verificação, mas o guard em memória permite somente uma consulta no processo.
**Rastreabilidade:** `AppRouteObserver`; `_checkedInCurrentProcess`.

---

## 7. Cobertura por contexto de tela (EXP)

Os casos abaixo verificam que as modais de atualização aparecem para o usuário independentemente da tela em que ele está: deslogado, logado na home, em tela de configuração/perfil e durante a edição de um orçamento.

### CT-MOB-UPD-019 — Modal obrigatória sobre a tela de login (app deslogado)
**Pré-condição:** App sem sessão autenticada; backend com build mínimo acima do instalado.
**Passos:**
1. Iniciar o aplicativo e permanecer na tela de login.
2. Provocar uma requisição a partir da própria tela (tentativa de login ou recuperação de senha).
**Esperado:** A modal **Atualização necessária** é apresentada sobre a tela de login e impede a continuidade.
**Rastreabilidade:** `VersionCheckerInterceptor` cobre requests não autenticadas; `AppUpdateCoordinator.requireUpdate`.

### CT-MOB-UPD-020 — Modal obrigatória sobre a home com sessão autenticada
**Pré-condição:** Usuário autenticado na home/lista de orçamentos; backend alterado para build mínimo acima do instalado com o app em uso.
**Passos:**
1. Autenticar com o backend no perfil normal.
2. Alterar o backend para o perfil de bloqueio.
3. Provocar uma requisição na home (recarregar a lista, busca ou navegação que consulte dados).
**Esperado:** A modal obrigatória aparece sobre a home e bloqueia o uso.
**Rastreabilidade:** resposta `426` em qualquer request autenticada.

### CT-MOB-UPD-021 — Modal obrigatória sobre tela de perfil/configurações com sessão autenticada
**Pré-condição:** Usuário autenticado em tela de perfil ou configuração; backend alterado para o perfil de bloqueio.
**Passos:** Provocar uma requisição a partir da tela (ação que consulte o backend).
**Esperado:** A modal obrigatória aparece sobre a tela de configuração e bloqueia o uso.
**Rastreabilidade:** `VersionCheckerInterceptor`; `requireUpdate`.

### CT-MOB-UPD-022 — Modal obrigatória durante edição de orçamento
**Pré-condição:** Usuário autenticado com um orçamento aberto em edição; backend alterado para o perfil de bloqueio.
**Passos:** Executar uma ação na edição que consulte o backend (carregar dados, salvar ou avançar etapa).
**Esperado:** A modal obrigatória interrompe a edição e o app permanece bloqueado.
**Rastreabilidade:** `requireUpdate` sobrepõe qualquer rota corrente.

### CT-MOB-UPD-023 — Modal opcional sobre a tela de login (app deslogado, versão < loja)
**Pré-condição:** Versão instalada inferior à publicada na loja; backend no perfil normal; novo processo.
**Passos:** Iniciar o aplicativo e aguardar a rota inicial de login estabilizar.
**Esperado:** A modal **Nova atualização disponível** aparece sobre a tela de login, sem bloquear o uso.
**Rastreabilidade:** `AppRouteObserver`; `checkOptionalUpdateOnce`.

### CT-MOB-UPD-024 — Modal opcional sobre a home com sessão autenticada
**Pré-condição:** Sessão autenticada persistida; versão instalada inferior à publicada; novo processo.
**Passos:** Iniciar o aplicativo e aguardar o redirecionamento para a home.
**Esperado:** A modal opcional aparece sobre a home.
**Rastreabilidade:** `AppRouteObserver.didReplace`/`didPush` na navegação pós-splash.

### CT-MOB-UPD-025 — Modal opcional disparada pela navegação para tela interna
**Pré-condição:** Verificação opcional ainda não executada no processo; versão instalada inferior à publicada; usuário autenticado.
**Passos:** Navegar para uma tela interna (edição de orçamento ou configuração) como primeira navegação do processo.
**Esperado:** A primeira navegação dispara a consulta e a modal opcional aparece sobre a tela interna.
**Rastreabilidade:** `didPush`/`didReplace`; `_checkedInCurrentProcess`.

### CT-MOB-UPD-026 — Modal obrigatória prevalece sobre a opcional em tela interna
**Pré-condição:** Modal opcional visível em tela interna; backend alterado para responder `426`.
**Passos:** Provocar uma requisição com a modal opcional aberta.
**Esperado:** A modal opcional é dispensada e somente a modal obrigatória permanece visível.
**Rastreabilidade:** `_required`; `_dismissOptionalUpdate`.

---

## 8. Registro da execução Mobile MCP — 25/09/2026

### 8.1 Contexto

| Campo | Valor |
|---|---|
| Dispositivo | Emulador `mobile_mcp_test` |
| Sistema | Android 15 |
| Aplicativo | `1.1.0+33`, debug |
| Backend obrigatório | Container temporário com mínimo Android `34` |
| Backend opcional | Backend normal com mínimo `0` |
| Verificação opcional | Forçada com `FORCE_OPTIONAL_UPDATE=true` |
| Consulta real da loja | Google Play informou versão 1.1.0, igual à instalada, sem flag de força |
| Usuário/papel | Sessão autenticada preexistente no emulador |
| Ferramenta | Mobile MCP |
| Evidência | Árvore semântica das telas, aplicação em foreground e respostas controladas do backend |

### 8.2 Resultados técnicos

| Caso | Status | Resultado obtido |
|---|---|---|
| VER-UPD-001 | Passou | Request sem headers seguiu ao JWT e retornou `401`, não `426` |
| VER-UPD-002 | Passou | Backend normal com mínimo `0` permitiu uso autenticado |
| VER-UPD-003 | Passou | Build `33` contra mínimo `34` retornou `426` e payload esperado |
| VER-UPD-004 | Passou | Build igual ao mínimo seguiu para autenticação no teste focado |
| VER-UPD-005 | Passou | Políticas Android/iOS e URLs independentes validadas pelo teste PHP |
| VER-UPD-006 | Passou | Build ausente e inválido retornaram `426` no teste focado |
| VER-UPD-007 | Passou | Plataforma `windows` seguiu para autenticação no teste focado |

### 8.3 Resultados mobile

| Caso | Status | Resultado obtido |
|---|---|---|
| CT-MOB-UPD-001 | Passou | Resposta `426` durante a restauração de sessão abriu a modal obrigatória |
| CT-MOB-UPD-002 | Passou | Apenas título, mensagem e botão **Atualizar aplicativo** ficaram disponíveis |
| CT-MOB-UPD-003 | Passou | Botão voltar e toque externo não fecharam a modal |
| CT-MOB-UPD-004 | Parcial | Apenas uma modal foi observada na inicialização, mas não foram disparadas múltiplas requisições `426` independentes de forma controlada |
| CT-MOB-UPD-005 | Passou | Botão abriu a URL da Google Play no Chrome |
| CT-MOB-UPD-006 | Passou | Ao voltar do Chrome, a modal obrigatória continuou visível |
| CT-MOB-UPD-007 | Passou | Novos processos ainda abaixo do mínimo voltaram a apresentar o bloqueio |
| CT-MOB-UPD-008 | Passou | Com conexão externa recusada, nenhuma modal obrigatória apareceu; após dispensar o aviso opcional forçado, o App permaneceu utilizável na tela de login |
| CT-MOB-UPD-009 | Passou | Novo processo apresentou a modal opcional após estabilizar a rota inicial |
| CT-MOB-UPD-010 | Passou | Botões **Mais tarde** e **Atualizar agora** foram exibidos |
| CT-MOB-UPD-011 | Passou | **Mais tarde** fechou a modal e permitiu navegar normalmente |
| CT-MOB-UPD-012 | Passou | Ir para a Home do Android e retornar não reapresentou a modal |
| CT-MOB-UPD-013 | Passou | Encerrar e iniciar novo processo reapresentou a modal opcional |
| CT-MOB-UPD-014 | Passou | **Atualizar agora** abriu o Chrome; ao voltar, a modal não reapareceu |
| CT-MOB-UPD-015 | Passou | Google Play informou versão 1.1.0, igual à instalada; o build sem flag de força não exibiu modal opcional |
| CT-MOB-UPD-016 | Passou | Com Wi-Fi e dados móveis desligados, a falha da consulta externa não exibiu modal nem travou o App; o fluxo permaneceu utilizável na tela de login |
| CT-MOB-UPD-017 | Passou | Com flag opcional ativa e backend em `426`, somente a modal obrigatória permaneceu visível |
| CT-MOB-UPD-018 | Passou | Navegação e retorno ao App não provocaram nova modal no mesmo processo |

## 9. Registro da execução Mobile MCP — 28/09/2026 (release 1.1.1+34)

### 9.1 Contexto

| Campo | Valor |
|---|---|
| Dispositivo | Emulador `mobile_mcp_test` |
| Sistema | Android 15 |
| Aplicativo | `1.1.1+34`, release (minificado, assinado por keystore de release) |
| Backend obrigatório | Webservice Docker local com `APP_MINIMUM_BUILD_ANDROID=35` / `APP_MINIMUM_BUILD_IOS=99` |
| Backend normal | Mesmo webservice com mínimos `0` |
| Conectividade | `adb reverse tcp:8080 tcp:8080` para o host; removido no perfil C |
| Verificação opcional | Consulta real à Google Play (build release: `FORCE_OPTIONAL_UPDATE` inerte por exigir `kDebugMode`) |
| Loja | Google Play com versão 1.1.0 publicada, inferior à instalada 1.1.1 |
| Usuário/papel | Sem sessão autenticada (instalação limpa por conflito de assinatura) |
| Ferramenta | Mobile MCP |
| Evidência | Árvore semântica das telas, aplicação em foreground e screenshots |

### 9.2 Resultados técnicos

| Caso | Status | Resultado obtido |
|---|---|---|
| VER-UPD-001 | Passou | Request sem headers seguiu ao JWT e retornou `401`, não `426` |
| VER-UPD-002 | Passou | Mínimo `0` permitiu request identificada com build baixo (`401` do JWT) |
| VER-UPD-003 | Passou | Build `34` contra mínimo `35` retornou `426` com payload e URL da Google Play |
| VER-UPD-004 | Passou | Build igual ao mínimo (`35`) seguiu para autenticação (`401`) |
| VER-UPD-005 | Passou | Android (`35`) e iOS (`99`) bloquearam com suas próprias URLs de loja; iOS com build `99` passou |
| VER-UPD-006 | Passou | `App-Build` ausente e não numérico retornaram `426` |
| VER-UPD-007 | Passou | `App-Platform: windows` seguiu para autenticação (`401`) |

### 9.3 Resultados mobile

| Caso | Status | Resultado obtido |
|---|---|---|
| CT-MOB-UPD-001 | Passou | `426` na tentativa de login abriu a modal obrigatória. Observação: o diálogo genérico "Erro ao fazer login" sobrepôs a modal, que ficou visível ao dispensar o erro |
| CT-MOB-UPD-002 | Passou | Apenas título, mensagem e botão **Atualizar aplicativo** na árvore semântica |
| CT-MOB-UPD-003 | Passou | Botão voltar nativo e toques fora da modal não a fecharam |
| CT-MOB-UPD-004 | Parcial | Apenas uma modal observada; sem sessão autenticada não foi possível disparar múltiplos `426` concorrentes |
| CT-MOB-UPD-005 | Passou | Botão abriu a URL da Google Play em aplicativo externo (Chrome) |
| CT-MOB-UPD-006 | Passou | Ao retornar do Chrome, a modal obrigatória continuou aberta |
| CT-MOB-UPD-007 | Passou | Novo processo voltou a bloquear após nova request com `426` |
| CT-MOB-UPD-008 | Passou | Com `adb reverse` removido (conexão recusada), o erro de login normal foi exibido e nenhuma modal obrigatória apareceu; app seguiu utilizável |
| CT-MOB-UPD-009 | Bloqueado | Build release não força a modal opcional (`kDebugMode && FORCE_OPTIONAL_UPDATE`); loja real sem versão superior à instalada |
| CT-MOB-UPD-010 | Bloqueado | Depende da modal opcional, indisponível em release neste ambiente |
| CT-MOB-UPD-011 | Bloqueado | Depende da modal opcional, indisponível em release neste ambiente |
| CT-MOB-UPD-012 | Bloqueado | Re-consulta não observável sem a modal opcional |
| CT-MOB-UPD-013 | Bloqueado | Depende da modal opcional, indisponível em release neste ambiente |
| CT-MOB-UPD-014 | Bloqueado | Depende da modal opcional, indisponível em release neste ambiente |
| CT-MOB-UPD-015 | Passou | Google Play com versão inferior à instalada; nenhuma modal opcional e app normal |
| CT-MOB-UPD-016 | Passou | Wi-Fi e dados móveis desligados; falha da consulta à loja não exibiu modal nem bloqueou o app |
| CT-MOB-UPD-017 | Bloqueado | Modal opcional indisponível em release; a prioridade da modal obrigatória foi verificada isoladamente |
| CT-MOB-UPD-018 | Bloqueado | Re-consulta não observável sem a modal opcional |

## 10. Registro da execução Mobile MCP — 28/09/2026 (release 1.0.12+33, versão < loja)

### 10.1 Contexto

| Campo | Valor |
|---|---|
| Dispositivo | Emulador `mobile_mcp_test` |
| Sistema | Android 15 |
| Aplicativo | `1.0.12+33`, release (assinado por keystore de release, gerado com `--build-name=1.0.12 --build-number=33`) |
| Backend obrigatório | Webservice Docker local com `APP_MINIMUM_BUILD_ANDROID=34` / `APP_MINIMUM_BUILD_IOS=99` |
| Backend normal | Mesmo webservice com mínimos ausentes (`0`) |
| Conectividade | `adb reverse tcp:8080 tcp:8080` para o host |
| Verificação opcional | Consulta real à Google Play com versão instalada `1.0.12` < publicada `1.1.0` → `canUpdate=true`, sem flag de força |
| Usuário/papel | `ct-mob-release-2809@example.test`, papel Vendedor, com orçamento próprio ORC-0015 (fixture temporária, removida ao final) |
| Ferramenta | Mobile MCP + `adb` para timing de toques |
| Evidência | Screenshots em `%TEMP%\upd-evidence\` (`ct023`, `ct024`, `ct025`, `ct014`, `ct021`, `ct022`, `ct004`) |

### 10.2 Resultados mobile

| Caso | Status | Resultado obtido |
|---|---|---|
| CT-MOB-UPD-009 | Passou | Novo processo consultou a loja real (1.0.12 < 1.1.0) e exibiu a modal opcional |
| CT-MOB-UPD-010 | Passou | Título **Nova atualização disponível**, mensagem e botões **Mais tarde**/**Atualizar agora** na árvore semântica |
| CT-MOB-UPD-011 | Passou | **Mais tarde** dispensou a modal, o app seguiu utilizável e ela não reapareceu após navegação (login → Wiki) no mesmo processo |
| CT-MOB-UPD-012 | Passou | Minimizar (HOME) e retornar ao app não re-consultou nem reexibiu a modal no mesmo processo |
| CT-MOB-UPD-013 | Passou | Novo processo re-consultou a loja e reexibiu a modal opcional |
| CT-MOB-UPD-014 | Passou | **Atualizar agora** abriu a URL da Google Play no Chrome; ao voltar, a modal não reapareceu |
| CT-MOB-UPD-017 | Passou | Com backend em `426`, a modal obrigatória foi exibida e a opcional não coexistia/reapareceu; obrigatória prevalece |
| CT-MOB-UPD-018 | Passou | Navegações internas no mesmo processo não provocaram nova consulta nem nova modal |
| CT-MOB-UPD-019 | Passou | Com sessão invalidada pelo `426`, a modal obrigatória apareceu sobre a tela de login (app deslogado) |
| CT-MOB-UPD-020 | Passou | Refresh + filtros na home com backend em `426` abriram a modal obrigatória sobre a lista de orçamentos |
| CT-MOB-UPD-021 | Passou | Ação **Sair** na tela de perfil disparou request que recebeu `426`; a modal obrigatória apareceu (o app navegou ao login e a modal permaneceu por cima) |
| CT-MOB-UPD-022 | Passou | Na edição do orçamento ORC-0015, abrir "Censo escolar" disparou request que recebeu `426` e a modal obrigatória interrompeu a edição |
| CT-MOB-UPD-023 | Passou | Novo processo deslogado exibiu a modal opcional sobre a tela de login |
| CT-MOB-UPD-024 | Passou | Novo processo com sessão persistida exibiu a modal opcional sobre a home (lista de orçamentos) |
| CT-MOB-UPD-025 | Passou | Navegação rápida para a edição do orçamento antes da consulta resolver fez a modal opcional aparecer sobre a tela interna de edição |
| CT-MOB-UPD-026 | Parcial | Não foi possível manter a opcional aberta enquanto uma request recebia `426` (a modal bloqueia interação); observado que, após dispensar a opcional, a primeira request `426` abriu apenas a obrigatória. O caminho `_dismissOptionalUpdate` depende de um `426` chegar enquanto a opcional está aberta, cenário sem gatilho determinístico pela UI |
| CT-MOB-UPD-004 | Passou | Múltiplas requests paralelas com `426` (pull-to-refresh + filtros na home) resultaram em uma única modal obrigatória |

### 10.3 Observações de produto

- A consulta opcional dispara na primeira navegação pós-splash do processo (`didPush`/`didReplace`) e a modal aparece sobre a tela que estiver ativa quando a resposta da loja chega — cobre login, home e telas internas quando a navegação é rápida.
- Com o backend em `426` e sessão persistida, o usuário é redirecionado ao login com a modal obrigatória por cima — não alcança a home.
- O `426` no fluxo de edição exibiu também um estado de erro inline ("Erro: ...") atrás da modal — o bloqueio funciona, mas a tela mostra erro genérico além da modal.
- Fixture temporária (usuário `ct-mob-release-2809@example.test` e orçamento ORC-0015) removida do banco local; `.env` restaurado; `adb reverse` removido. O emulador ficou com o APK `1.0.12+33` instalado.

---

## 11. Registro da execução Mobile MCP — 28/09/2026 (release 1.0.12+33, pós-ajustes)

Reexecução da suíte após os ajustes recomendados: supressão de erros genéricos quando `isUpdateRequired` (login, splash, edição de orçamento), novo getter `AppUpdateCoordinator.isUpdateRequired`, remoção do bind local de `AppHttpClient` no `BudgetModuleNew` e novos testes unitários.

### 11.1 Contexto

| Campo | Valor |
|---|---|
| Dispositivo | Emulador `mobile_mcp_test` |
| Sistema | Android 15 |
| Aplicativo | `1.0.12+33`, release, com os ajustes de tratamento de `426` |
| Backend obrigatório | `APP_MINIMUM_BUILD_ANDROID=34` / `APP_MINIMUM_BUILD_IOS=99` |
| Backend normal | Mínimos ausentes (`0`) |
| Verificação opcional | Consulta real à Google Play (`1.0.12` < `1.1.0` publicada) |
| Usuário/papel | `ct-mob-release-2809@example.test`, Vendedor, orçamento ORC-0016 (fixture removida ao final) |
| Testes unitários | `app_update_coordinator_test.dart` + `version_checker_interceptor_test.dart` — **5/5 passaram** |
| Evidência | Screenshots `r2-*` em `%TEMP%\upd-evidence\` |

### 11.2 Resultados mobile

| Caso | Status | Resultado obtido |
|---|---|---|
| CT-MOB-UPD-009 | Passou | Modal opcional exibida em novo processo (login deslogado) |
| CT-MOB-UPD-010 | Passou | Título, mensagem e botões **Mais tarde**/**Atualizar agora** conferidos |
| CT-MOB-UPD-011 | Passou | **Mais tarde** dispensou; navegação para Wiki não reexibiu a modal |
| CT-MOB-UPD-012 | Passou | HOME + retorno não re-consultou nem reexibiu |
| CT-MOB-UPD-013 | Passou | Novo processo reexibiu a modal opcional |
| CT-MOB-UPD-014 | Passou | **Atualizar agora** abriu a loja no Chrome; retorno sem modal |
| CT-MOB-UPD-017 | Passou | Com sessão persistida e backend em `426`, somente a modal obrigatória apareceu — a opcional não coexistiu |
| CT-MOB-UPD-018 | Passou | Navegações no mesmo processo não geraram nova consulta/modal |
| CT-MOB-UPD-001 | Passou | `426` na tentativa de login abriu a modal obrigatória |
| CT-MOB-UPD-002 | Passou | Somente título, mensagem e **Atualizar aplicativo** na modal |
| CT-MOB-UPD-003 | Passou | Voltar e toque externo não fecham a modal obrigatória |
| CT-MOB-UPD-004 | Passou | Refresh + filtros com `426` paralelos na home → única modal obrigatória |
| CT-MOB-UPD-005 | Passou | **Atualizar aplicativo** abriu a URL da Google Play no Chrome |
| CT-MOB-UPD-006 | Passou | Modal obrigatória permaneceu ao voltar do Chrome |
| CT-MOB-UPD-019 | Passou | Tentativa de login com backend em `426` abriu a modal obrigatória sobre o login **sem** o diálogo genérico "Erro ao fazer login" por cima — **ajuste validado** |
| CT-MOB-UPD-020 | Passou | Modal obrigatória sobre a home após requests `426` |
| CT-MOB-UPD-021 | Passou | **Sair** no perfil com `426` abriu a modal obrigatória (logout navegou ao login com a modal por cima) |
| CT-MOB-UPD-022 | Passou | `426` durante a edição (tela "Censo escolar") interrompeu com a modal obrigatória |
| CT-MOB-UPD-023 | Passou | Modal opcional sobre o login com app deslogado |
| CT-MOB-UPD-024 | Passou | Modal opcional sobre a home com sessão restaurada |
| CT-MOB-UPD-025 | Passou | Modal opcional sobre a edição de orçamento ao navegar antes da consulta resolver |
| CT-MOB-UPD-026 | Parcial | Com `426` na restauração de sessão, a opcional não permaneceu e só a obrigatória ficou visível — comportamento correto, mas ainda sem evidência visual do `_dismissOptionalUpdate` com a opcional aberta; coberto parcialmente pelo teste unitário do coordinator |

### 11.3 Validação dos ajustes

- **Login**: `426` não mostra mais o diálogo "Erro ao fazer login" — a modal obrigatória aparece diretamente. ✅
- **Splash**: `426` na restauração de sessão não redireciona ao login — a modal obrigatória fica sobre a splash em branco. ✅
- **Edição de orçamento**: a `EditBudgetPage` não mostra o estado de erro inline, mas a tela filha **"Censo escolar"** ainda exibe texto de erro cru (`Erro: ... api/orc...`) atrás da modal — o `426` continua bloqueando, mas o ajuste não cobriu essa página. ⚠️
- **Home**: a lista de orçamentos ainda mostra estado de erro com "Tentar novamente" atrás da modal — bloqueio correto, apenas erro residual de apresentação.
- Fixture temporária removida; `.env` restaurado; `adb reverse` removido. Emulador com APK `1.0.12+33` instalado.

---

## 12. Registro da execução Mobile MCP — 28/09/2026 (release 1.0.12+33, polimento residual)

Reexecução após o polimento residual: tratamento de `426`/`isUpdateRequired` na lista de orçamentos (`budget_list_page.dart`) e na tela de Censo escolar (`school_census_page.dart`).

### 12.1 Contexto

| Campo | Valor |
|---|---|
| Dispositivo | Emulador `mobile_mcp_test` |
| Sistema | Android 15 |
| Aplicativo | `1.0.12+33`, release, com polimento na lista e no censo |
| Backend | Alternado entre mínimo `34` (`426`) e `0` (normal) durante a sessão |
| Usuário/papel | `ct-mob-release-2809@example.test`, Vendedor, orçamento ORC-0019 (fixture removida ao final) |
| Testes | Suíte de orçamento: **169/169 passaram**; unitários de update: **5/5 passaram** |
| Evidência | Screenshots `r3-*` em `%TEMP%\upd-evidence\` |

### 12.2 Resultados

| Caso | Status | Resultado obtido |
|---|---|---|
| Integridade geral | Passou | Login, home com ORC-0019, edição de orçamento e censo carregam normalmente com backend no perfil normal |
| CT-MOB-UPD-009/023/024 | Passou | Modal opcional reexibida em novos processos, sobre login e home |
| CT-MOB-UPD-019 | Passou | Login com `426` abre a modal obrigatória diretamente, sem diálogo "Erro ao fazer login" |
| CT-MOB-UPD-020/004 | Passou | Refresh + filtros com `426` na home → modal obrigatória única, **sem "Tentar novamente" nem erro cru** atrás dela — **ajuste validado** |
| CT-MOB-UPD-022 | Passou | `426` na tela **Censo escolar** → modal obrigatória sobre body limpo, **sem texto técnico da API** — **ajuste validado** |
| CT-MOB-UPD-003 | Passou | Voltar e toque externo não fecham a modal obrigatória |
| CT-MOB-UPD-005/006 | Passou | **Atualizar aplicativo** abre a loja no Chrome; modal persiste ao voltar |

### 12.3 Validação dos ajustes desta rodada

- **Home/lista de orçamentos**: atrás da modal obrigatória não há mais erro cru nem botão "Tentar novamente" — a lista fica vazia/limpa. ✅
- **Censo escolar**: body não renderiza o texto técnico da API sob `426`; tela fica vazia sob a modal. ✅
- **Login e splash**: comportamento da rodada anterior mantido (modal direta, sem diálogo genérico). ✅
- **Regressão**: nenhuma — com `isUpdateRequired=false`, lista, edição e censo funcionam normalmente. ✅

---

## 13. Cobertura pendente

- Repetir CT-MOB-UPD-005, CT-MOB-UPD-009, CT-MOB-UPD-014 e CT-MOB-UPD-017 em dispositivo iOS.
- Repetir CT-MOB-UPD-005, CT-MOB-UPD-009, CT-MOB-UPD-014 e CT-MOB-UPD-017 em dispositivo iOS.
- Validar a consulta real da App Store após a publicação de uma versão superior.
- A instalação efetiva pela loja permanece fora do escopo desta suíte.
