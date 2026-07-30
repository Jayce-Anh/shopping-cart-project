[ 
  {
    "name": "${env}-${project}-${container_name}",
    "image": "${container_image}",   
    "cpu": ${cpu},
    "memory": ${memory},
    "essential": true,
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/${env}-${project}-${container_name}-log-group",
          "awslogs-region": "${region}",
          "awslogs-stream-prefix": "ecs",
          "awslogs-datetime-format": "%Y-%m-%d %H:%M:%S%L"
        }
    },
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${host_port},
        "protocol": "tcp"
      }
    ],
    "linuxParameters": {
        "initProcessEnabled": true
    },
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "curl -f http://localhost:${container_port}${health_check_path} || exit 1"
      ],
      "interval": 30,         
      "timeout": 5,           
      "retries": 3,           
      "startPeriod": 60      
    }      
  }
]