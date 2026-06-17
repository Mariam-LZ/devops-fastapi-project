# Analyse de l’architecture actuelle — Application FastAPI

## 1. Objectif du document

Ce document analyse l’architecture actuelle de l’application avant sa transformation DevOps.

L’objectif est de comprendre les services existants, leurs dépendances, les variables d’environnement utilisées, ainsi que les éléments à migrer progressivement vers une architecture Kubernetes.

---

## 2. Architecture actuelle

L’application fonctionne actuellement avec Docker Compose.

Elle repose sur plusieurs services :

- db : base de données PostgreSQL
- backend : API FastAPI
- frontend : interface web
- prestart : job d’initialisation du backend
- adminer : interface d’administration de la base
- traefik : reverse proxy externe (géré séparément)

Le fichier docker-compose.yml définit les services applicatifs, tandis que Traefik est configuré dans un fichier distinct.

---

## 3. Services applicatifs

### Backend

Le service backend correspond à l’API FastAPI.

Il est construit depuis le dossier :

    ./backend

Il expose le port interne 8000 et contient un healthcheck sur l’endpoint :

    /api/v1/utils/health-check/

Il dépend de la base de données PostgreSQL et du service prestart.

---

### Frontend

Le service frontend correspond à l’interface web.

Il est construit depuis le dossier :

    ./frontend

Le build utilise la variable :

    VITE_API_URL

Cette variable permet au frontend de connaître l’URL de l’API backend.

---

### Base de données

Le service db utilise l’image officielle :

    postgres:12

Les données sont persistées via le volume :

    app-db-data

En Kubernetes, cela sera remplacé par un PersistentVolumeClaim.

---

### Prestart

Le service prestart utilise la même image que le backend.

Il exécute le script :

    scripts/prestart.sh

Il permet d’effectuer les tâches d’initialisation avant le démarrage du backend.

En Kubernetes, il sera remplacé par un Job.

---

### Adminer

Le service adminer fournit une interface web pour administrer la base PostgreSQL.

Il est utile en développement et éventuellement en staging pour faciliter les vérifications techniques.

En production, il ne sera pas exposé publiquement afin de limiter la surface d’attaque. Si un accès à la base est nécessaire, il devra passer par un accès sécurisé et contrôlé.
---

## 4. Exposition réseau actuelle

L’exposition externe repose sur Traefik via Docker Compose.

Les routes principales sont :

    api.<domain>        → backend
    dashboard.<domain>  → frontend
    adminer.<domain>    → adminer

En Kubernetes, ces routes seront gérées via Ingress ou Gateway API.

---

## 5. Variables d’environnement

Actuellement, les variables sont centralisées dans le fichier `.env` utilisé par Docker Compose.

Dans l’architecture cible Kubernetes, ces variables seront séparées selon leur sensibilité.

Les variables de configuration seront migrées vers des ConfigMap Kubernetes. Les variables sensibles, comme les mots de passe et clés secrètes, seront migrées vers des Secrets Kubernetes ou injectées via les variables protégées GitLab CI/CD.

Les variables spécifiques à Docker Compose, comme DOCKER_IMAGE_BACKEND et DOCKER_IMAGE_FRONTEND, seront remplacées dans Helm par des valeurs d’image sous la forme repository/tag.

### Configuration (ConfigMap)

- DOMAIN
- FRONTEND_HOST
- ENVIRONMENT
- BACKEND_CORS_ORIGINS
- SMTP_HOST
- SMTP_USER
- EMAILS_FROM_EMAIL
- POSTGRES_SERVER
- POSTGRES_PORT
- POSTGRES_DB
- POSTGRES_USER
- SENTRY_DSN
- PROJECT_NAME
- STACK_NAME
- SMTP_TLS
- SMTP_SSL
- SMTP_PORT
### Docker Compose-specific variables

The following variables are currently used by Docker Compose and should not be migrated directly to Kubernetes ConfigMaps:

- DOCKER_IMAGE_BACKEND
- DOCKER_IMAGE_FRONTEND

In the Kubernetes target architecture, image references will be managed through Helm values using a `repository` and `tag` format.

### Secrets (Secret)

- SECRET_KEY
- FIRST_SUPERUSER
- FIRST_SUPERUSER_PASSWORD
- SMTP_PASSWORD
- POSTGRES_PASSWORD

Les valeurs par défaut doivent être remplacées.

### Variables frontend

Le frontend utilise un fichier `.env` spécifique basé sur Vite.

Variables identifiées :

- VITE_API_URL : URL de l’API backend
- MAILCATCHER_HOST : URL du service de test email

Ces variables sont injectées au moment du build et ne peuvent pas être modifiées dynamiquement à l’exécution.

Dans l’architecture cible Kubernetes, cela implique que le frontend devra être rebuild pour chaque environnement (dev, staging, production), ou qu’une stratégie alternative de configuration runtime devra être mise en place.

---

## 6. Images Docker

Images à construire :

- backend
- frontend

Images externes :

- postgres
- adminer

Le service prestart réutilise l’image backend.

---

## 7. Migration vers Kubernetes

Correspondance :

- db → StatefulSet + Service + PVC
- backend → Deployment + Service + Ingress
- frontend → Deployment + Service + Ingress
- prestart → Job
- adminer → Deployment (optionnel)
- volume → PersistentVolumeClaim
- traefik → Ingress / Gateway
- .env → ConfigMap + Secret

---

## 8. Architecture cible

Trois environnements seront utilisés :

    dev
    staging
    prod

Chaque environnement disposera de son propre cluster Kubernetes.

---

## 9. Points d’attention

Le frontend dépend de VITE_API_URL au moment du build.

La base de données nécessite une stratégie de persistance et de sauvegarde.

Les secrets ne doivent pas être stockés en clair.

Adminer ne doit pas être exposé en production.

---

## 10. Prochaine étape

Mettre en place une pipeline GitLab CI pour :

- tester le backend
- tester le frontend
- construire les images Docker
- publier les images dans le registry