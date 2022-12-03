Aufgabe zum Thema Clean-Code-Development

1) 
Ich habe mir die „Grade“ auf der Seite https://clean-code-developer.de/ durchgelesen und ein kleines cheat sheet angefertigt.
Liegt im repo.

2)
Voll motiviert habe ich mir gedacht, ich refactor mal mein altes iOS App Projekt (2017) (Also nur eine Klasse).
Es waren nur c.a 200 loc. Das refactoring hatte es aber in sich.

Die App ist heute noch im AppStore, könnte aber mal ein refactoring vertragen.

Ich hatte mir eine Klasse rausgesucht, welche einen teil der Datenbank zugriffe managed.

Der Code war sehr schlecht, an vielen stellen sehr Komplex, nicht strukturiert und unsicher.
Deshalb natürlich auch schwer zu verstehen.

Das Refactoring wurde schon nach kürzester Zeit wahnsinnig Komplex, dies zeigt auch die ganzen Abhängigkeiten der Klasse auf.

Hier muss ich auch ehrlich zugeben, ich hatte mich nicht getraut an jeder stelle refactoring zu betreiben. Die Klasse kommuniziert mit der Datenbank und eine möglich migration war mir zu aufwändig. 
Im Repo: Database.swift (original)
Database_ref.swift (refactored)

Hier ein paar der CCD Punkte, welche ich angewandt habe:

• DRY (Don´t Repeat Yourself)
Viele code Dopplungen entfernt und in Methoden ausgelagert.

• KISS (Keep it simple, stupid)
Angefangen, auf noch komplizierteren code gestoßen und es panisch wieder verworfen

• IOSP Integration Operation Segregation Principle
in einigen Methoden angewandt

• Boy Scout Rule
Das hoffe ich :)

• (SLA) Single Level of Abstraction
Aufbau der Klasse an das Prinzip angepasst

• Source Code Conventions
An einigen stellen wurde die Code Convention von Swift nicht eingehalten

• Richtig kommentieren
Sinnlose Kommentare entfernt und durch besseres naming ersetzt, sowie die Lesbarkeit der klasse mit Markdowns erhöht

• Information Hiding Principle
Einige Methoden private gemacht
