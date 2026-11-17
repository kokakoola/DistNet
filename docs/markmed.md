# Lahtised teemad

Tööjärjekord, mitte lõputöö tekst. Tehtud punktid märgi `[x]` või kustuta.

## Järgmisena (16.11.2026)

- [ ] **Word (docx) on ikka "corrupted"** – ka pärast callout'ide parandust (tabel callout'i lõpus) ja `freeze: false`.
  Uurida: renderdada uuesti, valideerida `word/document.xml` (nt python-docx / LibreOffice avamine), otsida muid
  kehtetuid elemente (tabelid joonise/tabeli allkirjadega, `{.mark}` tabelis, inline r tabelis).
- [ ] Rikutud `Docs/Review/DistNet_thesis_v2_2026-11-15.docx` SharePointis – kas kustutada?
- [ ] Tegur "Töötlus" joonistel/tabelites (tasemed võrgustunud/katkestatud) ja disaini alapealkiri "Töötlus":
  kas nimetada ümber (nt "Seenevõrgustik")? Mare otsustab.

## Analüüs: CWM ja naabruskond

- [ ] **Treatment-ebatasakaal naabruse CWM-is.** CWM arvutatakse nüüd R-is (`R/CWM.R`, lävend
  Mean_cover ≥ 0.8, AM %). Severed-ringide CWM on keskmiselt madalam
  (mets 7.0 vs 14.3 %, niit 80.4 vs 83.5 %). `lm` p = 0.020, kuid metsa jääkide SD on ~2.4× niidu omast;
  `gls` (`varIdent(~1 | habitat)`) p = 0.068, paar juhusliku efektina p = 0.079.
  Järeldus: mitteoluline, kuid metoodikas/arutelus mainida. CWM läheb põhimudelisse kovariaadina.
  (Vanad numbrid Exceli CWM-lehelt, kõik liigid: mets 0.12 vs 0.20, niit 0.79 vs 0.83; `gls` p = 0.085.)
- [ ] **`cover_share` piiranguna metoodikasse:** lävendi ületanud liigid katavad metsas 50–98 %
  koosluse katvusest (F6N 0.50), niidul 93–99 %.
- [x] **AM-väärtuste allikas:** Exceli veerg = FungalRoot GBIF-i kaudu, McGonigle, koondkeskmine + käsitsi väärtused;
  `R/am_colonization.R` kordab seda täpselt (15.11). `R/CWM.R` võib edasi Exceli veergu kasutada.
- [x] *Festuca pratensis*: Excelisse lisatud 95,3 (Quadrat_Grassland F11; 14 McGonigle kirjet *Lolium pratense* nime all), 15.11.
- [ ] Exceli niidulehe veerg `KW_means` (`=F4*$F$45/100`) ei ole CWM – ümber nimetada või eemaldada.
- [ ] **`lm` vs `gls` CWM-mudelis** – otsustamata (`R/CWM.R` kasutab praegu `lm`).
- [ ] **Paar (`pair`, nt F1, G3) juhusliku efektina kõigisse mudelitesse**, ka kolonisatsioonimudelisse.
  Metsas seletab paar ~22% CWM-i varieeruvusest, niidul 0%.
- [ ] **Katvuse lävend.** Kas eemaldada juhuslikud liigid (Mean_cover ≤ 0.5, ala tasemel)?
  Mõju: metsa liikide arvu erinevus severed/control kaob (7.3 vs 6.8), CWM-i erinevus jääb (~0.08).
  LAHTINE: praegu 0.8 nagu `R/AM_intensity.R`-is. Mare hüpotees: CWM-i severed/control erinevust
  mõjutasid juhuslikud, kohale mitteomased liigid (mitte tallamine); juhendaja nõustus need välja
  võtma → arutelu lävendi 0.5 üle. Juhendaja varasem soovitus: README järgi 1%, handoff'i järgi 0.7. Kaaluda alternatiivina
  Excelisse veergu `incidental` (oma liigiteadmise põhjal). Kui lävend tuleb, arvutada CWM R-is,
  mitte Excelis (Exceli CWM jätab välja ainult AM-väärtuseta liigid).
