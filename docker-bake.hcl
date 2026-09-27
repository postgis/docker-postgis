variable "VERSION" {
  default = "18-3.6"
}

variable "VARIANT" {
  default = "default"
}

variable "REPO_NAME" {
  default = "postgis"
}

variable "IMAGE_NAME" {
  default = "postgis"
}

variable "LATEST_VERSION" {
  default = "18-3.6"
}

variable "PLATFORMS" {
  default = "linux/amd64,linux/arm64"
}

variable "GHA_CACHE" {
  default = "false"
}

variable "CACHE_FROM_SCOPES" {
  default = "postgis-default"
}

variable "CACHE_TO_SCOPE" {
  default = "postgis-default"
}

target "image" {
  context = "."
  dockerfile = VARIANT == "alpine" ? "${VERSION}/alpine/Dockerfile" : "${VERSION}/Dockerfile"
  platforms = split(",", PLATFORMS)
  cache-from = GHA_CACHE == "true" ? [for scope in split(",", CACHE_FROM_SCOPES) : "type=gha,scope=${scope}"] : []
  cache-to = GHA_CACHE == "true" ? ["type=gha,mode=max,ignore-error=true,scope=${CACHE_TO_SCOPE}"] : []
  tags = concat(
    ["${REPO_NAME}/${IMAGE_NAME}:${VERSION}${VARIANT == "alpine" ? "-alpine" : ""}"],
    VERSION == LATEST_VERSION && VARIANT == "default" ? ["${REPO_NAME}/${IMAGE_NAME}:latest"] : []
  )
}

target "master-deps" {
  context = "."
  dockerfile = "${VERSION}/Dockerfile"
  target = "master-deps"
  platforms = split(",", PLATFORMS)
  cache-from = GHA_CACHE == "true" ? [for scope in split(",", CACHE_FROM_SCOPES) : "type=gha,scope=${scope}"] : []
  cache-to = GHA_CACHE == "true" ? ["type=gha,mode=max,ignore-error=true,scope=${CACHE_TO_SCOPE}"] : []
}

group "default" {
  targets = ["image"]
}
