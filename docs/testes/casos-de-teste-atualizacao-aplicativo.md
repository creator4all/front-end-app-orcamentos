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

## 7. Registro da execução Mobile MCP — 25/09/2026

### 7.1 Contexto

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

### 7.2 Resultados técnicos

| Caso | Status | Resultado obtido |
|---|---|---|
| VER-UPD-001 | Passou | Request sem headers seguiu ao JWT e retornou `401`, não `426` |
| VER-UPD-002 | Passou | Backend normal com mínimo `0` permitiu uso autenticado |
| VER-UPD-003 | Passou | Build `33` contra mínimo `34` retornou `426` e payload esperado |
| VER-UPD-004 | Passou | Build igual ao mínimo seguiu para autenticação no teste focado |
| VER-UPD-005 | Passou | Políticas Android/iOS e URLs independentes validadas pelo teste PHP |
| VER-UPD-006 | Passou | Build ausente e inválido retornaram `426` no teste focado |
| VER-UPD-007 | Passou | Plataforma `windows` seguiu para autenticação no teste focado |

### 7.3 Resultados mobile

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

## 8. Cobertura pendente

- Repetir CT-MOB-UPD-004 disparando múltiplas respostas `426` concorrentes e registrando evidência específica de deduplicação.
- Repetir CT-MOB-UPD-005, CT-MOB-UPD-009, CT-MOB-UPD-014 e CT-MOB-UPD-017 em dispositivo iOS.
- Validar a consulta real da App Store após a publicação de uma versão superior.
- A instalação efetiva pela loja permanece fora do escopo desta suíte.
