# Projection cloud AWS du projet FastAPI DevOps

## 1. Objectif du document

Ce document présente une projection concrète de migration du projet DevOps actuel depuis une infrastructure on-premise basée sur Proxmox vers une architecture cloud AWS basée sur Amazon EKS.

L’objectif n’est pas de reproduire exactement l’infrastructure actuelle dans le cloud, mais d’identifier quelles briques doivent être conservées, remplacées ou simplifiées grâce aux services managés AWS.

Le projet actuel a permis de construire et comprendre les briques fondamentales d’une plateforme Kubernetes :

* provisionnement d’infrastructure ;
* installation d’un cluster Kubernetes haute disponibilité ;
* exposition applicative ;
* stockage persistant ;
* sauvegarde et restauration ;
* monitoring ;
* GitOps ;
* CI/CD ;
* sécurité réseau et gestion des secrets.

Dans une vision cloud, ces mêmes besoins restent présents, mais les responsabilités changent.

---

## 2. État actuel : architecture on-premise

L’architecture actuelle repose sur une infrastructure Proxmox provisionnée avec Terraform, puis configurée avec Ansible.

### 2.1 Provisionnement

Terraform est utilisé pour créer les machines virtuelles nécessaires au cluster :

* 3 nœuds master ;
* 3 nœuds worker ;
* 1 nœud services ;
* réseau privé ;
* ressources CPU, RAM et disque par VM.

### 2.2 Configuration Kubernetes

Ansible configure les composants système et Kubernetes :

* installation de containerd ;
* installation de Kubernetes ;
* initialisation du control plane ;
* ajout des masters et workers ;
* configuration de la haute disponibilité via HAProxy et Keepalived ;
* installation des composants cluster.

### 2.3 Briques techniques actuelles

| Besoin              | Solution actuelle                   |
| ------------------- | ----------------------------------- |
| Infrastructure      | Proxmox + Terraform                 |
| Configuration       | Ansible                             |
| Kubernetes          | kubeadm sur VM Debian               |
| Control plane HA    | 3 masters + HAProxy + Keepalived    |
| Workers             | VM Proxmox                          |
| Réseau Kubernetes   | Calico                              |
| LoadBalancer        | MetalLB                             |
| Ingress             | Traefik                             |
| TLS                 | cert-manager + Let’s Encrypt        |
| Stockage persistant | Longhorn                            |
| Base de données     | PostgreSQL Bitnami dans Kubernetes  |
| Registry            | GitLab Container Registry           |
| GitOps              | Argo CD                             |
| CI/CD               | GitLab CI/CD                        |
| Monitoring          | Prometheus + Grafana + Alertmanager |
| Backup              | Velero + MinIO                      |
| Secrets             | Ansible Vault + Kubernetes Secrets  |

---

## 3. Architecture cible AWS

Dans une version AWS, le projet serait basé sur Amazon EKS.

Amazon EKS fournit un cluster Kubernetes managé. Le control plane Kubernetes n’est plus installé manuellement sur des VM : il est géré par AWS. Cela réduit fortement la charge d’exploitation sur les composants critiques du cluster.

L’architecture cible pourrait être la suivante :

```text
Utilisateurs
  ↓
Route 53
  ↓
Certificat ACM
  ↓
Application Load Balancer
  ↓
Ingress Kubernetes
  ↓
Services Kubernetes
  ↓
Pods frontend / backend
  ↓
Amazon RDS PostgreSQL
```

Autour de cette application :

```text
GitLab CI/CD
  ↓
Build images Docker
  ↓
GitLab Registry ou Amazon ECR
  ↓
Argo CD
  ↓
Amazon EKS

Backups :
Velero → Amazon S3

Secrets :
AWS Secrets Manager / SSM → External Secrets Operator → Kubernetes Secrets

Monitoring :
Prometheus/Grafana dans le cluster
ou
Amazon Managed Prometheus / Amazon Managed Grafana
```

---

## 4. Mapping on-premise vers AWS

