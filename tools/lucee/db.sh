#!/bin/bash

# SSH tunnel for Client A
echo "🔌 Starting SSH tunnel for Client A database..."

ssh -i ~/.ssh/id_rsa -N -L [DB-CONNECTION-STRING] [DB-USER]@[DB-HOST]

# -N = no command, just tunnel
# -L = local port : remote host : remote port