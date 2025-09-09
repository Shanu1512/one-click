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

        stage('Terraform Init & Plan') {
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
                            terraform init -reconfigure
                            terraform plan -out=tfplan
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
                            terraform apply -auto-approve tfplan
                            # Export the new bastion public IP
                            export BASTION_IP=$(terraform output -raw bastion_public_ip)
                            echo "BASTION_IP=${BASTION_IP}" > ../bastion_ip.env
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
                            # Load bastion IP from previous stage
                            source ../bastion_ip.env
                            export ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3
                            ansible-inventory -i mysql-infra-setup/inventory/inventory_aws_ec2.yml --list --extra-vars "bastion_ip=${BASTION_IP}"
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
                            # Load bastion IP
                            source ../bastion_ip.env
                            ansible-playbook -i mysql-infra-setup/inventory/inventory_aws_ec2.yml \
                                mysql-infra-setup/sql_playbook.yml \
                                -u ubuntu --private-key $SSH_KEY \
                                --extra-vars "bastion_ip=${BASTION_IP}"
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
