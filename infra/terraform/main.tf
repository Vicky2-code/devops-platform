# Root module wiring: compose all submodules and expose outputs.

module "networking" {
  source      = "./modules/networking"
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}

module "database" {
  source           = "./modules/database"
  environment      = var.environment
  vpc_id           = module.networking.vpc_id
  vpc_cidr         = var.vpc_cidr
  private_subnets  = module.networking.private_subnets
  db_name          = var.db_name
  db_username      = var.db_username
  db_password      = var.db_password
  db_instance_class = var.db_instance_class
}

module "compute" {
  source         = "./modules/compute"
  environment    = var.environment
  region         = var.region
  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnets
  backend_image  = var.backend_image
  frontend_image = var.frontend_image
  db_endpoint    = module.database.endpoint
  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = var.db_password
}