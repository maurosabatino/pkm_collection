# Guida alle contribuzioni

Grazie per l'interesse nel contribuire a PKMCollection! Segui questi passaggi per proporre modifiche in modo efficace.

## Come iniziare
1. **Apri un'issue** per descrivere bug, miglioramenti o nuove funzionalità che vuoi affrontare.
2. **Attendi il feedback** di un maintainer prima di procedere con lavorazioni sostanziali.

## Ambiente di sviluppo
- Installa le dipendenze con `tuist install`.
- Genera la workspace con `tuist generate` e lavora da `PKMCollection.xcworkspace`.
- Mantieni aggiornato `GoogleService-Info.plist` con valori fittizi per versionare il codice, se necessario, oppure usa variabili di ambiente/segreti.

## Linee guida per le modifiche
- Lavora sempre su una branch dedicata (`feature/nome-funzionalita`).
- Segui il formato di codice Swift standard e preferisci SwiftLint se attivo nel progetto.
- Aggiungi o aggiorna i test (`tuist test`) quando introduci nuovo comportamento o correggi bug.
- Assicurati che `tuist build` completi senza errori e che i warning siano risolti.
- Aggiorna la documentazione (README.md, commenti, changelog) quando opportuno.

## Pull Request
- Mantieni le PR piccole e focalizzate.
- Collega l'issue correlata (es. `Closes #123`).
- Fornisci un riepilogo dei cambiamenti ed eventuali note sulla verifica manuale.

## Codice di condotta
Tutti i contributori devono rispettare il [Codice di Condotta](CODE_OF_CONDUCT.md). Qualsiasi violazione può essere segnalata a `opensource@maurosabatino.com` (o al contatto indicato nel file).

Grazie per contribuire a rendere PKMCollection migliore!
