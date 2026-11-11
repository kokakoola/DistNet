# DistNet — magistritöö (CLAUDE.md)

Mare magistritöö kooslusökoloogias: arbuskulaarse mükoriisa (AMF) võrgustiku katse.
Kõik projektiülesed otsused ja detailid on failis `docs/Claude_README.md`. Loe see läbi enne,
kui muudad andmetorustikku, andmestruktuuri või metoodika teksti.

**Dokumentatsiooni hooldus (Claude teeb ise, ilma küsimata):** kui sessioonis muutub
andmetorustik, failistruktuur, töövoog või Mare teeb projektiotsuse, uuenda samas sessioonis
vastavat jaotist failides `docs/Claude_README.md` ja/või `CLAUDE.md`. Lahtised küsimused ja
tööjärjekord lähevad faili `docs/markmed.md`. Desktop-äpist tulevad ülesanded on failis
`docs/handoff.md`; tehtud punktid märgi `[x]`. Ära muuda Mare otsuseid ega sisulisi kirjeldusi
omal algatusel — kui README sisu tundub vananenud, küsi.

## Keel ja stiil
- Lõputöö tekst on **eesti keeles** (ülikooli nõue).
- R-koodi kommentaarid on **inglise keeles**, alati.
- Suhtle lakooniliselt ja otse. Ära lisa komplimente ega üleliigseid hoiatusi.
- Kui midagi on ebaselge, küsi. Ära oleta ja ära mõtle välja viiteid, väärtusi ega meetodeid.
- Failinimedes ja kaustades ära kasuta täpitähti ega tühikuid.

## Katse lühidalt
- **Küsimus:** kuidas ümbritsevate naabertaimede mükoriissus (1 m² quadrat) mõjutab
  katsetaimede AM-kolonisatsiooni (d = 15 cm rõngas).
- **Manipulatsioon:** `severed` (rõnga perimeeter lõigatakse kord nädalas noaga läbi, AMF-hüüfid
  katkevad) vs `control`. Termin on "severed", mitte "disturbance" (eeskuju: Dassen jt 2021,
  *New Phytologist* 232: 753–761).
- **Kasvukohad:** mets (hemiboreaalne männi-/segamets, ~58°N) ja niit, kummaski 12 rõngast
  (pooled severed, pooled control).
- **Referentstaimed:** loodusest kogutud, `treatment = "reference"`, pseudo-ring_id
  `FREF`/`GREF`/`OREF`. Neid **ei** kaasata `habitat * treatment` mudelisse.
- **Katseliigid (5):** *Achillea millefolium*, *Cichorium intybus*, *Dactylis glomerata*,
  *Leontodon hispidus*, *Silene latifolia*. *Solidago virgaurea* ei idanenud ja on katsest
  väljas, kuid jääb species-tabelisse alles.
- **Kolonisatsioon:** McGonigle jt 1990 RLC% (arb/ves/hyp/noamf/total), 1 isend liigi kohta
  rõngas (focal).
- **Focal-reegel:** focal on rõnga × liigi suurim (esimene) taim. Kui see suri, saab focal'iks
  järgmine ellujäänu. Ülejäänud taimed keskmistatakse.
- **Hierarhia:** kasvukoht → rõngas → taim. Kaalu mixed model'it (rõngas kui random effect).
- **Praegune baasmudel (piloot, WIP):** `lm(log_total ~ habitat * treatment + species, data = colonization)`,
  n = 44, R² = 0.60.
- **Põhihüpotees (veel koodis realiseerimata):** quadrat'i keskmine naabruse-AM läheb mudelisse
  pideva prediktorina koos interaktsiooniga `treatment × quadrat_mean_AM`.

## Dactylis — eraldi käsitlus
- Focal puudub, analüüsis kasutatakse ainult keskmist (kõik taimed on `-2` real).
- Tehtud: juure- ja lehekännid (ootavad analüüsi), värske- ja kuivmass.
- Juured on kogutud ja ootavad DNA-analüüsi. Kas DNA ja mullatoitained tehakse, on veel
  otsustamata.
- Juhendaja peab ka ainult Dactylisele keskenduvat tööd piisavaks. Mare ei taha teisi liike
  välja jätta.
- **Skannide analüüs:** Fiji (Mac). Lehepindala mõõdetakse Threshold + Analyze Particles abil,
  juured IJ_Rhizo pluginaga (Pierret jt 2013). WinRHIZO ja RhizoVision ei tule kõne alla.

