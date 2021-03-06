job "binstore-storagelocker" {
    region = "global"
    type = "service"
    priority = 50
    all_at_once = true
    datacenters = ["us2", "eu1"]

    meta {
        foo = "bar"
    }

    constraint {
        attribute = "kernel.os"
        value = "windows"
    }

    update {
        stagger = "60s"
        max_parallel = 2
    }

    task "outside" {
        driver = "java"
        config {
           jar = "s3://my-cool-store/foo.jar"
        }
        meta {
           my-cool-key = "foobar"
        }
    }

    group "binsl" {
        count = 5
        task "binstore" {
            driver = "docker"
            config {
                image = "hashicorp/binstore"
            }
            resources {
                cpu = 500
                memory = 128

                network {
                    mbits = "100"
                    reserved_ports = [1,2,3]
                    dynamic_ports = ["this_is_aport", "this#is$not-a!port"]
                }
            }
        }

        task "storagelocker" {
            driver = "java"
            config {
                image = "hashicorp/storagelocker"
            }
            resources {
                cpu = 500
                memory = 128
            }
            constraint {
                attribute = "kernel.arch"
                value = "amd64"
            }
        }

        constraint {
            attribute = "kernel.os"
            value = "linux"
        }

        meta {
            elb_mode = "tcp"
            elb_interval = 10
            elb_checks = 3
        }
    }
}
