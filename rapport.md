# Rapport – Flutter Mood

---

I den här uppgiften har jag skapat en enkel app i Flutter som heter **Flutter Mood**. Tanken med appen är att användaren ska kunna skriva en kort text om hur dagen känns, välja ett humör och sedan spara det. Den sparade datan visas sedan på en annan sida i appen.

Appen fungerar både på Android och i webbläsare. Jag har testat den på en Android-emulator och även som webbsida. För att layouten inte skulle bli konstig på webben begränsade jag bredden på innehållet, så att appen fortfarande känns ungefär som en mobilapp även i webbläsaren.

Appen har två sidor. Första sidan innehåller ett textfält, en dropdown för humör och en knapp för att spara. Det finns också en knapp som tar användaren vidare till sidan där de sparade humören visas. Navigationen görs med `Navigator`.

Som extra kriterium valde jag att använda Firebase Cloud Firestore som databas. Det gjorde att appen kunde spara och läsa data på riktigt istället för att bara hålla datan lokalt i appen. En svårighet var att få Firebase-konfigurationen och reglerna i Firestore att fungera rätt, men efter lite felsökning fungerade det på både Android och webb.

Appen använder också en bild via webblänk och har en egen appikon samt favicon för webben.

---

Erik Svensson `JAVA24`