- [ ] **Tallamise hüpotees – välistatud** (oma välikogemuse põhjal). Katvus severed/control ei
  erinenud (`R/quadrat_cover.R`). Taimeruudud kirjeldati 26.–27.07.2026, s.t pärast severing'u algust.
- [ ] **Metsas korreleerub katsetaimede biomass negatiivselt naabruse CWM-iga**
  (Spearman rho = −0.67, p = 0.02, n = 12; kõik ringid biomassiga > 4.5 g on CWM < 0.10).
  NB: arvutatud vana, Exceli CWM-iga – korrata uue `R/CWM.R` väärtustega.
  Võimalik, et madal CWM tähistab paremat mikrokasvukohta (valgus/muld?). Puudutab põhihüpoteesi
  (kas CWM-i mõju on eraldatav kasvukoha mõjust) – **arutada juhendajaga.**
- [ ] Ajutised kontrollarvutused (lävendi võrdlus, biomass × CWM) pole koodis – kirjutada
  skriptiks, kui tulemust töös kasutatakse.

- [ ] **Liigiline koosseis kasvukohtade kaupa (15.11):** NMDS stress niit 0,16, mets 0,13; PERMANOVA töötlus (permutatsioonid paaride
  sees) niit R² = 0,055, p = 0,50; mets R² = 0,063, p = 0,34 → töötlus koosseisu ei mõjuta. Metsas paarid F1, F4, F5, F6
  koos (mikrokasvukoht), F1 ja F6 ordinatsiooni vastasotstes – kooskõlas metsa heterogeensusega (vt Metoodika tekst: katseala).

## Andmed

- [ ] **Kolonisatsioon ↔ CWM liitmine.** Piloodi `data/processed/colonization.csv` kasutab
  `ring_id` = 1, 2… ja `isolated`/`network`; CWM `F1Y`… ja `severed`/`control`. Liitmine töötab
  alles `Colonization_26` lehega – `R/helpers/clean_data.R` loeb veel `Colonization_Pilot` lehte.
- [ ] **Biomass (`DistNet_Biomass.xlsx`):**
  - `status` ebaühtlane: `dead`/`DEAD`, `removed`/`REMOVED`, 4 tühja.
  - `n_plants` sisaldab mittenumbrilist väärtust; `height_cm` ei loe numbrina; J168 on kuupäev.
  - `Dac_all` ja `Dry_weight` annavad Dactylise kohta erinevaid kaale (nt G6Y shoot 0.377 vs 2.249 g).
    Kumb on õige? Mõned `Dac_all` taimekeskmised kahtlaselt suured (G1Y 8.7 g, F5Y 5.2 g).
  - [x] `SHAREPOINT_PATH_BIOMASS` lisatud `.Renviron`-i (15.11).
- [ ] **`DistNet_Quadrat.xlsx` leht `Community` (juhendaja NMDS/PERMANOVA sisend) – metsaosa nihkes (14.11).**
  Niidu 12 ringi vastavad `Quadrat_Grassland` lehele täpselt. Metsas on väärtused nihkunud ühe liigiveeru
  võrra paremale (nt F1Y: *Carex hirta* 5 → `Carex ornithopoda` all, *Melampyrum nemorosum* 20 → `Orthilia secunda` all),
  viimane väärtus on nimeta veerus 68. Lisaks on *Galium album* ja *G. verum* kaks korda (metsa väärtused topelt),
  *Pulsatilla pratense* (metsa kirjaviga) puudub. **Parandatud 14.11** (Claude): `Community` leht genereeriti
  `Quadrat_*` lehtedest, 64 liiki, iga liik üks kord, nimeta veerg eemaldatud; 0 lahtrit erineb `Quadrat_*`-st.
  Ülejäänud lehed muutmata, `Meta` oli korras. Originaal on juhendaja eraldi failis.
  - [ ] Juhendajale teada anda (metsa NMDS/PERMANOVA vanade andmetega valed).
- [x] **Kirjaviga:** `Pulsatilla pratense` parandatud 15.11.
- [ ] Metsa kehvad ringid (biomass < 1.5 g): F6N, F6Y (metsaserv), F2Y, F5N.

