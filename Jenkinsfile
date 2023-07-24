pipeline {
  agent any
  triggers {
      pollSCM('H/2 * * * *')
  }
  tools {
    maven 'Maven_3'
    git 'Git'
  }
  environment {
    DOCKERHUB_CREDS = 'docker_credentials'
    DOCKER_IMAGE = 'mohammadrony/java-library-app'
    REGISTRY = 'registry.hub.docker.com'
  }

  stages {
    stage('Git Clone') {
      steps {
        echo 'Pulling repository'
        git branch: 'kubernetes',url: 'https://github.com/mohammadrony-bjit/library-management-system.git'
      }
    }

    stage('Build Artifact') {
        steps {
            echo 'Constructing artifact'
            sh 'mvn clean package'
        }
    }

    stage('Build Container Image') {
      steps {
        script {
          app_image = docker.build("${REGISTRY}/${DOCKER_IMAGE}")
        }
      }
    }
    stage('Publish Docker Image') {
      steps {
        script {
          docker.withRegistry("https://${REGISTRY}", DOCKERHUB_CREDS) {
            app_image.push("${BUILD_NUMBER}")
            app_image.push('latest')
          }
        }
      }
    }

    stage('Remove Image from Local') {
      steps {
        script {
          sh "docker rmi ${REGISTRY}/${DOCKER_IMAGE}:latest"
          sh "docker rmi ${REGISTRY}/${DOCKER_IMAGE}:${BUILD_NUMBER}"
        }
      }
    }

    stage('Deploy App in Kubernetes') {
      steps {
        withKubeConfig(credentialsId: 'kubeconfig', serverUrl: '') {
            echo 'Creating config map and secrets'
            sh '/usr/local/bin/kubectl apply -f 1-app-config-and-secret.yml'

            echo 'Creating storage for mysql'
            sh '/usr/local/bin/kubectl apply -f 2-mysql-pv-pvc.yml'

            echo 'Creating mysql pod and service'
            sh '/usr/local/bin/kubectl apply -f 3-mysql-deploy-service.yml'

            sleep(30)
            echo 'Creating java app deployments'
            sh 'sed -i "s/\\${BUILD_NUMBER}/${BUILD_NUMBER}/" 4-java-app-deploy.yml'
            sh '/usr/local/bin/kubectl apply -f 4-java-app-deploy.yml'
        }
      }
    }
  }
}
