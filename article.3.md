Les statuts, ça pue (part. 3) : Les statuts, ça se lit
======================================================

Nous avons souvent dans nos modélisations, nos schémas, nos _user stories_, nos bases de données et
nos APIs un petit champ nommé `status`, parce que l'anglais ça fait classe.

Et bien je vous le dis tout de bon, ce petit champ qui stocke le statut de votre ressource, il sent mauvais
et augure bien des périls, en particulier si vous pouvez le modifier.
Il peut être révélateur d'une perte de richesse fonctionnelle de notre solution ainsi que de défauts de cohérences
ou de résilience de la conception technique. Bref : **Les statuts, ça pue**.

Les statuts, ça se lit
----------------------

Dans les articles précédents, nous avons vu comment, en analysant une machine à états, il était préférable de privilégier
les **verbes** qui y figurent pour transcrire nos [_User Stories_](https://blog.octo.com/les-statuts-ca-pue-part-1-fini-comme-un-automate/)
et dans nos [tests de recette](https://blog.octo.com/les-statuts-ca-pue-part-2-ciselage-en-us/).
Il apparaît alors un élément récurrent : on n'écrit pas un statut. En tout cas nos utilisateurs n'expriment pas cette
intention [<sup>1</sup>](#note-1). En revanche, les statuts font bel et bien partie du _Langage Omniprésent_ décrit
dans [DDD](https://blog.octo.com/domain-driven-design-des-armes-pour-affronter-la-complexite/).
Ils sont essentiels à la compréhension partagée du métier de notre système d'informations. Quelle est alors leur place
dans notre conception ?

### L'aide à la décision

Pour nos applications classiques, on cherche à faciliter les interactions entre nos utilisateurs et notre application.
Nos utilisateurs doivent décider quelles interactions lancer : Publier un article, Préparer une commande, Enregistrer
un brouillon, _etc_. C'est cette décision qui nécessite le concept de statut, en particulier lorsqu'il s'agit d'un système
qui coordonne plusieurs personnes ou plusieurs équipes. Les utilisateurs ne s'intéressent alors qu'à un sous-ensemble
des ressources qui portent le statut qui les intéresse.

Changeons un peu de domaine et parlons factures :

![Que faire d'une facture ?](./factures.png)
(_J'aime les fonctionnalités comptables car elles sont faciles à prioriser par la valeur !_)

On peut très bien imaginer que les actions « recevoir un paiement » et « signaler un retard » puissent être automatiques,
nous n'allons donc pas spécialement en parler ici.

L'aide à la décision peut alors se décliner en 2 cas de figure :

1. Que faire à propos de la facture #5678 ?
2. Quelles factures nécessitent une relance ?

Nos statuts jouent ici un rôle prépondérant pour répondre à ces questions.

1. Il est possible de _valider le montant du paiement_ ou _d'invalider le montant du paiement_ parce qu'elle a le statut
   `paiement_reçu`
2. Les factures #5678, #7890 et #1245 nécessitent une relance parce qu'elles ont le statut `délai_échu` ou `montant_insuffisant`

On peut imaginer que nos utilisateurs soient organisés de manière à être chacun responsable de tâches bien précises. Par exemple :

+ Alice contrôle les montants des paiement reçus
+ Bob relance les débiteurs
+ Charlotte engage les recours juridiques pour les impayés
+ David régularise les excédents de paiement

Nous aurons alors des _User Stories_ qui ressemblent à celles-ci :

> _En tant qu'Alice, je veux lister les commandes qui ont le statut `paiement_reçu` afin de vérifier leur montant_

> _En tant que Bob, je veux lister les commandes qui ont le statut `délai_échu` ou `montant_insuffisant` afin de relancer les débiteurs_

> _En tant que David, je veux lister les commandes qui ont le statut `excédent_paiement` afin de régulariser_

C'est bien ces fonctionnalités de consultation qui permettent à nos utilisateurs de lancer les bonnes actions ensuite, sans erreurs.
Les bonnes actions sont celles qu'il **faut** faire, qu'ils **peuvent** faire et qui seront **valides**.

On peut également imaginer le cas d'une autre équipe, beaucoup plus réduite, où c'est la même personne qui s'occupe de
toutes les factures. Il peut alors être légitime de prioriser d'autres fonctionnalités du type :

> _En tant qu'agent de facturation, je veux lister les actions qu'il est possible de faire sur une commande, afin de la traiter_

### L'aide à la conception !

En continuant sur notre exemple précédent, on peut remarquer le cas curieux de ces 2 _User Stories_ :

> _En tant que Bob, je veux lister les commandes qui ont le statut `délai_échu` ou `montant_insuffisant` afin de relancer les débiteurs_

> _En tant que Charlotte, je veux lister les commandes qui ont le statut `délai_échu` ou `montant_insuffisant` afin de lancer un recours juridique_

Ces deux utilisateurs semblent se baser sur les mêmes informations pour prendre des décisions différentes. Cependant,
nous savons intuitivement qu'il existe une règle métier qui indique par exemple le nombre de relances à faire avant
de lancer un recours juridique ou alors le temps passé sans paiement.

Dans notre cas, nos utilisateurs vont probablement se baser sur d'autres informations relatives à une facture :

+ Le temps passé depuis l'émission de le facture
+ Le nombre de relances déjà effectuées
+ Une date butoir définie
+ L'historique de paiement du débiteur
+ Les arrangements passés avec le débiteur
+ L'état de la trésorerie

Si ces informations sont utiles, alors on pourra concevoir les _User Stories_ qui apportent ces informations à l'utilisateur.

On peut également concevoir des statuts plus précis, taillés pour l'utilisateur qui va les consulter :

> _En tant que Charlotte, je veux consulter les factures qui ont le statut `recours_nécessaire`_

Que veut dire `recours_nécessaire` ? Il peut s'agir, par exemple, des factures qui ont à la fois :

+ le statut `délai_échu`
+ déjà fait l'objet d'au moins 3 relances
+ pas fait l'objet d'un recours juridique

Ces critères se basent à la fois sur **le statut** d'une ressource ainsi que sur **les ressources qui y sont liées**.
Ici il s'agit des relances et des recours.
Il est également à noter que ce statut n'a pas de sens en dehors de l'aide à la décision, il est utilisé uniquement pour
de la **consultation**.

### L'interface entre domaines métiers

Nous remarquons que nous avons délimité une **frontière entre 2 domaines fonctionnels** ! Dans les exemples précédents,
l'avènement d'un status `recours_nécessaire` permet de fusionner le détail de plusieurs statuts de gestion en un seul.
C'est ce statut qui est intéressant pour le domaine voisin du recours juridique. Les utilisateurs de ce domaine fonctionnel
n'ont qu'à _lire_ les dossiers qui correspondent à ce statut, sans se préoccuper du détail.
On peut le formaliser comme ceci par exemple :

    recours_nécessaire = délai_échu | montant_insuffisant

On remarque également que cela signifie qu'une facture peut avoir 2 statuts différents à un moment donné. En effet,
une facture peut très bien apparaître à la fois dans la liste des factures échues et dans la liste des factures
nécessitant un recours juridique. Ce sont des utilisateurs différents en revanche qui consultent ces 2 listes.

Une intuition du _Domain-Driven Design_ consiste à modéliser ceci sous la forme de 2 _contextes_ différents, chacun
ayant une seule entité désignant une _facture_ qui peut se trouver dans un état à la fois, dans chaque contexte.
Ceux-ci sont appelés _Bounded Context_ et servent à encapsuler une certaine complexité fonctionnelle que les autres
contextes n'ont pas besoin de connaître.

Ceci implique alors de définir quel sous-ensemble d'informations transitent
entre ces contextes. C'est bien là que nos statuts peuvent jouer un rôle : en tant que composant de **l'interface** 
qui lie les _Bounded Contexts_ entre eux.

![Les statuts en tant qu'interface entre contextes](./statut-interface.png)

Pour reprendre l'exemple précédent, les utilisateurs qui se chargent des recours juridiques ont un travail facilité
en pouvant consulter rapidement les factures qui en nécessitent. Ils pourront alors gérer tout un cycle de vie propre
au domaine des procédures juridiques. De même, les utilisateurs qui gèrent les factures au quotidien peuvent voir
un statut `procédure_en_cours` sur certaines factures, sans pour autant s'intéresser au détail des procédures.

En faisant quelques suppositions sur un domaine juridique que je ne maitrise pas, on peut par exemple avoir :

    procédure_en_cours = greffes_saisies | accusé_reception_tribunal | audience_planifiée

Les différentes contextes rendent disponibles entre eux une information _synthétique,_ par l'intermédiaire d'un statut,
de leur considérations internes. Cette synthèse est régie par les règles métiers propres à chaque contexte. Ce sont
ces règles qui constituent une partie de la valeur de noter système.

En termes plus formels, on dira qu'un statut est une _projection_ d'un ensemble de données. En d'autres termes,
réduire des informations sur plusieurs dimensions (identifiant, statut, ressources liées, historique, etc.) à un
nombre plus réduit de dimensions. Pour des statuts, on cherche à réduire à une seule dimension discrète. Si toutes,
les bonnes données sont disponibles, alors il est facile de déduire de manière déterministe le statut d'une ressource.
Pour caricaturer, disons qu'on peut calculer le statut d'une ressource avec une requête SQL bien calibrée.
C'est donc une opération de **lecture pure**.

Attention tout de même, les statuts peuvent consituer une partie de l'interface d'un contexte. En revanche, l'interface
d'un contexte ne peut pas se réduire un ensemble de statuts et tous les statuts n'ont pas vocation à faire partie de
l'interface.

### Pourquoi pas écrire alors ?

Au vu des paragraphes précédents, on peut être tenté de se dire que si les statuts servent de vecteur d'informations
entre contextes (et donc entre équipes dans notre exemple), alors il peut être légitime que l'utilisateur Bob puisse
demander l'écriture du statut `recours_nécessaire` explicitement dans le système à l'attention de Charlotte. C'est un
choix d'implémentation possible mais présente les limites suivantes :

+ Où sont les règles métiers qui déterminent qu'un recours est nécessaire ? Dans le cas présent : dans la tête de Bob.
  Bien que Bob connaisse bien son travail, il n'est pas impossible qu'il soit absent, indisposé ou confus et n'applique
  pas toujours les mêmes règles. C'est certes l'opportunité de laisser un jugement humain dans la procédure, mais notre
  système ne peut alors plus être garant de cette procédure.

+ Comment gérer les écritures concourantes ? Que se passe-t-il si 2 utilisateurs veulent appliquer un statut différent
  à une même facture ? Pour le statut `paiement_reçu` 3 options sont possibles comme statut suivant. Que se passe-t-il
  si 3 personnes, se basant sur cette même information, prennent des décision différentes quant au statut suivant ?

+ Comment gérer les statuts multiples ? Une facture peut très bien nécessiter un recours et une relance à la fois.
  L'information `recours_nécessaire` ne s'adresse qu'à un autre contexte et n'as pas forcément de sens pour les autres.

Enfin, si notre système porte aussi peut de valeur que _« faire passer des messages préformattés entre équipes »,_
alors il faut s'interroger sur l'opportunité d'utiliser des e-mail plutôt que de développer un outil _ad hoc._

### En résumé

Les statuts prennent tout leur sens dans les scénarios de **Consultation**.
Ils nous permettent d'exprimer facilement quelles actions nos utilisateurs peuvent lancer en fonction de leur rôle.
Ils leur permettent également de choisir efficacement quelles commandes ils doivent lancer. Ce sont les statuts qui
aident les utilisateurs à apprivoiser la complexité du système par l'attribution d'un vocabulaire spécifique à une
information synthétique.

En revanche, il y a des limites. L'historique d'une ressource peut être complexe à décrire pour atteindre un statut
donné et il sera alors peut-être plus facile d'exprimer le statut d'une ressource en fonction d'autres ressources qui 
lui sont associées. Le corollaire, c'est qu'il devient alors impossible de forcer (c'est-à-dire _d'écrire_) le statut
d'une ressource sans décrire ces ressources associées. En poussant encore plus loin, on peut conceptualiser certaines
de nos transitions comme des créations, des suppressions ou des modifications de ressources associées.

Pour maitriser cette complexité, on peut alors aussi considérer les statuts comme une partie de l'interface qui existe
entre plusieurs _Bounded Contexts._

On peut résumer ces considérations par ce mantra : « **les statuts, c'est en lecture seule** »

Dans le prochain article, nous intéresserons aux 2 différents cas dans lesquels nous pouvons _écrire_ un statut
justement.

<a name="note-1">[1]: </a> _Il existe des exceptions evidemment ! Nous en parlerons (enfin) dans l'article suivant_
