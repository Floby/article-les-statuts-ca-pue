Les statuts, ça pue. Partie 3 : Les statuts, ça se lit
======================================================

Nous avons souvent dans nos modélisations, nos schémas, nos _user stories_, nos bases de données et
nos APIs un petit champ nommé `status`, parce que l'anglais ça fait classe.

Et bien je vous le dis tout de bon, ce petit champ qui stocke le statut de votre ressource, il sent mauvais
et augure bien des périls, en particulier si vous pouvez le modifier.
Il peut être révélateur d'une perte de richesse fonctionnelle de notre solution ainsi que de défauts de cohérences
ou de résilience de la conception technique. Bref : **Les statuts, ça pue**.

Les statuts, ça se lit
----------------------

Dans les points que nous avons abordés jusqu'ici, il revient un élément récurrent : on n'écrit pas un statut. En tout
cas nos utilisateurs n'expriment pas cette intention (sauf cas particuliers, voir [Limites](#limites)). En revanche,
les statuts font bel et bien partie du _Langage Omniprésent_ décrit
dans [DDD](https://blog.octo.com/domain-driven-design-des-armes-pour-affronter-la-complexite/).
Ils sont essentiels à la compréhension partagée du métier de notre système d'informations. Quelle est alors leur place
dans notre conception ?

### L'aide à la décision

Pour nos applications classiques, on cherche à faciliter les interactions entre nos utilisateurs et notre application.
Nos utilisateurs doivent décider quelles interactions lancer : Publier un article, Préparer une commande, Enregistrer
un brouillon, _etc_. C'est cette decision qui nécessite le concept de statut, en particulier lorsqu'il s'agit d'un système
qui coordonne plusieurs personnes ou plusieurs équipes. Les utilisateurs ne s'intéressent alors qu'à un sous-ensemble
des ressources qui portent le statut qui les intéresse.

Changeons un peu de domaine et parlons factures :

![Que faire d'une facture ?](./factures.png)
(_J'aime les fonctionnalités comptables car elles sont faciles à prioriser par la valeur !_)

On peut très bien imaginer que les actions « recevoir un paiement » et « signaler un retard » puissent être automatiques,
non n'allons donc pas spécialement en parler ici.

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

> _En tant que David, je veux lister les commandes qui ont le statut `excedent_paiement` afin de régulariser_

C'est bien ces fonctionnalités de consultation qui permettent à nos utilisateurs de lancer les bonnes actions ensuite, sans erreurs.
Les bonnes actions sont celles qu'il **faut** faire, qu'ils **peuvent** faire et qui seront **valides**.

On peut également imaginer le cas d'une autre équipe, beaucoup plus réduite, où c'est la même personne qui s'occupe de
toutes les factures. Il peut alors être légitime de prioriser d'autres fonctionnalités du type :

> _En tant qu'agent de facturation, je veux lister les actions qu'il est possible de faire sur une commande, afin de la traîter_

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

A l'inverse, on peut imaginer qu'atteindre ce statut est encore une fois le résultat d'une suite de transitions. On peut
alors décrire les commandes associées :

> _En tant qu'agent de facturation, je veux demander un recours juridique afin d'arrêter le cycle de relances infructueuses_

Nous remarquons que nous avons délimité une **frontière entre 2 domaines fonctionnels** ! Cela peut nous permettre de
découper notre diagramme d'automate en plusieurs sections et de prioriser notre modélisation en se focalisant sur
un seul de ces domaines.

### En résumé

Les statuts prennent tout leur sens dans les scénarios de **Consultation**.
Ils nous permettent d'exprimer facilement quelles actions nos utilisateurs peuvent lancer en fonction de leur rôle.
Ils leur permettent également de choisir efficacement quelles commandes ils doivent lancer.

En revanche, il y a des limites. L'historique d'une ressource peut être complexe à décrire pour atteindre un statut
donné et il sera alors peut-être plus facile d'exprimer le statut d'une ressource en fonction d'autres ressources qui 
lui sont associées. Le corollaire, c'est qu'il devient alors impossible de forcer (c'est-à-dire _d'écrire_) le statut
d'une ressource sans décrire ces ressources associées. En poussant encore plus loin, on peut conceptualiser certaines
de nos transitions comme des créations, des suppressions ou des modifications de ressources associées.

On peut résumer ces considérations par ce mantra : « **les statuts, c'est en lecture seule** »

