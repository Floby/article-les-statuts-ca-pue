Les statuts, ça pue. Partie 2 : Ciselage en US
==============================================

Nous avons souvent dans nos modélisations, nos schémas, nos _user stories_, nos bases de données et
nos APIs un petit champ nommé `status`, parce que l'anglais ça fait classe.

Et bien je vous le dis tout de bon, ce petit champ qui stocke le statut de votre ressource, il sent mauvais
et augure bien des périls, en particulier si vous pouvez le modifier.
Il peut être révélateur d'une perte de richesse fonctionnelle de notre solution ainsi que de défauts de cohérences
ou de résilience de la conception technique. Bref : **Les statuts, ça pue**.

Tests de recette
----------------

En tant que _Product Owners_ consciencieux, nous allons réfléchir à la manière de découper ce modèle en _User Stories_
avec leur lot de tests d'acceptance. Pour le bien de tous, _Product Owners_, Développeurs et Testeurs, il convient
de rédiger ces tests de manière à ce qu'il soient systématisables, voire même automatisables. J'aime raisonner en
[Gherkin](https://cucumber.io/docs/gherkin/), qui nous permet de bien distinguer notre état initial de test, les actions
que nous testons et les prédictions que nous faisons sur leurs conséquences. Tentons quelques tests relatifs à la
livraison des commandes :

![Livraison des commandes](./delivery.png)

### Scénarios de succès


```
CONSIDERANT que la commande #1234 est prête à livrer
ET que je suis un livreur
QUAND je commence la livraison
ALORS la commande #1234 est en livraison
```

Plutôt simple ! Continuons :

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

Nous nageons désormais en plein détail d'implémentation pour des tests qui devraient pourtant décrire d'un point de vue
fonctionnel le métier du système. En effet, en approchant le problème par la modification du statut de ma ressource
je suis à terme obligé de définir l'exhaustivité de tests d'acceptance pour les transitions légitimes comme celles
illégitimes, en rouge dans cette illustration.

![Tous les cas interdits](./forbidden.png)

La combinatoire risque de nous dépasser, nous risquons d'oublier des cas et de rendre possible un état
qui n'a aucun sens dans notre système.

En approchant par les transitions, il suffit de décrire l'état dans lequel doit se trouver la ressource
avant d'y appliquer une action en considérant que tous les autres états sont alors illégitimes pour y
appliquer ladite action. Vous pouvez alors certes rédiger autant de tests sur les messages d'erreurs
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

Nous nous trouvons désormais avec une collection plus ou moins exhaustive de cas de tests. Ces tests ont l'immense
valeur de rendre explicite beaucoup de choses qui auraient pu autrement sembler évidentes pour les _Product Owners,_
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
Rappelons nous seulement que beaucoup de petites _User Stories_ sont préférables à peu de grosses car elle permettent
un _feedback_ bien plus rapide et donc plus d'occasions de s'adapter à temps.

### En résumé

Je trouve qu'il est plus aisé de concevoir ses critères d'acceptance lorsqu'on part du principe
que **personne ne modifie directement le statut** d'une ressource. Les utilisateurs du système lancent les **interactions** qu'ils
ont avec lui (les _cas d'usages_ ou même les _commandes_). C'est le nom des transitions qui se retrouve dans la section
`QUAND` (`WHEN`) de nos tests Gherkin.

Ces interactions ont une influence sur le statut d'une ressource que l'on
peut alors vérifier. Décrire qu'une ressource est dans un certain état revient alors à lister les transitions qui
lui ont permis de l'atteindre.

Consulter l'état d'une ressource nous permet alors de savoir si une commande donnée
peut y être appliquée ou non. Cette consultation relève donc de l'aide à la décision, c'est la lecture du statut
qui permet à l'utilisateur de lancer la bonne[<sup>1</sup>](#note-1) interaction.

Ces tests de recette peuvent constituer la base du découpage de nos _User Stories_.

Du coup, quand peut on parler de statuts dans nos _User Stories_ ?
Dans le prochain article, nous verrons quelle est la place des _statuts_ dans notre langage omniprésent (_Ubiquitous Language_)


<a name="note-1">[1]: </a> _La **bonne** interaction est celle qui sera acceptée par le système ET qui a le meilleur
sens métier._
