#!/bin/bash

# 1️⃣ Création du cluster Kubernetes avec k3d
echo "🚀 Création du cluster Kubernetes..."
k3d cluster create my-cluster
kubectl create namespace argocd
kubectl create namespace dev

# 4️⃣ Installation d'ArgoCD
echo "📦 Installation d'ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 5️⃣ Attente qu'ArgoCD soit prêt
echo "⏳ Attente du démarrage des pods ArgoCD..."
kubectl wait --for=condition=Ready pods -n argocd --all --timeout=300s

# 6️⃣ Récupération et affichage du mot de passe admin ArgoCD
echo "🔑 Récupération du mot de passe admin d'ArgoCD..."
ARGO_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "🔑 Mot de passe admin : $ARGO_PWD"
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
sleep 5

# 8️⃣ Connexion à ArgoCD via CLI
echo "🔗 Connexion à ArgoCD CLI..."
argocd login localhost:8080 --username admin --password $ARGO_PWD --insecure

# 9️⃣ Ajout du dépôt Git à ArgoCD
echo "📂 Ajout du dépôt Git à ArgoCD..."
argocd repo add https://github.com/Pirabaud/pirabaud --insecure

argocd login cd.argoproj.io --core
kubectl config set-context --current --namespace=argocd

# 🔟 Déploiement de l'application ArgoCD
echo "🚀 Création de l'application ArgoCD..."
argocd app create playground-app \
  --repo https://github.com/Pirabaud/pirabaud \
  --path "." \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev

# 1️⃣1️⃣ Synchronisation de l'application
echo "🔄 Synchronisation de l'application..."
argocd app sync playground-app
