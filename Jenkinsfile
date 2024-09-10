pipeline {
    agent any

    environment {
        region = "us-east-1"
        docker_repo_uri = "905418229977.dkr.ecr.us-east-1.amazonaws.com/simple-html-app"
        cluster = "DevCluster"
        ecs_service_name = "ECS-Service"
    }

    stages {
        stage('Install Dependencies') {
            steps {
                // ECR login
                sh "aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${docker_repo_uri}"
            }
        }

        stage('Pre-Build') {
            steps {
                script {
                    // Build Docker image
                    sh 'docker build -t sample-app .'
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    // Get the current Git commit ID
                    commit_id = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    
                    // Tag and push the Docker image
                    sh "docker tag sample-app:latest ${docker_repo_uri}:${commit_id}"
                    sh "docker push ${docker_repo_uri}:${commit_id}"
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                script {
                    // Update ECS service to force a new deployment
                    sh "aws ecs update-service --cluster ${cluster} --service ${ecs_service_name} --force-new-deployment"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
    }
}

