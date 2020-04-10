Les statuts ça pue
==================

> En tant que préparateur, je veux passer la commande en statut `préparé` afin d'informer
> le client de l'avancement de sa commande

Vous avez déjà vu cette User Story. Si ce n'est elle, c'est donc sa sœur. On conçoit souvent nos prodécures
métier comme une évolution linéaire, une succession d'état d'une ressource donnée qui tendent irrémédiablement
vers un statut `terminé`. _Tirer à droite !_ ou _Zero stock !_ sont autant de _gimmicks_ qui révèlent notre
inlassable vision finaliste d'un processus de production en flux.

C'est pourquoi nous avons souvent dans nos modélisations, nos schémas, nos User Stories, nos bases de données et
nos APIs un petit champ nommé `status`, parce que l'anglais ça fait classe.

Et bien je vous le dis tout de bon : _Les statuts, ça pue,_ c'est un _Code Smell._

1. Comme une automate

  -> on implémente les arcs, pas les nœuds

2. En client / serveur, c'est le serveur qui est garant de l'intégrité fonctionnelle

  -> les clients n'ont pas le droit d'écrire un champ statut

3. Les statuts ça se calcule / se lit

  -> un statut, c'est la projection d'une collection d'événements ou de ressources associées

Conclusion

  Un statut c'est readonly et c'est le serveur qui le calcule
