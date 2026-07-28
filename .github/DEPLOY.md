# Deploy em producao

Este repositorio publica o projeto Anderson MultiMarcas automaticamente com GitHub Actions.

## Como funciona

O workflow `.github/workflows/deploy.yml` executa somente quando ha `push` para a branch `main`.

Quando acionado, ele:

1. Inicia um runner `ubuntu-latest`.
2. Mostra nos logs o repositorio, a branch e o commit que esta sendo publicado.
3. Abre uma conexao SSH com o servidor usando `appleboy/ssh-action`.
4. Acessa a pasta `/opt/startingweb/apps/anderson-multimarcas`.
5. Executa `./deploy.sh`.

O script `deploy.sh` continua sendo a fonte da verdade do deploy no servidor. Ele ja executa `git fetch`, `git reset --hard origin/main`, `docker compose up -d --build`, health check e finalizacao do deploy.

## Secrets obrigatorios

Crie estes Secrets em `Settings > Secrets and variables > Actions > Repository secrets`:

| Secret           | Descricao                                              |
| ---------------- | ------------------------------------------------------ |
| `SERVER_HOST`    | IP ou dominio publico do servidor.                     |
| `SERVER_USER`    | Usuario SSH usado para acessar o servidor.             |
| `SERVER_SSH_KEY` | Chave privada SSH com permissao de acesso ao servidor. |

Nao sao usados outros Secrets neste pipeline.

## Como executar um deploy

Faca merge ou push para a branch `main`.

Exemplo:

```bash
git push origin main
```

O workflow sera iniciado automaticamente apos o push.

## Como acompanhar os logs

1. Abra o repositorio no GitHub.
2. Acesse a aba `Actions`.
3. Selecione o workflow `Deploy Production`.
4. Abra a execucao mais recente.
5. Consulte o job `Deploy Anderson Multimarcas`.

Os logs mostram o commit publicado e a saida do `deploy.sh` executado no servidor.

## Protecao contra deploy paralelo

O workflow usa `concurrency` com o grupo `anderson-multimarcas-production`.

Se um novo push chegar enquanto outro deploy ainda estiver em execucao, o GitHub Actions cancela a execucao anterior e mantem somente o deploy mais recente.

## Timeout

O job tem `timeout-minutes: 30` e a execucao remota usa `command_timeout: 30m`.

Se o deploy ultrapassar esse tempo, o GitHub Actions encerra a execucao e marca o workflow como falho.

## Em caso de falha

Verifique, nesta ordem:

1. Se os Secrets `SERVER_HOST`, `SERVER_USER` e `SERVER_SSH_KEY` existem e estao corretos.
2. Se o servidor aceita conexao SSH com o usuario configurado.
3. Se a chave publica correspondente esta em `~/.ssh/authorized_keys` no servidor.
4. Se o arquivo `/opt/startingweb/apps/anderson-multimarcas/deploy.sh` existe e tem permissao de execucao.
5. Se o servidor consegue acessar o GitHub e executar `git fetch`.
6. Se o Docker e o `docker compose` estao funcionando no servidor.
7. Se o health check do `deploy.sh` esta retornando sucesso.

Depois de corrigir a causa, faca um novo push para `main` ou use `Re-run jobs` na execucao falha do GitHub Actions.
