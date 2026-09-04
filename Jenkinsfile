pipeline {
    agent any

    tools {
        maven 'Maven' 
    }

    environment {
        DB_USER = 'arun'
        DB_NAME = 'ecommjava'
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
                echo 'Checking and preparing MySQL database environments...'
                // Note: There is NO SPACE between -p and the password 'Arun@1234'
                sh "mysql -u root -p'Arun@1234' -e 'CREATE DATABASE IF NOT EXISTS ${DB_NAME};'"
                sh "mysql -u root -p'Arun@1234' -e \"GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;\""
                
                echo 'Seeding initial database schemas...'
                script {
                    if (fileExists('basedata.sql')) {
                        sh "mysql -u root -p'Arun@1234' ${DB_NAME} < basedata.sql"
                    }
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
                sh 'mvn package -DskipTests=true'
            }
            post {
                success {
                    // Archives your compiled war or jar file inside the build history dashboard
                    archiveArtifacts artifacts: '**/target/*.war, **/target/*.jar', fingerprint: true
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
