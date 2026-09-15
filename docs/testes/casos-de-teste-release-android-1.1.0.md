# Casos de Teste da Release Android 1.1.0+33 — Multimídia: Parceiro

> **Motivo:** o pacote `32 (1.1.0)` foi recusado na Play Console por dois apontamentos:
> 1. **Política (bloqueador):** “Usar seletores de sistema alternativos para fotos/vídeos” — o pacote declarava `READ_MEDIA_IMAGES` e `READ_MEDIA_VIDEO`.
> 2. **Otimização do app (prazo fev/2027):** ofuscação em 2% e “Configuração do R8” vazia.
>
> **Correções aplicadas nesta versão:**
> - `android/app/src/main/AndroidManifest.xml`: remoção (`tools:node="remove"`) de `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO` e `READ_MEDIA_AUDIO`, injetadas pelo plugin `open_filex` 4.7.0.
> - `android/app/build.gradle`: `minifyEnabled true`, `shrinkResources true` e `proguardFiles` no build `release` (R8 ligado).
> - `android/app/proguard-rules.pro`: regras para `media_store_plus` (Gson + `@SerializedName`).
> - `pubspec.yaml`: `1.1.0+33`.
>
> **Fonte funcional:** `docs/regras-de-negocios.md` e `docs/testes/casos-de-teste.md` (casos citados na rastreabilidade).
> **Fonte técnica:** `lib/`, manifesto final do build e código dos plugins em uso.
> **Escopo:** somente os pontos de risco introduzidos por essas correções. Não substitui a suíte `CT-MOB-*` completa.
> **Convenção:** `CT-MOB-REL-NNN` para casos executados pela interface; `VER-REL-NNN` para verificações do pacote (não são casos mobile).

## 1. Regras da execução

Valem as regras da seção 1 de `casos-de-teste.md`, com estes acréscimos:

- **Testar somente o build de release.** O R8 e o `shrinkResources` não rodam em debug. Um PASS em `flutter run` (debug) ou em Patrol debug **não vale** para esta suíte.
- **Instalação aceita, em ordem de preferência:**
  1. Faixa de **teste interno** da Play Console com o `.aab` 33 (é o pacote que chega ao usuário).
  2. APKs gerados do mesmo `.aab` com `bundletool build-apks --connected-device` e instalados com `bundletool install-apks`.
  3. `flutter run --release` no dispositivo — só para triagem; o resultado final precisa de 1 ou 2.
- **Registrar logcat durante toda a sessão** e anexar trechos de erro como evidência:

  ```bash
  adb logcat -v time AndroidRuntime:E flutter:V *:W
  ```

- Procurar no log, em todos os casos: `ClassNotFoundException`, `NoSuchMethodException`, `NoSuchFieldException`, `MissingPluginException`, `JsonSyntaxException`, `Resources$NotFoundException`, `FATAL EXCEPTION`. Qualquer ocorrência ligada ao fluxo testado reprova o caso, mesmo que a tela pareça correta.
- Um diálogo de sistema pedindo acesso a **Fotos e vídeos**, **Música e áudio** ou **Arquivos e mídia** reprova o caso no Android 13+.
- Não registrar senhas, tokens, OTPs nem a chave de assinatura nas evidências.

## 2. Matriz de dispositivos

| Perfil | API | Por que entra |
|---|---|---|
| **A — Android 13+** (obrigatório) | 33, 34, 35 ou 36 | Política de fotos/vídeos vale a partir do 33; é onde `READ_MEDIA_*` existiria |
| **B — Android 11/12** (obrigatório) | 30, 31 ou 32 | Faixa em que `READ_EXTERNAL_STORAGE` ainda é declarada (`maxSdkVersion=32`) e o MediaStore é usado |
| **C — Android 9** (recomendado) | 28 | Caminho legado de gravação com `WRITE_EXTERNAL_STORAGE` (`maxSdkVersion=28`) |
| **D — Aparelho físico** (recomendado) | 33+ | Seletor de fotos, uCrop e players se comportam diferente de emulador |

Imagens de emulador devem ter **Google Play** (para seletor de fotos, apps de PDF e compartilhamento). Em cada caso, registrar o perfil usado.

## 3. Matriz de papéis

| Papel | Casos |
|---|---|
| Vendedor | Todos os casos de Drive, perfil, orçamento, PDF e sessão |
| Gestor ou Administrador | REL-006 (logo da empresa) e REL-007 (contrato do parceiro) |
| Administrador | REL-021 (links da prospecção) |

