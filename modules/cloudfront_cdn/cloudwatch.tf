resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = local.aws_resource_safe_domain_name

  dashboard_body = jsonencode({
    "start": "-PT720H",
    "widgets": [
        {
            "height": 6,
            "width": 9,
            "y": 0,
            "x": 0,
            "type": "log",
            "properties": {
                "query": "SOURCE '${module.cloudfront-logs.logs_cloudwatch_log_group.name}' | ${aws_cloudwatch_query_definition.request_status_codes.query_string}",
                "region": "eu-west-2",
                "stacked": false,
                "view": "pie",
                "title": "Request Status Codes"
            }
        },
        {
            "height": 6,
            "width": 9,
            "y": 0,
            "x": 9,
            "type": "log",
            "properties": {
                "query": "SOURCE '${module.cloudfront-logs.logs_cloudwatch_log_group.name}' | ${aws_cloudwatch_query_definition.requests_by_edge_location.query_string}",
                "region": "eu-west-2",
                "stacked": false,
                "view": "pie",
                "title": "Requests by Edge Location"
            }
        },
        {
            "height": 9,
            "width": 18,
            "y": 6,
            "x": 0,
            "type": "log",
            "properties": {
                "query": "SOURCE '${module.cloudfront-logs.logs_cloudwatch_log_group.name}' | ${aws_cloudwatch_query_definition.top_requested_files.query_string}",
                "region": "eu-west-2",
                "stacked": false,
                "view": "bar",
                "title": "Top 10 File Requests"
            }
        },
        {
            "height": 15,
            "width": 6,
            "y": 0,
            "x": 18,
            "type": "log",
            "properties": {
                "query": "SOURCE '${module.cloudfront-logs.logs_cloudwatch_log_group.name}' | ${aws_cloudwatch_query_definition.request_count_by_ip.query_string}",
                "region": "eu-west-2",
                "stacked": false,
                "view": "table",
                "title": "Request count by IP"
            }
        }
    ]
  })
}

resource "aws_cloudwatch_query_definition" "request_status_codes" {
  name = "${local.aws_resource_safe_domain_name}/request-status-codes"

  log_group_names = [
    module.cloudfront-logs.logs_cloudwatch_log_group.name
  ]

  query_string = <<EOF
fields status
| stats count (status) as status_codes by status
| sort status asc
EOF
}

resource "aws_cloudwatch_query_definition" "top_requested_files" {
  name = "${local.aws_resource_safe_domain_name}/top-requested-files"

  log_group_names = [
    module.cloudfront-logs.logs_cloudwatch_log_group.name
  ]

  query_string = <<EOF
parse `uri-stem` /(?<filepath>([^\/]+\.(jar|zip|etc)$))/
| filter filepath like ''
| stats count (filepath) as file_count by filepath
| sort file_count desc
| limit 10
EOF
}

resource "aws_cloudwatch_query_definition" "request_count_by_ip" {
  name = "${local.aws_resource_safe_domain_name}/request-count-by-ip"

  log_group_names = [
    module.cloudfront-logs.logs_cloudwatch_log_group.name
  ]

  query_string = <<EOF
fields ip
| stats count (ip) as request_count by ip
| sort request_count desc
EOF
}

resource "aws_cloudwatch_query_definition" "requests_by_edge_location" {
  name = "${local.aws_resource_safe_domain_name}/requests-by-edge-location"

  log_group_names = [
    module.cloudfront-logs.logs_cloudwatch_log_group.name
  ]

  query_string = <<EOF
fields `x-edge-location` as edge_location
| stats count (edge_location) as location by edge_location
| sort location desc
EOF
}
