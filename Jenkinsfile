pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        PATH = "/var/lib/jenkins/ansible-venv/bin:${env.PATH}"
    }

    stages {

        // -----------------------------
        // Initial Destroy (optional cleanup)
        // -----------------------------
        stage('Approval for Initial Destroy') {
            steps {
                script {
                    try {
                        timeout(time: 30, unit: 'MINUTES') {
                            input message: '⚠️ Approve Terraform Initial Destroy (cleanup existing infra)?'
                        }
                        dir('terraform') {
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
                    } catch (err) {
                        echo "⏭ Initial destroy aborted. Moving to next stage."
                    }
                }
            }
        }

        // -----------------------------
        // Checkout Code
        // -----------------------------
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Shanu1512/one-click.git'
            }
        }

        // -----------------------------
        // Terraform Init & Validate
        // -----------------------------
        stage('Terraform Init & Validate') {
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
                            terraform init
                            terraform validate
                        '''
                    }
                }
            }
        }

        // -----------------------------
        // Terraform Plan
        // -----------------------------
        stage('Terraform Plan') {
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
                            terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }

        // -----------------------------
        // Approval for Apply
        // -----------------------------
        stage('Approval for Apply') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: '✅ Approve Terraform Apply?'
                }
            }
        }

        // -----------------------------
        // Terraform Apply
        // -----------------------------
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
                            # Capture bastion public IP for Ansible
                            echo "BASTION_IP=$(terraform output -raw bastion_public_ip)" > ../bastion_ip.env
                        '''
                    }
                }
            }
        }

        // -----------------------------
        // Configure MySQL with Ansible
        // -----------------------------
        stage('Configure MySQL with Ansible') {
            steps {
                dir('ansible') {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'ssh_key', keyFileVariable: 'SSH_KEY'),
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']
                    ]) {
                        sh '''
                            set -e
                            BASTION_IP=$(cut -d= -f2 ../bastion_ip.env)
                            echo "Waiting for SSH on bastion $BASTION_IP..."
                            until nc -zv $BASTION_IP 22 >/dev/null 2>&1; do
                                echo "SSH not ready, waiting 60s..."
                                sleep 60
                            done
                            echo "SSH ready, running Ansible..."

                            export ANSIBLE_HOST_KEY_CHECKING=False
                            export ANSIBLE_SSH_COMMON_ARGS="-o ProxyCommand='ssh -i $SSH_KEY -W %h:%p ubuntu@$BASTION_IP' -o StrictHostKeyChecking=no"

                            ansible-playbook -i mysql-infra-setup/inventory/inventory_aws_ec2.yml \
                                mysql-infra-setup/sql_playbook.yml \
                                --extra-vars "bastion_ip=${BASTION_IP}"
                        '''
                    }
                }
            }
        }

        // -----------------------------
        // Final Destroy (cleanup)
        // -----------------------------
        stage('Approval for Final Destroy') {
            steps {
                script {
                    try {
                        timeout(time: 30, unit: 'MINUTES') {
                            input message: '⚠️ Approve Final Terraform Destroy?'
                        }
                        dir('terraform') {
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
                    } catch (err) {
                        echo "⏭ Final destroy aborted. Moving to next stage."
                    }
                }
            }
        }

        stage('Post-Cleanup Stage') {
            steps {
                echo "✅ Pipeline finished. Cleanup stages completed or skipped."
            }
        }
    }

    post {
        always {
            echo '🚀 Pipeline finished.'
        }
    }
}