## Andmed
Andmed asuvad SharePointis (TÜ), mitte gitis. Need tõmmatakse funktsiooniga
`get_data(path_env_var, dest_prefix)`, mis loeb asukohad failist `.Renviron` (gitignore'itud). SharePoint on Macis OneDrive'iga sünkitud (`SHAREPOINT_LOCAL`); Microsoft365R-i TÜ Conditional Access blokeerib.

| Fail | Sisu | Liitmisvõti |
|---|---|---|
| `DistNet_MasterData.xlsx` | `rings`, `plants`, `species` (viitetabelid) | — |
| `DistNet_Traits.xlsx` | igakuised mõõtmised, üks leht visiidi kohta (AAAA-KK-PP) | `plant_id` |
| `DistNet_Biomass.xlsx` | kuivkaalud: `-1` = focal, `-2` = ülejäänud taimed koos | **`ring_id + species + focal`**, MITTE `plant_id` |
| `DistNet_Colonization.xlsx` | mikroskoopia, leht `Colonization_26` (A:J sisend, K+ arvutus) | `plant_id` |
| `DistNet_Quadrat.xlsx` | koosluse katvus (struktuur lahtine) | `ring_id` |
| `data/raw/FungalRoot/` | lokaalsed CSV-d, ei tule SharePointist | liiginimi |

- `read_excel(..., na = c("", "NA"))`. `0` ei ole NA.
- Surnud või eemaldatud taimi ei kustutata kunagi (`status`: alive/dead/missing/removed).
- Käsitsi parandused (overrides) tehakse R-koodis, mitte Excelis. Väärtuse päritolu näitab
  `data_source` veerg. Kasuta `dplyr::rows_upsert()`.
- Mitme taime koondridade (`-2`) puhul jaga kaal `n_plants`-iga ja kasuta mudelis
  `weights = n_plants`.

## FungalRoot (taustkalibreering, mitte iseseisev tulemus)
- Kasutusel ainult McGonigle 1990 RLC%. Kategooria "forest" = temperate coniferous + broadleaf,
  "grassland" = temperate grassland.
- Fallback toimub kolmel tasandil: habitat-spetsiifiline kirje → sama liik mis tahes biomist →
  manual override.
- Oma mikroskoopia on veel pooleli neljal liigil: *Carex disticha*, *Helictotrichon pratensis*,
  *Artemisia campestris*, *Pulsatilla pratensis*.
- Esialgsed keskmised: mets ~21%, niit ~73%.

## Repo struktuur
```
DistNet/
├── R/helpers/        # fetch_data.R, clean_data.R, join_master.R
├── R/analyze.R
├── data/{raw,processed}/   # gitignore'itud
├── report/
│   ├── thesis/      # Quarto book: index.qmd (annotatsioon), 01–05 peatükid, _kasvunaitajad.qmd (include), references.qmd
│   └── blog/         # vana Quarto blogi, enam ei peeta ega avaldata (11.11.2026)
├── figures/
├── docs/Claude_README.md
└── .here             # vajalik juurkaustas, ära kustuta
```
- Failiteed kirjuta alati kujul `here::here(...)`, ära kasuta suhtelisi teid.
- Uue paketi lisamise järel käivita `renv::snapshot()`.
- `./publish.sh` renderdab lõputöö (HTML + docx), push'ib `main`-i ja avaldab lõputöö HTML-i
  GitHub Pages'i (gh-pages, asendas blogi). Lisaks kopeerib docx-i `upload_review()`-ga
  SharePointi `Docs/Review/` uue versioonina (üle ei kirjuta). Commit'i ei tee — commit'i enne ise.

## Lõputöö kirjutamine
- Lõputöö on Quartos, iga peatükk eraldi `.qmd` failina. Viited on `references.bib` failis
  (Zotero + Better BibTeX), tekstis kujul `[@key]`.
- Juhendaja jaoks renderda `quarto render --to docx` (vormingu annab `reference-doc`). Juhendaja
  kommenteerib Word Online'is. Kommentaarid kantakse käsitsi tagasi `.qmd` faili.
- Juba olemas: `_kasvunaitajad.qmd` (Traits'i metoodika, kaasatud `02-metoodika.qmd` alapeatükki).
- **Ära kasuta lõplikus tekstis kinnitamata viiteid.** Näiteks `tordoniXXXX` on platseholder,
  viide on alles juhendajalt saamata.

## Lahtised küsimused (juhendajaga arutamiseks)
- Dactylise ulatus: kas eraldi peatükk, millised lisaanalüüsid.
- Kas DNA ja mullatoitained tehakse.
- *Silene latifolia* mükoriisastaatus: species-tabelis on FM, kuid Silene on tavaliselt NM.
- species-tabeli `Mean_col`/`Mean_CV` allikas.
