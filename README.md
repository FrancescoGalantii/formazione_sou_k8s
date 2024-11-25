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
# spiegazione Jenkinsfile_depoly 
spiegazione variabili d'ambiente:

- GIT_REPO_URL identifica l'url del repository contentente il chart versionato
- GIT_BRANCH il branch sul quale si trova
- CHART_NAME il nome del chart
- RELEASE_NAME
- NAMESPACE specifica su quale namespace devo effettuare l'helm install

# spiegazione stages
Nel primo stage sono andato semplicemente a clonare il repository passandogli branch e url richiamando le variabili d'ambiente.

Nel secondo stage invece ho esportato il KUBECONFIG passandogli il path del container

    export KUBECONFIG=/var/jenkins_home/.kube/config
Ho poi utilizzato il token creato successivamente alla creazione di un service account che ho sfruttato per far si che jenkins riuscisse a comunicare con il cluster minikube che di default isola tutto localmente.

Ho proceduto alla creazione del service account con kubectl e con namespace formazione-sou creato in precedenza

    kubectl create serviceaccount jenkins-sa -n formazione-sou
ho poi creato autonomamente il secret poiche le ultime versioni di kubernetes non lo creano più in automatico alla creazione del serviceaccount 

    kubectl create secret generic jenkins-sa-token \
    --namespace formazione-sou \
    --type kubernetes.io/service-account-token \
    --from-literal=extra=extra \
    --dry-run=client -o yaml | \
    kubectl annotate --local -f - kubernetes.io/service-account.name=jenkins-sa -o yaml | \
    kubectl apply -f -
per poi estrarlo con il seguente comando 

    kubectl get secret jenkins-sa-token -n formazione-sou -o yaml
# come usare il token?
una volta creato il service account e dopo aver estratto il token bisogna andare sulla dashboard di jenkins e aggiungerlo come nuova credenziale.
