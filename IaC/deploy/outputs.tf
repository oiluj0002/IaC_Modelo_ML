#Output será um link DNS para acessar o modelo de Machine Learning via Web
output "instance_public_dns" {
  value = aws_instance.ml_ml_api.public_dns
}
