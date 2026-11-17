# DistNet -- magistritöö (Mare Hunt, Tartu Ülikool)

Kood: https://github.com/kokakoola/DistNet ·
Lõputöö (HTML): https://kokakoola.github.io/DistNet/

## Projekti jooksutamine oma arvutis (Windows, RStudio)

Kogu koodi saad ise jooksutada ja uuendused ühe klikiga alla tõmmata, ilma koodi kopeerimata.
GitHubi kontot pole vaja (repo on avalik):

**1. Git (ühekordne).** R ja RStudio on olemas; lisaks on vaja Git for Windows'i, et RStudio saaks
projekti GitHubist alla tõmmata: https://git-scm.com/download/win (vaikeseaded sobivad).
Pärast paigaldust taaskäivita RStudio. Projekt on tehtud R versiooniga 4.5.1; vanema R-iga võib
pakettide taastamine anda hoiatusi.

**2. Kloonimine RStudios**
- *File → New Project → Version Control → Git*
- Repository URL: `https://github.com/kokakoola/DistNet.git`
- Vali kaust (nt `Documents`) → *Create Project*. Projekt avaneb ise (`DistNet.Rproj`).

**3. Paketid (ühekordne, võtab mõne minuti).** Projekt kasutab paketihaldurit **renv** (vt allpool).
Eraldi midagi paigaldama ei pea: projekti avamisel laeb renv end ise alla (vajab internetti) ja
Console'is kuvatakse teade, et projekt pole sünkroonis. Siis käivita Console'is:
```r
renv::restore()
```
See paigaldab täpselt need paketiversioonid, mis on kirjas failis `renv.lock`.

**4. Ligipääs andmetele.** Andmed ei ole GitHubis, vaid SharePointis (PRG1836-Mare → MasterThesis).
- Sünkroniseeri see kaust OneDrive'iga: SharePointis kausta juures nupp *Sync* (*Sünkrooni*).
- Leia File Exploreris sünkitud kausta tee, tavaliselt
  `C:\Users\<kasutaja>\Tartu Ülikool\BioticNovelty-Mare - MasterThesis`.
- Andmeteed on failis `.Renviron`, mis peab asuma **projekti juurkaustas** (samas kaustas, kus
  `DistNet.Rproj`, vt failipuu allpool). Kopeeri see SharePointist -- Console'is:
