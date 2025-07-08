#!/bin/bash

# Script para configurar Git e subir o projeto para GitHub
# Execute: bash git-setup.sh

echo "🚀 Configurando Git e subindo projeto para GitHub..."

# Inicializar repositório Git
git init

# Adicionar .gitignore se não existir
if [ ! -f .gitignore ]; then
    echo "📝 Criando .gitignore..."
    cat > .gitignore << EOF
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Environment
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Temporary files
*.tmp
temp/

# Docker
.dockerignore

# Lock files
.~lock.*
EOF
fi

# Adicionar todos os arquivos
git add .

# Primeiro commit
git commit -m "🎉 Initial commit: Casa da Ana Contracts API v2.0

✨ Features:
- REST API para geração de contratos
- Integração com Evolution API para WhatsApp
- Containerização com Docker
- Deploy pronto para EasyPanel
- Health checks e monitoramento
- Documentação completa

📦 Stack:
- Python 3.11
- Flask
- python-docx
- Docker & Docker Compose
- Gunicorn"

echo "✅ Repositório local configurado!"
echo ""
echo "🔗 Agora execute os comandos abaixo substituindo 'SEU_USUARIO' pelo seu usuário do GitHub:"
echo ""
echo "git branch -M main"
echo "git remote add origin https://github.com/SEU_USUARIO/casa-da-ana-contracts-api.git"
echo "git push -u origin main"
echo ""
echo "📋 Ou se preferir SSH:"
echo "git remote add origin git@github.com:SEU_USUARIO/casa-da-ana-contracts-api.git"
echo "git push -u origin main" 