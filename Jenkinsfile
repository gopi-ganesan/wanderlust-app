pipeline {
    agent any

    environment {
        AWS_REGION      = 'us-east-1'
        AWS_ACCOUNT_ID  = '940521993730'
        ECR_REPOSITORY  = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        FRONTEND_REPO   = 'wanderlust-frontend'
        BACKEND_REPO    = 'wanderlust-backend'

        IMAGE_TAG       = 'v1'
        
    }

    stages {

        stage('Git Clone') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/gopi-ganesan/wanderlust-app.git',
                    credentialsId: 'github-creds'
            }
        }

        stage('SonarQube Scan') {
            steps {
                script {
                    def scannerHome = tool 'sonar-qube-scanner'
                    withSonarQubeEnv('sonarqube') {
                        withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                            sh """
                                ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=wenderlus \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=http://50.19.76.89:9000 \
                                -Dsonar.login=${SONAR_TOKEN}
                            """
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                dir('devops-project-o2') {
                    sh '''
                        docker build -t wanderlust-frontend:v1 ./frontend
                        docker build -t wanderlust-backend:v1 ./backend
                    '''
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                    trivy image --severity HIGH,CRITICAL \
                    --format table \
                    --output frontend-trivy-report.txt \
                    --no-progress wanderlust-frontend:v1

                    trivy image --severity HIGH,CRITICAL \
                    --format table \
                    --output backend-trivy-report.txt \
                    --no-progress wanderlust-backend:v1
                '''

                archiveArtifacts artifacts: '*trivy-report.txt'

                sh '''
                    trivy image --severity HIGH,CRITICAL \
                    --exit-code 1 \
                    --no-progress wanderlust-frontend:v1

                    trivy image --severity HIGH,CRITICAL \
                    --exit-code 1 \
                    --no-progress wanderlust-backend:v1
                '''
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials']
                ]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login \
                        --username AWS \
                        --password-stdin $ECR_REPOSITORY
                    '''
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                sh '''
                    docker tag wanderlust-frontend:v1 \
                    $ECR_REPOSITORY/$FRONTEND_REPO:$IMAGE_TAG

                    docker push \
                    $ECR_REPOSITORY/$FRONTEND_REPO:$IMAGE_TAG

                    docker tag wanderlust-backend:v1 \
                    $ECR_REPOSITORY/$BACKEND_REPO:$IMAGE_TAG

                    docker push \
                    $ECR_REPOSITORY/$BACKEND_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Update Helm Values') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'github-creds',
                        usernameVariable: 'GITHUB_USERNAME',
                        passwordVariable: 'GITHUB_PASSWORD'
                    )
                ]) {

                    sh '''
                        rm -rf helm-argocd

                        git clone \
                        https://$GITHUB_USERNAME:$GITHUB_PASSWORD@github.com/gopi-ganesan/helm-argocd.git

                        cd helm-argocd

                        git checkout main

                        sed -i "s|tag:.*|tag: $IMAGE_TAG|g" Helm/new-chart/values.yaml

                        git config user.name "$GITHUB_USERNAME"
                        git config user.email "devops@example.com"

                        git add Helm/new-chart/values.yaml

                        git commit -m "Update image tag to $IMAGE_TAG" || true

                        git pull --rebase origin main

                        git push origin main
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }

        success {
            echo "Pipeline completed successfully."
        }

        failure {
            echo "Pipeline failed."
        }
    }
}