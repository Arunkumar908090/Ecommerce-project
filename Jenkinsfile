pipeline {
    agent any

    tools {
        maven 'Maven' 
    }

    environment {
        DB_USER = 'arun'
        DB_NAME = 'ecommjava'
        DOCKER_CREDENTIALS = credentials('docker_hub')
        AWS_REGION       = 'eu-west-2'
        EKS_CLUSTER_NAME = 'sample-project-eks'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Pull source tracking configurations directly from the repository hook
                checkout scm
            }
        }

        stage('Database Initialization') {
            steps {
                echo 'Dropping and recreating clean database schemas...'
                // 1. Drop the database if it exists to clean out previous test runs
                sh "mysql -u root -p'Arun@1234' -e 'DROP DATABASE IF EXISTS ${DB_NAME};'"
                
                // 2. Re-create the clean blank database
                sh "mysql -u root -p'Arun@1234' -e 'CREATE DATABASE ${DB_NAME};'"
                
                // 3. Re-verify permissions for user 'arun'
                sh "mysql -u root -p'Arun@1234' -e \"GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;\""
                
                echo 'Seeding fresh base data configurations...'
                script {
                    if (fileExists('basedata.sql')) {
                        // 4. Import seed records securely into the freshly cleaned space
                        sh "mysql -u root -p'Arun@1234' ${DB_NAME} < basedata.sql"
                    }
                }
            }
        }



        stage('Maven Clean & Compile') {
            steps {
                echo 'Cleaning workspace and compiling source classes...'
                sh 'mvn clean compile'
            }
        }

        stage('Execute Unit Tests') {
            steps {
                echo 'Running project test automation suite...'
                // Executes tests using the newly fixed local database parameters
                sh 'mvn test'
            }
            post {
                always {
                    // Automatically parses target/surefire-reports to render visual test UI inside Jenkins
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package Application') {
            steps {
                echo 'Packaging application artifact into executable format...'
                // Bundles classes into target executable packages, skipping tests to save time
                sh 'mvn clean package -DskipTests=true'
            }
            post {
                success {
                    // Archives your compiled war or jar file inside the build history dashboard
                    archiveArtifacts artifacts: '**/target/*.war, **/target/*.jar', fingerprint: true
                }
            }
        }

        stage('Docker') {
            steps {
                sh 'docker build -t arunkumar9080/ecomjava-project:latest .'
            }
        }
        stage('Docker Login & Push') {
            steps {
                // Ensure you choose "Username and password" or "Secret text" in Jenkins credentials
                withCredentials([usernamePassword(credentialsId: 'docker_hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PAT')]) {
                    sh '''
                        echo "$DOCKER_PAT" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push "$DOCKER_USER"/ecomjava-project:latest
                    '''
                }
            }
        }


        stage('Deploy to Amazon EKS') {
            steps {
                // Fixed AWS login using usernamePassword instead of AWS specific bindings
                withCredentials([usernamePassword(credentialsId: 'aws_credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        # Export variables so the 'aws' CLI tool can read them natively
                        export AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY
                        export AWS_DEFAULT_REGION="$AWS_REGION"
                        
                        # Generate your secure cluster config file
                        aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER_NAME
                        
                        # Apply your application manifest to your worker-nodes-arun
                        kubectl apply -f deployment.yaml
                    '''
                }
            }
        }
    }
    }

    post {
        success {
            echo '🎉 CI Build Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed during execution. Review the specific stage breakdown logs above.'
        }
    }
}
