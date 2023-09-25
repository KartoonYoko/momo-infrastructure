### Сервис аккаунт для создание статического файла конфигурации для управления кластером
[Инструкция](https://cloud.yandex.ru/docs/managed-kubernetes/operations/connect/create-static-conf)

#### Краткая версия 
- yc managed-kubernetes cluster list
- $CLUSTER_ID = "<id'шник>"
- $CLUSTER = yc managed-kubernetes cluster get --id $CLUSTER_ID --format json | ConvertFrom-Json
- $CLUSTER.master.master_auth.cluster_ca_certificate | Set-Content ca.pem
- kubectl create -f sa.yaml
- $SECRET = kubectl -n kube-system get secret -o json | `
  ConvertFrom-Json | `
  Select-Object -ExpandProperty items | `
  Where-Object { $_.metadata.name -like "*admin-user*" }
- $SA_TOKEN = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($SECRET.data.token))
- $MASTER_ENDPOINT = $CLUSTER.master.endpoints.external_v4_endpoint
- kubectl config set-cluster sa-test2 `
  --certificate-authority=ca.pem `
  --server=$MASTER_ENDPOINT `
  --kubeconfig=test.kubeconfig
- kubectl config set-credentials admin-user `
  --token=$SA_TOKEN `
  --kubeconfig=test.kubeconfig
- kubectl config set-context default `
  --cluster=sa-test2 `
  --user=admin-user `
  --kubeconfig=test.kubeconfig
- kubectl config use-context default `
  --kubeconfig=test.kubeconfig