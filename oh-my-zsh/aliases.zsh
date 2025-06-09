alias tgv='terragrunt validate --terragrunt-source-update' 
alias tga='terragrunt apply'
alias tgd='terragrunt destroy'
alias tgua='terragrunt apply --terragrunt-source-update'

alias av-brushy-dev='unset AWS_VAULT && aws-vault exec gov-brushy-dev' #aws-vault brushy dev
alias av-usodi2e='unset AWS_VAULT && aws-vault exec usodi2e' #aws-vault US only DI2E -> d2 -> dd
alias av-personal='unset AWS_VAULT && aws-vault exec personal' #aws-vault personal
alias av-delos-gov-security='unset AWS_VAULT && aws-vault exec delos-gov-security' #aws-vault DELOS security
alias av-delos-gov-shared='unset AWS_VAULT && aws-vault exec delos-gov-shared' # aws-vault DELOS shared

alias tfip='terraform init && terraform plan'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfd='terraform destroy'
alias fmt='terraform fmt -recursive'

alias rotate='aws-vault rotate delos-gov-security'

# pass in profile and instance ID
function ssm(){
    aws-vault exec delos-gov-"$1" -- aws ssm start-session --target "$2"
}

function login(){
    echo "Adding link for delos-gov-$1 to clipboard"
    aws-vault login -s delos-gov-"$1" | pbcopy
} 

function branch(){
  # Get the current branch name
  branch_name=$(git rev-parse --abbrev-ref HEAD)

  # Copy the branch name to the clipboard
  echo -n "$branch_name" | pbcopy

  # Print the branch name to the terminal (optional)
  echo "Current branch: $branch_name"
}
