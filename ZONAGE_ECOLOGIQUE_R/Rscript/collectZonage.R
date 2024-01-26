# Chargement des librairies
if(!require("rstudioapi")){install.packages("rstudioapi")} ; library("rstudioapi")
if(!require("sf")){install.packages("sf")} ; library("sf")
if(!require("rgdal")){install.packages("rgdal")} ; library("rgdal")
if(!require("utils")){install.packages("utils")} ; library("utils")

# Choix du dossier de travail
WD = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(WD)

repertoir_shp = "../../ZONAGE_ECOLOGIQUE_QGIS/DATAworkflow"
# URL du fichier ZIP contenant le Shapefile
url_zip <- "https://inpn.mnhn.fr/docs/Shape/znieff1.zip"

# Nom du fichier ZIP
nom_zip <- basename(url_zip)

# Télécharger le fichier ZIP
download.file(url_zip, destfile = file.path(repertoir_shp, nom_zip), mode = "wb")

# Décompresser le fichier ZIP
unzip(file.path(repertoir_shp, nom_zip), exdir = repertoir_shp)

# Identifier le fichier Shapefile dans le répertoire décompressé
fichier_shp <- list.files(repertoir_shp, pattern = "\\.shp$", full.names = TRUE)

# Charger le Shapefile en tant que couche sf
couche_sf <- st_read(fichier_shp)

# Supprimer le fichier ZIP après décompression
file.remove(file.path(repertoir_shp, nom_zip))

#Création d'un objet SIG
points_sf  = st_as_sf(couche_sf, coords = c("x", "y"))


# Créer un GeoPackage vide
gpkg <- st_write(points_sf, "../../ZONAGE_ECOLOGIQUE_QGIS/Gpkg/fullfile.gpkg", driver = "GPKG", layer = "nom_de_la_couche")

# Charger les fichiers Shapefile
chemin_shp1 <- "chemin/vers/shapefile1.shp"
chemin_shp2 <- "chemin/vers/shapefile2.shp"

# Lire les fichiers Shapefile en tant que couches sf
couche_sf1 <- st_read(chemin_shp1)
couche_sf2 <- st_read(chemin_shp2)

# Ajouter les couches au GeoPackage
st_write(couche_sf1, gpkg, layer = "nom_de_la_couche1", driver = "GPKG", append = TRUE)
st_write(couche_sf2, gpkg, layer = "nom_de_la_couche2", driver = "GPKG", append = TRUE)

# Fermer le GeoPackage
st_close(gpkg)


# Installer le package si ce n'est pas déjà fait
# install.packages("gdalUtils")

# Charger les packages
library(gdalUtils)

# Chemin vers le GeoPackage
chemin_geopackage <- "chemin/vers/mon_geopackage.gpkg"

# Chemin vers les fichiers QML
chemin_qml1 <- "chemin/vers/style1.qml"
chemin_qml2 <- "chemin/vers/style2.qml"

# Appliquer les styles QML aux couches dans le GeoPackage
gdalUtils::ogr2ogr(
  dst_dataset = chemin_geopackage,
  src_dataset = chemin_geopackage,
  update = TRUE,
  sql = paste0("OGR_STYLE='", chemin_qml1, "' WHERE layer='nom_de_la_couche1'"),
  quiet = FALSE
)

gdalUtils::ogr2ogr(
  dst_dataset = chemin_geopackage,
  src_dataset = chemin_geopackage,
  update = TRUE,
  sql = paste0("OGR_STYLE='", chemin_qml2, "' WHERE layer='nom_de_la_couche2'"),
  quiet = FALSE
)

