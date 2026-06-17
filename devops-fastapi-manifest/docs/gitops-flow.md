# GitOps Flow

This project follows a GitOps deployment workflow with GitLab CI, the GitLab Container Registry, Argo CD, and Argo CD Image Updater.

## Deployment flow

1. A developer pushes code to GitLab.
2. GitLab CI builds the backend and frontend Docker images.
3. The images are pushed to the GitLab Container Registry.
4. Argo CD Image Updater detects new image tags in the registry.
5. Image Updater commits the updated image tags to the manifest repository.
6. Argo CD detects the Git changes in the manifest repository.
7. Argo CD synchronizes the Kubernetes cluster automatically.

## Repository roles

The application repository is responsible for building and publishing Docker images.

The manifest repository is the source of truth for Kubernetes deployments. It contains the Helm chart, environment values, and Argo CD Application manifests.

## Environments

The same Helm chart is used for both environments:

- `values-dev.yaml` is used for the `dev` namespace.
- `values-prod.yaml` is used for the `prod` namespace.

Each environment has its own Argo CD Application manifest:

- `fastapi-app-dev`
- `fastapi-app-prod`

## Synchronization behavior

Argo CD continuously compares the desired state stored in Git with the current state running in Kubernetes.

If a resource is changed manually in the cluster, Argo CD can restore it automatically thanks to `selfHeal`.

If a resource is removed from Git, Argo CD can also delete it from the cluster thanks to `prune`.

## Image update behavior

Argo CD Image Updater monitors the backend and frontend images.

When a newer image is available, it updates the image tag in the manifest repository.  
Once the change is committed to Git, Argo CD detects it and deploys the new version.

## Summary

The deployment chain is:

Application code
    -> GitLab CI
    -> Docker images
    -> GitLab Container Registry
    -> Argo CD Image Updater
    -> Manifest repository
    -> Argo CD
    -> Kubernetes cluster
    
In short: the application repository produces images, the manifest repository declares what should run, and Argo CD keeps the cluster aligned with Git.