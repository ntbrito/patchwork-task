output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "pub_subnet_id" {
  value = aws_subnet.public.*.id
}
