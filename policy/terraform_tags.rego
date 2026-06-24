package main

required_tags := {"Team", "Source"}

deny contains msg if {
  rc := input.resource_changes[_]
  not is_delete(rc)
  not is_data_resource(rc)

  after := rc.change.after
  after != null

  tags := effective_tags(after)
  tags == null

  msg := sprintf("Resource %s does not define tags or tags_all", [rc.address])
}

deny contains msg if {
  rc := input.resource_changes[_]
  not is_delete(rc)
  not is_data_resource(rc)

  after := rc.change.after
  after != null

  tags := effective_tags(after)
  tags != null

  tag := required_tags[_]
  not tags[tag]

  msg := sprintf("Resource %s is missing required tag %q", [rc.address, tag])
}

effective_tags(after) := after.tags_all if {
  after.tags_all != null
}

effective_tags(after) := after.tags if {
  after.tags_all == null
  after.tags != null
}

is_delete(rc) if {
  rc.change.actions == ["delete"]
}

is_delete(rc) if {
  rc.change.actions == ["delete", "create"]
}

is_delete(rc) if {
  rc.change.actions == ["create", "delete"]
}

is_data_resource(rc) if {
  startswith(rc.mode, "data")
}
