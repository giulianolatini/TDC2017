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

# Scarico la versione compatibile con lo swarm:
Invoke-WebRequest https://get.docker.com/builds/Windows/x86_64/docker-1.12.0.zip -UseBasicParsing -OutFile docker.zip