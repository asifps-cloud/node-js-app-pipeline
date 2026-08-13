pipeline {
  agent {
    docker {
        image 'jenkins-node-sonar'
        args '--group-add 110 -v /var/run/docker.sock:/var/run/docker.sock'
    }
}
  stages {
    stage('Checkout') {
      steps {
        sh 'echo "Starting build process..."'
      }
    }
    stage('Build and Test') {
    steps {
        sh '''
            export HOME="$WORKSPACE"
            export npm_config_cache="$WORKSPACE/.npm"

            cd node-app
            npm ci
            npm test
        '''
    }
}
    
    stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('SonarQube') {
            sh '''
                cd node-app

                sonar-scanner \
                    -Dsonar.projectKey=node-express-app \
                    -Dsonar.projectName="Node Express App" \
                    -Dsonar.sources=. \
                    -Dsonar.exclusions=node_modules/*,coverage/*
            '''
        }
    }
}

    stage('Build and Push Docker Image') {
      environment {
        DOCKER_IMAGE = "asifpsdocker/ultimate-cicd:${BUILD_NUMBER}"
      }
      steps {
        script {
            sh 'docker build -t ${DOCKER_IMAGE} node-app'
            def dockerImage = docker.image("${DOCKER_IMAGE}")
            docker.withRegistry('https://index.docker.io/v1/', "docker-cred") {
                dockerImage.push()
                dockerImage.push("latest")
            }
        }
      }
    }

    stage('Update Deployment File') {
      environment {
        GIT_REPO_NAME = "node-js-app-pipeline"
        GIT_USER_NAME = "asifps-cloud"
      }
      steps {
       withCredentials([
    string(
        credentialsId: 'github',
        variable: 'GITHUB_TOKEN'
    )
]) {
            sh '''
                rm -rf repo-temp
                git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME}.git repo-temp
                cd repo-temp
                
                git config user.email "asifdua7@gmail.com"
                git config user.name "${GIT_USER_NAME}"

                sed -i "s|image: .*|image: asifpsdocker/ultimate-cicd:${BUILD_NUMBER}|g" node-app-manifests/deployment.yml

                git add node-app-manifests/deployment.yml
                git commit -m "Update static site image tag to ${BUILD_NUMBER} [skip ci]" || echo "No changes to commit"
                git push origin master
            '''
        }
      }
    }
  }
}
