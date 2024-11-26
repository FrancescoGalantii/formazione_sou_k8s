# spiegazione del jenkinsfile passo passo
1)pipeline {} definisce i vari blocchi di configurazione: agent, environment, stages, post.

2)agent any specifica che questa pipeline può essere eseguita su qualsiasi nodo disponibile in jenkins.

3)environment {..} definisce le variabili d'ambiente globali usate nella pipeline accessibili in tutte le stages.

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        DOCKER_REGISTRY = 'localhost:5000'
        IMAGE_NAME = "francescogalanti/flask-app-example"
spiegazione variabili d'ambiente:

- DOCKERHUB_CREDENTIALS variabile di ambiente che identifica le credenziali dockeruhub

- DOCKER_REGISTRY, specifica l'indirizzo del registry locale di default localhost:5000

- IMAGE_NAME nome dell'immagine docker.

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

# modifiche aggiuntive
in seguito agli step precedenti ho aggiunto un nuovo jenkinsfile

- Jenkinsfile_depoly

ho creato questa pipeline al fine di effettuare l' helm install sull'istanza k8s locale.
# spiegazione Jenkinsfile_deploy 
spiegazione variabili d'ambiente:

- GIT_REPO_URL identifica l'url del repository contentente il chart versionato
- GIT_BRANCH il branch sul quale si trova
- CHART_NAME il nome del chart
- RELEASE_NAME identifica le release creata
- NAMESPACE specifica il namespace sul quale devo effettuare l'helm install

# spiegazione stages
Nel primo stage sono andato semplicemente a clonare il repository passandogli branch e url richiamando le variabili d'ambiente.

- "${GIT_BRANCH}"
- "${GIT_REPO_URL}"

Nel secondo stage invece ho esportato il KUBECONFIG passandogli il path del config interno al container jenkins

    export KUBECONFIG=/var/jenkins_home/.kube/config
Seguendo poi con l'helm install 

    helm upgrade --install flask-app-example charts --namespace ${NAMESPACE} --set image.tag=latest
dove ho passato:

- nome dell'applicazione,
- il percorso del charts,
- il namespace richiamando la variabile d'ambiente definita in precedenza ${NAMESPACE},
- assegnandogli il tag latest poichè situata sul branch main.