---

## 4. Verificações do pacote (VER)

Pré-condição de toda a suíte. Se qualquer `VER-REL-*` falhar, os casos mobile ficam `Bloqueado`.

### VER-REL-001 — Manifesto final sem permissões de mídia
**Passos:**
1. Gerar o pacote: `flutter build appbundle --release`.
2. Procurar `READ_MEDIA` no manifesto final:

   ```bash
   grep -c "READ_MEDIA" build/app/intermediates/merged_manifest/release/processReleaseMainManifest/AndroidManifest.xml
   ```

3. Conferir as demais permissões do mesmo arquivo.
**Esperado:**
- Resultado `0` para `READ_MEDIA`.
- Continuam presentes: `INTERNET`, `ACCESS_NETWORK_STATE`, `READ_EXTERNAL_STORAGE` com `maxSdkVersion="32"` e `WRITE_EXTERNAL_STORAGE` com `maxSdkVersion="28"`.
**Rastreabilidade:** Apontamento de política da Play Console; `open_filex` 4.7.0.

### VER-REL-002 — R8 executado no build de release
**Passos:**
1. Após o build, verificar a existência de `build/app/outputs/mapping/release/mapping.txt`.
2. Verificar que o build não parou com “Missing classes detected while running R8”.
3. Comparar o tamanho do `.aab` com o da versão 32 (57,8 MB no build local).
**Esperado:**
- `mapping.txt` gerado e não vazio.
- Build concluído sem erro de R8.
- Pacote menor que o da versão 32.
**Rastreabilidade:** Apontamento “Otimização do app”.

### VER-REL-003 — Play Console aceita o pacote 33
**Passos:**
1. Enviar o `.aab` 33 para a faixa de teste interno.
2. Na versão em rascunho, remover o pacote 32.
3. Abrir “Visão geral da publicação” e os detalhes do pacote 33 no Explorador de pacotes.
**Esperado:**
- O problema “Usar seletores de sistema alternativos para fotos/vídeos” não aparece.
- “Configuração do R8” preenchida e “Porcentagem de ofuscação” igual ou acima de **25%**.
- Se a ofuscação ficar abaixo de 25%, registrar o valor: as regras amplas `-keep class io.flutter.**` e `-keep class com.google.crypto.tink.**` do `proguard-rules.pro` são os primeiros candidatos a revisão.
**Rastreabilidade:** Apontamentos 1 e 2.

### VER-REL-004 — Relatório de pré-lançamento sem falhas
**Pré-condição:** VER-REL-003 concluída.
**Passos:** Aguardar o relatório de pré-lançamento da Play Console para o pacote 33.
**Esperado:** Nenhuma falha ou ANR nova em relação ao pacote 32; stack traces, se houver, aparecem com nomes originais (mapping enviado junto com o `.aab`).
**Rastreabilidade:** Apontamento 2.

---

## 5. Remoção das permissões de mídia (PER)

Risco: o `open_filex` pede `READ_MEDIA_*` quando o arquivo está **fora** das pastas do App. Com a permissão removida do manifesto, esse pedido não pode mais ser atendido. O código atual grava tudo que abre em `getTemporaryDirectory()`, então nenhum fluxo deve cair nesse caminho. Estes casos confirmam isso.

### CT-MOB-REL-001 — Abrir documento PDF do Drive sem pedido de permissão
**Perfis:** A (obrigatório), B.
**Pré-condição:** Vendedor autenticado; PDF acessível no Drive; aplicativo leitor de PDF instalado.
**Passos:**
1. Abrir o Drive.
2. Tocar em um PDF (tipo documento).
3. Aguardar o diálogo de carregamento.
4. Voltar ao App.
**Esperado:**
- O PDF abre no aplicativo externo.
- Nenhum diálogo de permissão do sistema aparece.
- Não aparece “Permissão negada para abrir o arquivo”.
- O diálogo de carregamento fecha ao voltar.
**Rastreabilidade:** CT-MOB-DRV-010; `DownloadAndOpenFileUsecase`; `FileOpenerImpl`.

