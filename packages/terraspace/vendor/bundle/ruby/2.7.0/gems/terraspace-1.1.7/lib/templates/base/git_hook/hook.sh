#!/bin/bash -ex
echo "Running: terraspace build"
<%= terraspace_build_commands %>
git add .terraspace-cache
git commit -m 'update .terraspace-cache' || true
