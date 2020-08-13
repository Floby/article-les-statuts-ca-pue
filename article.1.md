Les statuts, ça pue. Partie 1 : comme un automate
=================================================

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