### CT-MOB-REL-002 — Abrir documentos de outros tipos
**Perfis:** A.
**Pré-condição:** No Drive, arquivos do tipo documento em formatos variados: `.docx`, `.xlsx`, `.pptx`, `.txt`, `.csv` e, se existir, um arquivo de imagem ou áudio classificado como documento pelo backend.
**Passos:** Abrir cada arquivo pela lista e pelos detalhes (**Abrir/Visualizar**).
**Esperado:**
- Cada arquivo é entregue ao aplicativo compatível ou mostra “Nenhum aplicativo disponível para abrir este arquivo”.
- Em nenhum formato aparece pedido de permissão ou “Permissão negada”.
- Atenção especial ao arquivo de imagem/áudio aberto como documento: é o único caminho em que o plugin trataria o tipo como mídia.
**Rastreabilidade:** CT-MOB-DRV-010; CT-MOB-DRV-011.

### CT-MOB-REL-003 — Visualizar imagem e reproduzir vídeo do Drive
**Perfis:** A.
**Pré-condição:** Imagem e vídeo acessíveis no Drive.
**Passos:**
1. Abrir uma imagem; ampliar com gesto de pinça; voltar.
2. Abrir um vídeo; reproduzir por 30 segundos sem tocar na tela; pausar; voltar.
**Esperado:**
- Visualizador e player internos carregam o arquivo correto.
- Sem pedido de permissão.
- A tela não apaga durante a reprodução (`wakelock_plus`) e o áudio para ao sair.
**Rastreabilidade:** CT-MOB-DRV-008; CT-MOB-DRV-009. Também cobre R8 em `photo_view`, `video_player` (Media3) e `wakelock_plus`.

### CT-MOB-REL-004 — Trocar avatar pelo seletor de fotos do sistema
**Perfis:** A (obrigatório), B, D.
**Pré-condição:** Vendedor autenticado; ao menos uma imagem na galeria.
**Passos:**
1. Abrir o perfil e acionar a troca de avatar.
2. Observar a tela de seleção aberta.
3. Selecionar a imagem, recortar e confirmar.
**Esperado:**
- No perfil A abre o **seletor de fotos do Android** (não a galeria antiga) sem pedir permissão.
- No perfil B abre o seletor disponível sem pedido de “Arquivos e mídia”.
- Recorte quadrado do uCrop abre com barra superior e botões visíveis; avatar atualizado após o upload.
**Rastreabilidade:** CT-MOB-PRF-005; `profile_page.dart`.

### CT-MOB-REL-005 — Cancelar seletor e recorte do avatar
**Perfis:** A.
**Passos:** Abrir o seletor e cancelar; repetir, escolher imagem e cancelar no uCrop.
**Esperado:** Avatar anterior preservado; nenhum erro, crash ou diálogo de permissão.
**Rastreabilidade:** CT-MOB-PRF-006.

### CT-MOB-REL-006 — Atualizar logo da empresa pelo seletor do sistema
**Perfis:** A.
**Pré-condição:** Gestor ou administrador; imagem quadrada e imagem 16:9 na galeria.
**Passos:** Menu > **Editar empresa**; selecionar a logo; recortar com o preset indicado; salvar. Repetir com a outra proporção.
**Esperado:** Seletor do sistema sem permissão; uCrop com presets quadrado e 16:9 funcionando; logo atualizada após refresh.
**Rastreabilidade:** CT-MOB-EMP-006; CT-MOB-EMP-007; `partner_edit_page.dart`.

### CT-MOB-REL-007 — Visualizar contrato do parceiro
**Perfis:** A.
**Pré-condição:** Gestor ou administrador; empresa com **Contrato vinculado**; leitor de PDF instalado.
**Passos:** Menu > **Editar empresa**; acionar a visualização do contrato.
**Esperado:** Contrato abre no leitor externo, sem pedido de permissão e sem “Erro ao visualizar contrato”.
**Rastreabilidade:** `PartnerStore.viewContract`; `FileOpenerImpl`.

### CT-MOB-REL-008 — Logo no modal de exportação de PDF
**Perfis:** A.
**Pré-condição:** Orçamento válido.
**Passos:** Abrir **Compartilhar PDF**; escolher uma logo pela galeria; recortar; gerar o PDF.
**Esperado:** Seletor do sistema sem permissão; recorte **Recortar Logo** funcional; PDF gerado com a logo e folha de compartilhamento aberta.
**Rastreabilidade:** CT-MOB-EXP-001; `export_pdf_modal.dart`.

### CT-MOB-REL-009 — Tela de permissões do App no sistema
**Perfis:** A.
**Pré-condição:** App 1.1.0+33 instalado e todos os casos PER executados.
**Passos:** Configurações do Android > Apps > Multimídia B2B > Permissões.
**Esperado:** Não existem as entradas **Fotos e vídeos** nem **Música e áudio**, em “Permitidas” ou “Não permitidas”.
**Rastreabilidade:** Apontamento de política da Play Console.

