output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_ids" {
  value = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "private_subnet_1_id" {
  value = aws_subnet.private_1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private_2.id
}

output "private_subnet_1_az" {
  value = aws_subnet.private_1.availability_zone
}


output "redshift_sg_id" {
  value = aws_security_group.redshift_sg.id
}

output "glue_sg_id" {
  value = aws_security_group.glue_sg.id
}
