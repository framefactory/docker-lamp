#!/bin/bash
# restart server and follow all logs
docker-compose restart server
docker-compose logs -f
