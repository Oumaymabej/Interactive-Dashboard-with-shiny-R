fixedRow(
  column(12,
         align = "left",
         h1("Conception et Réalisation de Tableaux de Bord Dynamiques : "),
         h2("Applications pour l'Analyse de Bases de Données Médicales sur Parkinson et Alzheimer"),
         HTML("<div style='height: 25px;'>"),
         HTML("</div>"),
         h3("À Propos"),
         h4("La conception et la réalisation de tableaux de bord dynamiques jouent un rôle crucial dans le prétraitement et l'analyse exploratoire des bases de données médicales.
            Cette phase est essentielle pour comprendre les relations entre les variables et découvrir de nouvelles connaissances sur les processus biologiques liés au Parkinson et à Alzheimer.
            Ces avancées permettront d'améliorer les modèles existants pour le suivi, la détection précoce et la prédiction de ces maladies complexes.
           "),
         HTML("<div style='height: 5px;'>"),
         HTML("</div>"),
         h3("Guide d'Utilisation"),
         h4("Voici les étapes à suivre :"),
         tags$ol(
           tags$li(h4("Téléchargez la base de données médicales dans l'onglet \"Téléchargement\" et cliquez sur Soumettre.")), 
           tags$li(h4("Consultez la structure des données dans l'onglet \"Structure\".")),
           tags$li(h4("Visualisez les données réelles dans l'onglet \"Prévisualisation\".")),
           tags$li(h4("Sélectionnez les caractéristiques des colonnes dans l'onglet \"Choisir les attributs des colonnes\".")),
           tags$li(h4("Choisissez les dimensions pour les variables discrètes ou non continues")),
           tags$li(h4("Déterminez les mesures pour les variables continues")),
           tags$li(h4("Excluez les variables de l'analyse en utilisant l'option \"Exclure\"")),
           tags$li(h4("Cliquer sur \"Affecter\"pour passer au volet suivant")),
           tags$li(h4("Effectuez un prétraitement des données dans le volet \"Néttoyage de la data\"")), 
            tags$li(h4("Lorsque le prétraitement est terminé, cliquez sur Explorer dans l'onglet \"Sélectionner les Caractéristiques\".")),
           tags$li(h4("En cliquant sur Explorer, accédez à sept visualisations interactives différentes dans le volet latéral."))
         )
        
  )
)
