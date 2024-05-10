conditionalPanel(condition = "output.ValTabs",
                 fixedRow(
                   HTML("<div style='height: 10px;'>"),
                   HTML("</div>"),
                   column(
                     8,
                     align = "top",
                     h1("Aide"),
                     h3("Suivez les étapes ci-dessous pour visualiser les données de manière graphique :"),
                     h4("1. Importez le fichier de données dans l'onglet Téléchargement et cliquez sur \"Soumettre\"."),
                     h4("2. Sélectionnez les colonnes à inclure pour les mesures, les dimensions et celles à exclure."),
                     h4("3. Effectuez un prétraitement des données dans le volet \"Néttoyage de la data\""),
                     h4("4. Une fois les colonnes sélectionnées, le bouton \"Explorer\" apparaîtra."),
                     h4("5. Cliquez sur \"Explorer\" pour afficher les visualisations graphiques.")
                   )
                 ))

