Feature: Calculer le résultat d'un scrutin majoritaire
    En tant que client de l'API à la clôture d'un scrutin majoritaire
    Je veux calculer le résultat du scrutin
    Pour obtenir le vainqueur du vote

Background:
    Given un scrutin majoritaire existe
    And les candidats suivants sont enregistrés:
        | Nom      |
        | Candidat A |
        | Candidat B |
        | Candidat C |

Scenario: Un candidat obtient plus de 50% des voix au premier tour
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 600   |
        | Candidat B | 250   |
        | Candidat C | 150   |
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And le vainqueur doit être "Candidat A"
    And les résultats doivent afficher:
        | Candidat   | Votes | Pourcentage |
        | Candidat A | 600   | 60.00%      |
        | Candidat B | 250   | 25.00%      |
        | Candidat C | 150   | 15.00%      |

Scenario: Aucun candidat n'obtient plus de 50% - Second tour nécessaire
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 450   |
        | Candidat B | 350   |
        | Candidat C | 200   |
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And aucun vainqueur ne doit être déterminé
    And les candidats qualifiés pour le second tour doivent être:
        | Candidat   |
        | Candidat A |
        | Candidat B |
    And les résultats doivent afficher:
        | Candidat   | Votes | Pourcentage |
        | Candidat A | 450   | 45.00%      |
        | Candidat B | 350   | 35.00%      |
        | Candidat C | 200   | 20.00%      |

Scenario: Vainqueur déterminé au second tour
    Given le scrutin est au tour 2
    And les candidats qualifiés sont:
        | Candidat   |
        | Candidat A |
        | Candidat B |
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 450   |
        | Candidat B | 550   |
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And le vainqueur doit être "Candidat B"
    And les résultats doivent afficher:
        | Candidat   | Votes | Pourcentage |
        | Candidat B | 550   | 55.00%      |
        | Candidat A | 450   | 45.00%      |

Scenario: Égalité au second tour - Pas de vainqueur
    Given le scrutin est au tour 2
    And les candidats qualifiés sont:
        | Candidat   |
        | Candidat A |
        | Candidat B |
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 500   |
        | Candidat B | 500   |
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And aucun vainqueur ne doit être déterminé
    And le message doit indiquer "Égalité - Aucun vainqueur déterminé"

Scenario: Tentative de calcul sur un scrutin non clôturé
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 600   |
        | Candidat B | 400   |
    When je tente de calculer le résultat sans clôturer le scrutin
    Then une exception doit être levée avec le message "Le scrutin doit être clôturé pour calculer le résultat"

Scenario: Limite de deux tours maximum
    Given le scrutin est au tour 2
    And les candidats qualifiés sont:
        | Candidat   |
        | Candidat A |
        | Candidat B |
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 450   |
        | Candidat B | 550   |
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And le vainqueur doit être "Candidat B"
    And aucun troisième tour ne doit être possible

Scenario: Vainqueur avec exactement 50% des voix - Second tour nécessaire
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 500   |
        | Candidat B | 300   |
        | Candidat C | 200   |
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And aucun vainqueur ne doit être déterminé
    And les candidats qualifiés pour le second tour doivent être:
        | Candidat   |
        | Candidat A |
        | Candidat B |

Scenario: Un seul candidat au scrutin - Vainqueur automatique
    Given un scrutin majoritaire avec un seul candidat existe
    And le candidat "Candidat Unique" est enregistré
    And les votes suivants ont été enregistrés:
        | Candidat        | Votes |
        | Candidat Unique | 1000  |
    When je clôture le scrutin
    Then le vainqueur doit être "Candidat Unique"
    And les résultats doivent afficher:
        | Candidat        | Votes | Pourcentage |
        | Candidat Unique | 1000  | 100.00%     |

Scenario: Aucun vote enregistré
    Given le scrutin est au tour 1
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And aucun vainqueur ne doit être déterminé
    And le message doit indiquer "Aucun vote enregistré"

Scenario: Tentative d'enregistrement de votes après clôture
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 600   |
        | Candidat B | 400   |
    And le scrutin a été clôturé
    When je tente d'enregistrer des votes supplémentaires pour "Candidat A" avec 100 votes
    Then une exception doit être levée avec le message "Le scrutin est déjà clôturé"