---

## 6. R8 e redução de recursos (R8)

Risco: o R8 remove ou renomeia classes, campos e recursos que os plugins acessam por reflexão, pelo nome ou pelo manifesto. O erro só aparece no build de release e costuma ser um crash nativo ou um retorno vazio para o Dart.

### CT-MOB-REL-010 — Baixar arquivo do Drive para Downloads
**Perfis:** A (obrigatório), B (obrigatório), C.
**Pré-condição:** Vendedor autenticado; documento acessível no Drive.
**Passos:**
1. Abrir detalhes do arquivo e tocar em **Baixar**.
2. Aguardar o diálogo de conclusão.
3. Abrir o app **Arquivos** do Android > Downloads > pasta do App.
4. Abrir o arquivo salvo.
**Esperado:**
- Diálogo “Download concluido” com o nome do arquivo e “salvo em: Downloads”.
- Arquivo presente em Downloads, íntegro e abrindo corretamente.
- Nenhum “Erro no download”, “MediaStore retornou nulo” ou `JsonSyntaxException` no logcat.
- No perfil C, o pedido de permissão de armazenamento aparece e, aceito, o arquivo é salvo.
**Rastreabilidade:** RF-DRV-004; `FileSaverImpl` (MediaStore); regras `media_store_plus` no `proguard-rules.pro`. **Maior risco do R8 nesta versão** (Gson por reflexão).

### CT-MOB-REL-011 — Baixar o mesmo arquivo duas vezes
**Perfis:** A, B.
**Pré-condição:** CT-MOB-REL-010 concluído com o mesmo arquivo.
**Passos:** Baixar novamente o mesmo arquivo; conferir Downloads.
**Esperado:** Segundo download concluído sem erro, com o comportamento de duplicado/substituição igual ao da versão 32 (registrar o nome resultante); App não fica com progresso preso.
**Rastreabilidade:** `SaveInfo`/`SaveStatus` do `media_store_plus` (enum serializado por Gson).

### CT-MOB-REL-012 — Compartilhar arquivo do Drive
**Perfis:** A.
**Passos:** Nos detalhes, tocar em **Compartilhar**; escolher um destino (ex.: Gmail ou Drive) e verificar o anexo; repetir e cancelar a folha.
**Esperado:** Arquivo correto anexado; cancelamento volta ao App sem erro “Erro ao compartilhar”.
**Rastreabilidade:** CT-MOB-DRV-014; `share_plus`.

### CT-MOB-REL-013 — Gerar e compartilhar PDF do orçamento
**Perfis:** A.
**Passos:** Abrir orçamento válido; **Compartilhar orçamento**; preencher dados do responsável; gerar; enviar para um destino e abrir o PDF recebido.
**Esperado:** PDF gerado, legível e com dados corretos; folha de compartilhamento funcional.
**Rastreabilidade:** CT-MOB-EXP-001; CT-MOB-EXP-006.

### CT-MOB-REL-014 — Exportar censo em CSV
**Perfis:** A.
**Passos:** Abrir orçamento com censo; exportar o CSV; compartilhar e abrir o arquivo.
**Esperado:** Arquivo `censo_escolar_<timestamp>.csv` compartilhado e legível; sem “Erro ao exportar” ou “Erro ao compartilhar”.
**Rastreabilidade:** CT-MOB-EXP-007; `school_census_page.dart`.

### CT-MOB-REL-015 — Login e restauração de sessão
**Perfis:** A, B.
**Passos:**
1. Instalação limpa; login como vendedor.
2. Forçar parada do App pelas Configurações do Android.
3. Abrir o App novamente.
4. Fazer logout e login outra vez.
**Esperado:** Login conclui; ao reabrir, a sessão é restaurada sem novo login; logout limpa a sessão. Sem erro de criptografia no logcat.
**Rastreabilidade:** CT-MOB-AUT-001; CT-MOB-AUT-010; CT-MOB-AUT-012; `flutter_secure_storage` (Tink).

### CT-MOB-REL-016 — Atualização sobre a versão 32 preserva sessão e dados
**Perfis:** A, B.
**Pré-condição:** Versão 1.1.0+32 instalada **pela mesma assinatura** com usuário autenticado.
**Passos:** Instalar a 1.1.0+33 por cima (faixa interna ou `bundletool install-apks`), sem desinstalar; abrir o App.
**Esperado:** Usuário continua autenticado; preferências locais mantidas; App não fecha na abertura.
**Rastreabilidade:** CT-MOB-AUT-012; `flutter_secure_storage`; `shared_preferences`.