## Metoodika tekst

- [ ] **Katseala:** kirjeldada metsa ruumiline paigutus – ringid rivis mööda rada, juhuslikustatud
  järjekord; F1 kompostihunniku taga maja kõrval, F2 kadakate vahel varjus, F6 metsaservas;
  mikrokasvukohad heterogeensed. Niit ühtlane.
- [ ] Taimeruudu kirjelduse aeg (26.–27.07.2026) ja meetod (Braun-Blanquet/Domin – kontrolli).
- [ ] Viide `Midolo jt 2023` (häiringu indikaatorväärtused) – ainult kui kasutad; kontrolli Zoteros.

## Dactylise skännid (`_metoodika_funktsionaalsed_naitajad_Dac.qmd`)

- [ ] **Lehe kontrollruut:** mõõdetud 976–991 mm² → külg ~31,5 mm (mitte 3 cm). Tekstis 31,5 mm; Mare kontrollib laboris joonlauaga.
- [ ] Kaalu täpsus (Mare vaatab). Lehtede arv ringi kohta = osakeste arv (3–5), Mare: „peaaegu õige“.
- [ ] **SRL:** skaneeritud juurepikkus on alamproov (4–9 m, ei korreleeru kogu juurte massiga) → vaja skaneeritud proovide kuivkaalu. Proovid kastis, Mare kaalub. Kuni selleni SRL-i ei arvutata.
- [ ] Diameetriklassid: osakaalud või absoluutpikkus (Histo = toorskelett, mitte Kimura).
- [ ] Andmed R-i (handoff 7 ülesanded): lugemine, `ring_id`, ümberarvutused, liitmine Biomassiga.

## Kasvunäitajate metoodika (`_metoodika_kasvunaitajad.qmd`)

- [x] Roseti diameetri ja herbivooria allikad leitud (Bonham 2013, PROMETHEUS, HerbVar) – `.bib`-is, tekstis veel viitamata.
- [ ] Lehe max pikkuse mõõtmise allikas puudu.
- [ ] Lehe max pikkuse põhjendus tekstis (rosettliikide kasvu kompenseerimine) ei ole Mare tegelik põhjus:
  mõõdeti, sest algul tundus vajalik; see on ainus järjepidev mõõdik. Teksti üle vaadata.
- [x] Roseti laius: mõõdeti 23.08 ja 23.09 (`width_x/y_cm`), mitte Dactylisel; varasem `width_cm` tühi mallist. Tekst parandatud 15.11.
- [ ] **Silene `width_x/y_cm`** viimastel mõõtmistel kasutatud muuks otstarbeks, numbrid imelikud (Mare 15.11) – selgitada, mida
  need tähendavad; kuni selleni Silene roseti diameetrit analüüsis mitte kasutada.
- [ ] Dassen jt 2021 erineb meetodilt: nemad kasvatasid seemikuid terasvõrgust ingrowth-südamikes, mida tõsteti/pöörati
  2× nädalas (abstract: "cores that had been lifted"); siin lõigati ringi perimeeter noaga 1× nädalas. Terminoloogia sama,
  meetod mitte identne – tekstis nii sõnastada.
- [ ] Puudulikud mõõtmised: 31.05 mõõdeti ainult iga ringi × liigi suurim isend (taim nr 1, 90 tk), ainult max_leaf
  (Mare 15.11); 23.07 max_leaf ainult 60. Metoodikasse kirja.
- [ ] 31.05 + 15.06 liitmine üheks mõõtmiskorraks: andmed ei toeta – max_leaf kasvas 31.05 → 23.06 mediaan +2,3 cm
  (ainult 30 % taimedest ≤ 1 cm), kõrgus 15.06 → 23.06 mediaan 0. Ettepanek: iga tunnuse aegrida oma kuupäevadega,
  täisandmestiku algus 23.06.
- [x] **Traits:** rida 84 oli `G5N-L4`, õige `G4N-L4` – parandatud Excelis kõigil 2026 lehtedel (+ `2026_Monitoring` ring_id), 15.11.