| Besoin                | On-premise actuel                  | AWS cible                                           |
| --------------------- | ---------------------------------- | --------------------------------------------------- |
| Provisionnement infra | Terraform Proxmox                  | Terraform AWS                                       |
| Machines Kubernetes   | VM Proxmox                         | EKS Managed Node Groups, Karpenter ou EKS Auto Mode |
| Control plane         | kubeadm sur 3 masters              | Control plane EKS managé                            |
| HA API Kubernetes     | HAProxy + Keepalived               | Géré par EKS                                        |
| Réseau cluster        | Calico                             | Amazon VPC CNI                                      |
| DNS interne cluster   | CoreDNS installé/configuré         | CoreDNS EKS add-on                                  |
| LoadBalancer          | MetalLB                            | AWS Load Balancer Controller / ALB / NLB            |
| Ingress               | Traefik                            | ALB Ingress ou Traefik derrière NLB                 |
| TLS                   | cert-manager                       | ACM ou cert-manager                                 |
| Stockage persistant   | Longhorn                           | EBS CSI Driver / EFS CSI Driver                     |
| PostgreSQL            | PostgreSQL dans Kubernetes         | Amazon RDS PostgreSQL                               |
| Backup objet          | MinIO                              | Amazon S3                                           |
| Backup cluster        | Velero + MinIO                     | Velero + S3                                         |
| Secrets               | Ansible Vault + Kubernetes Secrets | AWS Secrets Manager / SSM + External Secrets        |
| Identité pods         | Secrets statiques                  | EKS Pod Identity ou IRSA                            |
| Monitoring            | kube-prometheus-stack              | kube-prometheus-stack ou services AWS managés       |
| GitOps                | Argo CD                            | Argo CD conservé                                    |
| CI/CD                 | GitLab CI/CD                       | GitLab CI/CD conservé                               |
| Registry              | GitLab Registry                    | GitLab Registry ou Amazon ECR                       |

---

## 5. Ce qui serait supprimé ou remplacé

En passant sur AWS/EKS, certaines briques ne seraient plus nécessaires.

### 5.1 À ne plus gérer manuellement

* installation de Kubernetes avec kubeadm ;
* configuration du control plane ;
* gestion manuelle d’etcd ;
* HAProxy / Keepalived pour l’API Kubernetes ;
* création manuelle des masters ;
* installation manuelle de CoreDNS ;
* MetalLB ;
* MinIO pour le stockage objet ;
* Longhorn si le stockage AWS est utilisé ;
* PostgreSQL dans Kubernetes si RDS est choisi.

### 5.2 Pourquoi ?

Sur AWS, l’objectif est de déléguer les composants à forte responsabilité opérationnelle :

* le control plane à EKS ;
* le stockage objet à S3 ;
* la base de données à RDS ;
* le load balancing à ALB/NLB ;
* les certificats TLS à ACM ;
* les identités cloud à IAM.

Le projet reste Kubernetes et DevOps, mais il devient plus cloud-native.

---

## 6. Ce qui serait conservé

Certaines briques restent pertinentes, même sur AWS :

* GitLab CI/CD ;
* Dockerfiles backend/frontend ;
* Helm chart applicatif ;
* Argo CD ;
* Argo CD Image Updater ;
* values Helm dev/prod ;
* ServiceMonitor et PrometheusRule si Prometheus est conservé ;
* NetworkPolicies ;
* Velero ;
* logique de sauvegarde/restauration ;
* documentation d’exploitation ;
* logique GitOps.

Le passage au cloud ne supprime donc pas le travail DevOps. Il déplace surtout le niveau de responsabilité.

---

## 7. Rôle de Terraform sur AWS

Sur l’infrastructure actuelle, Terraform sert principalement à créer des VM Proxmox.

Sur AWS, Terraform aurait un rôle plus large. Il permettrait de créer tout le socle cloud :

* VPC ;
* subnets publics et privés ;
* route tables ;
* Internet Gateway ;
* NAT Gateway ;
* security groups ;
* rôles IAM ;
* cluster EKS ;
* node groups ou configuration Karpenter ;
* add-ons EKS ;
* bucket S3 pour Velero ;
* base RDS PostgreSQL ;
* certificats ACM ;
* zones DNS Route 53 ;
* repository ECR si besoin.

Exemple de structure Terraform possible :

```text
terraform/
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── iam/
│   ├── karpenter/
│   ├── rds/
│   ├── s3-backup/
│   ├── ecr/
│   └── route53/
├── environments/
│   ├── dev/
│   └── prod/
└── providers.tf
```

Exemple d’intention :

