# spiegazione del jenkinsfile passo passo
1)pipeline {} definisce i vari blocchi di configurazione: agent, environment, stages, post.
2)agent any specifica che questa pipeline può essere eseguita su qualsiasi nodo disponibile in jenkins.
3)environment {..} definisce le variabili d'ambiente globali usate nella pipeline accessibili in tutte le stages.

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        DOCKER_REGISTRY = 'localhost:5000'
        IMAGE_NAME = "francescogalanti/flask-app-example"
spiegazione variabili d'ambiente:
-->DOCKERHUB_CREDENTIALS variabile di ambiente che identifica le credenziali dockeruhub
-->DOCKER_REGISTRY, specifica l'indirizzo del registry locale di default localhost:5000
-->IMAGE_NAME nome dell'immagine docker.

4)checkout scm, permette di clonare il repository 

5)stage('Set Docker Image Tag'), crea il tag dell'immagine docker:

    def branch = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim() 
    --> permette di ottenere il branch corrente salvando l'output nella variabile branch e rimuovendo spazi o altro con          trim in modo da avere solo il branch nell'output
    def sha = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    --> che ottiene i primi 7 caratteri dell' hash del commit attuale
    def tag = 'latest'
    --> variabile locale usata per costruire il tag dell' immagine docker
    
Lo stage('Build Docker Image'), questo stage costruisce l'immagine docker usando la funzione docker.build() messa a disposizione dal plugin Docker di jenkins che ho installato manualmente dalla dashboard
--> in questo stage e nel successivo ho aggiunto il blocco try-cache per avere un output più chiaro e capire dove si trova l'errore

    } catch (Exception e) {
       error "Docker build failed: ${e.message}"
6)stage(docker push), pusha l' immagine, anche in questo caso ho aggiunto un blocco try-cache
7)il post finale invece permette di eseguire delle operazioni in questo caso una pulizia della workstation

    post {
        always {
            cleanWs()
        }
    }
