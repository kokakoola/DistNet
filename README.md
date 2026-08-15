
## file path Sharepointis:
drv$list_items(path = "Mare")                              # peaks näitama MasterThesis. 
drv$list_items(path = "Mare/MasterThesis")                  # peaks näitama RawData, Docs, Scratch, Archive. 
drv$list_items(path = "Mare/MasterThesis/RawData")           # peaks näitama Fieldwork, Microscopy, ExternalDatabases. 
drv$list_items(path = "Mare/MasterThesis/RawData/Fieldwork")  # peaks näitama DistNet_MasterData.xlsx. 

## renv - package manager
konsoolis. 
renv::snapshot()   # käivitad käsitsi, kui oled lisanud/uuendanud pakette. 
renv::restore()    # käivitad, kui avad projekti teises arvutis/pärast pausi. 

# blogi
konsoolis:   
quarto preview. 
quarto add ext quarto-ext/quarto-blog. 
quarto publish gh-pages. 