### CT-MOB-REL-017 — Links externos
**Perfis:** A.
**Pré-condição:** Administrador para prospecção; WhatsApp e cliente de e-mail instalados (ou registrar ausência).
**Passos:** Na prospecção, acionar WhatsApp e e-mail de um prospect; na tela de login e na Wiki, abrir os links públicos.
**Esperado:** Cada link abre o aplicativo ou navegador correto; voltar retorna ao App sem erro.
**Rastreabilidade:** Casos PRO e WIK de `casos-de-teste.md`; `url_launcher` e bloco `<queries>` do manifesto.

### CT-MOB-REL-018 — Perda e retorno de rede
**Perfis:** A.
**Passos:** Com o App aberto, ativar modo avião; tentar carregar orçamentos e o Drive; desativar o modo avião e repetir.
**Esperado:** Erro de conexão controlado sem crash; ao voltar a rede, as telas carregam normalmente.
**Rastreabilidade:** CT-MOB-NFR-004; CT-MOB-DRV-013; `connectivity_plus`.

### CT-MOB-REL-019 — Ícone, splash e telas nativas
**Perfis:** A, B.
**Passos:** Conferir o ícone na tela inicial e na lista de apps; abrir o App a frio e observar a splash; abrir o uCrop e observar cores e ícones da barra.
**Esperado:** Ícone adaptativo correto (fundo branco); splash sem tela preta ou ícone faltando; uCrop com tema `Ucrop.CropTheme` e ícones visíveis. Nenhum `Resources$NotFoundException` no logcat.
**Rastreabilidade:** `shrinkResources true`; `flutter_launcher_icons`; `LaunchTheme`.

### CT-MOB-REL-020 — Aviso de atualização obrigatória
**Perfis:** A.
**Pré-condição:** Condição controlada no backend para exigir versão acima da instalada.
**Passos:** Abrir o App; tocar em **ATUALIZAR**.
**Esperado:** Diálogo “Atualização Necessária” exibido; o botão abre a página do App na Play Store.
**Rastreabilidade:** `version_checker_interceptor.dart`; `package_info_plus`; `url_launcher`.

### CT-MOB-REL-021 — Varredura rápida da navegação em release
**Perfis:** A.
**Passos:** Com logcat gravando, percorrer como administrador todos os itens do menu (orçamentos, criação, relatórios, empresas, usuários, catálogo, prospecção, Drive, Wiki, perfil), abrindo ao menos uma tela de cada.
**Esperado:** Nenhuma tela fecha o App, fica em branco ou mostra erro inesperado; logcat sem as exceções listadas na seção 1.
**Rastreabilidade:** CT-MOB-NFR-011; R8 em todos os plugins nativos.

---

## 7. Resumo de cobertura

| Grupo | IDs | Quantidade | Risco coberto |
|---|---|---:|---|
| Verificações do pacote | VER-REL-001 a 004 | 4 | Manifesto, R8 e aceite da Play Console |
| Permissões de mídia | CT-MOB-REL-001 a 009 | 9 | Remoção de `READ_MEDIA_*` |
| R8 e recursos | CT-MOB-REL-010 a 021 | 12 | `minifyEnabled` e `shrinkResources` |
| **Total** | | **25** | |

### Mapa risco → caso

| Componente afetado | Correção | Casos |
|---|---|---|
| `open_filex` (abrir arquivos) | Permissões removidas + R8 | REL-001, 002, 007 |
| `image_picker` (seletor do sistema) | Permissões removidas | REL-004, 005, 006, 008 |
| `image_cropper` / uCrop | R8 + `shrinkResources` | REL-004, 005, 006, 008, 019 |
| `media_store_plus` (Gson) | R8 + regras novas | REL-010, 011 |
| `share_plus` | R8 | REL-008, 012, 013, 014 |
| `flutter_secure_storage` (Tink) | R8 | REL-015, 016 |
| `video_player` (Media3), `wakelock_plus`, `photo_view` | R8 | REL-003 |
| `url_launcher`, `package_info_plus` | R8 | REL-017, 020 |
| `connectivity_plus` | R8 | REL-018 |
| Recursos Android (ícone, splash, temas) | `shrinkResources` | REL-019 |
| Demais plugins | R8 | REL-021 |

