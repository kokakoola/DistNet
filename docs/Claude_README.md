# Andmeanalüüs (DistNet) — jooksvad kokkulepped ja otsused
See dokument on projektiülene "mälu" magistritöö erinevate peatükkide (eraldi chattide) vahel. Uus chat peaks selle enne tööle asumist üle vaatama (project_search / project_read), et püsida kooskõlas varasemate otsustega. (Varem claude_projekti_kokkulepped.md — nimi vahetatud, kuna "README" on tuttavam/standardsem.)

Praegune seis (viimane uuendus: 09.10.2026)
MasterData valmis: README + plants + rings + species lehed. species on juhendaja oma tabel, jääb sinna, ei lähe analüüsi.
Traits pooleli — kasutaja teeb parasjagu korda. Esimese mõõtmiskorra (31.05) protokolliprobleem lahendatud, vt allpool. estimation_flag veerg eemaldati; status veerule lisandus neljas väärtus removed; visiidilehed on balanced panel (kõik plant_id kõigil lehtedel kogu katse kestel) — vt "Traits metoodika". Otsus (04.09.2026): width_cm (Dactylisel/Silenel niikuinii alati NA, kuna nad pole rosetid) kasutatakse erandlikel õitsevatel isenditel generatiivse osa (õisikuvars + tutt/õisik) pikkuse jaoks — kasutaja kinnitas ettepaneku. Vt "Traits metoodika".
Biomass (saagikoristuse kuivkaalud) — sisestamine käib (09.10.2026): iga ring × liik kohta 2 rida (-1 focal, -2 kõik ülejäänud hunnikus), Dactylisel focal puudub. Dactylisel on lisaks oma eraldi tabel, sest sinna tuleb rohkem mõõtmisi kui teistele liikidele (samad kaalunumbrid põhitabelist + leaf scan dry/wet, root scan hiljem) — vt "Andmefailide struktuur". Juhendajaga veel arutamata.
Colonization pipeline TÖÖTAB otsast lõpuni (21.08.2026): eraldi DistNetColonization fail (lahutatud MasterDatast), fetch → clean → CSV väljund. Kasutusel Colonization_Pilot leht, veerud arb/ves/hyp/noamf/total (McGonigle RLC%). Esimene lm() jooksutatud edukalt (log_total ~ habitat * treatment + species), vt "Praegune baasmudel" allpool. NA-d (arb/ves/hyp osadel ridadel, mikroskopeerimata slaidid) on teadlikud ja jäetud alles, lm() käsitleb vaikimisi.
Fetch loogika ümber tehtud generic funktsiooniks get_data(path_env_var, dest_prefix) — üks funktsioon kõigi failide jaoks, mitte fail-spetsiifilised wrapperid. Vt "SharePointi ligipääs R-ist".
Kataloogid MasterDatast lahku splititud — igal domeenil (Colonization, Traits, Quadrat, Biomass, ExternalDatabases) oma fail, oma fetch-kutse, oma .Renviron muutuja. join_master.R samuti .Renviron-i peale ümber tehtud (site nimi + failiteed muutujatena, ei ole koodis hardcoded).
Infrastruktuur (SharePoint, git, GitHub, renv, Quarto blog) seadistatud ja töökorras — vt "Infrastruktuur ja andmetorustik" allpool, oluliselt täienenud.
Quadrat — struktuur veel kahtlane/lahtine, vaadatakse hiljem eraldi.
Katse kontekst
Valdkond: bioloogia / botaanika, kooslusökoloogia, mükoriisavõrgustik (arbuskulaarne mükoriisa). Taimed jagunevad kategooriatesse AM / OM / FM.
Projekti nimi: DistNet.
Analüüsikeskkond: R, Positron.
Magistritöö kirjutatakse eesti keeles (ülikooli nõue) Quartos (.qmd failid, jaotatud eraldi peatükkideks; tsitaadid ühises/peatükipõhises .bib failis).
R-koodi kommentaarid tuleb kirjutada inglise keeles — kasutaja eelistus, kehtib kõikjal, isegi kui muu suhtlus/tekst on eesti keeles.
Katse eesmärk ja hüpotees
Katse teel tuvastada, kuidas ümbritsevate naabertaimede mükoriissus (mõõdetud 1m² quadrat'ina) mõjutab katsetaimede mükoriissust (mõõdetud d=15cm ringis, mikroskoopia, McGonigle jt 1990 RLC%-meetod).

5 katseliiki (vt allpool) külvatud igasse katserõngasse, mittesteriilsesse kohalikku mulda (muld sisaldab juba kasvukohale omaseid AMF-spoore).
Manipulatsioon: "severed" (varem kutsutud "disturbance" — vahetatud täpsuse pärast, vt allpool): rõnga perimeeter lõigatakse 1x nädalas noaga läbi, et katkestada AMF-hüüfide ühendus naabertaimede ja katsetaimede vahel. Võrreldakse häirimata "control" rõngastega.
2 kasvukohta (forest, grassland), 12 katserõngast igas (pooled control, pooled severed).
Lisaks kogutakse referentstaimed looduses (kummastki kasvukohast, liigi kohta) loomuliku mükoriissuse mõõtmiseks — neil pole quadrat'i tehtud (juhendaja otsus, pole vajalik), pole osa treatment-disainist.
Teadaolev keerukus mudeldamisel: rõnga sees on kõik 5 liiki koos — nemad võivad ka omavahel (rõnga sees) võrgustuda, st "naaber" pole ainult väljaspool rõngast (quadrat), vaid ka rõnga-sisesed teised katsetaimed. Ei tühista quadrat-analüüsi, aga tasub diskussioonis mainida.
Hierarhiline struktuur mudeldamiseks: kasvukoht (2) → rõngas (12 igas) → katsetaim rõnga sees. Kaaluda mixed model'it (rõngas kui random effect), et vältida pseudorepikatsiooni.
Põhihüpotees analüüsi jaoks: quadrat'i keskmine naabruse-AM läheb mudelisse pideva prediktorina, koos interaktsiooniga treatment × quadrat_mean_AM. Veel kontseptuaalses faasis, pole koodis realiseeritud.
Praegune pilootanalüüsi baasmudel: `lm(log_total ~ habitat * treatment
species, data = colonization)`.
Kolonisatsiooni mikroskoopiaks võetakse ainult 1 isend liigi/ringi kohta (nii oli "tellimuses"; ülejäänud külvatud isendid on suremuspuhver, mitte lisareplikaadid). Eeldus (täpselt kinnitamata): see isend on biomassi-andmestikus focal-taim (Dactylisel focal puudub, vt Biomass). Kaaluda väikest lisakontrolli (2 isendit mõnel juhuslikul ringil) isendisisese müra hindamiseks, kui aega jääb — pole kohustuslik.
Katseliigid
5 liiki katses (lõplik, kinnitatud):

Achillea millefolium (FM) — noorena 2-4 vastassuunalist lehte, piklik kuju, mitte tõeline ringikujuline rosett.
Cichorium intybus (FM) — käitub sarnaselt Achilleaga (piklik, mitte rosett).
Dactylis glomerata (FM) — kõrreline; märjana/vihma järel kaldub lonti vajuma (mõjutab kõrguse mõõtmist, mitte laiust).
Leontodon hispidus (OM) — tõeline rosett, kasvab laiusesse.
Silene latifolia (FM???, vt allpool) — kasvatab õieroote vegetatiivsest rosetist selgelt eraldi.
Silene taksonoomia (lahendatud): "Silene alba" ja "Silene pratensis" on sama taksoni kaks vana sünonüümi — kehtiv nimi on Silene latifolia (täpsemalt subsp. alba). Pole kaks segiaetavat liiki, vaid üks liik kahe nimega. Silene nutans on aga päriselt teine liik — seemnepakil oli vale märgistus (tellitud/märgitud S. nutans, tegelikult kasvas S. latifolia/alba). TODO: liigi species-tabeli Myc_status "FM" oli määratud S. nutans eeldusel — kontrollida, kas kehtib ka S. latifolia kohta (kasutaja mainis, et Silene on tavaliselt NM — vastuolu, juhendajalt kinnitust vaja).
Lõputöö tekstis kasutatakse nime Silene latifolia (otsus 11.11.2026, Mare kinnitas); "Silene alba" asendatakse kõikjal tekstis.

6. liik ära langes: Solidago virgaurea (OM) oli algselt plaanis, aga ei idanenud — pole katses, aga jäetakse species-tabelisse alles koos märkega (ei kustutata, dokumenteeritakse kõrvalekaldena).

Treatment terminoloogia: "severed", mitte "disturbance"
"Disturbance" on liiga üldine (kõlab nagu füüsiline mullahäiring). Vahetatud "severed" vastu, järgides otsest metoodilist eeskuju: Dassen, S., van der Putten, W.H., De Deyn, G.B. (2021). Severance of arbuscular mycorrhizal fungal mycelial networks in restoration grasslands enhances seedling biomass. New Phytologist, 232(2), 753–761. — identne meetod (hüüfid läbi lõigatud 2x nädalas pooltel katsekehadel, "severed" vs "control"), erinev küsimus (nemad: biomass ühes elupaigas kunstlikes südamikes; DistNet: kolonisatsioon, 2 elupaika, naabruse-mükoriissuse ülekanne võrgustiku kaudu). See ei tähenda, et DistNeti teema on juba "ära tehtud" — meetod kattub, uurimisküsimus mitte.

Y/N koodid rõngastel (vt allpool) võivad jääda samaks, muutub ainult kirjeldav silt tabelites/tekstis.

Ring_id / plant_id koodistandard
ring_id: habitat-täht (F=forest, G=grassland) + number + Y (severed) / N (control). Nt F1Y, G4N. Referentstaimede jaoks (loodusest kogutud, pole päris rõngas) pseudo-ring_id GREF/FREF, treatment = "reference" (kolmas väärtus, EI ole severed ega control — ei tohi kogemata sattuda habitat * treatment põhimudelisse).
Referentstaimede habitat-täht valitakse HABITAT-TÜÜBI, mitte täpse asukoha järgi — kas leiukoht on ökoloogiliselt niidu- või metsa-tüüpi, mitte kas see on täpselt katseala. Nt:
Leontodon (rannakarjamaa serv) → G (niidu-tüüpi, kuigi mitte identne katseniiduga — note: "rannakarjamaa, võimalik erinevus soolasuse/mullatüübi/karjatamise poolest").
Silene (metsa vahel, teeäärne) → F (mets, kuigi teeäärne/edge — note: "võimalik edge-efekt vs katseala metsa sisemus").
Cichorium (muuli pealt, kaugemalt) → O (other/outside) — muul on tehisrajatis, ei kuulu kumbagi habitat-tüüpi.
OREF on kolmas pseudo-ring_id (nagu GREF/FREF) liikidele, mis ei esine kummaski habitat-tüübis — üks juhuslik leiukoht katab mõlema habitati võrdluse (nõrgem tõend kui habitat-matched referents, mainida lõputöö piiranguna).
plant_id: ring_id + "-" + liigi esitäht + isendinumber, number ALATI olemas (ka 1 isendi puhul, nt G4Y-A1, mitte G4Y-A) — otsustatud, et vältida hilisemat segadust (kas numbri puudumine tähendab 1 isendit või andmeviga). Liigikoodid: A=Achillea, C=Cichorium, D=Dactylis, L=Leontodon, S=Silene — kõik unikaalsed esitähed, pole kollisiooni.
Liigi 3-täheline kood (09.10.2026, kasutusel Biomass-tabelis species veerus): esimesed 3 tähte perekonnanimest — Ach, Cic, Dac, Leo, Sil (NB: Cichorium on Cic, mitte Chi — "Chi" tuli inglise "chicory"-st ja ei klapi reegliga). plant_id jääb 1-täheliseks (G1Y-L1). Täisnimest tuletamine R-is: substr(species, 1, 3). Muuda plant_id-konventsiooni 3 tähele ainult kõigis failides korraga (plants, Traits visiidilehed, Colonization), muidu plant_id-liitmine katki — praegu seda tehtud ei ole.
plants tabelis lisaveerg sample_type: väärtused täpselt "experiment" / "reference" (R on täht-tähelt tundlik, kasuta läbivalt sama sõna kõikjal).
Andmefailide struktuur (DistNet_MasterData jagati laiali)
Endine üks suur DistNet_MasterData.xlsx (kõik lehed koos) jagati domeeni/vaatlusühiku/uuendamissageduse järgi eraldi failideks — kriteerium on erinev allikas/vaatlusühik/sagedus, mitte "kas see on minu enda mõõdetud" (kõik on kasutaja enda andmed):

DistNet_MasterData.xlsx (VALMIS) — ainult viitetabelid, ei mingeid mõõtmisandmeid:
rings: ring_id, habitat, treatment (severed/control/reference).
plants: plant_id, ring_id, species, sample_type. (sowing_date eemaldati — kõik isendid külvatud samal päeval, konstant, kirjas ainult README-märkusena, mitte veeruna.)
species: species, Myc_status, Seed_year, Collected (seemne allikas), Mean_col, Mean_CV, Order_in_ring, note (germineerumise/ märgistusvigade dokumenteerimiseks). Juhendaja tabel, ei lähe analüüsi. TODO: Mean_col/Mean_CV allikas kinnitamata (FungalRoot? kirjandus? pilot-aasta?) — küsida juhendajalt, enne lõplikku tsiteerimist mitte oletada.
README-sheet selgitab: teised failid EI liitu Exceli valemitega (habras SharePointis) — liitumine toimub R-is (left_join plant_id/ring_id järgi), vt join_master.R.
DistNet_Traits.xlsx (POOLELI) — isendipõhised korduvmõõtmised (kõrgus, lehepikkus, kahjustused). Struktuur: üks leht mõõtmiskorra kohta (leht nimega kuupäev AAAA-KK-PP), mitte üks lai tabel kasvavate veergudega. Veerud: plant_id, height_cm, max_leaf_cm, width_cm, chew_pct, pathogen_pct, status, surma_pohjus, notes. Ei sisalda species/ring/treatment veerge (tulevad MasterData'st plant_id kaudu). Detailid vt allpool "Traits metoodika".
DistNet_Biomass.xlsx (sisestamine käib; struktuur kasutaja poolt otsustatud 09.10.2026, juhendajaga veel arutamata) — saagikoristuse kuivkaalud (shoot + root), ühekordne mõõtmine. Tööfailis kaks lehte: Dry_weight (lühike, ring × liik × focal, kuhu kaalutud andmed sisestati) ja Dry-07-10 (pikk, plant_id-põhine, R-ile mineva tabeli aluseks). Eraldi fail, mitte Traits'i sisse, sest vaatlusühik on teine (Traits: üks rida = üks taim ja kõik taimed kõigil visiitidel; Biomass: taimed koondatud).
Struktuur: iga ring × liik kohta 2 rida. -1 = focal (kõige suurem taim liigi kohta ringis; plant_id lõpunumber on ALATI 1, n_plants = 1, kaal on üksiku taime kaal). -2 = täiendtaimed kõik koos hunnikus (focal = n, n_plants = taimede arv hunnikus, kaal on KOKKU summa). Hunnik võib olla ka ühetaimeline (n_plants = 1, focal = n) — eriline märge pole vajalik. Muud plant_id-numbrid (-3, -4) ei ole selles tabelis eraldi ridadena (või jäävad tühjaks, notes: "kaalutud koos -2-ga") — hunniku n_plants sisaldab neid niikuinii.
Veerud: ring_id, species (3-täheline kood), plant_id, n_plants, focal (y/n), shoot_dry_g, root_dry_g, notes. focal = y ⇔ plant_id lõpeb 1-ga, n ⇔ lõpeb 2-ga.
HOIATUS: plant_id -2 tähendab MITUT taime koos, mitte ühte taime, kuigi id näeb välja nagu üksiku taime oma. Taimepõhiste tabelitega (Traits, Colonization) liida ring_id + species + focal kaudu, MITTE plant_id kaudu — muidu läheb hunniku kaal ühe päris taime (nt -L2) külge.
Dactylis: focal puudub, kõik Dactylise taimed on pandud kokku (-2 real, n_plants = kõigi arv); -1 rida jääb kaaluveergudes tühjaks, notes: "focal puudub, kõik koos -2 real". Analüüsis jäävad kõik Dactylise taimed n gruppi ja keskmistatakse koos.
Dactylise eraldi tabel (09.10.2026): Dactylis sai lisaks põhitabelile (Dry-07-10) oma eraldi tabeli, sest sinna tuleb rohkem mõõtmisi kui teistele liikidele. Tabelis on (a) samad kaalunumbrid kui põhitabelis (kopeeritud duplikaat, EI ole korduskaalumine — kaalu ei tohi analüüsis topelt arvestada, ametlik kaal tuleb ühest kohast), (b) leaf scan dry/wet (lehe skaneering, kuiv ja märg) ning (c) root scan, mis lisandub hiljem, kui kasutaja selle tehtud saab. Täpne tabeli/lehe nimi ja veerud pole veel kirja pandud — TODO: küsi kasutajalt, kui seda analüüsis vaja läheb. Liitmine analüüsis ring_id + species kaudu (Dactylisel focal puudub).
Tühjad: tühi (ei 0, ei NA) = "oma kaalu pole": Dactylise focal puudub / hunnikusse läinud lisataimed / veel kaalumata. 0 oleks vale (tähendaks "kaalus 0 g"). Põhjus notes veerus.
Excelis täitmine (09.10.2026): Dry-07-10 täidetud INDEX/MATCH-iga (XLOOKUP kasutaja Excelis ei tööta), võtmeveeruga ring_id & "-" & species & "-" & focal ja abiveeruga (MATCH-i rea number); lõpuks väärtustena (paste special), abiveerud kustutatud. Kontroll: COUNTIF iga lühikese tabeli rea kohta peab olema 1; focal valem =IF(RIGHT(C2;1)="1";"y";IF(RIGHT(C2;1)="2";"n";"")) (nii ei saa -3/-4 hunniku kaalu endale).
R-poolne agregeerimine (hunniku kaal summast keskmiseks, trait'id eraldi taimedelt keskmiseks; focal on Traits'is plant_id lõpunumbriga 1 — kasutaja kinnitas 09.10.2026, et focal on alati olnud taim number 1):
r
    dry <- dry |>
      mutate(shoot_per_plant = shoot_dry_g / n_plants,
             root_per_plant  = root_dry_g  / n_plants)
    focal_ids <- dry |> filter(focal == "y") |> pull(plant_id)
    traits_grouped <- traits |>
      left_join(plants |> select(plant_id, ring_id, species), by = "plant_id") |>
      mutate(species = substr(species, 1, 3),
             focal = if_else(plant_id %in% focal_ids, "y", "n")) |>
      group_by(ring_id, species, focal) |>   # add visit/date if several visits
      summarise(across(c(height_cm, max_leaf_cm, width_cm, chew_pct, pathogen_pct),
                       \(x) if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)),
                .groups = "drop")
    analysis <- dry |>
      select(ring_id, species, focal, n_plants, shoot_per_plant, root_per_plant) |>
      left_join(traits_grouped, by = c("ring_id", "species", "focal"))
Mudelis: focal = üks taim, hunnik = keskmine n_plants taimest —
kasuta `weights = n_plants` või analüüsi eraldi, ära pane võrdsetena
ühte mudelisse. Mitme visiidi korral kasuta kaalumisele vastavat
(viimast) visiiti.
n_plants = taimede arv saagikoristuse HETKEL (mitte külvatud arv; surnud taimed on välja jäänud).
focal väärtused y/n (väiketähed; R loeb tekstina, focal == "y" annab loogilise väärtuse). Komaga kümnendid Excelis (2,249) on ok, kui lahtrid on numbrid; kui tekstina, siis readr::parse_number(x, locale = locale(decimal_mark = ",")).
Dactylis — juurekaal mittetäielik (07.10.2026): osa Dactylise juuri on eraldatud mikroskoopiaks, selle osa kaal lisatakse hiljem. Kuni selle ajani on Dactylise root_dry_g alahinnatud — märgi notes väljale ("juur mittetäielik, mikroskoopiaosa lisamata") ja ära kasuta root:shoot suhet neil ridadel enne lisamist. Teistel liikidel sellist eraldamist ei olnud. Kust täpselt mikroskoopiaosa võeti, kui Dactylisel focal puudub — kinnitamata. Soovitus (kinnitamata): mikroskoopiaosa kaal eraldi veeruna (nt root_micro_g), kogujuur = root_dry_g + root_micro_g.
DistNet_Quadrat.xlsx (OODAB, struktuur kahtlane) — kooslus- tasandi mõõtmised (varem MasterData sees Quadrat_Forest/Quadrat_Grassland lehtedel — see viide on nüüd vananenud, andmed elavad edaspidi siin). Liitub rings-iga otse ring_id kaudu (mitte plant_id, kuna vaatlusühik on quadrat/ring, mitte isend).
DistNet_Colonization.xlsx (OODAB saagikoristust/mikroskoopiat) — mikroskoopia (McGonigle), pilot (eelmine aasta) + final lehtedena. Liitub plants-iga plant_id kaudu.
Mullastik (pH, N-P-K) ja eDNA-põhised liigiandmed lisanduvad tulevikus — samuti oma failidena (lab/väline allikas, teine vaatlusühik), mitte MasterData sisse. Ellenberg väärtused (kui juhendaja need lisab) → väike lookup-fail/CSV, kuna on tõeline väline referents (ainus, mida kasutaja ise ei mõõda).

Traits metoodika (kasvu/kahjustuste mõõtmine)
Failid: report/thesis/_kasvunaitajad.qmd (kaasatud {{< include >}}-iga 02-metoodika.qmd alapeatükki "Taimede kasvu ja kahjustuste seire") + report/thesis/references.bib. Varem meetodid_kasvunaitajad.qmd (ümber nimetatud 11.11.2026).

Igakuine mittedestruktiivne seire kuni katse lõpuni; lõpus saagikoristus (juured + maapealne osa eraldi, kuivkaal) — kuivkaalud lähevad eraldi faili DistNet_Biomass.xlsx, mitte Traits'i (vt "Andmefailide struktuur").
Kõrgus = kogukõrgus koos õieroostiga (mitte puhas vegetatiivne), juhendaja valik — põhjendus: konkurentsiökoloogia "canopy height" traditsioon (Gaudet & Keddy 1988), erinevalt trait-andmebaaside konventsioonist (Cornelissen jt 2003; Pérez-Harguindeguy jt 2013). Mõõtmisel väldita vahetult pärast vihma (lonti vajumise müra).
Iga mõõtmisring kestab süstemaatiliselt min. 2 päeva (~180 taime, ühe päevaga ei jõua) — see EI ole erandjuht, vaid norm. Sellepärast: date_measured veerg lisati, siis eemaldati uuesti — päevatäpsus ei anna lisaväärtust (taimed kahanevad kuu jooksul niikuinii, mitte monotoonselt kasvavad), otsustati, et pole vaja. Lehe nimi (AAAA-KK-PP) = mõõtmisringi ESIMENE päev, sõltumata sellest, mitmendal päeval konkreetne taim tegelikult mõõdeti — läbiv reegel, juba niigi kasutusel (31.05, 15.06, 23.06, 23.07 olid kõik ringi esimesed päevad).
leaf_count kaaluti, ei kasutata — kasutaja ei kogu seda (polnud "tellimuses"), kuigi see oleks aidanud tuvastada tervelt kadunud lehti (vt PROMETHEUS allpool).
Rosett-liikide (Leontodon, Achillea, Cichorium) laiuse mõõt: UUS, sõltumatu mõõtmine (mitte max_leaf'ist tuletatud — need on erinevad asjad, eriti Dactylise puhul, kus max_leaf on longus kõrreleht, mitte laotus). Nimi: width_cm, täidetakse ainult viimasel mõõtmiskorral (vahetult enne saagikoristust). Ei kehti Dactylisele (tema probleem oli kõrguse mõõtmise müra, mitte laiuse alahindamine) ega Silenele (õieroots juba eraldi käsitletud) — vaikimisi jääb width_cm neil kahel liigil alati NA-ks. Achillea/ Cichorium pole tõelised ringikujulised rosetid (2-4 vastassuunalist lehte, piklik kuju) — mõõt defineeritud üldisemalt kui "laiim horisontaalne ulatus + risti sellele", mitte "rosett".
Silene: viimasel mõõtmiskorral mõõdeti eraldi vegetatiivse rosetti kõrgus ja õieroote pikkus (vrd Sun & Frelich 2011) — lahutab vegetatiivset kasvu reproduktiivsest investeeringust. Täpsustus (21.08.2026): Silenel on max_leaf_cm olnud kogu katse jooksul praktikas sama väärtus mis height_cm (mitte viga) — kuna lehed on külgharudena (ei ulatu taime tipust kõrgemale), pole Silenel eraldiseisvat "pikimat lehte" mõõta; väli on sisuliselt kajastanud sama peatelge, mis kõrgus. Alles nüüd, kui õisik hakkab arenema, lähevad height_cm (kogukõrgus koos õisikuga) ja max_leaf_cm (vegetatiivne osa, ilma õisikuta) tegelikult lahku — see on oodatud, mitte andmeviga.
Erandliku õitsemise probleem Dactylisel — width_cm repurposing (otsus, 04.09.2026): valdav enamik Dactylise isendeid ei jõua katse jooksul õitsemiseealiseks ega jõua seda ilmselt ka enne katse lõppu, seega on Dactylisel width_cm reeglina NA (liik pole rosett, vt eelmine punkt). Aga üks konkreetne erandlik isend on hakanud õitsema — sellel on lisaks kõrgusele ja max_leaf'ile olemas ka kolmas mõõt, mida praeguse veeruskeemiga polnud kuhugi panna: generatiivne osa (õisikuvars + tutt), mis on eraldiseisev pikkus peale vegetatiivse kõrreosa. Kuna Dactylisel on width_cm niikuinii strukturaalselt alati NA (vt eelmine punkt), otsustati see veerg taaskasutada erandlike õitsevate isendite generatiivse osa (õisikuvars + tutt) pikkuse jaoks — täidetakse ainult siis, kui vastav isend tegelikult õitseb, ülejäänud Dactylise/Silene ridadel jääb width_cm endiselt NA-ks nagu tavaliselt. Kehtib mõlemale liigile, kellel width_cm on struktuurselt NA (Dactylis ja Silene), kuna sama loogika (vegetatiivne rosett-mõõt ei kehti, generatiivne pikkus vajab siiski kuhugi minna erandjuhtudel) laieneb mõlemale. Selgitus, MIKS väärtus on täidetud, kuulub notes väljale (nt "erandlikult õitsev isend, width_cm = õisikuvars+tutt pikkus"), et lugeja ei ajaks seda segi rosett-laiusega. Ei vaja uut veergu — järgib juba kehtestatud põhimõtet, et NA põhjus/tähendus elab metaandmetes (siin: notes), mitte struktuuris.
Loomulik senesents (kuivanud/surnud leheosa, eriti kõrrelistel) EI LÄHE chew_pct/pathogen_pct alla (otsus, 21.08.2026) — need veerud mõõdavad konkreetselt biootilise kahjustuse (herbivooria, patogeen) osakaalu, mitte loomulikku vananemist. Kõrrelistel on vanemate lehtede pidev kuivamine/surm normaalne fenoloogia (uued lehed kasvavad samal ajal), mitte kahjustus. Kõrguse/max_leaf/width mõõtmisse jääb kuivanud osa SEES (mõõdad füüsilist struktuuri sellisena, nagu ta on — ei hinnata, mis osa oleks "elus"). Ei muuda status-t (taim jääb alive). Kui kuivanud osa hulk on märkimisväärne, kirjelda notes väljal — see selgitab tagantjärele visiitide vahelist näivat kahanemist, mis pole suremus ega kahjustus (seostub juba tehtud otsusega, et taimed kahanevad kuu jooksul niikuinii — senesents on tõenäoliselt suur osa sellest mehhanismist).
Visiidilehed on balanced panel (otsus, 20.08.2026 — juhendaja soovitus, kuigi kõhklev): iga plant_id jääb NÄHTAVANA KÕIGIL visiidilehtedel kogu katse kestel — rida ei kao lehelt kunagi, ka mitte pärast surma/eemaldamist. See on analüüsi jaoks tegelikult eelistatav variant (täisristkülikukujuline/balanced paneel iga visiidi kohta), ei vaja õigustust — vältab hiljem küsimust "kas puuduv rida tähendab, et ei mõõdetud, või et taime pole enam olemas".
Surnud ja eemaldatud taimed EI KUSTUTATA kunagi. status veerg: alive / dead / missing / removed. Kui taim sureb või eemaldatakse, jäävad kõik mõõtmisveerud (height_cm, max_leaf_cm, width_cm, chew_pct, pathogen_pct) sellest visiidist edasi NA-ks, ja status (dead/removed) kordub samamoodi igal järgneval visiidilehel kuni katse lõpuni (ei lähe tagasi "alive"-ks). surma_pohjus (herbivore/pathogen/unknown) täidetakse ainult kui status=dead. Suremus (rohutirtsud, teod) arvatakse suuresti juhuslikuks treatment'i suhtes, aga seenkahjustusest tingitud surm ei pruugi olla (AMF kaitseb mõnikord juurepatogeenide eest — "mycorrhiza-induced resistance") — seetõttu surma_pohjus eraldi veerg, mitte eeldus.
status = removed: kasutaja jaoks juhuks, kui taim eemaldatakse käsitsi katsest (nt liiga tihe kasv samas ringis, taimed kitkutud harvendamiseks) — see EI ole dead. Dead eeldab bioloogilist surma (herbivore/pathogen/unknown), removed on katsekorralduslik otsus, mitte bioloogiline tulemus — kokku segades kallutaks suremuse/kahjustuse statistikat. surma_pohjus jääb removed puhul tühjaks, notes selgitab põhjust (nt "eemaldatud, liiga tihe kasv"). Analüüsis: removed taimed filtreeritakse suremuse/ ellujäämuse analüüsist välja (censored, mitte death event) — nad ei kuulu "kui palju sureb rohutirtsude/patogeenide tõttu" küsimuse alla.
Tühjad väärtused: kas tühi lahter VÕI kirjutatud "NA" (mõlemad ok). Kasutaja eelistab käsitsi "NA" kirjutada (topeltkontroll, et ei jäta kogemata tühjaks sisestamata). R-i poole pealt tuleb see lugemisel deklareerida: read_excel(path, sheet, na = c("", "NA")) — nii loeb R nii tühja lahtri kui teksti "NA" identselt puuduvaks väärtuseks ja veerg jääb numbriliseks. Kasuta täpselt suurtähtedega "NA" (mitte "na", "n/a", "-"). 0 ei ole NA — chew_pct/pathogen_pct = 0 tähendab "mõõdetud, kahjustust polnud" (kehtiv tulemus), NA/tühi tähendab "ei saanud hinnata".
estimation_flag veerg EEMALDATI (otsus, 20.08.2026). Algne idee oli eristada "measured" vs "estimated" vs "unknown" chew_pct/ pathogen_pct väärtuste juures. Kasutaja täheldas, et tema praktikas on see eristus väärtuse enda deterministlik funktsioon, mitte sõltumatu info: väikesed väärtused (<50%) ja väga suured väärtused (>90-95%, kui taimest on järel vähe, saab suure kindlusega öelda "üle 90% söödud") on mõlemad kindlad; ebakindel on ainult keskmine vahemik (~50-90%). Flag ei lisanud seega midagi, mida väärtusest endast poleks juba näha — eemaldati kui üleliigne. Tõeliselt määramatu juht (nt leht 100% kadunud, pole baasi millega võrrelda, % pole üldse omistatav) ei kao kuhugi — see väljendub lihtsalt tühja/NA chew_pct/pathogen_pct väärtusena + selgitus notes veerus, mitte eraldi flag'ina.
Neli erinevat "NA/erilise staatuse põhjust" (dead, removed, struktuurne mittekohaldatavus, reaalne lünk) EI vaja nelja erinevat tühja-lahtri esitust. Põhjus elab metaandmetes, mitte mõõtmislahtris: dead/removed → status, struktuurne (nt width_cm ei kehti Dactylisele/Silenele tavajuhul) → tuleneb liigist (species joinituna) + notes erandjuhtudel (vt "Erandliku õitsemise probleem" ülal), reaalne lünk (unustati, vihmane, või täiesti määramatu kahjustuse ulatus) → notes. Mõõtmisveerg ise ütleb ainult "kehtivat numbrit pole", mis on statistiliselt kõigil juhtudel õige.
Esimese mõõtmiskorra (31.05) protokolliprobleem — otsus
Kronoloogia: 31.05 mõõdeti ainult suurim isend rõnga kohta (n=1/ rõngas; eeldati, et ülejäänud lähevad niikuinii välja kitkumisele), kõrgus mõõdetud ebajärjekindlalt (vahel lehte venitades, vahel mitte). Juhendaja täpsustas hiljem nõude: kõik isendid, loomulik kõrgus — 15.06 mõõdeti vastavalt (kõik taimed, loomuliku kõrgus, ja sellest visiidist alates kehtib balanced-panel struktuur, vt "Traits metoodika"). 23.06 lisandus width_cm + max_leaf_cm (juuni), 23.07 sama protokoll (juuli). Visiidid pole ühtlaste vahedega: 31.05→15.06 = 16 päeva, 15.06→23.06 = 8 päeva, 23.06→23.07 = 30 päeva.

Otsus: 31.05 ja 15.06 EI liideta üheks "mai" mõõtmiseks. Põhjused: (1) erinev valim (n=1/rõngas vs kõik isendid — enamiku taimede kohta poleks 31.05 andmeid, tagantjärele täitmine oleks 15.06 andmete valemai-nimeliseks tegemine); (2) erinev ja isegi seesmiselt ebajärjekindel mõõtmismeetod (juhuslik vs defineeritud loomulik kõrgus) — keskmistamine seguneb süstemaatilise nihkega, mitte juhusliku müraga; (3) mitmed taimed surid 31.05→15.06 vahel (elus → surnud 2 nädalaga) — see on ise oluline varajase suremuse signaal, mida liitmine varjaks, mitte müra, mida tasandada.

Praktiline lahendus:

31.05 leht jääb erandiks (n=1/rõngas, eelnes balanced-panel otsusele) — taimed, keda 31.05 ei mõõdetud, on selle lehe peal lihtsalt puudu (mitte tagantjärele täidetud). Alates 15.06 kehtib balanced panel (kõik plant_id kõigil lehtedel).
Kasvukõverate analüüsis kasutada tegelikku kuupäeva/päevi külvist pideva prediktorina, mitte "kuu" kategooriaid — see lahendab ebaühtlaste visiidivahede probleemi loomulikult.
31.05 andmed märkida metoodikas mittevõrreldavaks pilootmõõtmiseks — jätta kasvukõvera põhianalüüsist välja või kasutada ainult kirjeldavalt ("esimene vaatlus enne protokolli kinnitamist"). Dokumenteerida ausalt metoodika peatükis (protokolli varajane täpsustamine on väliuuringutes tavaline).
31.05→15.06 suremus (alive→dead 2 nädalaga) jääb omaette intervall-vaatluseks status/suremuse andmestikus, mitte segamini visiitide liitmisega.
Kasutatud viited (Traits metoodika)
Cornelissen, J.H.C. jt (2003). A handbook of protocols for standardised and easy measurement of plant functional traits worldwide. Australian Journal of Botany, 51, 335–380.
Pérez-Harguindeguy, N. jt (2013). New handbook for standardised measurement of plant functional traits worldwide. Australian Journal of Botany, 61, 167–234.
Gaudet, C.L., Keddy, P.A. (1988). A comparative approach to predicting competitive ability from plant traits. Nature, 334, 242–243.
Sun, S., Frelich, L.E. (2011). Flowering phenology and height growth pattern... Journal of Ecology, 99, 991–1000.
Bonham, C.D. (2013). Measurements for Terrestrial Vegetation, 2nd ed. Wiley. Ptk 6.5 "Crown diameter and canopy closure method" — kinnitatud, et peatükk eksisteerib, täpset valemit/sõnastust ei saanud paywalli tõttu kontrollida; tsiteeri kui "standardne meetod (Bonham 2013)", mitte otsetsitaadina.
Determining herbivory rate. PROMETHEUS Protocols (prometheusprotocols.net) — "100% leheherbivooriat jäetakse tihti mõõtmata", lehtede arvu jälgimise põhjendus (leaf_count idee algallikas, kuigi lõpuks ei kasutata).
HerbVar Damage Estimation Guidelines (herbvar.org) — võrdlusleht (petiole/midrib) täielikult söödud lehe suuruse tuletamiseks.
Dassen jt (2021) — vt "severed" terminoloogia jaotist ülal.
Lahtine/kinnitamata: "Tordoni" meetod (juhendaja algne kõrgusmõõtmise soovitus) — täpne publikatsioon endiselt kinnitamata. .bib failis platseholder tordoniXXXX. Ära kasuta lõplikus tekstis enne juhendajalt viite saamist.
FungalRoot võrdlusandmestiku pipeline
Eesmärk: FungalRoot andmebaasi põhjal arvutatud forest vs grassland keskmine AM-kolonisatsioon on taustvõrdlus/kalibreering, mitte iseseisev tulemus.

Quadrat (kooslus-)andmed liiguvad edaspidi DistNet_Quadrat.xlsx faili (vt "Andmefailide struktuur" ülal — varem MasterData sees). Veerud Species/Mean_Cover/Mean_Abundance, katvuse lävend liigi kaasamiseks 0.8% (juhendaja soovitas 1%, kasutaja valis 0.8%). LAHTINE (11.11.2026): Mare hüpotees on, et severed/control CWM-erinevust mõjutasid juhuslikud, kohale mitteomased liigid (mitte tallamine) — juhendaja nõustus need välja võtma, sellest arutelu lävendi 0.5 üle (Mean_cover ≤ 0.5 välja, ala tasemel). Lõplik lävend otsustamata; vt docs/markmed.md.
CWM (11.11.2026): naabruse kooslusmükoriissus arvutatakse R-is (R/CWM.R) kvadraadilehtede liigiridadest — weighted.mean(AM %, w = katvus) üle lävendi ületanud liikide, lisaks cover_share (lävendi ületanud liikide katvus / kogu liikide katvus). Exceli CWM-lehte ei kasutata (see võtab kõik liigid). Exceli niidulehe KW_means ei ole CWM. AM-väärtuste allikas praegu Exceli veerg "AM intensity FungalRoot"; erineb R/AM_intensity.R pipeline'ist 11 liigil — lõplik allikas otsustamata. FungalRoot liikide CSV-d data/raw/FungalRoot/ (üks fail liigi kohta; veerud: id, ID [liiginimi], Rights holder, Last modified, Habitat, Mycorrhiza type, AM method, AM intensity — järjekord varieerub, pole probleem, read_csv/bind_rows ühendavad nime järgi).
Kasutatakse ainult McGonigle jt 1990 RLC% meetodit (mitte Selivanov 1981 — sarnane põhimõte, erinev protokoll, hoitakse eraldi).
Biomi kategoriseerimine: "forest" = temperate coniferous + broadleaf forest biome kokku (katsekoht hemiboreaalne, 58°N — ENVO "subpolar" ei kvalifitseeru, see on pigem 60-70°N). "grassland" = temperate grassland biome.
Kolmetasandiline fallback-loogika: (1) habitat-specific McGonigle kirje, (2) fallback — sama liigi mis tahes McGonigle kirje olenemata biomist, (3) manual override liikidele, millel pole ühtegi kirjet — kas ökoloogilise teadmise põhjal 0 (selged EcM/NM taksonid: Orthilia secunda, Melampyrum nemorosum, Chimaphila umbellata) või kasutaja enda mikroskoopiamõõtmised (Carex disticha, Helictotrichon pratensis, Artemisia campestris, Pulsatilla pratensis — ~3h/liik, pooleli). Iga rida: data_source + override_reason veerg läbipaistvuse jaoks.
Veebiotsing override-liikidele (14.09.2026) — tulemus: ei leidnud kasutuskõlblikku %-väärtust. Kontrollitud Carex disticha, Helictotrichon pratense (nüüd Helictochloa pratensis) ja Pulsatilla pratensis. P. pratensis: Öpik jt (2003, New Phytologist, Eesti männimets vs niit) kinnitab AM-kolonisatsiooni mõlemas habitatis, aga täistekst paywalli taga, %-i ei kätte saanud. Carex disticha: liigi kohta andmeid pole; perekonna uuringus (23 Carex liiki, Põhja-Ameerika) 16/23 mükoriissed (~10–30%), 7/23 järjekindlalt mittemükoriissed; Cyperaceae üldiselt "ebajärjekindlalt mükoriisne" (Brundrett). Helictochloa pratensis: mingit andmestikku ei leidnud. FloraVeg.EU-l mükoriisa tunnust ei ole. Järeldus: oma mikroskoopiamõõtmine jääb nende kolme jaoks ainsaks usaldusväärseks teeks — ära kuluta veebiotsingule uuesti aega.
Tehniline võte: dplyr::rows_upsert() (mitte rows_update()).
Liigipõhised keskmised elupaiga kohta, iga liik võrdse kaaluga.
NB (21.08.2026): FungalRoot CSV-d asuvad lokaalselt (data/raw/FungalRoot/), mitte SharePointis — need on avaliku andmebaasi ühekordne, harva muutuv väljavõte, mitte kasutaja enda jooksvalt lisanduv välitöö andmestik. Seetõttu ei kasutata siin fetch_data.R / .Renviron / get_data() mustrit, mida kasutatakse SharePointi failide jaoks (Colonization, Traits, Quadrat, Biomass, MasterData) — teadlik ja põhjendatud erinevus, mitte ebajärjekindsus.
Esialgne tulemus: mets ~21.2% (n=7, pärast override'e), niit ~73.2% (n=17) — kooskõlas kirjandusega.
Infrastruktuur ja andmetorustik — seadistatud 2026 suvel
Andmete asukoht
SharePoint, kasutaja enda saidil (BioticNovelty-Mare, TÜ konto) — andmed olid algselt juhendaja kaustas, migreeritud kasutaja enda saidile (21.08.2026 paiku), et pipeline oleks stabiilne ja kasutaja täieliku kontrolli all ("minu projekt, minu kogutud andmed"). Juhendajale jagatud ligipääs samasse asukohta, nii et koostöö jätkub muutumatult. Turvalisuse kohta kontrollitud otse TÜ Wikist: SharePoint on TÜ IT poolt ametlikult soovitatud lahendus just sellise koostöö jaoks; ülikooliga seotud andmed peaksid pigem jääma ülikooli enda keskkondadesse kui kolmandate osapoolte teenustesse. Andmed (liigikatvused, kolonisatsiooni%, mullakeemia) pole isikuandmed, seega GDPR-tüüpi kaal puudub. Soovitus: hoolimata sellest, lisaks üks varukoopia väljaspool SharePointi (mitmeaastane kriitiline andmestik).
Kataloogipuu (MasterThesis/ saidi drive'i sees; Macis OneDrive'iga sünkitud kausta ~/Library/CloudStorage/OneDrive-SharedLibraries-TartuÜlikool/BioticNovelty-Mare - MasterThesis/):
  MasterThesis/
  ├── RawData/
  │   ├── Fieldwork/       (DistNet_MasterData/Traits/Quadrat/Colonization/Biomass.xlsx, Photos/)
  │   ├── Microscopy/      (Axiocam/, PhonePhotos_Roots/)
  │   └── ExternalDatabases/FungRoot/  (viide/allikas dokumenteeritud "Source"-tabina faili sees)
  ├── Docs/                (Magistritöö projekt.docx, Renviron.txt = .Renviron varukoopia, Review/ = juhendaja ülevaatuse docx-id)
  ├── Scratch/
  └── Archive/
Kaustanimedes vältida täpitähti ja tühikuid (encoding/git/cross-platform probleemid).
Fotode timestamp: usalda EXIF (R: exifr), mitte SharePointi "Modified date" (muutub üleslaadimisel).
SharePointi ligipääs R-ist (OneDrive'i sünk, alates 10.11.2026)
Muudatus (10.11.2026): Microsoft365R-i (Graph API) kaudu ligipääs EI TÖÖTA enam — TÜ Conditional Access blokeerib Microsoft365R rakenduse ("Your sign-in was successful but does not meet the criteria to access this resource"). Ei ole koodi viga, R-i poolt parandada ei saa. Lahendus: SharePointi teek on Macis sünkitud OneDrive'i rakendusega ja R kopeerib failid lokaalsest sünkkaustast. Tokeneid/sisselogimist pole vaja; OneDrive peab töötama.
Otsus (21.08.2026) kehtib edasi: üks generic get_data() funktsioon kõigi SharePointi failide jaoks, failiteed .Renviron-ist.

R/helpers/fetch_data.R:
- sp_local(rel_path) — sünkitud teegi täielik lokaalne tee (SHAREPOINT_LOCAL + suhteline tee).
- get_data(path_env_var, dest_prefix) — kopeerib faili data/raw/<dest_prefix>_<kuupäev>.xlsx ja tagastab selle tee.

Kasutus (clean_data.R või analyze.R sees, iga domeeni jaoks eraldi kutse):

r
raw_file <- get_data("SHAREPOINT_PATH_COLONIZATION", "colonization")
.Renviron (projekti juurkaustas, EI OLE git'is; varukoopia SharePointis Docs/Renviron.txt). Failiteed on suhtelised sünkitud teegi juure suhtes:

SHAREPOINT_SITE=BioticNovelty-Mare
SHAREPOINT_LOCAL=/Users/mare/Library/CloudStorage/OneDrive-SharedLibraries-TartuÜlikool/BioticNovelty-Mare - MasterThesis
SHAREPOINT_PATH_MASTER=RawData/Fieldwork/DistNet_MasterData.xlsx
SHAREPOINT_PATH_COLONIZATION=RawData/Fieldwork/DistNet_Colonization.xlsx
SHAREPOINT_PATH_QUADRAT=RawData/Fieldwork/DistNet_Quadrat.xlsx
SHAREPOINT_PATH_TRAITS=RawData/Fieldwork/DistNet_Traits.xlsx
(SHAREPOINT_PATH_BIOMASS veel lisamata; fail on RawData/Fieldwork/DistNet_Biomass.xlsx.)

.Renviron.example (LÄHEB git'i, placeholder-väärtustega) dokumenteerib samu muutujaid.
Miks eraldi .Renviron: peegeldab tavapärast .env-mustrit — täpne asukoht ei pea olema avalikult git'is nähtav. .Renviron loetakse ainult R-sessiooni alguses — pärast muutmist Session → Restart R (või readRenviron(here::here(".Renviron"))). NB: .Renviron kirjutab üle samanimelised shelli keskkonnamuutujad, s.t SHAREPOINT_LOCAL-i ei saa testimiseks käsurealt ümber suunata.

Ülevaatuse töövoog (R/helpers/review_sync.R, 11.11.2026):
- upload_review(local_file) kopeerib renderdatud docx-i sünkitud kausta Docs/Review/, nimega <nimi>_v<N>_<kuupäev>.docx (nt DistNet_thesis_v1_2026-11-11.docx; peatüki puhul eesliide "02-" kaob: metoodika_v1_...). Versioon valitakse automaatselt järgmine vaba; olemasolevat faili üle ei kirjutata. ./publish.sh kutsub selle iga kord välja (Mare otsus 11.11.2026), s.t iga avaldamine = uus versioon Review kaustas.
- Juhendaja kommenteerib Word Online'is.
- download_review() kopeerib viimati muudetud docx-i projekti kausta review/ (gitignore'itud).
- read_review(docx) teeb sellest markdowni (pandoc --track-changes=all Quarto pandoc'iga), kus jälgitud muudatused ja kommentaarid on alles. Parandused kantakse käsitsi .qmd faili; Mare otsust vajavad kommentaarid eraldi nimekirja.

Git / GitHub
Kohalik repo (git init, kaust nimega DistNet), push'itud GitHubi, avalik repo (andmed pole tundlikud, kasutaja teadlik otsus). SSH-autentimine töökorras — sama SSH-võti, mis on juba GitLabi jaoks olemas (~/.ssh/id_ed25519), lisatud lisaks GitHubi kontole. Kui ssh -T git@github.com annab "Permission denied", kontrolli võtme olemasolu (ls -la ~/.ssh) ja ssh-agent-is (ssh-add -l).
.gitignore: suured/genereeritud/tundlikud failid välja (data/raw/*, data/processed/*, _site/, .quarto/, renv/library/, .Rproj.user/, .Rhistory, .DS_Store, .Renviron) — git hoiab koodi, SharePoint andmeid, .Renviron konfiguratsiooni (site nimi + failiteed, vt "SharePointi ligipääs R-ist"). .Renviron.example (placeholder-väärtustega) LÄHEB git'i.
Projekti kaustastruktuur
DistNet/
├── R/
│   ├── helpers/
│   │   ├── fetch_data.R    # get_data(path_env_var, dest_prefix), sp_local() — kopeerib sünkitud SharePointi kaustast
│   │   ├── join_master.R   # rings+plants+species liitmine domeenifailidega
│   │   ├── clean_data.R    # puhastus, valideerimine, CSV väljund (nt clean_masterdata())
│   │   └── review_sync.R   # upload_review(), download_review(), read_review() — juhendaja ülevaatus
│   ├── CWM.R               # naabruse CWM (AM %) kvadraadi liigiridadest + habitat × treatment mudel
│   ├── quadrat_cover.R     # kvadraatide katvus ja liigid severed vs control
│   └── analyze.R           # mudelid, statistika — kasutab helpereid, ei tea/hooli päritolust
├── data/{raw,processed}/   # mõlemad gitignore'itud
├── report/
│   ├── thesis/             # lõplik magistritöö, Quarto book (eesti keeles), vt "Lõputöö struktuur" allpool
│   └── blog/                # eraldi Quarto website, vt "Quarto blogi" allpool
├── figures/
├── docs/                   # Claude_README.md (see fail), markmed.md (lahtised teemad), handoff.md
├── review/                 # juhendaja docx-id + markdown, gitignore'itud
├── .gitignore, .Renviron (gitignore'itud), .Renviron.example, renv.lock, .here
└── README.md
Otsus (21.08.2026): andmetorustiku "tehniline pool" (fetch/join/clean) liigutatud R/helpers/ alamkausta, eristamaks selgelt utility-koodi (kuidas andmed tekivad) sisulisest analüüsikoodist (R/analyze.R). Muudatus tehtud Claude Code kaudu, otse projektis. source() viited kasutavad nüüd läbivalt here::here("R", "helpers", "..."), mitte suhtelist "R/..." teed — sõltumatu sellest, millisest kaustast käsku käivitatakse.

Kasutus analyze.R (ja Quarto blogi postituste) sees:

r
source(here::here("R", "helpers", "clean_data.R"))
colonization <- clean_masterdata(get_data("SHAREPOINT_PATH_COLONIZATION", "colonization"))
here pakett
here::here("data", "processed", ...) suhteliste teede asemel. NB: tühi .here fail projekti tegelikus juurkaustas, kui here() valib vale root'i (nt kui alamkaustas on oma _quarto.yml).

renv
renv::init() ühekordselt, snapshot() uute pakettide järel, restore() taastamiseks. library(...) ikka iga skriptis eraldi vajalik (renv haldab ainult installatsiooni, mitte kasutust).

Andmetorustiku loogika (fetch → clean → analyze)
fetch_data.R: get_data(path_env_var, dest_prefix) — generic funktsioon (vt "SharePointi ligipääs R-ist"), kopeerib sünkitud kaustast, tagastab selgesõnaliselt (return()) failitee stringi. Kutsutakse eraldi iga domeeni jaoks (colonization, traits, quadrat, master, biomass).
clean_data.R: kontrolli sheet= nimi excel_sheets()-ga enne lugemist, clean_names(), eemalda tühjad/duplikaatread, teisenda tüübid (mutate()-s =, mitte <-), vali lõpuks select()-iga ainult analüüsis vajaminevad veerud (mitte kõik, mis Excelis olid — hoiab väljundi struktuuri stabiilsena, kui workbook kasvab), valideeri stopifnot()-iga.
NA väärtused (osad mikroskoopia slaidid veel lugemata, nt arb/ves/hyp veerud) teadlikud ja oodatud, jäetud teadlikult nähtavale (hoiatused ei ole vaigistatud) — lm() käsitleb vaikimisi (na.omit), kontrolli nobs() vs nrow(), kui palju ridu reaalselt mudelisse jõudis.
CSV ei säilita R-i tüüpe (Positroni data-viewer näitab kõike "varchar"-ina) — CSV formaadi piirang, mitte viga; R-i sees on tüübid mutate() kaudu õigesti määratud.
Peamine andmeobjekti nimi analüüsis: colonization (mitte data/data_clean — liiga lakoonilised/kattuvad base R funktsiooniga).
analyze.R ei tõmba iga kord SharePointist uuesti — kontrollib esmalt, kas puhastatud CSV juba eksisteerib:
r
  if (!file.exists("data/processed/colonization.csv")) {
    source(here::here("R", "helpers", "clean_data.R"))
  }
  library(readr)
  colonization <- read_csv(here::here("data", "processed", "colonization.csv"))
Analüüsi (analyze.R) ja avaldamise (Quarto blog, vt allpool) vaheline koodikordus (mudeli-kood mõlemas kohas) on WIP-faasis teadlikult aktsepteeritud (paindlikkus katsetamiseks) — kui mudel stabiliseerub, kaaluda mudeli-loogika tõstmist eraldi funktsiooniks (nt R/models.R), mida kutsutakse mõlemast kohast.
Praegune baasmudel, esimesed tulemused (21.08.2026): lm(log_total ~ habitat * treatment + species, data = colonization) — jooksutatud edukalt, n=44 (13 vaatlust NA tõttu välja jäetud), R² = 0.60. Esialgne, WIP.
Lõputöö struktuur (report/thesis/, Quarto book, 11.11.2026)
report/thesis/
├── _quarto.yml           # project type: book; lang: et; docx + html; reference-doc/csl veel lisamata
├── index.qmd             # annotatsioon + abstract (nummerdamata)
├── 01-sissejuhatus.qmd
├── 02-metoodika.qmd      # sh alapeatükk 2.4 = {{< include _kasvunaitajad.qmd >}}
├── _kasvunaitajad.qmd    # Traits'i metoodika; alakriips = Quarto ei renderda eraldi
├── 03-tulemused.qmd      # põhi (märksõnad)
├── 04-arutelu.qmd        # põhi (märksõnad)
├── 05-kokkuvote.qmd      # põhi
├── references.qmd        # "Kasutatud kirjandus" ({#refs})
└── references.bib
Renderdamine: cd report/thesis && quarto render (html) / quarto render --to docx → _book/DistNet_thesis.docx. Juhendajale saatmine: vt "Ülevaatuse töövoog".

Quarto blogi / vahetulemuste avaldamine (GitHub Pages)
Otsus (21.08.2026): jooksva juhendajaga suhtluse/vahetulemuste jagamiseks kasutatakse Quarto website (blogi-tüüpi) projekti, mitte üksikuid dokumente — iga vahetulemus oma kuupäeva-pealkirjaga postitusena, esilehel automaatne kronoloogiline nimekiri (nagu tavaline blogi). Avaldatakse GitHub Pages'i kaudu, kuna repo on juba avalik ja andmed pole tundlikud (kasutaja on SharePointi suhtes pigem negatiivne, "jälestab", aga saab sellega hakkama — GitHub Pages on mugavam avaldamiseks).

Struktuur — eraldi Quarto-projekt (report/blog/), erinev report/thesis/ book-projektist (lõplik magistritöö), et need omavahel segi ei läheks:

report/blog/
├── _quarto.yml       # project type: website, brand: _brand.yml, robots: noindex
├── _brand.yml        # logo/favicon (peab olema _quarto.yml's selgesõnaliselt viidatud)
├── index.qmd          # esileht, listing: contents: posts, sort: date desc
└── posts/
    └── YYYY-MM-DD-postituse-nimi/
        └── index.qmd  # üks fail: YAML + tekst + R-koodiplokid koos
Avaldamine:

bash
cd report/blog
quarto publish gh-pages
Renderdab kogu saidi (kõik postitused + esilehe) ja push'ib gh-pages branch'i — see on eraldi branch renderdatud HTML-i jaoks, main branch hoiab ainult lähtekoodi (qmd failid). _site/ ja .quarto/ (lokaalsed renderdamise vahefailid) on .gitignore-is.

robots: noindex _quarto.yml-is — teadlik valik: andmed/tulemused tohivad olla avalikud (kasutaja pole mures, kui keegi "varastaks" kolonisatsiooniprotsente), aga pole vajadust, et esialgsed WIP-tulemused aktiivselt Google'i otsingusse kerkiksid.

Külmutatud vs elav andmeseis (lahtine otsustamiskoht, 21.08.2026): kuna postitused peaksid ideaalis olema "ajapildid" (näitama seisu, mille peal konkreetne postitus tehti), mitte muutuma tagantjärele järgmisel quarto publish-il, kui andmed vahepeal uuenevad — kaalutakse clean_data.R väljundi kuupäevastamist (colonization_YYYY-MM-DD.csv) ja iga postituse setup plokis viidataks käsitsi konkreetsele kuupäeva-failile, mitte üldnimelisele "viimasele" CSV-le. Lõplik lahendus veel rakendamata — kui uus chat seda teemat jätkab, kontrolli esmalt, kas see otsus on vahepeal tehtud.

Tehnilised nüansid, mis ette tulid:

.here tühi fail on kohustuslik projekti tegelikus juurkaustas (DistNet/.here) — ilma selleta valib here() ekslikult root'iks blog/ kausta (kuna seal on oma _quarto.yml), mitte projekti tegelikku tippu. Ei tohi kustutada.
Pipe operaator (%>%) qmd koodiplokkides vajab library(dplyr) eraldi (broom üksi ei anna %>%) või kasutada base R |>.
yaml R-pakett vajalik Quarto sõltuvuste parsimiseks (install.packages("yaml") + renv::snapshot()), aga ei kuulu ühtegi konkreetsesse skripti — Quarto/knitr kasutab seda taustal.
Google Photosi otsest embedimist Quarto/GH Pages lehele ei ole ametlikult toetatud, kolmanda osapoole generaatorid töötaksid, aga ebastabiilsed pikaajaliselt — praegu ei ole ette võetud (väliandmete fotod on hetkel Google Photosis, mitte SharePointis).
GitHub Pages üldiselt (taustateadmine)
Piiramatu arv avalikke saite/reposid lubatud (iga repo saab oma Pages'i), piirangud (1GB suurus, 100GB bandwidth/kuu, 10 build'i tunnis) kehtivad repo kohta eraldi, mitte kokku. Kasutajal on lisaks DistNetile veel kaks "iidvana" Jekyll-põhist projekti serverist väljas (arendusteekonna/bash-õppimise päevik ja maja ehituse päevik) — potentsiaalselt taaselustatavad samal põhimõttel, kuid see on hetkel ainult teadmine tagataskus, mitte ette võetud tegevus.

Kasutaja töövahendite ja koostöö-eelistused
Homebrew (kõik tööriistad brew kaudu, sh brew install --cask claude-code, kui kunagi vajalikuks osutub).
Kasutab alates 11.2026 Claude Code'i (repo failide muutmine, render, testid) koos Claude'i desktop-äpiga (pikemad arutelud). Ülesanded antakse üle failiga docs/handoff.md; lahtised teemad docs/markmed.md.
Positroni integreeritud terminal = tavaline zsh, sh Homebrew PATH.
Mitu eraldi Claude.ai Projekti (DistNet, orhideed, shibad, UX disain) — teadlikult lahus hoitud, kontekstid ei tohiks seguneda. Iga Projekt omab eraldi mälu-ruumi. suhtlusstiili eelistus (lakooniline) kehtib pigem üldiselt (Settings → user preferences), mitte projektipõhises mälus.
Claude'i "Search past chats" / mälu funktsioon sisse lülitatud (21.08.2026) — kasutaja teadlik, et see genereerub taustal järk-järgult, mitte kohe reaalajas; ei salvesta seda ise kuhugi käsitsi.
Suhtlusstiil: lakooniline, otsekohene, ei talu üleliigset emotsionaalset ballasti või komplimentide vahetust.
Excel on kasutajal vanem versioon: XLOOKUP ja ilmselt LET ei tööta — kasuta INDEX/MATCH (SWITCH töötab). Eestikeelses Excelis on funktsioonide nimed ja eraldaja (;) lokaliseeritud.
Oluline piirang, mida iga uus chat peab teadma
Claude'i sessioonid ei jaga vestluste ajalugu omavahel — uus chat näeb ainult seda, mis on kirjutatud projekti dokumenti (ja "Search past chats" funktsiooni kaudu, kasutaja sisse lülitatud 2026 augustis, aga taustaprotsess võtab aega). Kõik peatükkidevaheliselt olulised otsused kuuluvad siia. Kuna mitu chatti võivad seda faili muuta ja project_write kirjutab kogu faili üle (pole partial patch), tee alati project_read vahetult enne kirjutamist — muidu kaob kergesti mõne teise chati hiljutine lisandus (nagu juba kord juhtus: 21.08 lisatud "loomulik senesents" märkus ja see hoiatuslause ise kadusid korraks ühe suurema infrastruktuuri-uuenduse käigus, kuni 04.09 taastati).

Soovitus uue analüüsi-teemalise chati alustamiseks: setup/pipeline (see dokument) ja tegelik statistiline analüüs on eraldiseisvad teemad — tee analüüs eraldi vestluses. Alguses korda lühidalt: DistNet projekt, AMF kolonisatsioon niidu-/metsataimedel, habitat × treatment (severed/ control/reference) eksperiment, andmestiku struktuur (5 eraldi faili: MasterData/Traits/Quadrat/Colonization/Biomass, liitumine plant_id/ring_id kaudu; Biomass-i hunniku-ridu liita ring_id + species + focal kaudu, mitte plant_id kaudu), praegune baasmudel: lm(log_total ~ habitat * treatment + species, data = colonization).

Kasutaja eelistused (üldised, kehtivad kõikjal)
Eestikeelne tekst magistritöösse; ingliskeelsed R-koodi kommentaarid.
Töövorming: Quarto, mitte Word.
Failinimedes/kaustastruktuuris vältida täpitähti ja tühikuid.
Andmete "kodu" (SharePoint) ja koodi "kodu" (git) hoitakse lahus.
Andmehügieen: ei kustuta kunagi surnud/ebaõnnestunud ridu (taimed, liigid) — dokumenteeri kõrvalekaldena note-veeruna, mitte kustuta.
