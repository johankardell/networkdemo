using 'main.bicep'

param location = 'swedencentral'

param tags = {
  environment: 'demo'
  project: 'avnm-demo'
}

param sshPublicKey = readEnvironmentVariable('SSH_PUBLIC_KEY')
