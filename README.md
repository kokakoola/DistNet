
## R kood asub:
https://github.com/kokakoola/DistNet/tree/main

### Kaustastruktuur
`R/helpers/` -- andmetöötluse abifunktsioonid, mida analüüsiskriptid `source()`-iga sisse laevad:
- `fetch_data.R` -- laeb toorandmed SharePointist (`get_data()`)
- `clean_data.R` -- puhastab ja formaadib toorandmed (`clean_masterdata()`), salvestab `data/processed/` alla
- `join_master.R` -- ühendab domeenifailid (Traits/Quadrat/Colonization) MasterData rings/plants lehtedega

Ülejäänud `R/` juurkaustas olevad skriptid (`PilotColonization.R`, `AM_intensity.R`, `Analysis11-05-26.R`) on analüüsiskriptid, mis kasutavad neid abifunktsioone läbi `source("R/helpers/...")`.

## Projektis on kasutusel pipeline ekstrad:
### renv - package manager
Hoolitseb, et projekti käivitamisel kasutatakse pakettide versioone, mis olid kasutusel kirjutamise hetkel. Sest uuendused võivad muidu projekti katki teha
Concole >
renv::snapshot()   # käivita käsitsi, kui oled lisanud/uuendanud pakette. 
renv::restore()    # käivita, kui avad projekti teises arvutis/pärast pausi. 

### envir
sisaldab kasutusel olevaid Sharepointi täispathe. Turvakaalutlus. Avalikus GH-s on näidis, tegelik .Renviron on leitav Sharepointis MasterThesis/Docs kaustas. Lae alla, tõsta projekti sisse ja käivita alles siis R.
Kui muudad .Renviron-it, tuleb R taaskäivitada (Session → Restart R Positronis), et muudatused kehtima hakkaksid — see fail loetakse ainult sessiooni alguses, mitte jooksvalt.

#### Kontroll, et environment-muutujad on laetud:
r
Sys.getenv("SHAREPOINT_SITE")

## Blogi
Töö käik on dokumenteeritud Quarto blogi kujul GH Page-na, asukoht:
https://kokakoola.github.io/DistNet/

Blogi lokaalseks jooksutamiseks pead asuma blogi kaustas (./report/blog)

Console >   
quarto preview. # lokaalne preview
quarto add ext quarto-ext/quarto-blog.  # järgmine chapter
quarto publish gh-pages. # publish to live