locals {

  dns_records = {
    # vault = {
    #   value = aws_instance.vault.private_ip
    #   type  = "A"
    # }
    "_acme-challenge.vault" = {
      value = "j5tAD6jsXadjSCOZuA5Wtq8Dc5nH8LkDeQoUUxyFL1g"
      type  = "TXT"
    }
  }
}