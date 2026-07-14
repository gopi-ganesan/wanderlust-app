pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID   = "562404438689"
        ECR_REPOSITORY   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        FRONTEND_REPO = 'wanderlust-frontend'
        BACKEND_REPO = 'wanderlust-backend'
        IMAGE_TAG = 'v1'
        HELM_CHART_PATH  = "./helm-k8s"
    }

    stages {

        stage('Git Clone') {
            steps {
                git branch: 'main',
                    url: 'YOUR_GITHUB_REPO_URL',
                    credentialsId: 'github-credentials'
            }
        }

        stage('Sonar Scan') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'

                    withSonarQubeEnv('sonarqube') {
                        withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {

                            sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=devops-project-o2 \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=http://localhost:9000 \
                            -Dsonar.login=${SONAR_TOKEN}
                            """
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    try {
                        timeout(time: 1, unit: 'HOURS') {
                            waitForQualityGate abortPipeline: true
                        }
                    } catch (err) {
                        echo "Skipping Quality Gate due to timeout."
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                dir('devops-project-o2') {
                    sh 'docker build -t wanderlust-frontend:v1 ./frontend'
                    sh 'docker build -t wanderlust-backend:v1 ./backend'
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {

                    sh """
                    trivy image \
                    --severity HIGH,CRITICAL \
                    --format table \
                    --output frontend-trivy-report.txt \
                    --no-progress \
                    frontend:v1
                    """

                    sh """
                    trivy image \
                    --severity HIGH,CRITICAL \
                    --format table \
                    --output backend-trivy-report.txt \
                    --no-progress \
                    backend:v1
                    """

                    archiveArtifacts artifacts: '*trivy-report.txt', fingerprint: true

                    sh """
                    trivy image \
                    --severity HIGH,CRITICAL \
                    --exit-code 1 \
                    --no-progress \
                    frontend:v1
                    """

                    sh """
                    trivy image \
                    --severity HIGH,CRITICAL \
                    --exit-code 1 \
                    --no-progress \
                    backend:v1
                    """
                }
            }
        }
        stage('Login to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh """
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REPOSITORY}
                    """
                }
            }
        }
        stage('Push Images to ECR') {
            steps {
                sh """
                docker tag  book-app${ECR_REPOSITORY}/${BACKEND_REPO}:${IMAGE_TAG}
                docker push ${ECR_REPOSITORY}/${BACKEND_REPO}:${IMAGE_TAG}

                docker tag  book-app${ECR_REPOSITORY}/${FRONTEND_REPO}:${IMAGE_TAG}
                docker push ${ECR_REPOSITORY}/${FRONTEND_REPO}:${IMAGE_TAG}
                """
            }
        }
        stage('Update Helm Values') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'github-creds',
                    usernameVariable: 'GITHUB_USERNAME',
                    passwordVariable: 'GITHUB_PASSWORD'
                    )]) {
                    sh """
                        # git clone \
                        #https://$GITHUB_USERNAME:$GITHUB_PASSWORD@github.com/gopi-ganesan/argocd-starbucks.git \
                        # argocd-starbucks
                        cd argocd-starbucks
                        git remote set-url origin \
                        https://\$GITHUB_USERNAME:\$GITHUB_PASSWORD@github.com/gopi-ganesan/argocd-starbucks.git
                        git fetch origin
                        git reset --hard origin/main
                        sed -i "s|tag:.*|tag: ${IMAGE_TAG}|g" Helm/my-chart/values.yaml
                        grep "tag:" Helm/my-chart/values.yaml
                        git config user.name "\$GITHUB_USERNAME"
                        git config user.email "devops@example.com"
                        git add Helm/my-chart/values.yaml
                        git commit -m "ci: update image tag to ${IMAGE_TAG} [skip ci]" || \
                        echo "Nothing to commit"
                        git pull --rebase origin main
                        git push origin main
                    """
                }
            }
        }
    }
}