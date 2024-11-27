import subprocess
#import yaml
import sys

def get_deployment_yaml(deployment_name, namespace):
    try:
        result = subprocess.run(
            ["kubectl", "get", "deployment", "flask-app-example-deployment", "-n", "formazione-sou", "-o", "yaml"],
            check=True,
            capture_output=True,
            text=True
        )
        return yaml.safe_load(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Errore nell'ottenere il Deployment: {e.stderr}")
        sys.exit(1)

def check_probes_and_resources(deployment_yaml):
    try:
        container = deployment_yaml["spec"]["template"]["spec"]["containers"][0]
    except (KeyError, IndexError):
        print("Errore: il Deployment non ha un container configurato correttamente.")
        sys.exit(1)
    
    errors = []
  
    if "livenessProbe" not in container:
        errors.append("livenessProbe mancante.")

    if "readinessProbe" not in container:
        errors.append("readinessProbe mancante.")

    resources = container.get("resources", {})
    if "limits" not in resources:
        errors.append("limits mancante nelle risorse.")
    if "requests" not in resources:
        errors.append("requests mancante nelle risorse.")
    
    if errors:
        print("Errori trovati nel Deployment:")
        for error in errors:
            print(f"- {error}")
        sys.exit(1)
    else:
        print("Tutte le configurazioni richieste sono presenti nel Deployment.")

def main():
    deployment_name = "flask-app-example-deployment"
    namespace = "formazione-sou"
    
    print(f"Eseguo l'export del Deployment '{flask-app-example-deployment}' nel namespace '{formazione-sou}'...")
    deployment_yaml = get_deployment_yaml(flask-app-example, formazione-sou)
    
    print("Verifico la presenza di livenessProbe, readinessProbe, limits e requests...")
    check_probes_and_resources(deployment_yaml)

if __name__ == "__main__":
    main()

