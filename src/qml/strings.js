.pragma library
// UI texts; the language comes from the phone setting (uiLang, set in main.py).
// Columns: pl, en, de, es, it, fr. A missing entry falls back to English.

var texts = {
    "from":         { "pl": "Z języka", "en": "From", "de": "Von", "es": "De", "it": "Da", "fr": "De" },
    "to":           { "pl": "Na język", "en": "To", "de": "Nach", "es": "A", "it": "A", "fr": "Vers" },
    "placeholder":  { "pl": "Wpisz tekst…", "en": "Enter the text…", "de": "Text eingeben…", "es": "Escribe el texto…", "it": "Scrivi il testo…", "fr": "Saisissez le texte…" },
    "translate":    { "pl": "Tłumacz", "en": "Translate", "de": "Übersetzen", "es": "Traducir", "it": "Traduci", "fr": "Traduire" },
    "detected":     { "pl": "Wykryty język: %1", "en": "Detected language: %1", "de": "Erkannte Sprache: %1", "es": "Idioma detectado: %1", "it": "Lingua rilevata: %1", "fr": "Langue détectée : %1" },
    "paste":        { "pl": "Wklej", "en": "Paste", "de": "Einfügen", "es": "Pegar", "it": "Incolla", "fr": "Coller" },
    "copy":         { "pl": "Kopiuj", "en": "Copy", "de": "Kopieren", "es": "Copiar", "it": "Copia", "fr": "Copier" },
    "copied":       { "pl": "Skopiowano tłumaczenie", "en": "Translation copied", "de": "Übersetzung kopiert", "es": "Traducción copiada", "it": "Traduzione copiata", "fr": "Traduction copiée" },
    "speak":        { "pl": "Czytaj", "en": "Read aloud", "de": "Vorlesen", "es": "Leer", "it": "Leggi", "fr": "Lire" },
    "stop":         { "pl": "Zatrzymaj", "en": "Stop", "de": "Stopp", "es": "Detener", "it": "Ferma", "fr": "Arrêter" },
    "speakError":   { "pl": "Nie udało się pobrać mowy", "en": "Could not download the speech", "de": "Sprachausgabe konnte nicht geladen werden", "es": "No se pudo descargar la voz", "it": "Impossibile scaricare la voce", "fr": "Impossible de télécharger la voix" },
    "settings":     { "pl": "Ustawienia", "en": "Settings", "de": "Einstellungen", "es": "Ajustes", "it": "Impostazioni", "fr": "Paramètres" },
    "about":        { "pl": "O programie", "en": "About", "de": "Über", "es": "Acerca de", "it": "Informazioni", "fr": "À propos" },
    "dictionaries": { "pl": "Słowniki offline", "en": "Offline dictionaries", "de": "Offline-Wörterbücher", "es": "Diccionarios sin conexión", "it": "Dizionari offline", "fr": "Dictionnaires hors ligne" },
    "service":      { "pl": "Źródło tłumaczenia", "en": "Translation source", "de": "Übersetzungsquelle", "es": "Fuente de traducción", "it": "Fonte di traduzione", "fr": "Source de traduction" },
    "google":       { "pl": "Google Tłumacz", "en": "Google Translate", "de": "Google Übersetzer", "es": "Google Traductor", "it": "Google Traduttore", "fr": "Google Traduction" },
    "mymemory":     { "pl": "MyMemory", "en": "MyMemory" },
    "offline":      { "pl": "Słownik offline", "en": "Offline dictionary", "de": "Offline-Wörterbuch", "es": "Diccionario sin conexión", "it": "Dizionario offline", "fr": "Dictionnaire hors ligne" },
    "searchLang":   { "pl": "Szukaj języka", "en": "Search language", "de": "Sprache suchen", "es": "Buscar idioma", "it": "Cerca lingua", "fr": "Rechercher une langue" },
    "noDict":       { "pl": "Brak słownika %1. Pobierz go w menu „Słowniki offline”.", "en": "No %1 dictionary. Download it in “Offline dictionaries”.", "de": "Kein Wörterbuch %1. Unter „Offline-Wörterbücher“ herunterladen.", "es": "No hay diccionario %1. Descárgalo en «Diccionarios sin conexión».", "it": "Manca il dizionario %1. Scaricalo in «Dizionari offline».", "fr": "Pas de dictionnaire %1. Téléchargez-le dans « Dictionnaires hors ligne »." },
    "needSource":   { "pl": "Słownik offline wymaga wybrania języka źródłowego", "en": "The offline dictionary needs a source language", "de": "Das Offline-Wörterbuch braucht eine Ausgangssprache", "es": "El diccionario sin conexión necesita un idioma de origen", "it": "Il dizionario offline richiede una lingua di partenza", "fr": "Le dictionnaire hors ligne nécessite une langue source" },
    "netError":     { "pl": "Brak odpowiedzi usługi tłumaczeń: %1", "en": "The translation service did not answer: %1", "de": "Der Übersetzungsdienst antwortet nicht: %1", "es": "El servicio de traducción no responde: %1", "it": "Il servizio di traduzione non risponde: %1", "fr": "Le service de traduction ne répond pas : %1" },
    "usedFallback": { "pl": "Google nie odpowiada, użyto MyMemory", "en": "Google did not answer, MyMemory was used", "de": "Google antwortet nicht, MyMemory wurde verwendet", "es": "Google no responde, se usó MyMemory", "it": "Google non risponde, è stato usato MyMemory", "fr": "Google ne répond pas, MyMemory a été utilisé" },
    "noInternet":   { "pl": "Brak internetu. Włącz Wi-Fi lub dane komórkowe, albo pobierz słownik offline.", "en": "No internet. Turn on Wi-Fi or mobile data, or download an offline dictionary.", "de": "Kein Internet. Schalte WLAN oder mobile Daten ein oder lade ein Offline-Wörterbuch herunter.", "es": "Sin internet. Activa el Wi-Fi o los datos móviles, o descarga un diccionario sin conexión.", "it": "Nessuna connessione. Attiva il Wi-Fi o i dati mobili, oppure scarica un dizionario offline.", "fr": "Pas d’internet. Activez le Wi-Fi ou les données mobiles, ou téléchargez un dictionnaire hors ligne." },
    "serviceOffline": { "pl": "Usługa tłumaczeń nie odpowiada, wynik ze słownika offline", "en": "The translation service did not answer, result from the offline dictionary", "de": "Der Übersetzungsdienst antwortet nicht, Ergebnis aus dem Offline-Wörterbuch", "es": "El servicio de traducción no responde, resultado del diccionario sin conexión", "it": "Il servizio di traduzione non risponde, risultato dal dizionario offline", "fr": "Le service de traduction ne répond pas, résultat du dictionnaire hors ligne" },
    "usedOffline":  { "pl": "Brak internetu, wynik ze słownika offline", "en": "No internet, result from the offline dictionary", "de": "Kein Internet, Ergebnis aus dem Offline-Wörterbuch", "es": "Sin internet, resultado del diccionario sin conexión", "it": "Niente internet, risultato dal dizionario offline", "fr": "Pas d'internet, résultat du dictionnaire hors ligne" },
    "notFound":     { "pl": "Nie ma tego słowa w słowniku", "en": "This word is not in the dictionary", "de": "Dieses Wort steht nicht im Wörterbuch", "es": "Esta palabra no está en el diccionario", "it": "Questa parola non è nel dizionario", "fr": "Ce mot n'est pas dans le dictionnaire" },
    "dictionary":   { "pl": "Słownik", "en": "Dictionary", "de": "Wörterbuch", "es": "Diccionario", "it": "Dizionario", "fr": "Dictionnaire" },
    "similar":      { "pl": "Podobne hasła", "en": "Similar entries", "de": "Ähnliche Einträge", "es": "Entradas parecidas", "it": "Voci simili", "fr": "Entrées similaires" },
    "download":     { "pl": "Pobierz", "en": "Download", "de": "Laden", "es": "Descargar", "it": "Scarica", "fr": "Télécharger" },
    "downloading":  { "pl": "Pobieranie… %1", "en": "Downloading… %1", "de": "Wird geladen… %1", "es": "Descargando… %1", "it": "Download… %1", "fr": "Téléchargement… %1" },
    "preparing":    { "pl": "Przygotowanie słownika…", "en": "Preparing the dictionary…", "de": "Wörterbuch wird vorbereitet…", "es": "Preparando el diccionario…", "it": "Preparazione del dizionario…", "fr": "Préparation du dictionnaire…" },
    "installedOk":  { "pl": "Słownik %1 gotowy", "en": "Dictionary %1 ready", "de": "Wörterbuch %1 bereit", "es": "Diccionario %1 listo", "it": "Dizionario %1 pronto", "fr": "Dictionnaire %1 prêt" },
    "installFail":  { "pl": "Nie udało się pobrać słownika: %1", "en": "Could not download the dictionary: %1", "de": "Wörterbuch konnte nicht geladen werden: %1", "es": "No se pudo descargar el diccionario: %1", "it": "Impossibile scaricare il dizionario: %1", "fr": "Impossible de télécharger le dictionnaire : %1" },
    "remove":       { "pl": "Usuń", "en": "Remove", "de": "Entfernen", "es": "Quitar", "it": "Rimuovi", "fr": "Supprimer" },
    "cancel":       { "pl": "Anuluj", "en": "Cancel", "de": "Abbrechen", "es": "Cancelar", "it": "Annulla", "fr": "Annuler" },
    "installed":    { "pl": "Zainstalowane", "en": "Installed", "de": "Installiert", "es": "Instalados", "it": "Installati", "fr": "Installés" },
    "newDict":      { "pl": "Nowy słownik", "en": "New dictionary", "de": "Neues Wörterbuch", "es": "Nuevo diccionario", "it": "Nuovo dizionario", "fr": "Nouveau dictionnaire" },
    "none":         { "pl": "Brak", "en": "None", "de": "Keine", "es": "Ninguno", "it": "Nessuno", "fr": "Aucun" },
    "dictHint":     { "pl": "Słowniki z Wiktionary (WikDict, CC BY-SA). Tłumaczą pojedyncze słowa i zwroty, bez internetu. Każdy kierunek to osobny plik (np. angielski → polski).",
                      "en": "Dictionaries from Wiktionary (WikDict, CC BY-SA). They translate single words and phrases without internet. Each direction is a separate file (e.g. English → Polish).",
                      "de": "Wörterbücher aus Wiktionary (WikDict, CC BY-SA). Sie übersetzen einzelne Wörter und Wendungen ohne Internet. Jede Richtung ist eine eigene Datei (z. B. Englisch → Polnisch).",
                      "es": "Diccionarios de Wiktionary (WikDict, CC BY-SA). Traducen palabras y expresiones sin internet. Cada dirección es un archivo aparte (p. ej. inglés → polaco).",
                      "it": "Dizionari da Wiktionary (WikDict, CC BY-SA). Traducono parole ed espressioni senza internet. Ogni direzione è un file a parte (es. inglese → polacco).",
                      "fr": "Dictionnaires issus du Wiktionnaire (WikDict, CC BY-SA). Ils traduisent des mots et expressions sans internet. Chaque sens est un fichier séparé (ex. anglais → polonais)." },
    "darkTheme":    { "pl": "Ciemny motyw", "en": "Dark theme", "de": "Dunkles Design", "es": "Tema oscuro", "it": "Tema scuro", "fr": "Thème sombre" },
    "useFallback":  { "pl": "MyMemory, gdy Google nie odpowiada", "en": "MyMemory when Google does not answer", "de": "MyMemory, wenn Google nicht antwortet", "es": "MyMemory si Google no responde", "it": "MyMemory se Google non risponde", "fr": "MyMemory si Google ne répond pas" },
    "useOffline":   { "pl": "Słownik offline, gdy brak internetu", "en": "Offline dictionary when there is no internet", "de": "Offline-Wörterbuch ohne Internet", "es": "Diccionario sin conexión cuando no hay internet", "it": "Dizionario offline senza internet", "fr": "Dictionnaire hors ligne sans internet" },
    "enterKey":     { "pl": "Tłumacz klawiszem Enter", "en": "Translate with the Enter key", "de": "Mit Eingabetaste übersetzen", "es": "Traducir con la tecla Intro", "it": "Traduci con il tasto Invio", "fr": "Traduire avec la touche Entrée" },
    "pasteGo":      { "pl": "Tłumacz od razu po wklejeniu", "en": "Translate right after pasting", "de": "Nach dem Einfügen sofort übersetzen", "es": "Traducir al pegar", "it": "Traduci subito dopo aver incollato", "fr": "Traduire dès le collage" },
    "close":        { "pl": "Zamknij", "en": "Close", "de": "Schließen", "es": "Cerrar", "it": "Chiudi", "fr": "Fermer" },
    "aboutText":    { "pl": "Zaprojektowany i napisany przez Claude (Anthropic) wspólnie ze smyhu dla Nokii N9.\n\nTłumaczenia: Google Tłumacz, MyMemory (translated.net).\nSłowniki offline: WikDict (Wiktionary, CC BY-SA).\nCzytanie: Google.\nWygląd wzorowany na TAO Translator (Oleksii Serdiuk).",
                      "en": "Designed and written by Claude (Anthropic) together with smyhu for the Nokia N9.\n\nTranslations: Google Translate, MyMemory (translated.net).\nOffline dictionaries: WikDict (Wiktionary, CC BY-SA).\nSpeech: Google.\nLook inspired by TAO Translator (Oleksii Serdiuk).",
                      "de": "Entworfen und geschrieben von Claude (Anthropic) gemeinsam mit smyhu für das Nokia N9.\n\nÜbersetzungen: Google Übersetzer, MyMemory (translated.net).\nOffline-Wörterbücher: WikDict (Wiktionary, CC BY-SA).\nSprachausgabe: Google.\nAussehen nach TAO Translator (Oleksii Serdiuk).",
                      "es": "Diseñada y escrita por Claude (Anthropic) junto con smyhu para el Nokia N9.\n\nTraducciones: Google Traductor, MyMemory (translated.net).\nDiccionarios sin conexión: WikDict (Wiktionary, CC BY-SA).\nVoz: Google.\nAspecto inspirado en TAO Translator (Oleksii Serdiuk).",
                      "it": "Progettata e scritta da Claude (Anthropic) insieme a smyhu per il Nokia N9.\n\nTraduzioni: Google Traduttore, MyMemory (translated.net).\nDizionari offline: WikDict (Wiktionary, CC BY-SA).\nVoce: Google.\nAspetto ispirato a TAO Translator (Oleksii Serdiuk).",
                      "fr": "Conçue et écrite par Claude (Anthropic) avec smyhu pour le Nokia N9.\n\nTraductions : Google Traduction, MyMemory (translated.net).\nDictionnaires hors ligne : WikDict (Wiktionnaire, CC BY-SA).\nVoix : Google.\nApparence inspirée de TAO Translator (Oleksii Serdiuk)." }
};

function t(lang, key)
{
    var entry = texts[key];
    if (!entry)
        return key;
    return entry[lang] !== undefined ? entry[lang] : entry["en"];
}