Scenario: Candidat inexistant lors de l'enregistrement des votes
    Given le scrutin est au tour 1
    When je tente d'enregistrer des votes pour un candidat inexistant "Candidat Inexistant" avec 500 votes
    Then une exception doit être levée avec le message "Le candidat Candidat Inexistant n'existe pas"

Scenario: Tour invalide (tour 3)
    Given un scrutin majoritaire existe
    When je tente de définir le tour à 3
    Then une exception doit être levée avec le message "Le tour doit être 1 ou 2"

Scenario: Tour invalide (tour 0)
    Given un scrutin majoritaire existe
    When je tente de définir le tour à 0
    Then une exception doit être levée avec le message "Le tour doit être 1 ou 2"

Scenario: Égalité parfaite entre trois candidats au premier tour
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 333   |
        | Candidat B | 333   |
        | Candidat C | 334   |
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And aucun vainqueur ne doit être déterminé
    And les candidats qualifiés pour le second tour doivent être:
        | Candidat   |
        | Candidat C |
        | Candidat A |

Scenario: Égalité pour la deuxième place au premier tour
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 400   |
        | Candidat B | 300   |
        | Candidat C | 300   |
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And aucun vainqueur ne doit être déterminé
    And les candidats qualifiés pour le second tour doivent être:
        | Candidat   |
        | Candidat A |
        | Candidat B |

Scenario: Modification des votes avant clôture
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 300   |
        | Candidat B | 400   |
    And je modifie les votes pour "Candidat A" à 700
    When je clôture le scrutin
    Then le vainqueur doit être "Candidat A"
    And les résultats doivent afficher:
        | Candidat   | Votes | Pourcentage |
        | Candidat A | 700   | 63.64%      |
        | Candidat B | 400   | 36.36%      |

Scenario: Calcul des pourcentages avec décimales
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 333   |
        | Candidat B | 333   |
        | Candidat C | 334   |
    When je clôture le scrutin
    Then les résultats doivent afficher:
        | Candidat   | Votes | Pourcentage |
        | Candidat C | 334   | 33.40%      |
        | Candidat A | 333   | 33.30%      |
        | Candidat B | 333   | 33.30%      |

Scenario: Second tour avec un seul candidat qualifié (cas limite)
    Given le scrutin est au tour 2
    And les candidats qualifiés sont:
        | Candidat   |
        | Candidat A |
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 1000  |
    When je clôture le scrutin
    Then le vainqueur doit être "Candidat A"

Scenario: Vérification de l'ordre des candidats dans les résultats
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 100   |
        | Candidat B | 300   |
        | Candidat C | 200   |
    When je clôture le scrutin
    Then les candidats doivent être ordonnés par nombre de votes décroissant:
        | Position | Candidat   | Votes |
        | 1        | Candidat B | 300   |
        | 2        | Candidat C | 200   |
        | 3        | Candidat A | 100   |

Scenario: État du scrutin après clôture
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 600   |
        | Candidat B | 400   |
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And le tour actuel doit être 1
    And aucune modification ne doit être possible

Scenario: Vainqueur avec majorité absolue importante
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 800   |
        | Candidat B | 100   |
        | Candidat C | 100   |
    When je clôture le scrutin
    Then le vainqueur doit être "Candidat A"
    And les résultats doivent afficher:
        | Candidat   | Votes | Pourcentage |
        | Candidat A | 800   | 80.00%      |
        | Candidat B | 100   | 10.00%      |
        | Candidat C | 100   | 10.00%      |

Scenario: Égalité parfaite entre les 2ème et 3ème candidats - Ordre alphabétique
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 500   |
        | Candidat B | 250   |
        | Candidat C | 250   |
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And aucun vainqueur ne doit être déterminé
    And les candidats qualifiés doivent être dans l'ordre alphabétique en cas d'égalité:
        | Candidat   |
        | Candidat A |
        | Candidat B |

