# Demo Gitlab on Digital Ocean managed by Terraform

    Ondrej Sika <ondrej@ondrejsika.com>
    https://github.com/ondrejsika/terraform-demo-gitlab

## Run Gitlab

```
terraform init
terraform plan
terraform apply -auto-approve
```

Gitlab will be on <https://gitlab.sikademo.com>. You can log in user `demo` with password `asdfasdf`.

### Stop Gitlab

```
terraform destroy -auto-approve
```