```hcl
module "vpc" {
  source = "./modules/vpc"

  name = "fastapi-devops"
  cidr = "10.0.0.0/16"
}

module "eks" {
  source = "./modules/eks"

  cluster_name = "fastapi-cluster"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids
}

module "rds" {
  source = "./modules/rds"

  engine     = "postgres"
  db_name    = "fastapi"
  subnet_ids = module.vpc.private_subnet_ids
}

module "s3_velero" {
  source = "./modules/s3-backup"

  bucket_name = "fastapi-velero-backups"
}
```

Résumé :

```text
On-premise :
Terraform crée des machines.

AWS :
Terraform crée des services cloud complets.
```

---

## 8. Rôle d’Ansible sur AWS

Dans l’architecture actuelle, Ansible construit quasiment tout le cluster Kubernetes.

Sur EKS, Ansible ne devrait plus installer Kubernetes. Son rôle serait plutôt de configurer le cluster après sa création par Terraform.

### 8.1 Rôles Ansible actuels

Actuellement, Ansible installe notamment :

* containerd ;
* Kubernetes ;
* masters ;
* workers ;
* HAProxy ;
* Keepalived ;
* MetalLB ;
* Traefik ;
* cert-manager ;
* Longhorn ;
* Prometheus/Grafana ;
* Argo CD ;
* Velero ;
* MinIO ;
* secrets.

### 8.2 Rôles Ansible cible AWS

Sur AWS, Ansible pourrait gérer :

* récupération du kubeconfig EKS ;
* installation d’Argo CD ;
* bootstrap des applications Argo CD ;
* installation d’External Secrets Operator ;
* installation de Velero ;
* installation du monitoring si non managé ;
* installation du AWS Load Balancer Controller si nécessaire ;
* configuration des namespaces ;
* application des manifests de sécurité ;
* déploiement des charts Helm complémentaires.

Structure possible :

```text
ansible/
├── roles/
│   ├── eks_kubeconfig/
│   ├── argocd/
│   ├── argocd_bootstrap/
│   ├── external_secrets/
│   ├── velero/
│   ├── monitoring/
│   └── aws_load_balancer_controller/
└── playbooks/
    └── configure-eks.yml
```

Résumé :

```text
On-premise :
Ansible construit le cluster.

AWS :
Ansible configure le cluster déjà fourni par EKS.
```

---

## 9. Gestion des nœuds : Managed Node Groups, Karpenter ou EKS Auto Mode

Trois approches sont possibles.

### 9.1 Managed Node Groups

C’est l’approche la plus simple.

On définit des groupes de nœuds avec :

* un nombre minimum de nœuds ;
* un nombre maximum ;
* un type d’instance ;
* une capacité souhaitée.

Avantage :

* simple à comprendre ;
* stable ;
* proche des workers actuels.

Inconvénient :

* moins dynamique ;
* risque de surdimensionnement ;
* choix d’instances plus rigide.

### 9.2 Karpenter

Karpenter est plus adapté à une vision cloud optimisée.

Au lieu de créer des workers fixes, Karpenter observe les pods en attente de scheduling et provisionne automatiquement les nœuds adaptés.

Principe :

```text
Pods non schedulables
  ↓
Karpenter détecte le besoin
  ↓
Création d’un nœud EC2 adapté
  ↓
Scheduling du pod
  ↓
Suppression/consolidation du nœud si inutile
```

Avantages :

* scaling plus dynamique ;
* meilleure optimisation des coûts ;
* possibilité d’utiliser plusieurs types d’instances ;
* possibilité d’utiliser du Spot ;
* réduction du surdimensionnement.

### 9.3 EKS Auto Mode

EKS Auto Mode va encore plus loin dans la délégation à AWS.

Il automatise davantage la gestion de l’infrastructure du cluster, notamment le compute, le scaling et certains aspects de load balancing. Il s’appuie sur une logique basée sur Karpenter.

Avantage :

* moins d’exploitation ;
* AWS prend plus de responsabilités ;
* intéressant pour une architecture très managée.

Inconvénient :

* moins de contrôle fin ;
* moins pédagogique dans un contexte de projet DevOps ;
* dépendance plus forte au fonctionnement AWS.

### 9.4 Choix recommandé pour le projet

Pour une projection réaliste et formatrice :

```text
Choix recommandé :
EKS + Karpenter
```

Pour une première migration simple :

```text
Choix possible :
EKS + Managed Node Groups
```

