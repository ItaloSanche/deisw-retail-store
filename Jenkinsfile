pipeline {
    agent any

    environment {
        REGISTRY_USER = "italo750"
        IMAGE_NAME = "retail-store-u202316967"
        TAG = "v1"
        SONARQUBE_ENV = "MiSonarServer"
    }

    stages {

        //  ELIMINADO: stage('1. Checkout')
        // Jenkins ya hace el checkout automáticamente desde SCM

        stage('1. Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('2. Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('3. SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('4. Quality Gate') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('5. Build & Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'DOCKER_HUB_CREDENTIALS',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    script {
                        sh """
                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                        
                        docker buildx create --use || true
                        
                        docker buildx build \
                        --platform linux/amd64 \
                        -t ${REGISTRY_USER}/${IMAGE_NAME}:${TAG} \
                        -t ${REGISTRY_USER}/${IMAGE_NAME}:latest \
                        --push .
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo " Pipeline ejecutado correctamente"
        }
        failure {
            echo "Pipeline falló"
        }
    }
}
