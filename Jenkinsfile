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

        stage('Terraform Init & Validate') {
            steps {
                dir('Terraform-MySQL-Deploy/terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            set -e
                            terraform init
                            terraform validate
                        '''
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('Terraform-MySQL-Deploy/terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            set -e
                            terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('Approval for Terraform Apply') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: '✅ Approve Terraform Apply?'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('Terraform-MySQL-Deploy/terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script {
                            def applyResult = sh(script: 'terraform apply -auto-approve tfplan', returnStatus: true)
                            // Capture bastion IP only if apply succeeded
                            if (applyResult == 0) {
                                sh 'echo "BASTION_IP=$(terraform output -raw bastion_public_ip)" > ../bastion_ip.env'
                            } else {
                                echo "Terraform apply aborted or failed. Proceeding to Ansible."
                            }
                        }
                    }
                }
            }
        }

        stage('Configure MySQL with Ansible') {
            steps {
                dir('Terraform-MySQL-Deploy/ansible') {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'ssh_key', keyFileVariable: 'SSH_KEY')
                    ]) {
                        sh '''
                            set -e
                            BASTION_IP=$(cut -d= -f2 ../bastion_ip.env || echo "3.86.83.184")
                            echo "Waiting for SSH on bastion $BASTION_IP..."
                            until nc -zv $BASTION_IP 22 >/dev/null 2>&1; do
                                echo "SSH not ready, waiting 15s..."
                                sleep 15
                            done
                            echo "SSH ready, running Ansible..."

                            export ANSIBLE_HOST_KEY_CHECKING=False
                            export ANSIBLE_SSH_COMMON_ARGS="-o ProxyCommand='ssh -i $SSH_KEY -W %h:%p ubuntu@$BASTION_IP' -o StrictHostKeyChecking=no"

                            ansible-playbook -i mysql-infra-setup/inventory/inventory_aws_ec2.yml \
                                             mysql-infra-setup/sql_playbook.yml \
                                             --extra-vars "bastion_ip=${BASTION_IP}" \
                                             -u ubuntu \
                                             --private-key $SSH_KEY
                        '''
                    }
                }
            }
        }

        stage('Approval for Terraform Destroy') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: '⚠️ Approve Final Terraform Destroy?'
                }
            }
        }

        stage('Terraform Destroy (Final Cleanup)') {
            steps {
                dir('Terraform-MySQL-Deploy/terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials-id',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            set -e
                            terraform destroy -auto-approve || echo "Nothing to destroy"
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