Pour une version très managée :

```text
Évolution possible :
EKS Auto Mode
```

---

## 10. Ingress et exposition applicative

### 10.1 Situation actuelle

Actuellement :

```text
Utilisateur
  ↓
DNS
  ↓
MetalLB IP 192.168.1.200
  ↓
Traefik
  ↓
Ingress Kubernetes
  ↓
Service Kubernetes
  ↓
Pods
```

### 10.2 Version AWS recommandée

Sur AWS :

```text
Utilisateur
  ↓
Route 53
  ↓
Application Load Balancer
  ↓
Ingress Kubernetes
  ↓
Service Kubernetes
  ↓
Pods
```

Le AWS Load Balancer Controller permet de créer automatiquement des load balancers AWS à partir de ressources Kubernetes.

Un Ingress peut donc créer un ALB.

Exemple d’Ingress cible :

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fastapi-app
  namespace: prod
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  ingressClassName: alb
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: fastapi-app-frontend
                port:
                  number: 80
```

### 10.3 TLS

Deux options :

#### Option AWS-native

* certificat ACM ;
* terminaison TLS sur l’ALB ;
* DNS Route 53.

#### Option Kubernetes-native

* cert-manager ;
* Let’s Encrypt ;
* certificat stocké dans Kubernetes.

Choix recommandé AWS :

```text
ACM + ALB + Route 53
```

---

## 11. Base de données : PostgreSQL dans Kubernetes ou RDS

### 11.1 Situation actuelle

PostgreSQL est déployé dans Kubernetes via le chart Bitnami.

Cette approche est utile pour apprendre :

* les StatefulSets ;
* les PVC ;
* les secrets ;
* les sauvegardes ;
* le monitoring de base de données dans Kubernetes.

### 11.2 Version AWS recommandée

Sur AWS, il serait préférable d’utiliser Amazon RDS PostgreSQL.

Architecture :

```text
Pods backend
  ↓
Endpoint RDS privé
  ↓
Amazon RDS PostgreSQL
```

Avantages :

* base de données hors du cluster Kubernetes ;
* sauvegardes gérées ;
* snapshots ;
* meilleure séparation entre applicatif et données ;
* maintenance simplifiée ;
* haute disponibilité possible avec Multi-AZ.

Ce changement est important :

```text
On-premise :
PostgreSQL est une charge stateful dans Kubernetes.

AWS :
PostgreSQL devient un service managé RDS.
```

---

## 12. Stockage persistant

### 12.1 Situation actuelle

Le stockage persistant est géré avec Longhorn.

Longhorn fournit des volumes distribués dans le cluster Kubernetes.

### 12.2 Version AWS

Sur AWS, plusieurs services remplacent Longhorn selon le besoin :

| Besoin                                | Service AWS    |
| ------------------------------------- | -------------- |
| Volume bloc pour un pod               | EBS CSI Driver |
| Stockage partagé entre plusieurs pods | EFS CSI Driver |
| Stockage objet                        | S3             |
| Base de données managée               | RDS            |

Si PostgreSQL est déplacé vers RDS, le besoin de volumes critiques dans Kubernetes diminue fortement.

---

## 13. Backup et restauration

### 13.1 Situation actuelle

Le projet utilise :

```text
Velero → MinIO
```

MinIO joue le rôle de stockage objet compatible S3.

### 13.2 Version AWS

Sur AWS, MinIO serait remplacé par S3 :

```text
Velero → S3
```

À créer avec Terraform :

* bucket S3 ;
* policy IAM ;
* rôle IAM pour Velero ;
* chiffrement ;
* lifecycle policy ;
* éventuellement versioning.

Velero serait toujours installé dans le cluster, mais son backend de stockage serait S3.

Différence importante :

```text
On-premise :
nous devons héberger le stockage objet.

AWS :
nous utilisons S3 comme service managé.
```

---

## 14. Secrets et IAM

### 14.1 Situation actuelle

Les secrets sont gérés avec :

* Ansible Vault ;
* Kubernetes Secrets ;
* variables GitLab CI/CD.

### 14.2 Version AWS

Sur AWS, les secrets sensibles pourraient être stockés dans :

* AWS Secrets Manager ;
* AWS Systems Manager Parameter Store.

Puis synchronisés dans Kubernetes via :

* External Secrets Operator.

Architecture :

```text
AWS Secrets Manager
  ↓
