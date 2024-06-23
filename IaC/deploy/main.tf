#Provider
provider "aws" {
  region = "us-east-2"
}

#Criar Bucket
resource "aws_s3_bucket" "ml_bucket_flask" {
  bucket = "ml-<your-id>-bucket" 		#Coloque aqui o seu id de conta da AWS para gerar bucket unico

  tags = {
    Name        = "ML Bucket"
    Environment = "Lab4"
  }

  provisioner "local-exec" {			#Provisioner para rodar o script de upload dos scripts de Machine Learning para o bucket S3
    command = "aws s3 cp /iac/ml_app s3://ml-<your-id>-bucket --recursive"
  }

  provisioner "local-exec" {			#Provisioner para excluir o bucket quando encerrado a estrutura
    when    = destroy
    command = "aws s3 rm s3://ml-<your-id>-bucket --recursive"       
  }
}

#Criação de instância virtual que roda o script de ML
resource "aws_instance" "ml_ml_api" {

  ami = "ami-0a0d9cf81c479446a"  

  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

  vpc_security_group_ids = [aws_security_group.ml_api_sg.id]

  # Script de inicialização
  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y python3 python3-pip awscli
                sudo pip3 install flask joblib scikit-learn numpy scipy gunicorn
                sudo mkdir /ml_app
                sudo aws s3 sync s3://ml-<your-id-bucket /ml_app
                cd /ml_app
                nohup gunicorn -w 4 -b 0.0.0.0:5000 app:app &
              EOF


  tags = {
    Name = "FlaskApp"
  }
}

#Criação de Grupo de Segurança (Firewall) -> Serão abertas as portas 22 para conexão ssh, 80 para conexão http e 5000 para conexão gunicorn com o ip da internet
resource "aws_security_group" "ml_api_sg" {
  
  name        = "ml_api_sg"
  
  description = "Security Group for Flask App in EC2"

  ingress {
    description = "Inbound Rule 1"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Inbound Rule 2"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Inbound Rule 3"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound Rule"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Recurso de segurança interna que permite acesso da instancia EC2 ao bucket S3
resource "aws_iam_role" "ec2_s3_access_role" {
  
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "s3_access_policy" {
  
  name = "s3_access_policy"
  
  role = aws_iam_role.ec2_s3_access_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.ml_bucket_flask.arn}/*",
          "${aws_s3_bucket.ml_bucket_flask.arn}"
        ]
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_s3_access_role.name
}


