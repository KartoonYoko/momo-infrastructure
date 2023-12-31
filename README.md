# Пример инфраструктуры для запуска в яндекс облаке

## Описание
Репозиторий содержит: 
- [терраформ скрипты](./terraform/) для поднятия виртуалки в yandex cloud
- [ansible](./ansible/) для накатки конфигурации на виртуалку в виде docker и польователя для подключения и запуска контейнеров

В корне репозитория [файл основного пайплайна](./.gitlab-ci.yml), внутри которого описаны downstream пайлайны для [ansible](./ansible/.gitlab-ci.yml) и [terraform](./.gitlab-ci.yml). Downstram пайплайны срабатывают только при изменениях в каталогах проектов.

## Правила внесения изменений с terraform
- Добавить данные в переменную TERRAFORM_TFVARS, которая содержит данные для развёртывания ВМ в нужном облаке. [Подробнее](./terraform/Readme.md#L7)
- Проверить актуальность token'а в переменной TERRAFORM_TFVARS
- Внести необходимые изменения в tf файлы
- запушить изменения

## Правила внесения изменений конфигурации с ansible
- проверить актуальность пароля для ansible vault в переменной ANSIBLE_PASSWORD
- проверить [файл группы](./ansible/group_vars/vm-momo.yml) 
- внести нужные изменения в ansible проект
- запушить изменения