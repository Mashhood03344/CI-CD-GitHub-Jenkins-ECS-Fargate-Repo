// Declarative pipelines must be enclosed with a "pipeline" directive.
pipeline {
    // This line is required for declarative pipelines. Just keep it here.
    agent any

    // This section contains environment variables which are available for use in the
    // pipeline's stages.
     environment {
        region = "us-east-1"
        docker_repo_uri = "905418229977.dkr.ecr.us-east-1.amazonaws.com/sample-app"
        cluster = "default"
        exec_role_arn = "arn:aws:iam::905418229977:role/ecsTaskExecutionRole"
        service_name = "sample-app-service"
    }

    stages {
        stage('Build') {
            steps {
                // Get SHA1 of current commit
                script {
                    commit_id = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                }
                // Build the Docker image
                sh "docker build -t ${docker_repo_uri}:${commit_id} ."
                
                // Get Docker login credentials for ECR and log in
                sh "aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${docker_repo_uri}"
                
                // Push Docker image
                sh "docker push ${docker_repo_uri}:${commit_id}"
                
                // Clean up the local Docker image
                sh "docker rmi -f ${docker_repo_uri}:${commit_id}"
            }
        }

        stage('Deploy') {
            steps {
                // Override image field in taskdef.json
                sh "sed -i 's|{{image}}|${docker_repo_uri}:${commit_id}|' taskdef.json"
                
                // Register a new task definition revision
                script {
                    task_def_arn = sh(script: "aws ecs register-task-definition --execution-role-arn ${exec_role_arn} --cli-input-json file://taskdef.json --region ${region} --query 'taskDefinition.taskDefinitionArn' --output text", returnStdout: true).trim()
                }
                
                // Update the ECS service with the new task definition revision
                sh "aws ecs update-service --cluster ${cluster} --service ${service_name} --task-definition ${task_def_arn} --region ${region}"
            }
        }
    }
}