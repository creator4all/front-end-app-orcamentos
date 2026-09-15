# Skill: testar o App Multimídia Parceiro

Use esta skill para executar, escrever ou julgar testes do aplicativo Flutter. Não invente regra, caso nem resultado esperado.

## Fontes — o que abrir e em que ordem

| Papel | Arquivo | Quando usar |
|---|---|---|
| **Veracidade** | [`docs/regras-de-negocios.md`](../regras-de-negocios.md) | Sempre. Define o que o produto **deve** fazer. |
| **Catálogo** | [`docs/testes/casos-de-teste.md`](casos-de-teste.md) | Base de execução. Cada caso é `CT-MOB-<DOMÍNIO>-NNN`. |
| Código | `lib/` | Só para achar tela, texto, rota ou se a UI consegue provocar a regra. |
| Suíte E2E | `test/patrol/` | Jornadas automatizadas (não é 1:1 com os 196 casos). |
| Unit/widget | `test/` (fora de `patrol/`) | Validação local, cálculo, empty/erro. Sem API real. |

Ordem obrigatória:

1. Ler a regra em `regras-de-negocios.md` (RF/RN/CA citados no caso, ou a seção do domínio).
2. Abrir o `CT-MOB-*` correspondente em `casos-de-teste.md`.
3. Só então interagir com o App (mobile-mcp) ou rodar Patrol.
4. Comparar o obtido com a **regra**. Se a UI divergir da regra, o caso falha ou fica bloqueado — não “atualize” o esperado para caber no bug. Divergências já reconhecidas estão na seção 24 de `regras-de-negocios.md`.

`casos-de-teste.md` é a lista do que executar no App. Não cria caso novo sem regra. Não reutiliza `CT-MOB-*` para painel web, `curl` ou SQL. Fora de escopo: seção 21 do catálogo.

## Quando usar o quê

| Objetivo | Ferramenta |
|---|---|
| Explorar tela, validar um `CT-MOB-*` na mão, evidência visual | **mobile-mcp** (emulador Android) |
| Fluxo crítico tela + API + estado persistido, repetível | **Patrol** (`test/patrol/`) |
| Campo, diálogo, empty, máscara, cálculo isolado | `flutter test` (unit/widget) |
| Pré-condição que a conta fixa não tem | **criar fixture** (cenário existente ou novo no webservice) |
| Confirmar dado no backend depois da UI | consulta pontual — **não substitui** o passo na interface |

Não rode mobile-mcp e Patrol no **mesmo** emulador ao mesmo tempo. Os dois usam UiAutomation; o Patrol trava com `UiAutomationService already registered`. Termine o MCP (ou reinicie o emulador) antes do Patrol.

Não trate chamada de API sozinha como execução de `CT-MOB-*`.

---

## Fixtures — criar quando o caso precisar

Se a **pré-condição** do `CT-MOB-*` (ou da jornada Patrol) pede dado que a conta fixa do time não tem, **crie um fixture** no backend de desenvolvimento. Não reuse produção, não invente usuário “na mão” no banco e não deixe o registro para trás.

Precisa de fixture, por exemplo:

- usuário inativo, gestor, subordinado ou descartável (senha, cadastro, exclusão);
- orçamento próprio com cidade/produto conhecidos;
- lista com nomes/status para busca e filtro;
- volume para paginação;
- segunda cidade (multi-cidade);
- OTP de recuperação para ler no teste.

Não precisa, por exemplo:

- unit/widget (sem API);
- caso que só usa a conta estável de vendedor/admin do ambiente;
- só abrir tela já autenticada com essa conta.

### Como criar

0. **Antes de usar a API de fixture, crie um arquivo local com a chave** (não commitar). O caminho é livre — `tmp/mobile-fixture-api.env` é só um exemplo. Sem a chave no backend e sem esse arquivo (ou o `--dart-define` equivalente) o `POST` responde 404/401 e o caso fica `Bloqueado`. Conteúdo mínimo:

   ```bash
   MOBILE_FIXTURE_API_KEY=<mesma chave do backend PATROL_MOBILE_FIXTURE_API_KEY>
   ```

   A chave tem que ser a do ambiente de desenvolvimento que o App alcança. Não cole a chave neste documento nem em evidência. No Patrol, passe a mesma chave em `--dart-define=PATROL_MOBILE_FIXTURE_API_KEY`. No mobile-mcp / `curl`, leia o arquivo e mande o header `X-Mobile-Fixture-Key`.

