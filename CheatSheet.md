# Clean-Code-Development


My Cheat Sheet


• DRY (Don´t Repeat Yourself)
- Keine code dopplungen


• KISS (Keep it simple, stupid)
- simple statt aufwändige implementierungen verwenden


• FCoI Favour Composition over Inheritance
– abhängigkeiten zu anderen Klassen möglichst vermeiden.
  Funktionen nur mit guten und wiederverwendbaren interfaces auslagern


• IOSP Integration Operation Segregation Principle
– Die Logik von methoden sollte getrent werden. Datenbeschaffung z.B. API calls oder Transformationen.
  Beides sollte nicht vermischt werden
  
• Boy Scout Rule
- Nach erfolgter Aänderung solte code immer in einem besseren zustand zurückgelassen werden


• (SLA) Single Level of Abstraction 
- Auf abstraktions ebenen achten. Code sollte analog zu einem Artikel aufgebaut werden.
  Dabei wird es immer detailiert um so tiefer es in die klasse geht
  
  
• Single Responsibility Principle (SRP)
– Eine Klasse eine Aufgabe


• Source Code Conventions
- Stiel der Sprache einhalten

• Richtig kommentieren
- komentare vermeiden wo es geht und methoden und variablen besser gestallen

• (ISP) Interface Segregation Principle 
- Interfaces und Schnittstellen zwischen Komponenten möglichst klein halten

• Dependency Inversion Principle (DIP)
– direkte Abhängigkeiten zwischen klassen vermeiden. besser über interfaces komunizieren

• Information Hiding Principle
- Details einer schnitstelle zurückhalten und auf das nötigste reduzieren.
