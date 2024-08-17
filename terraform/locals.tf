locals {

  # dns_records = {
  #   # vault = {
  #   #   value = aws_instance.vault.private_ip
  #   #   type  = "A"
  #   # }
  #   "_acme-challenge.vault" = {
  #     value = "j5tAD6jsXadjSCOZuA5Wtq8Dc5nH8LkDeQoUUxyFL1g"
  #     type  = "TXT"
  #   }
  # }

  dns_records = flatten([
    for node, config in var.fabric : [
      for dns_name in config.dns : {
        name    = dns_name
        content = aws_instance.fabric["${node}"].private_ip  # Replace with the correct IP or value for each DNS entry
        type    = "A"          # Replace with the correct DNS record type (A, CNAME, etc.)
      }
    ]
  ])

}