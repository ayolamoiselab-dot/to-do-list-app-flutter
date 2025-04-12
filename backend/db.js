const mysql = require('mysql2');

    // Configuration de la connexion MySQL
    const db = mysql.createConnection({
        host: 'localhost',
        user: 'root',
        password: '',
        database: 'todolist',
        charset: 'utf8mb4', // Ajoute cette ligne pour forcer l'encodage utf8mb4
    });

    // Connexion à MySQL
    db.connect((err) => {
        if (err) {
            console.error('Erreur de connexion à MySQL:', err.stack);
            return;
        }
        console.log('Connecté à MySQL avec l\'ID', db.threadId);
    });

    // Création de la base de données si elle n'existe pas
    db.query('CREATE DATABASE IF NOT EXISTS todolist', (err) => {
        if (err) {
            console.error('Erreur lors de la création de la base de données:', err.stack);
            return;
        }
        console.log('Base de données créée ou déjà existante.');
    });
    
    // Selection de la base de données
    db.changeUser({ database: 'todolist' }, (err) => {
        if (err) {
            console.error('Erreur lors de la sélection de la base de données:', err.stack);
            return;
        }
        console.log('Base de données sélectionnée.');
    });
    
    // Création des tables si elles n'existent pas
    // Création de la table `users`
    const createUsersTable = `
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            email VARCHAR(30) NOT NULL UNIQUE,
            password VARCHAR(100) NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        );
    `;

    // Vérification de l'existence de la table `users` et création si elle n'existe pas
    db.query(createUsersTable, (err) => {
        if (err) {
            console.error('Erreur lors de la création de la table `users`:', err.stack);
            return;
        }
        console.log('Table `users` créée ou déjà existante.');
    });

    // Création de la table `todoitems`
    // const createTodoItemsTable = `
    //     CREATE TABLE IF NOT EXISTS todoitems (
    //         id INT AUTO_INCREMENT PRIMARY KEY,
    //         title VARCHAR(30) NOT NULL,
    //         tasks TEXT NOT NULL,
    //         status ENUM('À faire', 'En cours', 'Terminé') NOT NULL DEFAULT 'À faire',
    //         user_id INT,
    //         group_name VARCHAR(50) DEFAULT 'default',
    //         created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    //         updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    //         FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE 
    //     );
    // `;

    // db.query(createTodoItemsTable, (err) => {
    //     if (err) {
    //         console.error('Erreur lors de la création de la table `todoitems`:', err.stack);
    //         return;
    //     }
    //     console.log('Table `todoitems` créée ou déjà existante.');
    // });

module.exports = db;