## 8. Critério de liberação para produção

- `VER-REL-001` a `VER-REL-003` com PASS.
- Todos os casos do perfil **A** com PASS.
- `CT-MOB-REL-010` e `CT-MOB-REL-016` com PASS também no perfil **B**.
- Qualquer FAIL em casos R8 (REL-010 a REL-021): antes de desligar o R8, verificar se `build/app/outputs/mapping/release/missing_rules.txt` ou o logcat apontam a classe removida, e acrescentar a regra `-keep` correspondente.
- Se a política de mídia for resolvida mas o R8 não puder ser estabilizado a tempo, é aceitável publicar com `minifyEnabled false` e `shrinkResources false`; o apontamento de otimização tem prazo até fev/2027 e não bloqueia o envio.

## 9. Registro da execução

| ID | Perfil/API | Papel | Data | Status | Evidência | Observação |
|---|---|---|---|---|---|---|
| VER-REL-001 | — | — | 15/09/2026 | PASS | Manifesto release; sem READ_MEDIA_*; maxSdk correto | `grep` no merged_manifest |
| VER-REL-002 | — | — | 15/09/2026 | PASS | mapping.txt não vazio; R8 concluído | `build/app/outputs/mapping/release/mapping.txt` |
| VER-REL-003 | — | — | — | Bloqueado | Requer Play Console | — |
| VER-REL-004 | — | — | — | Bloqueado | Requer relatório Play Console | — |
| CT-MOB-REL-001 | A | Admin | 15/09/2026 | PASS | PDF abriu no Google Docs sem permissão | logcat sem erro do app |
| CT-MOB-REL-002 | A | Admin | 15/09/2026 | PASS | MP3 abriu externo; DOCX mostrou erro controlado | sem permissão |
| CT-MOB-REL-003 | A | Admin | 15/09/2026 | PASS | Imagem/zoom e vídeo/player testados | tela permaneceu acordada |
| CT-MOB-REL-004 | A | Admin | 15/09/2026 | PASS | Seletor Android + uCrop + upload | avatar atualizado |
| CT-MOB-REL-005 | A | Admin | 15/09/2026 | PASS | Cancelamento preservou avatar | sem erro |
| CT-MOB-REL-006 | A | Admin | 15/09/2026 | PASS | Logo + uCrop atualizados | sem permissão |
| CT-MOB-REL-007 | A | Admin | 15/09/2026 | PASS | Contrato abriu no leitor externo | sem permissão |
| CT-MOB-REL-008 | A | Admin | — | Bloqueado | Requer orçamento e logo no modal | — |
| CT-MOB-REL-009 | A | Admin | 15/09/2026 | PASS | Pacote não lista READ_MEDIA_* | `dumpsys package` |
| CT-MOB-REL-010 | A | Admin | 15/09/2026 | PASS | Download íntegro em Downloads | 625179 bytes |
| CT-MOB-REL-011 | A | Admin | 15/09/2026 | PASS | Segundo download substituiu sem erro | timestamp atualizado |
| CT-MOB-REL-012 | A | Admin | 15/09/2026 | PASS | Share sheet abriu com anexo; cancelamento ok | share_plus |
| CT-MOB-REL-013 | A | Admin | — | Bloqueado | Requer orçamento válido | — |
| CT-MOB-REL-014 | A | Admin | — | Bloqueado | Requer orçamento com censo | — |
| CT-MOB-REL-015 | A | Vendedor | 15/09/2026 | PASS | Login, force-stop, restauração e logout | sem erro de criptografia |
| CT-MOB-REL-016 | A/B | Vendedor | — | Bloqueado | Requer versão 32 com mesma assinatura | — |
| CT-MOB-REL-017 | A | Admin | — | Bloqueado | Sem prospect disponível no beta | — |
| CT-MOB-REL-018 | A | Admin | 15/09/2026 | PASS | Sem rede exibiu erro controlado; sem crash | Wi-Fi/dados restaurados |
| CT-MOB-REL-019 | A | Admin | 15/09/2026 | PASS | Splash, ícone e uCrop verificados | sem Resources$NotFoundException |
| CT-MOB-REL-020 | A | Admin | — | Bloqueado | Requer condição de atualização no backend | — |
| CT-MOB-REL-021 | A | Admin | 15/09/2026 | PASS parcial | Menu, Wiki, Drive, perfil, empresa e prospecção abertos | sem crash; varredura ampliada pendente |
