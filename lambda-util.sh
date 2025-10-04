terraform destroy -target=aws_lambda_function.$1 -auto-approve
cd lambdas
rm $1.zip
zip -r $1.zip $1.py
cd ..
terraform apply -auto-approve