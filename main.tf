provider "aws" {
  region = "eu-central-1"
}

module "efs" {
  source     = "./modules/efs"
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
}

module "alb" {
  source           = "./modules/alb"
  vpc_id           = var.vpc_id
  subnets          = var.subnet_ids
  ecs_service_name = var.ecs_service_name
}

module "ecs" {
  source               = "./modules/ecs"
  vpc_id               = var.vpc_id
  subnet_ids           = var.subnet_ids
  security_group_id    = var.security_group_id
  ecs_cluster_id       = var.ecs_cluster_id
  efs_id               = module.efs.efs_id

  # Ось ці аргументи були пропущені, додаємо їх:
  efs_sg_id            = module.efs.efs_sg_id
  alb_sg_id            = module.alb.alb_sg_id

  alb_target_group_arn = module.alb.target_group_arn
}