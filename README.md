# Automatisation du Déploiement de Spark avec Ansible et Terraform

## Présentation

Ce projet vise à automatiser le déploiement d'une infrastructure **Big Data** basée sur **Apache Spark**.  
L’infrastructure est créée avec **Terraform**, le déploiement et la configuration de Spark sont gérés avec **Ansible**, et la connectivité réseau est assurée via **Hamachi VPN**.

## Technologies utilisées

- **Terraform** : Création et gestion des machines virtuelles avec **KVM/libvirt**.
- **Ansible** : Installation et configuration automatisées de **Apache Spark**.
- **Hamachi VPN** : Communication sécurisée entre les machines.
- **Java/Maven** : Développement et exécution de l’application **WordCount** pour tester Spark.

## Architecture

Le projet repose sur **quatre machines virtuelles**, réparties sur **deux hôtes physiques**, connectées via **Hamachi**.

- 1 VM **Master Spark**
- 3 VMs **Workers Spark**

## Installation

### 1. Déploiement des machines virtuelles

```sh
terraform init
terraform apply -auto-approve
```
### 2. Configuration du réseau (Hamachi)

Sur chaque machine virtuelle :

```sh
sudo systemctl start logmein-hamachi
sudo hamachi login
sudo hamachi join selsa-infra infra
```

### 3. Installation de Spark avec Ansible

```sh
ansible-playbook -i inventory.ini spark_install.yml
```

### 4. Validation avec WordCount

```sh
spark-submit --master spark://25.49.208.249:7077 --class com.example.WordCount target/wordcount.jar fichier.txt output.txt
```

## Résultats attendus

- Infrastructure **Big Data** déployée automatiquement.
- **Spark installé** et configuré sur toutes les VMs.
- Test de l’application **WordCount** validant le bon fonctionnement du cluster.
