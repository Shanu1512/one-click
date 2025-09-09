pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        PATH = "/var/lib/jenkins/ansible-venv/bin:${env.PATH}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Shanu1512/one-click.git'
            }
        }

        stage('Terraform Init & Reconfigure') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            set -e
                            echo "🔹 Initializing Terraform with -reconfigure..."
                            terraform init -reconfigure
                        '''
                    }
                }
            }
        }

        stage('Terraform Plan (Safe Check)') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            set -e
                            echo "🔹 Running Terraform Plan..."
                            terraform plan -out=tfplan -input=false
                        '''
                    }
                }
            }
        }

        stage('Approval for Apply') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: '✅ Approve Terraform Apply?'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            set -e
                            echo "🔹 Applying Terraform Plan..."
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('Check Dynamic Inventory') {
            steps {
                dir('ansible') {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'ssh_key', keyFileVariable: 'SSH_KEY'),
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'aws-credentials-id',
                         accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                         secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']
                    ]) {
                        sh '''
                            set -e
                            export ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3
                            ansible-inventory -i mysql-infra-setup/inventory/inventory_aws_ec2.yml --list
                        '''
                    }
                }
            }
        }

        stage('Configure MySQL with Ansible') {
            steps {
                dir('ansible') {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'ssh_key', keyFileVariable: 'SSH_KEY'),
                        [$class: 'AmazonWebServicesCredentialsBinding',
                         credentialsId: 'aws-credentials-id',
                         accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                         secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']
                    ]) {
                        sh '''
                            set -e
                            ansible-playbook -i mysql-infra-setup/inventory/inventory_aws_ec2.yml \
                                mysql-infra-setup/sql_playbook.yml \
                                -u ubuntu --private-key $SSH_KEY
                        '''
                    }
                }
            }
        }

        stage('Approval for Destroy') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: '⚠️ Approve Terraform Destroy?'
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            set -e
                            echo "🔹 Destroying Terraform Infrastructure..."
                            terraform destroy -auto-approve
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            echo '🚀 Pipeline finished.'
        }
    }
}