## Liiginimed (GBIF, `R/gbif_name_check.R` → `data/processed/gbif_name_check.csv`, 15.11)

69 nime (MasterData Species + Quadrat_Forest + Quadrat_Grassland). Tabel juhendajale: `_metoodika_eksperimendi_disain.qmd` callout. *Bromus*, *Festuca* juhendajaga otsustada:
- [x] MasterData `Species`: `Silene nutans` → `Silene latifolia` (Excelis parandatud 15.11).
- [ ] *Bromus mollis* – mitmetähenduslik; *B. mollis* L. = *Bromus hordeaceus* (GBIF kehtiv).
- [ ] *Festuca pratensis* – mitmetähenduslik; *F. pratensis* Huds. = *Lolium pratense* (GBIF kehtiv; ka *Schedonorus pratensis*).
- [ ] *Helictotrichon pratensis* → GBIF: *Helictotrichon pratense* (L.) Besser või *Helictochloa pratensis*. Mare: jääb praegu (FungalRoot fail `Helictotrichon_pratensis.csv` sama nimega).
- [x] *Helictotrichon pubescens* – jääb (Mare 15.11).
- [x] *Pulsatilla pratense* → *Pulsatilla pratensis*, Quadrat_Forest B31 parandatud 15.11.
- [x] *Euphrasia sp*, *Hieracium sp* – jääb sp (Mare 15.11).

## Eksperimendi disain

- [ ] Viide *Silene* NM-staatusele ja MC väärtus (FungalRoot?); MasterData `Species` `Myc_status` Silenel FM → NM? (Mare otsustab).

## Tehisintellekti kasutamine (Mare loeb kunagi)

- [ ] TÜ juhend tehisintellekti kasutamise kohta lõputöödes: kas ja kuidas deklareerida (nt eessõnas/metoodikas).
  Selles töös on Claude't kasutatud: koodi kirjutamine (R-skriptid), andmete kontroll (nt Community-lehe nihe,
  liiginimede GBIF-kontroll), FungalRoot'i väärtuste pärimine (Desktop, hiljem `R/am_colonization.R`), viidete
  kontroll (Crossref/DataCite), metoodika teksti mustandid. Kõik arvutused on repos skriptidena korratavad;
  viited on DOI järgi kontrollitud.

## Sissejuhatus (`01-sissejuhatus.qmd`, 2025. a projekti tekstist, 15.11)

- [ ] Viide: esimeste maismaataimede juurtes krohmseente-sarnased struktuurid.
- [ ] Viide: keskmiselt 15 krohmseent taime kohta.
- [x] *Silene* hüpoteesidesse ei lähe (Mare 15.11): tundlik teema – mükoloogide järgi fülogeneetiliselt AMF-iks võimetu, Mare leidis
  vesiikuleid ja hüüfe; juhendaja pani liigi katsesse teadlikult. Tekstis mitte esile tõsta.
- [x] Glomeromycotina (Spatafora jt 2016), Mare 15.11.

## Lõputöö seadistus (`report/thesis/`)

- [ ] Pealkiri (`[PEALKIRI]` failis `_quarto.yml`).
- [ ] Ülikooli `reference.docx` ja `.csl` – lisada ja kommentaar eemaldada `_quarto.yml`-is.
- [x] Kasvunäitajate metoodika on `_metoodika_kasvunaitajad.qmd`, kaasatud `02-metoodika.qmd` alapeatükki 2.4.
- [x] Peatükid 03–05 põhjadena olemas; annotatsioon + abstract `index.qmd`-s.

## Repo

- [ ] `report/blog/posts/2026-08-15-habitat-AM-intensity copy/` – juhuslik koopia? Kustutada.
- [ ] `report/.DS_Store` on veel gitis: `git rm --cached report/.DS_Store`.
- [ ] `R/CWM.R`, `R/quadrat_cover.R`, `docs/markmed.md` commit'imata.
- [x] `docs/Claude_README.md` lisatud (11.11); infrastruktuuri jaotised uuendatud, ülejäänud sisu Mare loeb üle.
