#!/bin/bash

# Script para testar a API no EasyPanel
# Execute: bash test-api.sh https://seu-link.easypanel.host

if [ $# -eq 0 ]; then
    echo "❌ Erro: Forneça a URL da sua aplicação no EasyPanel"
    echo "📋 Uso: bash test-api.sh https://seu-link.easypanel.host"
    exit 1
fi

API_URL=$1

echo "🔍 Testando API Casa da Ana no EasyPanel..."
echo "🌐 URL: $API_URL"
echo ""

# Remover barra no final se existir
API_URL=${API_URL%/}

echo "1️⃣ Testando Health Check..."
health_response=$(curl -s "$API_URL/health")
echo "✅ Resposta: $health_response"
echo ""

echo "2️⃣ Verificando Configurações..."
config_response=$(curl -s "$API_URL/config")
echo "⚙️ Resposta: $config_response"
echo ""

echo "3️⃣ Testando Geração de Contrato (TESTE)..."
test_contract=$(curl -s -X POST "$API_URL/generate-contract" \
  -H "Content-Type: application/json" \
  -d '{
    "nome_do_locatario": "João Silva TESTE",
    "estado_civil": "Solteiro",
    "nacionalidade": "Brasileira",
    "profissao": "Engenheiro",
    "numero_do_rg": "12.345.678-9",
    "numero_do_cpf": "123.456.789-00",
    "telefone_celular": "(61) 99999-9999",
    "email": "joao.teste@email.com",
    "endereco": "Rua das Flores, 123, Brasília-DF"
  }')

echo "📄 Resposta do contrato: $test_contract"
echo ""

# Verificar se o health check funcionou
if echo "$health_response" | grep -q "healthy"; then
    echo "✅ Health Check: OK"
else
    echo "❌ Health Check: FALHOU"
fi

# Verificar configurações
if echo "$config_response" | grep -q '"template_exists":true'; then
    echo "✅ Template: OK"
else
    echo "❌ Template: FALHOU - Arquivo CONTRATO Casa da Ana.docx não encontrado"
fi

if echo "$config_response" | grep -q '"api_key_configured":true'; then
    echo "✅ API Key: OK"
else
    echo "❌ API Key: FALHOU - Variável EVOLUTION_API_KEY não configurada"
fi

# Verificar teste de contrato
if echo "$test_contract" | grep -q '"success":true'; then
    echo "✅ Geração de Contrato: OK"
    echo "🎉 API está funcionando perfeitamente!"
else
    echo "❌ Geração de Contrato: FALHOU"
    echo "🔍 Verifique os logs no EasyPanel para mais detalhes"
fi

echo ""
echo "📋 Resumo dos Testes:"
echo "🌐 URL testada: $API_URL"
echo "📖 Documentação: $API_URL/api-docs"
echo "❤️ Health Check: $API_URL/health"
echo "⚙️ Config Check: $API_URL/config" 