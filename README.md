# 💊 Mad Drug - Vente de Drogue

Système de vente de drogue immersif et sécurisé pour FiveM, utilisant **ox_target** et **ox_inventory**.

## Fonctionnalités

### Vente aux PNJs Ambiants

- Utilisez votre **Alt (ox_target)** sur n'importe quel civil dans la rue.
- Détection intelligente : Ne fonctionne pas sur les joueurs, les cadavres, les animaux ou les PNJs en véhicule.
- Le PNJ s'arrête, se tourne vers vous et attend votre offre.

### Système de Négotiation

- Slider de prix fluide : Le prix demandé influence directement vos chances de réussite.
- Demande aléatoire : Les PNJs demandent une quantité variable (configurables par item).
- Animation synchronisée : Échange d'objet et d'argent physique entre le joueur et le PNJ.

### Réactions Dynamiques

En cas d'échec de la vente, plusieurs scénarios sont possibles :

- **Refus simple** : Le client s'en va en trouvant le prix trop cher.
- **Vol** : Le client vous vole votre marchandise et prend la fuite sans payer !
- **Agression** : Le client sort une arme (couteau, batte, pistolet) et vous attaque.
- **Police** : Chance configurable d'appeler les forces de l'ordre (Dispatch) lors d'un incident.

### Configuration Avancée

- **Zones de vente** : Option pour restreindre la vente à des quartiers spécifiques.
- **Quota Police** : Exiger un nombre minimum de policiers en service.
- **Heures IRL** : Possibilité de bloquer la vente à certaines heures réelles du serveur.
- **Bonus de Nuit** : Multiplicateur de gains configurable pour les ventes nocturnes (heure in-game).

### Sécurité & Performance

- **0.00ms** en veille et en utilisation.
- **Anti-Cheat Serveur** : Vérification des prix maximums, des stocks réels, des distances et de la probabilité de réussite.
- **Anti-Spam** : Cooldown de 2 secondes par transaction côté serveur.

## Installation

1. Glissez le dossier `mad_drug` dans votre dossier `resources`.
2. Assurez-vous d'avoir les dépendances : **es_extended**, **ox_inventory**, **ox_target**.
3. Ajoutez `ensure mad_drug` dans votre `server.cfg`.
4. Configurez vos items et vos chances dans `config.lua`.

## 🔧 Dispatch (Optionnel)

Pour activer les appels de police, ouvrez `config.lua` et ajoutez votre export de dispatch dans la fonction :

```lua
Config.CallPolice = function()
    -- Exemple pour ps-dispatch
    exports['ps-dispatch']:SuspiciousActivity()
end
```

---

_Développé pour une immersion maximale._