External Secrets Operator
  ↓
Kubernetes Secret
  ↓
Pod backend
```

Pour les accès AWS depuis les pods, on éviterait les clés statiques.

À la place :

```text
ServiceAccount Kubernetes
  ↓
EKS Pod Identity ou IRSA
  ↓
IAM Role
  ↓
Accès autorisé à S3, Secrets Manager, etc.
```

Exemples :

* Velero accède à S3 via un rôle IAM ;
* External Secrets accède à Secrets Manager via un rôle IAM ;
* l’application peut accéder à certains services AWS sans stocker de clés dans le cluster.

---

## 15. Monitoring et alerting

### 15.1 Option 1 : conserver kube-prometheus-stack

On peut garder :

* Prometheus ;
* Grafana ;
* Alertmanager ;
* ServiceMonitor ;
* PrometheusRule ;
* alertes Discord.

Avantage :

* continuité avec le projet actuel ;
* portabilité Kubernetes ;
* mêmes dashboards ;
* même logique d’alerting.

Inconvénient :

* Prometheus et Grafana restent à maintenir.

### 15.2 Option 2 : services AWS managés

On peut utiliser :

* Amazon Managed Service for Prometheus ;
* Amazon Managed Grafana ;
* CloudWatch Logs ;
* CloudWatch Container Insights ;
* SNS pour certaines alertes.

Avantage :

* moins de maintenance ;
* intégration AWS plus forte.

Inconvénient :

* moins portable ;
* coût potentiel ;
* dépendance AWS plus importante.

### 15.3 Choix recommandé

Pour une première projection :

```text
Conserver kube-prometheus-stack
```

Puis prévoir une évolution :

```text
Étudier Amazon Managed Prometheus / Grafana pour réduire l’exploitation.
```

---

## 16. CI/CD et Registry

### 16.1 Situation actuelle

Le projet utilise GitLab CI/CD pour :

* tester ;
* builder les images Docker ;
* pousser les images dans GitLab Container Registry ;
* gérer les tags dev/prod ;
* déclencher les déploiements via Argo CD et Image Updater.

### 16.2 Version AWS

Deux options :

#### Option A : conserver GitLab Registry

Avantage :

* peu de changement ;
* continuité avec l’existant ;
* pipeline déjà prêt.

#### Option B : utiliser Amazon ECR

Avantage :

* intégration AWS ;
* IAM ;
* proximité avec EKS ;
* gestion native dans AWS.

Exemple de cible :

```text
GitLab CI/CD
  ↓
docker build
  ↓
push vers ECR
  ↓
Argo CD Image Updater détecte le nouveau tag
  ↓
Mise à jour du chart Helm
  ↓
Déploiement par Argo CD
```

---

## 17. Adaptation du Helm chart

Le Helm chart resterait globalement conservé, mais certains values changeraient.

### 17.1 Images

Avant :

```yaml
backend:
  image:
    repository: registry.gitlab.com/devops-glmt/backend
    tag: prod
```

Avec ECR :

```yaml
backend:
  image:
    repository: 123456789012.dkr.ecr.eu-west-3.amazonaws.com/fastapi-backend
    tag: prod
```

### 17.2 Ingress

Avant :

```yaml
ingress:
  className: traefik
```

Après :

```yaml
ingress:
  className: alb
```

### 17.3 PostgreSQL

Avant :

```yaml
postgresql:
  enabled: true
```

Après, si RDS :

```yaml
postgresql:
  enabled: false

externalDatabase:
  host: fastapi-db.xxxxx.eu-west-3.rds.amazonaws.com
  port: 5432
  database: fastapi
  existingSecret: fastapi-db-secret
```

### 17.4 Stockage

Avant :

```yaml
storageClass: longhorn
```

Après :

```yaml
storageClass: gp3
```

ou inutile si la base est sur RDS.

---

## 18. Étapes concrètes de migration

### Étape 1 : Créer le socle AWS avec Terraform

Créer :

* VPC ;
* subnets publics/privés ;
* NAT Gateway ;
* Internet Gateway ;
* security groups ;
* IAM roles ;
* cluster EKS ;
* node groups ou Karpenter ;
* bucket S3 Velero ;
* base RDS PostgreSQL ;
* certificats ACM ;
* DNS Route 53.

### Étape 2 : Configurer l’accès au cluster

Configurer le kubeconfig EKS :

```bash
aws eks update-kubeconfig \
  --region eu-west-3 \
  --name fastapi-cluster
