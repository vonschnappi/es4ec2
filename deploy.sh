function print_stage() {
    echo "*******************************"
    echo $1
    echo "*******************************"
}

cd lambda
print_stage "installing pip packages..."
python3 -m pip install --system -r requirements.txt -t $(pwd)

print_stage "zipping lambda function and packages..."
zip -r lambda_function.zip *


cd ../terraform
print_stage "initialzing terraform..." 
terraform init

print_stage "applying terraform..." 
terraform apply -auto-approve

