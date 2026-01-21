# GitHub Actions container deploy quickstart

This workflow builds the app container from `./src/Dockerfile`, pushes it to your Azure Container Registry, and updates the App Service defined in `infra/main.bicep` to use the new image tag.

## Configure repository secrets and variables

1. Create secret `AZURE_CREDENTIALS` with the JSON output of:
   - `az ad sp create-for-rbac --name <appName> --role contributor --scopes /subscriptions/<subscriptionId> --sdk-auth`
   - Ensure the service principal has access to the resource group that contains your App Service and ACR.
2. Create repository variables (Settings → Variables → Repository variables):
   - `ACR_NAME` → the registry name provisioned by Bicep (e.g., `zavastoredevacr`).
   - `WEBAPP_NAME` → the Web App name provisioned by Bicep (e.g., `zavastore-dev-web-<suffix>` from the deploy output).

## Run it

- Trigger: push to `main` or manual `workflow_dispatch`.
- The workflow tags images with `GITHUB_SHA` and deploys that tag to the Web App via `azure/webapps-deploy@v3`.
