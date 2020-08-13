Les statuts, ça pue
===================

> _En tant que préparateur, je veux passer la commande en statut `en cours de préparation` afin d'informer_
> _le client de l'avancement de sa commande_

Vous avez déjà vu cette _User Story_. Si ce n'est elle, c'est donc sa sœur. On conçoit souvent nos procédures
métier comme une évolution linéaire, une succession d'état d'une ressource donnée qui tendent irrémédiablement
vers un statut `terminé`. _Tirer à droite !_ ou _Zero stock !_ sont autant de _gimmicks_ qui révèlent notre
inlassable vision finaliste d'un processus de production en flux.

C'est pourquoi nous avons souvent dans nos modélisations, nos schémas, nos _user stories_, nos bases de données et
nos APIs un petit champ nommé `status`, parce que l'anglais ça fait classe.

Et bien je vous le dis tout de bon, ce petit champ qui stocke le statut de votre ressource, il sent mauvais
et augure bien des périls, en particulier si vous pouvez le modifier.
Il peut être révélateur d'une perte de richesse fonctionnelle de notre solution ainsi que de défauts de cohérences
ou de résilience de la conception technique. Bref : **Les statuts, ça pue**.

Comme une automate
------------------

Lorsque l'on modélise nos précessus, ils arrive fréquemment qu'on tombe sur une modélisation
dite [d'automate fini](https://fr.wikipedia.org/wiki/Automate_fini). Ces modèles sont pratiques car faciles à visualiser
et à décrire. Sans s'engager complètement dans leur formalisme, elles gardent un grand pouvoir explicatif.
Par exemple, pour mon exemple de système de livraisons de commandes.

![Flux basique de livraison](./base.png)

Ce diagramme indique le cycle de vie d'une commande dans un service de logistique une fois qu'elle est passée par un client.
On y voit les temps d'attente entre les équipes qui préparent les commandes et celles qui les livrent. On y voit également
quel état précede quel état, et donc quelles transitions sont légitimes.

Cependant j'y vois déjà 3 défauts :

1. On ne comprends pas les **actions** à faire pour faire passer d'un statut à l'autre ;
2. On ne comprend pas **qui** doit agir lorsqu'une commande est en attente ;
3. On n'y voit pas les cas **d'echec** et leur **stratégie de contournement** ;

### Nommer les transitions avec le vocabulaire métier

Le premier point est le plus aisé à corriger, puisqu'il suffit de nommer nos transitions

![transitions nommées](./named.png)

Voilà qui est un peu plus clair. Ce qui me gène encore, c'est que le statut `en_attente` traduit l'attente d'acteurs
variés qui, selon mon métier, agissent tour à tour ou en parallèle. Démélons ceci pour l'instant afin d'y voir plus clair

![Qu'est-ce qu'on attend ?](./waiting.png)

Génial ! Rendre explicite quelles personnes peuvent résoudre une _attente_ nous a permis d'identifier un travail distinct
entre 2 processus en série. Ceci rendra le raisonnement plus simple. Nous avons aussi permis de faire apparaître du
vocabulaire plus spécifique avec des commandes qui identifie le traîtement que ces états appellent.

Tentons maintenant de modéliser les cas d'echecs (seulement sur la seconde partie du processus).

![Rien ne marche !](./errors.png)

Prévoir les cas d'erreurs possibles et la reprise sur echec d'un processus est souvent long et difficile…
Je me suis arrêté en route pour me concentrer sur 2 élements :

+ Certains cas font intervenir des domaines complètement différents (ex. réapprovisionner des produits lorsque le stock est vide) ;
+ D'autres peuvent former des boucles lorsqu'on tente plusieurs fois la même action. Il conviendrait alors dans notre modèle
  de déterminer également ce qui permet de sortir d'une boucle ;

En se posant seulement les questions _Quelle action résulte en cet état ?_, _Qui fait cette action ?_ et _Quand fait-on cette action ?_,
nous avons pu :

+ Identifier des frontières entre des processus distincts, à propos desquels il sera plus simple de raisonner en
  isolation et d'identifier les points de connexion ;
+ Distinguer des états qui semblaient identiques ;
+ Identifier les _verbes_ qui régissent notre processus ;

C'est justement sur ce dernier point que je voulais attirer votre attention.

### Implémentons les transitions et non les états

Si la finalité du Système d'Informations que nous développons est de garantir la cohérence d'un processus [<sup>1</sup>](#note-1),
alors notre principal enjeu est d'implementer correctement **les transitions** qui régissent ce processus. À l'inverse,
fonder notre modélisation sur les _étapes_ d'un processus risque de nous faire manquer des éléments fonctionnels cruciaux
ainsi que des stratégies de priorisation par la valeur utiles.

C'est tout à fait évident dans l'exemple de _user story_ que j'ai donnée en introduction. En voici une version amendée
pour coller à la modélisation que nous venons de faire.

> En tant que préparateur, je veux commencer le picking d'une commande
> afin d'aller chercher les bons produits dans le stock

Ici on ne parle plus de statut, mais bien de la **transition** que l'on cherche à implémenter. En réalité, le statut
de la commande, tel qu'affiché à un client ou tracé dans un journal, ne concerne que peu le préparateur. Il vaudra alors
mieux rendre ces fonctionnalités explicites pour les utilisateurs qui en ont effectivement besoin et les réaliser en
temps opportun.


> En tant que client, je veux visualiser l'état de préparation de ma commande afin de me rassurer sur son avancement

> En tant que contremaître, je veux lister les préparations de commandes réalisées par un préparateur afin de valider son
> quota quotidien

(_Ah c'est sûr, rédiger correctement ses stories peut vous conduire à réaliser que vous participez à la construction
d'un outil d'oppression_ 😳)

### En résumé

La modélisation d'un processus ou du cycle de vie d'une ressource sous forme de diagramme d'automate est
très utile et pertinente. Cependant, il convient de lire cette modélisation en se focalisant sur les arcs qui lient
les états entre eux. En effet, quand ils interagissent avec notre système, nos utilisateurs expriment les transitions qu'ils veulent
déclencher et non les états qu'ils veulent atteindre[<sup>1</sup>](#note-1). L'état courant d'une ressource peut en revanche leur permettre de décider
quelle interaction ils décident d'avoir ensuite. C'est bien le **nom des transitions** qui apparaît dans la section « _je veux …_ »
de nos _User Stories._

Ces diagrammes sont un bon support de discussion pour explorer et expliquer les règles fonctionnelles d'un logiciel. Pour
aller plus loin, vous pouvez collaborer sur cette documentation à la façon
des [ADR evoqués dans cet article](https://blog.octo.com/larchitecte-et-git-une-fusion-de-raison/) si vous basez comme
moi sur le langage [Dot](https://graphviz.org/Gallery/directed/fsm.html) pour les décrire.

Dans le prochain article nous nous intéresseront aux stratégies de découpage en _User Story_ une fois que le cycle de vie
de notre ressource est bien compris.

<a name="note-1">[1]: </a> _Nous parlons bien ici des logiciels qui sont garants d'un processus métier. Dans un prochain
article, nous verrons qu'il y a des cas légitimes qui contredisent ce qui est énoncé ici, parce que sinon, c'est pas drôle_ 🙃.

Tests de recette
----------------

En tant que _Product Owners_ consciencieux, nous allons réfléchir à la manière de découper ce modèle en _User Stories_
avec leur lot de tests d'acceptance. Pour le bien de tous, _Product Owners_, Développeurs et Testeurs, il convient
de rédiger ces tests de manière à ce qu'il soient systématisables, voire même automatisables. J'aime raisonner en
[Gherkin](https://cucumber.io/docs/gherkin/), qui nous permet de bien distinguer notre état inital de test, les actions
que nous testons et les prédictions que nous faisons sur leurs conséquences. Tentons quelques tests relatifs à la
livraison des commandes :

![Livraison des commandes](./delivery.png)

### Scenarios de succès


```
CONSIDERANT que la commande #1234 est prête à livrer
ET que je suis un livreur
QUAND je commence la livraison
ALORS la commande #1234 est en livraison
```

plutôt simple ! continuons :

```
CONSIDERANT que la commande #1234 est en absence destinataire
ET que je suis un planificateur
QUAND je replanifie la livraison au lendemain
ALORS la commande #1234 est prête à être livrée
```

Celui-ci ignore beaucoup de détails de la vie réelle, mais je simplifie pour garder les exemples courts.
Ici, on peut aussi remarquer que dans la description de mon état initial, je dit simplement qu'une commande
est dans un état précis. La connaissance des étapes nécessaires pour parvenir à cet état doit être
partagée entre _product owner_, développeurs et testeurs.

Comparons maintenant à ces mêmes tests si nous avions pris le parti de construire notre fonctionnalité à partir
des états de notre diagramme plutôt que des transitions.


```
CONSIDERANT que la commande #1234 a le statut "prête à livrer"
ET que je suis un livreur
QUAND je change le statut de la commande #1234 à "en livraison"
ALORS la commande #1234 a le statut "en livraison"
```

```
CONSIDERANT que la commande #1234 a le statut "absence de destinataire"
ET que je suis un planificateur
QUAND je change le statut de la commande à "prête à livrer"
ALORS la commande #1234 a le statut "prête à livrer"
```


Tout de suite, nous remarquons que ces tests sont moins intéressant à lire (et je vous laisse imaginer
quant à leur rédaction). J'y remarque aussi une perte de richesse fonctionnelle. Par exemple, on n'y voit plus
apparaître qu'il faut replanifier une livraison pour qu'elle puisse passer de nouveau dans le
statut `prête à livrer`. Si on n'est pas précautionneux, on peut alors omettre des éléments fonctionnels
cruciaux dans nos tests et par extension dans nos _user stories_ et donc notre système.

Ce n'est pas tout, jetons un œil aux tests qui nous permettent de vérifier que nous interdisons certaines transitions.

### Scénarios d'erreur

```
CONSIDERANT que la commande #1234 a le statut "prête à livrer"
ET que je suis un livreur
QUAND je change le statut de la commande à "absence de destinataire"
ALORS un message d'erreur m'informe qu'une commande ne peut pas passer de l'état "prête à livrer" à "absence de destinataire"
```

```
CONSIDERANT que la commande #1234 a le statut "prête à livrer"
ET que je suis un livreur
QUAND je change le statut de la commande à "prête à livrer"
ALORS un message d'erreur m'informe que la commande a déjà le statut "prête à livrer"
```

Nous nageons désormais en plein détail d'implementation pour des tests qui devraient pourtant décrire d'un point de vue
fonctionnel le métier du système. En effet, en approchant le problème par la modification du statut de ma ressource
je suis à terme obligé de définir l'exhaustivité de tests d'acceptance pour les transitions légitimes comme celles
illégitimes, en rouge dans cette illustration.

![Tous les cas interdits](./forbidden.png)

La combinatoire risque de nous dépasser, nous risquons d'oublier des cas et de rendre possible un état
qui n'a aucun sens dans notre système.

En approchant par les transitions, il suffit de décrire l'état dans lequel doit se trouver la ressource
avant d'y appliquer une action en considérant que tous les autres états sont alors illégitimes pour y
appliquer ladite action. Vous pouvez alors certes rédigier autant de tests sur les messages d'erreurs
mais la logique est alors plus aisée à comprendre à la lecture.

```
CONSIDERANT que la commande #1234 est prête à livrer
ET que je suis un livreur
QUAND je signale l'absence du destinataire
ALORS un message d'erreur m'informe "vous ne pouvez pas signaler l'absence du destinataire car la commande n'est pas en livraison"
```

```
CONSIDERANT que la commande #1234 est en livraison
ET que je suis un livreur
QUAND je commence la livraison
ALORS un message d'erreur m'informe "vous ne pouvez pas commencer la livraison car la commande n'est pas prête à livrer"
```

### Découpons selon les pointillés 

Nous nous trouvons desormais avec une collection plus ou moins exhaustive de cas de tests. Ces tests ont l'immense
valeur de rendre explicite beaucoup de choses qui auraient pu autrement sembler evidentes pour les _Product Owners,_
comme pour les Testeurs et les Développeurs. Le problème est que l'évidence est souvent très différente pour chacun !

Rendre le maximum de choses explicites peut nous aider à trouver la bonne taille pour découper nos _User Stories._ Ces
tests peuvent nous aider à mieux saisir la complexité ou la taille d'une fonctionnalité.

Certaines équipes estiment la complexité des _User Stories_ par leur nombre de tests de recette. Les tâches les plus
simples ne comprennent qu'un seul test. Afin de concevoir des _user stories_ de taille raisonnable, vous pouvez alors construire
avec votre équipe, le découpage de celles-ci en cherchant à minimiser le nombre de tests de recette par _User Story_.
Vous pouvez par exemple vous adonner à un atelier [_Tres Amigos_](https://blog.octo.com/le-bdd/).

Baser ses estimations sur le nombre de cas de tests d'acceptance possède également l'avantage d'être plus objectif
et moins sujet [au biais d'optimisme](https://fr.wikipedia.org/wiki/Biais_d%27optimisme). Ils permettent aussi de
délimiter clairement les bornes d'une fonctionnalité afin que tous les acteurs de son développement puissent s'accorder
à dire quand elle est terminée.

Considérant cette _User Story_ :

> _En tant que livreur, je veux signaler l'absence d'un destinataire afin de permettre une replanification_


Je peux alors décider d'y inclure ce test de recette :

```
CONSIDERANT que la commande #1234 est en livraison
ET que je suis un livreur
QUAND je signale l'absence du destinataire
ALORS la commande #1234 a le statut "destinataire absent"
```

Mais aussi ceux-ci :

```
CONSIDERANT que la commande #1234 est livrée
ET que je suis livreur
QUAND je signale l'absence du destinataire
ALORS un message m'informe "Vous ne pouvez pas signaler l'absence d'un destinataire car la commande n'est pas en livraison (elle est livrée)"
```

```
CONSIDERANT que la commande #1234 est prête à livrer
ET que je suis livreur
QUAND je signale l'absence du destinataire
ALORS un message m'informe "Vous ne pouvez pas signaler l'absence d'un destinataire car la commande n'est pas en livraison (elle est prête à livrer)"
```

Mais je peux aussi choisir la simplicité et décrire un cas générique :

```
CONSIDERANT que la commande #1234 est payée
ET que je suis livreur
QUAND je signale l'absence du destinataire
ALORS un message m'informe "Vous ne pouvez pas signaler l'absence d'un destinataire pour la commande #1234"
```

Ou si on veut prioriser les droits d'accès :

```
CONSIDERANT que la commande #1234 est en livraison
ET que je suis préparateur
QUAND je signale l'absence du destinataire
ALORS un message m'informe "Vous ne pouvez pas faire cette action en tant que préparateur"
```

Bref, en piochant quelques tests de recette, nous pouvons concevoir une _User Story_ cohérente de taille raisonnable.
Rappelons-nous seulement que la plus petite des _User Stories_ ne comporte peut-être qu'un seul test de recette !

### En résumé

Je trouve qu'il est plus aisé de concevoir ses critères d'acceptance lorsqu'on part du principe
que **personne ne modifie directement le statut** d'une ressource. Les utilisateurs du système lancent les **intéractions** qu'ils
ont avec lui (les _cas d'usages_ ou même les _commandes_). Ces interactions ont une influence sur le statut d'une ressource que l'on
peut alors déduire. Décrire qu'une ressource est dans un certain état revient alors à lister les transitions qui
lui ont permis de l'atteindre. Consulter l'état d'une ressource nous permet alors de savoir si une action donnée
peut y être appliquée ou non. Il relève donc de l'aide à la décision et de la cohérence de l'action demandée.
Ces tests de recette peuvent constituer la base du découpage de nos _User Stories_.

Du coup, quand peut-on parler de statuts dans nos _User Stories_ ?

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

Limites
-------

TODO

* logique métier dans la tête de qqn
* logique métier sur un autre service
* design incremental

Conclusion
----------

TODO

Un statut c'est readonly et c'est le serveur qui le calcule
