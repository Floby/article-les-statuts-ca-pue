Les statuts, ça pue
===================

> _En tant que préparateur, je veux passer la commande en statut `en cours de préparation` afin d'informer_
> _le client de l'avancement de sa commande_

Vous avez déjà vu cette _User Story_. Si ce n'est elle, c'est donc sa sœur. On conçoit souvent nos procédures
métier comme une évolution linéaire, une succession d'états d'une ressource donnée qui tendent irrémédiablement
vers un statut `terminé`. _Tirer à droite !_ ou _Zero stock !_ sont autant de _gimmicks_ qui révèlent notre
inlassable vision finaliste d'un processus de production en flux.

C'est pourquoi nous avons souvent dans nos modélisations, nos schémas, nos _user stories_, nos bases de données et
nos APIs un petit champ nommé `status`, parce que l'anglais ça fait classe.

Et bien je vous le dis tout de bon, ce petit champ qui stocke le statut de votre ressource, il sent mauvais
et augure bien des périls, en particulier si vous pouvez le modifier.
Il peut être révélateur d'une perte de richesse fonctionnelle de notre solution ainsi que de défauts de cohérence
ou de résilience de la conception technique. Bref : **Les statuts, ça pue**.

+ [Partie 1 : Comme un automate](./1.html)
+ [Partie 2 : Ciselage en US](./2.html)
+ [Partie 3 : Les statuts, ça se lit](./3.html)
+ Partie 4 : Quand ça ne marche plus
+ Partie 5 : L'œuf et la poule
+ Partie 6 : La théorie avec CQ(R)S, DDD, Clean Archi, Event Sourcing, _etc._