1. Veja se já existe **cenário** que cubra a pré-condição. Hoje: `active`, `inactive`, `manager`, `subordinate`, `seller_budget`, `seller_list`, `seller_pagination`.
2. Se nenhum servir, **crie o cenário no webservice** (schema + service + teste PHPUnit) e o campo correspondente em `test/patrol/helpers.dart` (`MobileFixture`). Não abra rota OpenAPI dessas APIs de teste.
3. No Patrol, use `withMobileFixture('<cenário>', …)` — cria, roda, **apaga** no `finally`. Helpers: `createMobileFixture`, `deleteMobileFixture`, `revealMobileFixtureOtp`, `loginAsFixture`.
4. No mobile-mcp, o mesmo `POST` vale (header `X-Mobile-Fixture-Key`, body `{ "scenario": "…" }`). Anote `fixture_id` / e-mail da resposta, execute o caso na UI e **apague** no fim (`DELETE /users/{id}`).
5. OTP: `GET /users/{id}/otp` só no ambiente de fixture. Não cole o código na evidência.

Endpoint: `POST /api/test/mobile-fixtures/users`. Liga só com `PATROL_MOBILE_FIXTURE_ENABLED=true` e `APP_ENV` em `development|local|testing`. **Não habilitar em produção.** Sem arquivo de chave, sem cenário e sem fixture, o caso fica `Bloqueado` — não force PASS com dado errado.

---

## Mobile-mcp — teste interativo

O catálogo pede interação real pela UI, preferencialmente via **mobile-mcp** em emulador Android. No Cursor o namespace é `user-mobile-mcp`.

### Preparar

1. Emulador ou device Android visível em `adb devices`.
2. App instalado: pacote `br.com.multimidiaeducacional.parceiro`.
3. Backend de desenvolvimento alcançável pelo App (no emulador Android o host da máquina é `10.0.2.2`).
4. Se a pré-condição do caso exigir, **criar o fixture** antes de abrir o App; apagar depois.
5. `mobile_list_available_devices` e, se precisar, `mcp_auth`.

### Fluxo típico de um caso

1. Anote o `CT-MOB-*`, o papel (visitante / vendedor / gestor / admin) e o esperado da regra.
2. `mobile_launch_app` no pacote do App.
3. `mobile_list_elements_on_screen` para achar o controle (não chute coordenada se a árvore listar o texto).
4. Interaja: `mobile_click_on_screen_at_coordinates`, `mobile_type_keys`, `mobile_swipe_on_screen`, `mobile_press_button` (back nativo **sai da Activity** — no App, prefira a seta da top bar).
5. Evidência: `mobile_take_screenshot` (ou `mobile_save_screenshot`). Não grave senha, token nem OTP na evidência.
6. Se travar: `mobile_get_foreground_app`, `mobile_get_device_logs`, `mobile_list_crashes`.

Contas descartáveis para cadastro, troca de senha e exclusão. Restaure dados depois de cenário destrutivo.

### Registrar a execução

Para cada caso: **esperado** (da regra + catálogo), **obtido**, **status** (`Passou` / `Falhou` / `Parcial` / `Bloqueado`), emulador, usuário/papel, data, evidência.

---

## Patrol — E2E automatizado

Patrol 4 (`patrol: ^4.9.0`) em `test/patrol/`. Não copia os 196 casos 1:1: uma jornada cobre vários `CT-MOB-*`. Os IDs âncora vão no nome do teste (ex.: `seller_login_shows_own_budget_list (AUT-001, ORC-001)`).

| Arquivo | Uso |
|---|---|
| `seller_core_journeys_test.dart` | Login, sessão, menu, criar, editar e PDF |
| `seller_followup_journeys_test.dart` | Busca, paginação, multi-cidade, senha, cadastro e Drive |
| `authentication_test.dart`, `budget_list_test.dart`, … | Suíte por domínio (`CT-MOB-*`) |
| `helpers.dart`, `app_starter.dart` | Login, fixture, logout, dropdown |

Mapeamento caso → jornada, se existir no clone, é só apoio. FAIL de produto conhecidos **não** entram no lote verde até a regra/implementação mudar.