```

### Étape 3 : Installer les composants Kubernetes nécessaires

Via Ansible, Helm ou Terraform Helm provider :

* Argo CD ;
* AWS Load Balancer Controller ;
* External Secrets Operator ;
* Velero ;
* kube-prometheus-stack si conservé ;
* Argo CD Image Updater ;
* namespaces dev/prod.

### Étape 4 : Adapter les secrets

Migrer les secrets vers :

* AWS Secrets Manager ;
* ou SSM Parameter Store.

Puis créer les ExternalSecrets Kubernetes.

### Étape 5 : Adapter le Helm chart

Modifier :

* image repository ;
* ingressClass ;
* annotations ALB ;
* désactivation PostgreSQL interne ;
* connexion RDS ;
* storageClass si nécessaire.

### Étape 6 : Déployer via Argo CD

Créer les Applications Argo CD :

* fastapi-app-dev ;
* fastapi-app-prod.

Vérifier :

```bash
kubectl get applications -n argocd
kubectl get pods -n dev
kubectl get pods -n prod
kubectl get ingress -A
```

### Étape 7 : Valider l’exposition

Vérifier :

* création de l’ALB ;
* résolution DNS Route 53 ;
* certificat ACM ;
* accès HTTPS ;
* routage frontend/backend.

### Étape 8 : Valider les backups

Tester :

```bash
velero backup create test-backup --include-namespaces prod
velero backup get
velero restore create --from-backup test-backup
```

### Étape 9 : Valider monitoring et alerting

Vérifier :

* dashboards Grafana ;
* métriques pods/nodes ;
* alertes Prometheus ;
* réception Discord ou autre canal.

### Étape 10 : Tester la résilience

Tester :

* suppression d’un pod backend ;
* scaling applicatif ;
* indisponibilité simulée ;
* restauration Velero ;
* connexion RDS ;
* comportement Karpenter si utilisé.

---

## 19. Différences principales à expliquer à l’oral

### 19.1 En on-premise

Nous sommes responsables de presque toute la stack :

* VM ;
* OS ;
* runtime container ;
* installation Kubernetes ;
* HA du control plane ;
* réseau ;
* load balancing ;
* stockage ;
* backup objet ;
* monitoring ;
* base de données ;
* certificats ;
* sécurité.

### 19.2 Sur AWS

AWS reprend une partie des responsabilités :

* control plane EKS ;
* stockage objet S3 ;
* base RDS ;
* load balancers ALB/NLB ;
* certificats ACM ;
* IAM ;
* services managés optionnels pour monitoring.

### 19.3 Ce que l’équipe garde

L’équipe garde la responsabilité :

* du code applicatif ;
* des images Docker ;
* du Helm chart ;
* des manifests Kubernetes ;
* de la stratégie GitOps ;
* des pipelines CI/CD ;
* des règles de sécurité applicative ;
* du monitoring fonctionnel ;
* des sauvegardes à valider ;
* du coût cloud ;
* de la documentation.

---

## 20. Message de synthèse

La migration vers AWS ne consisterait pas à recopier l’infrastructure actuelle telle quelle sur des instances EC2.

L’objectif serait de conserver les principes DevOps du projet, tout en remplaçant les briques auto-hébergées par des services cloud managés lorsque cela apporte de la valeur.

Nous conserverions :

* Terraform ;
* Ansible pour la configuration post-cluster ;
* Helm ;
* Argo CD ;
* GitLab CI/CD ;
* Prometheus/Grafana ou une alternative managée ;
* Velero ;
* la séparation dev/prod ;
* la logique GitOps.

Nous remplacerions probablement :

* kubeadm par EKS ;
* HAProxy/Keepalived par le control plane managé EKS ;
* MetalLB par ALB/NLB ;
* MinIO par S3 ;
* PostgreSQL dans Kubernetes par RDS ;
* Longhorn par EBS/EFS ou RDS selon les besoins ;
* les secrets statiques par AWS Secrets Manager et IAM.

Cette projection montre que le projet actuel a permis de comprendre les fondations techniques d’une plateforme Kubernetes, et que ces connaissances peuvent être transposées vers une architecture cloud plus robuste, plus automatisée et plus scalable.
