resource "aws_instance" "phishing_server" {
  ami           = "ami-abc12345"
  instance_type = "t2.micro"
  key_name      = "mykey"

  tags = {
    Name = "PhishingServer"
  }
}


