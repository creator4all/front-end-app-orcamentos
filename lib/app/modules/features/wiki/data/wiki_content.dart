/// Modelo de item da Wiki
class WikiItem {
  final String id;
  final String title;
  final String? content;
  final List<WikiSubItem>? subItems;

  const WikiItem({
    required this.id,
    required this.title,
    this.content,
    this.subItems,
  });
}

/// Modelo de subitem da Wiki (para itens aninhados)
class WikiSubItem {
  final String id;
  final String title;
  final String content;

  const WikiSubItem({
    required this.id,
    required this.title,
    required this.content,
  });
}

/// Conteúdo estático da Wiki
class WikiContent {
  static const List<WikiItem> items = [
    WikiItem(
      id: 'help',
      title: 'Como pedir ajuda',
      content: '''Para solicitar suporte, acesse o TomTicket:

1. Entre no link: https://multimidiaeducacional.tomticket.com/
2. Se você não possui conta, clique em "Criar Conta"
3. Preencha as informações:
   • Nome
   • Telefone
   • Email para login
   • Senha e Confirmação de senha
   • Empresa/Instituição
   • Cargo ou função
4. Clique em "Criar Conta"
5. Um e-mail será enviado para aprovação da conta
6. Após aprovação, faça login para criar tickets de suporte''',
    ),
    WikiItem(
      id: 'access',
      title: 'Acessando a plataforma',
      content:
          '''Para acessar a plataforma, será necessário inserir o seu e-mail e senha cadastrados ou passados anteriormente.

Após inserir seus dados nos campos, clique em "Acessar".

Se o seu usuário estiver aprovado pelo Gestor da empresa, você será redirecionado para a tela inicial do aplicativo.

Se o seu usuário ainda não estiver aprovado pelo Gestor da empresa, entre em contato com o Gestor da sua empresa e peça para aprová-lo.''',
    ),
    WikiItem(
      id: 'register',
      title: 'Cadastro na plataforma',
      content: '''1. Com o aplicativo aberto, clique em "Cadastrar";
2. Informe o CNPJ da sua empresa, sem espaços, pontos ou hífens:
   a. Após inserir, aparecerá uma caixa informando o nome da empresa e perguntando se está correto, caso esteja, clique em "Sim", caso contrário clique em "Não" e informe o CNPJ correto.
3. Ao clicar em "Sim", você será redirecionado para o cadastro do seu usuário, assim preencha as informações com:
   a. E-mail;
   b. Nome;
   c. Telefone;
   d. Senha;
   e. Confirmar senha.
4. Em seguida clique em "Cadastrar";
5. Assim aparecerá uma confirmação de cadastro efetuado com sucesso, clique em "Voltar para área de login";
6. Agora será possível fazer o login na plataforma:
   a. Para que um login seja válido é necessário utilizar as credenciais cadastradas (E-mail e senha);
   b. Seu cadastro deverá ser aprovado por um Gestor, portanto após finalizar o cadastro peça que o Gestor da sua empresa o aprove;
   c. Se os passos acima foram executados, você poderá entrar na plataforma sem mais problemas.''',
    ),
    WikiItem(
      id: 'home',
      title: 'Página inicial',
      subItems: [
        WikiSubItem(
          id: 'home_seller',
          title: 'Vendedor',
          content:
              '''A página inicial é o local da qual são exibidos todos os orçamentos feitos por você, neste local é possível filtrar por orçamentos Pendentes, Expirados, Não Aprovados e Aprovados, além dos orçamentos arquivados, assim é possível visualizar informações rápidas como:

1. Qual a cidade do orçamento;
2. Código do orçamento;
3. Data de criação do orçamento;
4. Valor total do orçamento;
5. Quantidade de dias até o vencimento do orçamento;
6. Status do orçamento (Aprovado, Não Aprovado, Expirado ou Pendente).

Nesta página também podemos fazer pesquisa pela caixa de texto, seja pelo nome da cidade da qual deseja buscar ou então pelo código do orçamento, para pesquisar por código é necessário colocar o prefixo "D-" ficando por exemplo:

"D-4113700-507".

O código do orçamento é composto por:
1. Prefixo: D-
2. Código da cidade
3. Sufixo: Número randômico gerado pelo App.''',
        ),
      ],
    ),
    WikiItem(
      id: 'profile_edit',
      title: 'Edição de perfil',
      content:
          '''Para editar seu perfil, acesse o menu lateral e clique em "Perfil".

Nesta tela você pode:
• Alterar sua foto de perfil
• Atualizar seu nome
• Alterar seu telefone
• Modificar sua senha

Após fazer as alterações desejadas, clique em "Salvar" para confirmar.''',
    ),
    WikiItem(
      id: 'new_budget',
      title: 'Gerando um novo orçamento',
      content: '''Para gerar um novo orçamento:

1. Na página inicial, clique no botão "+" ou "Novo Orçamento";
2. Selecione a cidade desejada;
3. Informe os dados do censo escolar (se aplicável);
4. Selecione as categorias e produtos desejados;
5. Revise o orçamento e clique em "Salvar".''',
    ),
    WikiItem(
      id: 'edit_budget',
      title: 'Editando um novo orçamento',
      content: '''Para editar um orçamento existente:

1. Na página inicial, localize o orçamento desejado;
2. Clique no card do orçamento para abrir os detalhes;
3. Clique no botão "Editar";
4. Faça as alterações necessárias;
5. Clique em "Salvar" para confirmar as mudanças.''',
    ),
    WikiItem(
      id: 'export_budget',
      title: 'Exportando um orçamento',
      content: '''Para exportar um orçamento em PDF:

1. Abra o orçamento desejado;
2. Clique no botão de exportar/compartilhar;
3. Selecione as opções de exportação desejadas;
4. O PDF será gerado e você poderá compartilhá-lo ou salvá-lo.''',
    ),
    WikiItem(
      id: 'delete_account',
      title: 'Excluir conta',
      content: '''Para excluir sua conta:

1. Acesse o menu lateral;
2. Clique em "Perfil";
3. Role até o final da página;
4. Clique em "Excluir conta";
5. Confirme a exclusão digitando sua senha;
6. Sua conta será removida permanentemente.

⚠️ Atenção: Esta ação é irreversível e todos os seus dados serão perdidos.''',
    ),
    WikiItem(
      id: 'become_partner',
      title: 'Como se tornar um parceiro',
      content: '''Para se tornar um parceiro Multimídia:

1. Entre em contato com nossa equipe comercial;
2. Apresente sua empresa e área de atuação;
3. Aguarde a análise do seu perfil;
4. Após aprovação, você receberá as credenciais de acesso;
5. Acesse o aplicativo e comece a gerar orçamentos.''',
    ),
  ];
}
