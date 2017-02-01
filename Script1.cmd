docker run -it azuresdk/azure-cli-python:latest

az login

az group create -n tcd2017 -l "westeurope"

az acs create -n tcd-cluster -g tcd2017 -d tcdlnk01 --generate-ssh-keys

az acs list --output table

# Estrarre dal container la parte pubblica e privata della chiave ssh generata
docker cp CONTAINER:/root/.ssh/id_rsa id_rsa
docker cp CONTAINER:/root/.ssh/id_rsa.pub id_rsa.pub

# Convertire con la funzione import di PuTTYgen 
# leggendo la chiave privata id_rsa e salvandola
# come id_rsa.ppk così da renderla utilizzabile da plink.
plink azureuser@tcdlnk01mgmt.westeurope.cloudapp.azure.com -A -P 2200 -ssh -C -i id_rsa.ppk
# Creare un tunnel tra lo swarm in esecuzione per presentare alla cli
# locale la porta di comunicazione con lo swarm manager.
plink azureuser@tcdlnk01mgmt.westeurope.cloudapp.azure.com -A -P 2200 -ssh -C -i id_rsa.ppk -L 2376:localhost:2375 -N
plink azureuser@tcdlnk01mgmt.westeurope.cloudapp.azure.com -A -P 2200 -ssh -C -i id_rsa.ppk -L 80:localhost:32849 -N

# Scaricare la versione compatibile con lo swarm:
Invoke-WebRequest https://get.docker.com/builds/Windows/x86_64/docker-1.11.2.zip -UseBasicParsing -OutFile docker.zip

# Decomprimere in una cartella 
Expand-Archive docker.zip -DestinationPath .

# Verificare la versione del remote API client presente nella cli
.\docker\docker.exe version

# Usare la cli per avere informazioni sullo swarm
.\docker\docker.exe -H 127.0.0.1:2376 info

# Installare Magento2:
cd docker-magento2
docker-compose -H 127.0.0.1:2376 run cli bash
..\docker\docker.exe -H 127.0.0.1:2376 start --attach --interactive dockermagento2_cli_run_1
cd /var/www/magento
magento-installer

# Eseguire Magento2:
docker-compose -H 127.0.0.1:2376 up -d

# URL repository versioni Docker Engine
# https://github.com/docker/docker/tags

# URL Repository materiale TDC2017
# https://github.com/giulianolatini/TDC2017

# URL Repository Magento
# https://github.com/meanbee/docker-magento2

# URL Gist per Q&A su questo talk
# https://gist.github.com/giulianolatini/181e57732aef9f388d2403b4208c8d2f
