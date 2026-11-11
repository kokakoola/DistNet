# Lahtised teemad

Tööjärjekord, mitte lõputöö tekst. Tehtud punktid märgi `[x]` või kustuta.

## Analüüs: CWM ja naabruskond

- [ ] **Treatment-ebatasakaal naabruse CWM-is.** CWM arvutatakse nüüd R-is (`R/CWM.R`, lävend
  Mean_cover ≥ 0.8, AM %). Severed-rõngaste CWM on keskmiselt madalam
  (mets 7.0 vs 14.3 %, niit 80.4 vs 83.5 %). `lm` p = 0.020, kuid metsa jääkide SD on ~2.4× niidu omast;
  `gls` (`varIdent(~1 | habitat)`) p = 0.068, paar juhusliku efektina p = 0.079.
  Järeldus: mitteoluline, kuid metoodikas/arutelus mainida. CWM läheb põhimudelisse kovariaadina.
  (Vanad numbrid Exceli CWM-lehelt, kõik liigid: mets 0.12 vs 0.20, niit 0.79 vs 0.83; `gls` p = 0.085.)
- [ ] **`cover_share` piiranguna metoodikasse:** lävendi ületanud liigid katavad metsas 50–98 %
  koosluse katvusest (F6N 0.50), niidul 93–99 %.
- [ ] **AM-väärtuste allikas:** `R/CWM.R` kasutab Exceli veergu `AM intensity FungalRoot`, mitte
  `R/AM_intensity.R` pipeline'i. Need erinevad 11 liigil kuni 29 p.p. (nt *Medicago lupulina* 70 vs 100);
  4 liiki (Carex disticha, Artemisia campestris, Helictotrichon pratensis, Pulsatilla pratensis)
  pipeline'is puuduvad (oma mikroskoopia pooleli). Otsustada, kumb on lõplik allikas.
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
  erinenud (`R/quadrat_cover.R`). Kvadraadid kirjeldati 26.–27.07.2026, s.t pärast severing'u algust.
- [ ] **Metsas korreleerub katsetaimede biomass negatiivselt naabruse CWM-iga**
  (Spearman rho = −0.67, p = 0.02, n = 12; kõik rõngad biomassiga > 4.5 g on CWM < 0.10).
  NB: arvutatud vana, Exceli CWM-iga – korrata uue `R/CWM.R` väärtustega.
  Võimalik, et madal CWM tähistab paremat mikrokasvukohta (valgus/muld?). Puudutab põhihüpoteesi
  (kas CWM-i mõju on eraldatav kasvukoha mõjust) – **arutada juhendajaga.**
- [ ] Ajutised kontrollarvutused (lävendi võrdlus, biomass × CWM) pole koodis – kirjutada
  skriptiks, kui tulemust töös kasutatakse.

## Andmed

- [ ] **Kolonisatsioon ↔ CWM liitmine.** Piloodi `data/processed/colonization.csv` kasutab
  `ring_id` = 1, 2… ja `isolated`/`network`; CWM `F1Y`… ja `severed`/`control`. Liitmine töötab
  alles `Colonization_26` lehega – `R/helpers/clean_data.R` loeb veel `Colonization_Pilot` lehte.
- [ ] **Biomass (`DistNet_Biomass.xlsx`):**
  - `status` ebaühtlane: `dead`/`DEAD`, `removed`/`REMOVED`, 4 tühja.
  - `n_plants` sisaldab mittenumbrilist väärtust; `height_cm` ei loe numbrina; J168 on kuupäev.
  - `Dac_all` ja `Dry_weight` annavad Dactylise kohta erinevaid kaale (nt G6Y shoot 0.377 vs 2.249 g).
    Kumb on õige? Mõned `Dac_all` taimekeskmised kahtlaselt suured (G1Y 8.7 g, F5Y 5.2 g).
  - `.Renviron`-is puudub `SHAREPOINT_PATH_BIOMASS`.
- [ ] **Kirjaviga:** metsalehel `Pulsatilla pratense`, niidulehel `Pulsatilla pratensis`.
- [ ] Metsa kehvad rõngad (biomass < 1.5 g): F6N, F6Y (metsaserv), F2Y, F5N.

## Metoodika tekst

- [ ] **Katseala:** kirjeldada metsa ruumiline paigutus – rõngad rivis mööda rada, juhuslikustatud
  järjekord; F1 kompostihunniku taga maja kõrval, F2 kadakate vahel varjus, F6 metsaservas;
  mikrokasvukohad heterogeensed. Niit ühtlane.
- [ ] Kvadraadikirjelduse aeg (26.–27.07.2026) ja meetod (Braun-Blanquet/Domin – kontrolli).
- [ ] Viide `Midolo jt 2023` (häiringu indikaatorväärtused) – ainult kui kasutad; kontrolli Zoteros.

## Lõputöö seadistus (`report/thesis/`)

- [ ] Pealkiri (`[PEALKIRI]` failis `_quarto.yml`).
- [ ] Ülikooli `reference.docx` ja `.csl` – lisada ja kommentaar eemaldada `_quarto.yml`-is.
- [x] Kasvunäitajate metoodika on `_kasvunaitajad.qmd`, kaasatud `02-metoodika.qmd` alapeatükki 2.4.
- [x] Peatükid 03–05 põhjadena olemas; annotatsioon + abstract `index.qmd`-s.

## Repo

- [ ] `report/blog/posts/2026-08-15-habitat-AM-intensity copy/` – juhuslik koopia? Kustutada.
- [ ] `report/.DS_Store` on veel gitis: `git rm --cached report/.DS_Store`.
- [ ] `R/CWM.R`, `R/quadrat_cover.R`, `docs/markmed.md` commit'imata.
- [x] `docs/Claude_README.md` lisatud (11.11); infrastruktuuri jaotised uuendatud, ülejäänud sisu Mare loeb üle.
