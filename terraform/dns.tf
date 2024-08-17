# Add a record to the domain
# resource "cloudflare_record" "fabric" {
#   for_each = local.dns_records
#   zone_id  = "98472f9ebecee15d45c588b9526b0f55"
#   name     = each.key
#   content  = each.value.value
#   type     = each.value.type

# }

# resource "cloudflare_record" "fabric_node" {
#   for_each = var.fabric
#   zone_id  = "98472f9ebecee15d45c588b9526b0f55"
#   name     = replace("${each.key}", "_", ".")
#   content  = aws_instance.fabric["${each.key}"].private_ip
#   type     = "A"
# }

resource "cloudflare_record" "fabric" {
  for_each = { for record in local.dns_records : "${record.name}" => record }
  zone_id  = "98472f9ebecee15d45c588b9526b0f55"
  name     = each.value.name
  content  = each.value.content
  type     = each.value.type
}



