Les statuts, ça pue
===================

<style>
:root {
  font-family: sans-serif;
  font-size: 18px;
}

* {
  max-width: 900px;
  margin-left: auto;
  margin-right: auto;
}

blockquote {
  padding: 1em;
  box-sizing: border-box;
  border-left: 3px solid darkblue;
  background: #eee;
  background: linear-gradient(90deg, #eee 0%, #eee 95%, rgba(255,255,255,0) 100%);
}
blockquote p {
  margin: 0;
  padding: 0;
}
pre {
  background-color: black;
  color: lightgray;
  overflow-x: auto;
  padding: .5em;
  box-sizing: border-box;
  border-radius: 5px;
}

code {
  font-family: monospace;
  font-size: 80%;
}


@media print {
  pre {
    border: 1px solid lightgray;
    background: none;
    white-space: pre-line;
    color: gray;
  }
}

</style>

> _En tant que préparateur, je veux passer la commande en statut `en cours de préparation` afin d'informer_
> _le client de l'avancement de sa commande_

Vous avez déjà vu cette _User Story_. Si ce n'est elle, c'est donc sa sœur. On conçoit souvent nos procédures
métier comme une évolution linéaire, une succession d'état d'une ressource donnée qui tendent irrémédiablement
vers un statut `terminé`. _Tirer à droite !_ ou _Zero stock !_ sont autant de _gimmicks_ qui révèlent notre
inlassable vision finaliste d'un processus de production en flux.

C'est pourquoi nous avons souvent dans nos modélisations, nos schémas, nos _user stories_, nos bases de données et
nos APIs un petit champ nommé `status`, parce que l'anglais ça fait classe.

Et bien je vous le dis tout de bon, ce petit champ qui stocke le statut de votre ressource, il sent mauvais
et augure bien des difficultés. Bref : **Les statuts, ça pue**.

Comme une automate
------------------

Lorsque l'on modélise nos précessus, ils arrive fréquemment qu'on tombe sur une modélisation
dite [d'automate fini](https://fr.wikipedia.org/wiki/Automate_fini). Ces modèles sont pratiques car faciles à visualiser
et à décrire. Par exemple, pour mon exemple de système de livraisons de commandes.

![Flux basique de livraison](./base.png)

Ce diagramme indique le cycle de vie d'une commande dans un service de logistique une fois qu'elle est passée par un client.
On y voit les temps d'attente entre les équipes qui préparent les commandes et celles qui les livrent. On y voit également
quel état précede quel état, et donc quelles transitions sont légitimes.

Cependant j'y vois déjà 3 défauts :

1. On ne comprends pas les **actions** à faire pour faire passer d'un statut à l'autre ;
2. On ne comprend pas **qui** doit agir lorsqu'une commande est en attente ;
3. On n'y voit pas les cas **d'echec** et leur **stratégie de contournement** ;

### Modélisons plus explicitement

Le premier point est le plus aisé à corriger, puisqu'il suffit de nommer nos transitions

![transitions nommées](./named.png)

Voilà qui est un peu plus clair. Ce qui me gène encore, c'est que le statut `en_attente` traduit l'attente d'acteurs
variés qui, selon mon métier, agissent tour à tour ou en parallèle. Démélons ceci pour l'instant afin d'y voir plus clair

![Qu'est-ce qu'on attend ?](./waiting.png)

Génial ! Rendre explicite quelles personnes peuvent résoudre une _attente_ nous a permis d'identifier un travail distinct
entre 2 processus en série. Ceci rendra le raisonnement plus simple. Nous avons aussi permis de faire apparaître du
vocabulaire plus spécifique avec des commandes _prêtes_ qui identifie le traîtement que ces états appellent.

Passons maintenant à tenter de modéliser les cas d'echecs (seulement sur la seconde partie du processus).

![Rien ne marche !](./errors.png)

Prévoir les cas d'erreurs possibles et la reprise sur echec d'un processus est souvent long et difficile…
Je me suis arrêté en route pour me focaliser sur 2 élements :

+ Certains cas font intervenir des domaines complètement différents (ex. réapprovisionner des produits lorsque le stock est vide) ;
+ D'autres peuvent former des boucles lorsqu'on tente plusieurs fois la même action. Il conviendrait alors dans notre modèle
  de déterminer également ce qui permet de sortir d'une boucle ;

En itérant un peu sur notre modélisation, nous avons pu :

+ Identifier des frontières entre des processus distincts, à propos desquels il sera plus simple de raisonner ;
+ Distinguer des états qui semblaient identiques ;
+ Identifier les _verbes_ qui régissent notre processus ;

C'est justement sur ce dernier point que je voulais attirer votre attention.

### Implémentons les transitions et non les états

Si la finalité du Système d'Informations que nous développons est de garantir la cohérence d'un processus,
alors notre principal enjeu est d'implementer correctement **les transitions** qui régissent ce processus. À l'inverse,
fonder notre modélisation sur les _étapes_ d'un processus risque de nous faire manquer des éléments fonctionnels cruciaux.

C'est tout à fait évident dans l'exemple de _user story_ que j'ai donnée en introduction. En voici une version amendée
pour coller à la modélisation que nous venons de faire.

> En tant que préparateur, je veux commencer le picking d'une commande
> afin d'aller chercher les bons produits dans le stock

Ici on ne parle plus de statut, mais bien de la transition que l'on cherche à implémenter. En réalité, le statut
de la commande, tel qu'affiché à un client ou tracé dans un journal, ne concerne que peu le préparateur. Il vaudra alors
mieux rendre ces fonctionnalités explicites pour les utilisateurs qui en ont effectivement besoin


> En tant que client, je veux visualiser l'état de préparation de ma commande afin de me rassurer sur son avancement

> En tant que contrôleur, je veux lister les préparations de commande réalisée par un préparateur afin de vérifier
  qu'il atteint ses quotas journaliers

(_Ah c'est sûr, rédiger correctement ses stories peut vous conduire à réaliser que vous participez à la construction
d'un outil d'oppression_ 😳)

### En résumé

La modélisation d'un processus ou du cycle de vie d'une ressource sous forme de diagramme d'automate est donc
bien utile et pertinente. Cependant, il convient de lire cette modélisation en se focalisant sur les arcs qui lient
les états entre eux. En effet, quand ils interagissent avec notre système, nos utilisateurs expriment les transitions qu'ils veulent
déclencher et non les états qu'ils veulent atteindre. L'état courant d'une ressource peut en revanche leur permettre de décider
quelle interaction ils décident d'avoir. C'est bien le **nom des transitions** qui apparaît dans la section « je veux ... »
de nos _User Stories._

Mais alors, comment rédiger et découper ces _User Stories_ ?

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


```gherkin
CONSIDERANT que la commande #1234 est prête à livrer
ET que je suis un livreur
QUAND je commence la livraison
ALORS la commande #1234 est en livraison
```

plutôt simple ! continuons :

```gherkin
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


```gherkin
CONSIDERANT que la commande #1234 a le statut "prête à livrer"
ET que je suis un livreur
QUAND je change le statut de la commande #1234 à "en livraison"
ALORS la commande #1234 a le statut "en livraison"
```

```gherkin
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

```gherkin
CONSIDERANT que la commande #1234 a le statut "prête à livrer"
ET que je suis un livreur
QUAND je change le statut de la commande à "absence de destinataire"
ALORS un message d'erreur m'informe qu'une commande ne peut pas passer de l'état "prête à livrer" à "absence de destinataire"
```

```gherkin
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

En approchant par les transitions, il suffit de décrire l'état dans le quel doit se trouver la ressource
avant d'y appliquer une action en considérant que tous les autres états sont alors illégitimes pour y
appliquer ladite action. Vous pouvez alors certes rédigier autant de tests sur les messages d'erreurs
mais la logique est alors plus aisée à comprendre à la lecture.

```gherkin
CONSIDERANT que la commande #1234 est prête à livrer
ET que je suis un livreur
QUAND je signale l'absence du destinataire
ALORS un message d'erreur m'informe "vous ne pouvez pas signaler l'absence du destinataire car la commande n'est pas en livraison (elle est prête à livrer)"
```

```gherkin
CONSIDERANT que la commande #1234 est en livraison
ET que je suis un livreur
QUAND je commence la livraison
ALORS un message d'erreur m'informe "vous ne pouvez pas commencer la livraison car la commande n'est pas prête à livrer (elle est en livraison)"
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

```gherkin
CONSIDERANT que la commande #1234 est en livraison
ET que je suis un livreur
QUAND je signale l'absence du destinataire
ALORS la commande #1234 a le statut "destinataire absent"
```

Mais aussi ceux-ci :

```gherkin
CONSIDERANT que la commande #1234 est livrée
ET que je suis livreur
QUAND je signale l'absence du destinataire
ALORS un message m'informe "Vous ne pouvez pas signaler l'absence d'un destinataire car la commande n'est pas en livraison (elle est livrée)"
```

```gherkin
CONSIDERANT que la commande #1234 est prête à livrer
ET que je suis livreur
QUAND je signale l'absence du destinataire
ALORS un message m'informe "Vous ne pouvez pas signaler l'absence d'un destinataire car la commande n'est pas en livraon (elle est prête à livrer)"
```

Mais je peux aussi choisir la simplicité et décrire un cas générique :

```gherkin
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

Rappelons-nous seulement que la plus petite des _User Stories_ ne comporte peut-être qu'un seul test de recette !

### En résumé

Je trouve qu'il est plus aisé de concevoir ses critères d'acceptance lorsqu'on part du principe
que **personne ne modifie directement le statut** d'une ressource. Les utilisateurs du système lancent les **intéractions** qu'ils
ont avec lui (les _cas d'usages_ ou même les _commandes_). Ces interactions ont une influence sur le statut d'une ressource que l'on
peut alors déduire. Décrire qu'une ressource est dans un certain état revient alors à lister les transitions qui
lui ont permis de l'atteindre. Consulter l'état d'une ressource nous permet alors de savoir si une action donnée
peut y être appliquée. Il relève donc de l'aide à la décision et de la validation de l'action avant exécution.

Ces tests de recette peut constituer la base du découpage de nos _User Stories_.

Les statuts, ça se lit
----------------------

  -> un statut, c'est la projection d'une collection d'événements ou de ressources associées



Pour le Web et les API
----------------------

Il y a beaucoup de chances pour que le système que vous concevez soit basée sur une architecture _Web_ et donc
sur un paradigme [Client / Server](https://fr.wikipedia.org/wiki/Client%E2%80%93serveur). Dans ce type d'architecture,
le _client_ est l'interface par laquelle les utilisateurs interagissent avec le système qui est lui situé sur le serveur
et réputé source de vérité. Or nous avons vu précédemment qu'il est préférable de modéliser quelle **actions**
les utilisateurs entreprennent sur les ressources plutôt que la modification du statut de celles-ci.
Si l'ambition de votre système est d'assurer le bon suivi et la traçabilité d'un processus métier, alors il est
impensable que la logique qui s'en assure soit executée sur un client plutôt qu'un serveur.

  -> les clients n'ont pas le droit d'écrire un champ statut

Limites
-------

  -> logique métier dans la tête de qqn
  -> logique métier sur un autre service

Conclusion
----------

  Un statut c'est readonly et c'est le serveur qui le calcule