### Ambiente

Na raiz do clone do App:

- Flutter no `PATH` (FVM do projeto, se o time usar). O CLI `patrol` precisa achar o `dart` desse Flutter.
- Device em `adb devices`.
- API de desenvolvimento que o App já usa no `lib/config` / `--dart-define`.
- Fixtures (quando o teste criar usuário/orçamento): `POST /api/test/mobile-fixtures` com header `X-Mobile-Fixture-Key`. No backend: `PATROL_MOBILE_FIXTURE_ENABLED=true`, `APP_ENV` em `development|local|testing` e chave definida. **Não habilitar em produção.**
- No emulador Android, `10.0.2.2` é o host. A URL da fixture no device costuma ser `http://10.0.2.2:<porta>/api/test/mobile-fixtures`. No host, a mesma API é `localhost:<porta>`.

### Como rodar

Patrol 4 **não tem** `--name`. Rode o arquivo (ou tags). Confie nas linhas nativas `✅ …` / `❌ …`. Ignore “All tests passed” do Dart em testes que **não** foram o solicitado daquele processo.

```bash
patrol test -t test/patrol/seller_core_journeys_test.dart \
  --device <device-id> \
  --dart-define=PATROL_SELLER_EMAIL=<email-vendedor> \
  --dart-define=PATROL_SELLER_PASSWORD=<senha-vendedor> \
  --dart-define=PATROL_ADMIN_EMAIL=<email-admin> \
  --dart-define=PATROL_ADMIN_PASSWORD=<senha-admin> \
  --dart-define=PATROL_MOBILE_FIXTURE_API_KEY=<chave-fixture> \
  --dart-define=PATROL_MOBILE_FIXTURE_PASSWORD=<senha-dos-fixtures> \
  --dart-define=PATROL_MOBILE_FIXTURE_API_URL=http://10.0.2.2:<porta>/api/test/mobile-fixtures
```

Follow-up: o mesmo comando com `-t test/patrol/seller_followup_journeys_test.dart`.

Um domínio: `-t test/patrol/authentication_test.dart` (mesmos `--dart-define`).

Credenciais e chave vêm do ambiente de teste do time — não commitar e não colar neste arquivo.

### Armadilhas (não “corrigir” o produto para o teste passar)

- `waitUntilVisible` exige widget **hit-testable**. Prefira `$.tester.pump()`; `pumpAndSettle` estoura com cursor/animação.
- `enterText` do Patrol unfoca o campo. Dropdown pesquisável fecha — filtrar pelo `controller` e tocar o item no `ListView`.
- `pressBack` nativo mata a Activity e o processo do teste. Voltar por `Icons.arrow_back`.
- `startAppClean` depois de logado **não** volta ao login (sessão em memória). Sair pelo menu (`logoutToLogin`).
- Chips da lista não são exclusivos (Arquivados + Pendentes exige os dois).
- Relatório: `build/app/reports/androidTests/connected/debug/index.html`.

---

## Julgar o resultado

1. O passo do `CT-MOB-*` foi feito **na UI**?
2. O obtido bate com o **Esperado** do catálogo **e** com a regra (deve / decidido em 10/09/2026)?
3. Se o código faz outra coisa: `Falhou` (ou `Bloqueado` se não deu para provocar). Citar a seção da regra e, se houver, a divergência da seção 24.
4. `atualmente` / `intenção original` / `necessita validação` na regra **não** viram PASS só porque a tela “parece ok”.
5. Não registrar senha, token ou OTP.

## Checklist rápido

- [ ] Li a regra em `docs/regras-de-negocios.md`
- [ ] Executei a partir de `docs/testes/casos-de-teste.md` (`CT-MOB-*`)
- [ ] Guardei a chave do fixture num arquivo local (fora do Git) ou no `--dart-define`
- [ ] Criei fixture se a pré-condição pedia (ou cenário novo, se nenhum servia) e apaguei no fim
- [ ] Exploração/evidência: **mobile-mcp**, sem Patrol no mesmo emulador
- [ ] E2E repetível: **Patrol** com Flutter do projeto + `dart-define` + fixture
- [ ] Status e evidência sem segredo
- [ ] Não alterei o esperado para mascarar divergência da regra