```r
file.copy("C:/Users/<kasutaja>/Tartu Ülikool/BioticNovelty-Mare - MasterThesis/Docs/Renviron.txt", ".Renviron")
file.edit(".Renviron")
```
- Muuda failis rida `SHAREPOINT_LOCAL=` oma sünkitud kausta teeks (kaldkriipsud `/`, mitte `\`), salvesta.
  Ülejäänud read (`SHAREPOINT_PATH_...`) jäävad samaks.
- *Session → Restart R* (`.Renviron` loetakse ainult R-i käivitamisel). Kontroll -- peab andma `TRUE`:
```r
dir.exists(Sys.getenv("SHAREPOINT_LOCAL"))
```

**5. Jooksutamine.** Ava skript `R/` kaustast (nt `R/community_ordination.R`, `R/CWM.R`) ja vajuta *Source*.
Skript kopeerib toorandmed `data/raw/` alla ja salvestab tulemused `data/processed/` alla.
Lõputöö peatükid on `report/thesis/` kaustas (nt `03-tulemused.qmd` → *Render*); tulemuste peatükk
vajab, et vastavad R-skriptid oleks enne jooksnud.

**6. Uuendused.** RStudio paremal üleval *Git* paneel → *Pull* (sinine nool alla).
Kui muudad repo faile ise, võib *Pull* anda konflikti -- oma katsetused tee pigem eraldi failis väljaspool repot.

## Failipuu

```
DistNet/
├── DistNet.Rproj         # RStudio projekt -- ava see
├── .Renviron             # andmeteed (EI ole GitHubis; kopeeri SharePointist, vt samm 4)
├── .Renviron.example     # .Renviron näidis
├── renv.lock             # pakettide versioonid (renv)
├── renv/                 # renv-i käivitusfail; paketid ise on renv/library/ all (ei ole GitHubis)
├── R/
│   ├── helpers/          # abifunktsioonid (source()-iga)
│   │   ├── fetch_data.R      # toorandmed SharePointi sünkkaustast: get_data(), sp_local()
│   │   ├── clean_data.R      # andmete puhastamine
│   │   ├── join_master.R     # domeenifailide liitmine MasterData rings/plants lehtedega
│   │   └── review_sync.R     # juhendaja docx-ülevaatus: upload_review(), download_review(), read_review()
│   ├── CWM.R                 # naabruskonna kooslusmükoriissus (CWM)
│   ├── am_colonization.R     # kvadraadiliikide AM-kolonisatsioon (FungalRoot GBIF-i kaudu)
│   ├── community_ordination.R # liigikoosseis: NMDS, PERMANOVA, dbRDA
│   ├── quadrat_cover.R       # kvadraatide katvus
│   ├── dac_leaf_traits.R     # Dactylise lehtede SLA ja LDMC
│   ├── gbif_name_check.R     # liiginimede kontroll GBIF-i vastu
│   └── ...                   # varasemad skriptid (PilotColonization.R, AM_intensity.R, Analysis11-05-26.R)
├── data/
│   ├── raw/              # toorandmete koopiad (tekivad skriptide jooksutamisel; ei ole GitHubis)
│   └── processed/        # tulemused .csv/.rda (tekivad skriptide jooksutamisel; ei ole GitHubis)
├── report/thesis/        # lõputöö (Quarto book): 01–05 peatükid, _metoodika_*/_tulemused_* include-failid
├── docs/                 # projekti märkmed
└── publish.sh            # Mare: renderdus + GitHub + GitHub Pages + docx juhendajale
```

## renv -- paketihaldur

renv on R-i pakett, mis hoiab projekti pakettide versioonid paigal: igal projektil on oma
paketikogu (`renv/library/`) ja failis `renv.lock` on kirjas, millised versioonid kasutusel on.
Nii ei lähe projekt katki, kui kuskil mujal paketid uuenevad. renv-i ei pea eraldi paigaldama --
fail `.Rprofile` käivitab projekti avamisel `renv/activate.R`, mis vajadusel laeb renv-i alla.

Console'is:
```r
renv::restore()    # paigaldab renv.lock-is olevad versioonid (teises arvutis / pärast Pull'i, kui lock muutus)
renv::snapshot()   # kirjutab renv.lock-i uued versioonid -- käivita pärast paketi lisamist/uuendamist
renv::status()     # näitab, kas paketid ja renv.lock on kooskõlas
```

## .Renviron -- andmeteed

Andmed on SharePointis ja OneDrive'iga arvutisse sünkitud; `.Renviron` ütleb R-ile, kus sünkitud
kaust asub (`SHAREPOINT_LOCAL`) ja kus selle sees on iga andmefail (`SHAREPOINT_PATH_...`).
Turvakaalutlusel ei ole see fail avalikus GitHubis -- seal on ainult näidis `.Renviron.example`.
Tegelik fail on SharePointis `MasterThesis/Docs/Renviron.txt`; kopeeri see projekti juurkausta
täpselt nimega `.Renviron`.

Kui muudad `.Renviron`-it, taaskäivita R (*Session → Restart R*), sest fail loetakse ainult R-i
käivitamisel. Kontroll:
```r
Sys.getenv("SHAREPOINT_LOCAL")
dir.exists(Sys.getenv("SHAREPOINT_LOCAL"))
```

## Lõputöö avaldamine (Mare)

Lõputöö on Quarto raamat kaustas `report/thesis/`. `./publish.sh` (repo juurkaustas, pärast commit'i)
renderdab HTML-i ja docx-i, push'ib GitHubi, avaldab HTML-i GitHub Pages'i ja kopeerib docx-i
juhendajale SharePointi `Docs/Review/` kausta uue versioonina. Enne seda sulge `quarto preview`.
Eelvaade kirjutamise ajal: `./preview.sh` (uueneb ka `_*.qmd` include-failide muutmisel).
Vana Quarto blogi (`report/blog/`) enam ei peeta.
