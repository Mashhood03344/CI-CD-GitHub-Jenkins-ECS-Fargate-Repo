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
                    // Fetch Git commit hash
                    def commitHash = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()

                    // Send an email notification with additional build details
                    emailext(
                        subject: "Approval Needed for Jenkins Build #${env.BUILD_NUMBER}",
                        body: """The build is ready for approval.
                        \nBuild Details:
                        \nBuild Number: ${env.BUILD_NUMBER}
                        \nBuild URL: ${env.BUILD_URL}
                        \nCommit Hash: ${commitHash}
                        \nBranch: ${env.GIT_BRANCH}
                        \nDuration: ${currentBuild.durationString}
                        \nConsole Output: ${env.BUILD_URL}console
                        \nPlease approve or reject the build.""",
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
                subject: "Build Success #${env.BUILD_NUMBER}",
                body: """The build was successful.
                \nBuild Details:
                \nBuild Number: ${env.BUILD_NUMBER}
                \nBuild URL: ${env.BUILD_URL}
                \nDuration: ${currentBuild.durationString}
                \nCommit Hash: ${sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()}
                \nConsole Output: ${env.BUILD_URL}console""",
                to: "${recipient}"
            )
        }
        failure {
            emailext(
                subject: "Build Failed #${env.BUILD_NUMBER}",
                body: """The build failed.
                \nBuild Details:
                \nBuild Number: ${env.BUILD_NUMBER}
                \nBuild URL: ${env.BUILD_URL}
                \nDuration: ${currentBuild.durationString}
                \nCommit Hash: ${sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()}
                \nConsole Output: ${env.BUILD_URL}console""",
                to: "${recipient}"
            )
        }
    }
}