Scenario: Égalité parfaite entre 3 candidats pour la 2ème place - Ordre alphabétique
    Given un scrutin majoritaire existe
    And les candidats suivants sont enregistrés:
        | Nom        |
        | Candidat A |
        | Candidat B |
        | Candidat C |
        | Candidat D |
    And le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 400   |
        | Candidat B | 200   |
        | Candidat C | 200   |
        | Candidat D | 200   |
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And aucun vainqueur ne doit être déterminé
    And les candidats qualifiés doivent être dans l'ordre alphabétique en cas d'égalité:
        | Candidat   |
        | Candidat A |
        | Candidat B |

Scenario: Gestion des votes blancs - Premier tour avec vainqueur
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 600   |
        | Candidat B | 300   |
        | Candidat C | 100   |
    And 200 votes blancs ont été enregistrés
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And le vainqueur doit être "Candidat A"
    And le nombre de votes blancs doit être 200
    And le total des votes exprimés doit être 1200
    And les résultats doivent afficher:
        | Candidat   | Votes | Pourcentage |
        | Candidat A | 600   | 60.00%      |
        | Candidat B | 300   | 30.00%      |
        | Candidat C | 100   | 10.00%      |

Scenario: Gestion des votes blancs - Premier tour sans vainqueur
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 400   |
        | Candidat B | 350   |
        | Candidat C | 250   |
    And 300 votes blancs ont été enregistrés
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And aucun vainqueur ne doit être déterminé
    And le nombre de votes blancs doit être 300
    And le total des votes exprimés doit être 1300
    And les candidats qualifiés pour le second tour doivent être:
        | Candidat   |
        | Candidat A |
        | Candidat B |

Scenario: Gestion des votes blancs - Second tour avec vainqueur
    Given le scrutin est au tour 2
    And les candidats qualifiés sont:
        | Candidat   |
        | Candidat A |
        | Candidat B |
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 450   |
        | Candidat B | 350   |
    And 200 votes blancs ont été enregistrés
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And le vainqueur doit être "Candidat A"
    And le nombre de votes blancs doit être 200
    And le total des votes exprimés doit être 1000

Scenario: Gestion des votes blancs - Second tour avec égalité
    Given le scrutin est au tour 2
    And les candidats qualifiés sont:
        | Candidat   |
        | Candidat A |
        | Candidat B |
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 400   |
        | Candidat B | 400   |
    And 200 votes blancs ont été enregistrés
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And aucun vainqueur ne doit être déterminé
    And le message doit indiquer "Égalité - Aucun vainqueur déterminé"
    And le nombre de votes blancs doit être 200

Scenario: Votes blancs uniquement
    Given le scrutin est au tour 1
    And 1000 votes blancs ont été enregistrés
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And aucun vainqueur ne doit être déterminé
    And le nombre de votes blancs doit être 1000
    And le total des votes exprimés doit être 1000

Scenario: Tentative d'enregistrement de votes blancs après clôture
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 600   |
        | Candidat B | 400   |
    And le scrutin a été clôturé
    When je tente d'enregistrer 100 votes blancs après clôture
    Then une exception doit être levée avec le message "Le scrutin est déjà clôturé"

Scenario: Égalité triple pour la première place au premier tour - Ordre alphabétique
    Given le scrutin est au tour 1
    And les votes suivants ont été enregistrés:
        | Candidat   | Votes |
        | Candidat A | 300   |
        | Candidat B | 300   |
        | Candidat C | 300   |
    When je clôture le scrutin
    Then le scrutin doit être clôturé
    And aucun vainqueur ne doit être déterminé
    And les candidats qualifiés doivent être dans l'ordre alphabétique en cas d'égalité:
        | Candidat   |
        | Candidat A |
        | Candidat B |

Scenario: Votes blancs avec candidat unique
    Given un scrutin majoritaire avec un seul candidat existe
    And le candidat "Candidat Unique" est enregistré
    And les votes suivants ont été enregistrés:
        | Candidat        | Votes |
        | Candidat Unique | 700   |
    And 300 votes blancs ont été enregistrés
    When je clôture le scrutin
    Then le vainqueur doit être "Candidat Unique"
    And le nombre de votes blancs doit être 300
    And le total des votes exprimés doit être 1000
    And les résultats doivent afficher:
        | Candidat        | Votes | Pourcentage |
        | Candidat Unique | 700   | 100.00%     |
