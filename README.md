
<div align="center">
  <a href="[https://hydralauncher.site](https://www.shinyapps.io/admin/#/application/11984121)">
    </a>
  <h1 align="center">Canopy</h1>
</div>
- [Introduction](#Introduction)
- [Installation](#installation)


# Introduction:
 Dans ce projet, nous allons concevoir et réaliser un tableau de bord dynamique en
utilisant RShiny pour le prétraitement et l’analyse de bases de données médicales. Nous
allons nous concentrer sur les bases de données concernant la maladie de Parkinson et la
maladie d’Alzheimer.

#installation
## Résolution de l'erreur de chargement du package 'xlsx'

Lorsque vous essayez de charger le package 'xlsx' dans R, vous pouvez rencontrer une erreur indiquant que le chargement du package 'rJava' a échoué et que JAVA_HOME ne peut pas être déterminé à partir du Registre. Voici comment résoudre ce problème :

## 1. Vérifier si Java est installé

Assurez-vous que Java est installé sur votre système en ouvrant un terminal ou une invite de commande et en tapant la commande suivante :

bash
Cela devrait afficher les informations de version de Java si Java est installé correctement.

## 2. Définir la variable JAVA_HOME
Si Java est installé, vous devez définir la variable d'environnement JAVA_HOME.
 Cette variable indique à R où Java est installé sur votre système. Suivez ces étapes :
Sur Windows :

 Recherchez "Variables d'environnement" dans le menu Démarrer et ouvrez-le.
    Cliquez sur "Variables d'environnement" en bas.
    Dans la section "Variables système", cliquez sur "Nouveau" et ajoutez une variable nommée JAVA_HOME avec le chemin vers votre répertoire d'installation Java (par exemple, C:\Program Files\Java\jdk1.8.0_281).
    Cliquez sur "OK" pour enregistrer les modifications.

Sur Linux/Mac :

   Ouvrez votre fichier de configuration shell (par exemple, ~/.bashrc, ~/.bash_profile, ~/.profile) dans un éditeur de texte.
    Ajoutez la ligne suivante à la fin du fichier :

bash:
export JAVA_HOME=/chemin/vers/votre/installation/java

   Enregistrez le fichier et exécutez source ~/.bashrc (ou le fichier approprié selon votre shell) pour appliquer les modifications.
Après avoir défini la variable JAVA_HOME, redémarrez votre session R et essayez de charger à nouveau le package 'xlsx'.

Si vous rencontrez toujours des problèmes, vérifiez que la variable JAVA_HOME est correctement définie et pointe vers le répertoire d'installation de Java.

Pour plus d'informations sur l'installation de Java SDK et la configuration de l'environnement, consultez le site officiel de Java: [Java Downloads]("https://www.oracle.com/java/technologies/javase-jdk11-downloads.html")







