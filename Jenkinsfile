pipeline {
  agent any
  triggers {
      pollSCM 'H * * * *'
  }
  tools {
    maven "MAVEN_3"
  }
  environment {
    registryCredential = ''
    DOCKER_IMAGE = 'mohammadrony/java-library-app'
  }
  
  stages {
    stage('Git clone') {
      steps {
        echo 'Pulling repository'
        git branch: 'kubernetes',url: 'https://github.com/mohammadrony-bjit/library-management-system.git'
      }
    }
    
    stage('Build artifact') {
        steps {
            echo 'Constructing artifact'
            sh 'mvn clean package'
        }
    }

    stage('Building image') {
      steps {
        script {
          // Build the Docker image
          app_image = docker.build(DOCKER_IMAGE)
        }
      }
    }
    stage('Push Docker Image') {
      steps{
        script {
          docker.withRegistry('https://registry.hub.docker.com', docker_credentials) {
            app_image.push("${env.BUILD_NUMBER}")
            app_image.push("latest")
          }
        }
      }
    }
    stage('Remove Unused docker image') {
      steps{
        sh "docker rmi ${DOCKER_IMAGE}:latest"
        sh "docker rmi ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
      }
    }
    // stage("Deploy container"){
    //   steps{
    //     script {
    //       echo "Creating config map and secrets"
    //       sh '/usr/local/bin/kubectl apply -f 1-app-config-and-secret.yml'
    //     }
    //   }
    // }
  }
}
