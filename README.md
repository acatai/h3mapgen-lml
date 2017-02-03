# h3mapgen-lml
Part of the Heroes 3 Map Generator: Logic Map Layout generation.




## Wymagania
- Lua - pisałem pod [standardową 5.3](https://www.lua.org/download.html), natomiast docelowo raczej chcielibyśmy korzystać z [LuaJIT](http://luajit.org/download.html) (program jest kompatybilny) 
- [Graphviz](http://www.graphviz.org/) - do rysowania grafów (polecenie `dot` powinno być w PATH)

#### IDE
Jeśli ktoś chce jakieś podstawowe IDE nie będące notepadem to proponuję [ZeroBrane Studio](https://studio.zerobrane.com/).


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





