# h3mapgen-lml
Part of the Heroes 3 Procedural Map Generator: Logic Map Layout generation.


# Aktualności

## Instrukcja obsługi

- Do uruchomienia wymagana [LuaJIT](http://luajit.org/download.html) - download i instalacja zgodnie z instrukcją ( na linuxie generalnie `make && sudo make install`)
- Na linuxie powinno się kompilowac po uruchomieniu [compile.sh](compile.sh), g++ musi mieć ścieżki do bibliotek i headerów
- Do rysowania grafów [Graphviz](http://www.graphviz.org/)

(Jeśli ktoś chce do Lua jakieś podstawowe IDE nie będące notepadem to proponuję [ZeroBrane Studio](https://studio.zerobrane.com/).)

## Co jak działa

- testowy program sprawdza zapis/odczyt z plików mapsave (.h3pgm - tak naprawdę to .lua) i rysuje wygenerowany graf.
- [test.h3pgm](out_mapsaves/test.h3pgm) zawiera stan początkowy generatora oraz seed. Jeśli seed jest < 0 to seedem jest time.
- grafy są generowane do folderu [LMLGenerator\debug_graphs](LMLGenerator\debug_graphs)
- dodatkowo w [Configs](Configs) znajdują się pliki .cfg z opcjami (na razie jest ich niewiele)

## Nad czym teraz trwają prace

- rozbudowanie generatora
- przekazanie wynikowej struktury LML do c++






# Stare info (częściowo wciąż aktualne):



## Uruchamianie

Plik [LMLGenerator.lua](LMLGenerator.lua), działanie ustala się głównie następującymi parametrami:
- `INITSTATE` - plik `data/init_{INITSTATE}.lua` będzie wykorzystywany jako stan generatora
- `GRAMMAR` - plik `data/grammar_{GRAMMAR}.lua` będzie wykorzystywany jako gramatyka
- `TRIALS` - liczba generowanych grafów
- `DRAW_NONFINAL` - jeśli jest true, to rysuje obrazki co krok, a nie tylko finalne

#### Output
Rysunki generowane są w folderze `out_graphs` w formacie `png`.

#### Stan początkowy
Stan początkowy zakodowany jest w plikach lua z prefiksem `init_` w folderze `data`.

Listę stref ustala się w polu `zones`, jako napis oddzielający strefy przecinkami, każda strefa to jedna litera (`L` lub `B` za którą jest dowolna liczba).

Listę cech obszaru ustala się w polu `features`, jako napis oddzielający featues przecinkami, każdy feature to nazwa (dowolny ciag alfanumerycznych), myślnik, strefa do której przynależy

#### Gramatyka
Gramatyka zakodowana jest w plikach lua z prefiksem `grammar_` w folderze `data`.

Gramatyka to tablica reguł, każda reguła musi implementować dwie funkcje:
- `IsApplicable`, która bierze jeden node grafu (o którym wiemy, że są w nim co najmniej dwie zony) i zwraca nil jeśli ta reguła startując z zadanego node nie da się dopasować lub tablicę nodów które się dopasowały.
- `ComputeEffect`, która bierze dopasowane wierzchołki grafu (zwrócone przez funkcję `IsApplicable`) oraz identyfikator który nalezy wstawić tworzonemu wierzchołkowi, funkcja powinna zwrocić listę zmodyfikowanych przez siebie wierzchołków.

## Gramatyka
_todo_

## Implementacja

_todo_


## Uwagi różne/TODO

- dopisać nowe reguły
- rozszerzyć opis stref buforowych na format 3B2, gdzie 3 będzie oznaczało ilu graczy ma łączyć strefa
- dodać wagi do reguł (wtedy reguły wybierane roulette wheel?)
- ...
- dopisac multiplayer-merge ;-)
- dopisać program translujący parametry na zawartość początkową





