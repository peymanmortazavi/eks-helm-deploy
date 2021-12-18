# EKS Helm Deploy GitHub Action

This GitHub action uses AWS CLI to login to EKS and deploy a helm chart.

## Inputs
Input parameters allow you to specify data that the action expects to use during runtime.

- `aws-secret-access-key`: AWS secret access key part of the aws credentials. This is used to login to EKS. (required)
- `aws-access-key-id`: AWS access key id part of the aws credentials. This is used to login to EKS. (required)
- `aws-region`: AWS region to use. This must match the region your desired cluster lies in. (default: us-west-2)
- `cluster-name`: The name of the desired cluster. (required)
- `cluster-role-arn`: If you wish to assume an admin role, provide the role arn here to login as. 
- `config-files`: Comma separated list of helm values files.
- `debug`: Enable verbose output.
- `dry-run`: Simulate an upgrade.
- `namespace`: Kubernetes namespace to use.
- `values`: Comma separates list of value set for helms. e.x: key1=value1,key2=value2
- `name`: Helm release name. (required)
- `chart-path`: The path to the chart. (defaults to `helm/`)

## Example usage

```yaml
uses: peymanmortazavi/eks-helm-deploy@v1
with:
  aws-access-key-id: ${{ secrets.AWS_ACCESS__KEY_ID }}
  aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  aws-region: us-west-2
  cluster-name: mycluster
  config-files: .github/values/dev.yaml
  namespace: dev
  values: key1=value1,key2=value2
  name: release_name
```
