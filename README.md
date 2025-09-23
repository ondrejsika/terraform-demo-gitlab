> [!TIP]
> <a href="https://ondrej-sika.cz/skoleni/terraform"><img src="https://img.shields.io/badge/Školení%20Terraform-by%20Ondřej%20Šika-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" style="width: 100%; height: auto;" alt="Školení Terraform by Ondřej Šika" /></a>
>
> 🚀 Naučte se, jak efektivně pracovat s **Terraformem**! Praktické školení vedené [Ondřejem Šikou](https://ondrej-sika.cz).
>
> 👉 [Více informací a registrace zde](https://ondrej-sika.cz/skoleni/terraform)


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
