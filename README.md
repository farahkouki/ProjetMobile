# 🚍 Voyagea – Gestion de véhicules pour agences de voyage

![App Banner](assets/icons/app_icon.png)

**Voyagea** est une application mobile Flutter conçue pour simplifier la gestion des agence de vooyage avec une section pour les voyages volontaires . Elle utilise le pattern **MVC**, **SqFlite** pour la base locale et propose une interface moderne et animée.

---

## ✨ Fonctionnalités principales

- **Gestion des véhicules**
  - Ajouter, modifier, supprimer et visualiser les véhicules.
  - Historique des véhicules et détails complets.
- **Gestion des conducteurs**
  - Ajouter et gérer les conducteurs avec informations détaillées.
- **Maintenance & alertes**
  - Suivi de la maintenance des véhicules.
  - Notifications pour les entretiens et disponibilités.
- **Planning & réservations**
  - Planification des trajets et réservations.
  - Vue calendrier intuitive avec `table_calendar`.
- **QR Code**
  - Génération de QR codes pour conducteurs.


---

## 🎨 Design & animations

L’application propose une interface moderne avec des animations fluides grâce à :  

- [`animate_do`](https://pub.dev/packages/animate_do) pour les animations des composants.  
- [`shimmer`](https://pub.dev/packages/shimmer) pour les états de chargement élégants.  
- Utilisation des **Google Fonts** pour un rendu typographique professionnel.  

Exemple d’écran :  

![Screenshot](assets/images/screenshot_home.png)

---

## 🛠 Tech Stack

- **Flutter 3.x**  
- **Dart 3.x**  
- **SqFlite** pour la base de données locale  
- **Provider** pour la gestion d’état  
- **Image Picker** pour les images des véhicules et conducteurs  
- **QR Flutter** pour la génération de QR codes  

---

## 📂 Structure du projet

