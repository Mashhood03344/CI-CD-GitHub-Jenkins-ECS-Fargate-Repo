pipeline {
    agent any

    environment {
        region = "us-east-1"
        docker_repo_uri = "905418229977.dkr.ecr.us-east-1.amazonaws.com/simple-html-app"
        cluster = "simple-html-cluster"
        ecs_service_name = "simple-html-service"
        recipient = "mashhoodhamid786@gmail.com"  // Replace with the real admin email
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh "aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${docker_repo_uri}"
            }
        }

        stage('Pre-Build') {
            steps {
                script {
                    sh 'docker build -t sample-app .'
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    sh "docker tag sample-app:latest ${docker_repo_uri}:latest"
                    sh "docker push ${docker_repo_uri}:latest"
                }
            }
        }

        stage('Approval') {
            steps {
                script {
                    // Send an email notification
                    emailext(
                        subject: "Approval Needed for Jenkins Build",
                        body: "The build is ready for approval. Details:\n\n" +
                              "Build URL: ${env.BUILD_URL}\n" +
                              "Please approve or reject the build.",
                        to: "${recipient}"
                    )

                    // Wait for manual approval
                    input message: "Approve deployment to ECS?", submitter: 'admin'
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                script {
                    sh "aws ecs update-service --cluster ${cluster} --service ${ecs_service_name} --force-new-deployment"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
        success {
            emailext(
                subject: "Build Success",
                body: "The build was successful.\n\nBuild URL: ${env.BUILD_URL}",
                to: "${recipient}"
            )
        }
        failure {
            emailext(
                subject: "Build Failed",
                body: "The build failed.\n\nBuild URL: ${env.BUILD_URL}",
                to: "${recipient}"
            )
        }
    }
}

