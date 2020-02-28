

const Config = {
    host:"localhost", //database host
    user:"root",    //database user
    password:"", // database password
    database:"node_utstats", // database name
    port: "3306",   //database port

    ftpServers: [
        {"host": "127.0.0.1", "port": 21, "user": "scott", "password": "password"}
       // {"host": "127.0.0.1", "port": 21, "user": "scott", "password": "password"},
        //{"host": "127.0.0.1", "port": 21, "user": "scott", "password": "password"},
    ],

    bDeleteFilesFromFTP: true,
    bImportBTRecords: true,
    bImportMaps: true,

    bIgnoreBots: true,
    bIgnoreDuplicates: true,
    //bMoveTmpFiles: true,
    tmpFileTimeMoveLimit: 300 * 60 , // minutes * seconds
    //bMoveLogFiles: false,
    multiKillTimeLimit: 3,
    minCaps: 1, //Ignore matches that don't have any caps (BT and CTF)
    minPlayers: 0, // set this to 2 if you want to ignore matches that only have 1 human player
    importInterval: 60 * 1000, //seconds * miliseconds
    tmpDir: "Logs/tmpfiles/",
    logDir: "Logs/",
    importDir: "Logs/imported/" ,
    btMaxCapTime: 600000,
   // acePrefix: "[ACE] - ",
    //acePlayerPrefix: "[ACE-PLAYER] - ",
    aceSShotDir: "Shots/",
    aceSShotDirImport: "Logs/Imported/Ace-shots/",
    bMoveAceLogs: true,
    aceImportDir: "Logs/Imported/Ace/",
    btPlusPlusIni: "BTPlusPlus.ini",
    btGameIni: "BTGame.ini",
    btIniImportDir: "BT/Imported/",
    mapsDir: "Maps/",
    mapsImportJSON: "imported.json",
    tmpDir: "Tmp/"
};



module.exports = Config;